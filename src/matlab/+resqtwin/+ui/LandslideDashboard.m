classdef LandslideDashboard < handle
    %LANDSLIDEDASHBOARD Present the deterministic slope and road scenario.
    %   Playback reveals one observation per timer tick. It does not acquire
    %   sensor data or perform forecasting. SEEK pauses and selects the
    %   nearest whole simulation second; PLAY at the end starts a new replay.

    properties (SetAccess = private)
        Figure
        Observations
        CurrentTime = 0
        IsPlaying = false
    end

    properties (Access = private)
        Parameters
        SampleIndex = 1
        PlaybackTimer
        Closing = false
        RoadValue
        RoadDetail
        RoadPanel
        StateValue
        FactorValue
        PressureValue
        StatusMessage
        TimeValue
        Timeline
        PlayButton
        PauseButton
        PlaybackLabel
        SafetyHistory
        PressureHistory
        SafetyPoint
        PressurePoint
        SafetyCursor
        PressureCursor
    end

    methods
        function app = LandslideDashboard(options)
            arguments
                options.Visible (1, 1) string ...
                    {mustBeMember(options.Visible, ["on", "off"])} = "on"
            end

            [app.Observations, app.Parameters] = ...
                resqtwin.scenarios.basicLandslide();
            try
                app.buildFigure();
                app.PlaybackTimer = timer( ...
                    'Name', 'ResQTwin landslide playback', ...
                    'ExecutionMode', 'fixedSpacing', ...
                    'Period', 1, 'StartDelay', 1, ...
                    'TimerFcn', @(~, ~) app.advance(), ...
                    'ErrorFcn', @(~, ~) app.playbackError());
                app.render();
                app.Figure.Visible = options.Visible;
            catch exception
                delete(app);
                rethrow(exception);
            end
        end

        function play(app)
            if app.IsPlaying
                return
            end
            if app.SampleIndex == height(app.Observations)
                app.SampleIndex = 1;
            end
            app.IsPlaying = true;
            app.render();
            start(app.PlaybackTimer);
        end

        function pause(app)
            app.IsPlaying = false;
            stop(app.PlaybackTimer);
            app.render();
        end

        function reset(app)
            app.seek(0);
        end

        function seek(app, timeSeconds)
            %SEEK Pause and select the nearest whole second in [0, 60].
            app.selectTime(timeSeconds, true);
        end

        function delete(app)
            % Closing the figure, deleting the app, and failed construction
            % all release the timer and figure owned by this instance.
            if ~isvalid(app) || app.Closing
                return
            end
            app.Closing = true;
            if ~isempty(app.PlaybackTimer) && isvalid(app.PlaybackTimer)
                app.PlaybackTimer.TimerFcn = '';
                app.PlaybackTimer.ErrorFcn = '';
                stop(app.PlaybackTimer);
                delete(app.PlaybackTimer);
            end
            if ~isempty(app.Figure) && isgraphics(app.Figure)
                app.Figure.CloseRequestFcn = '';
                app.Figure.DeleteFcn = '';
                delete(app.Figure);
            end
        end
    end

    methods (Access = private)
        function buildFigure(app)
            ink = [0.09, 0.16, 0.25];
            muted = [0.35, 0.41, 0.49];
            background = [0.94, 0.96, 0.98];

            app.Figure = uifigure('Name', 'ResQTwin | Landslide dashboard', ...
                'Position', [100, 80, 1160, 820], 'Visible', 'off', ...
                'Color', background, 'Theme', 'light', ...
                'Tag', 'ResQTwinDashboard', ...
                'CloseRequestFcn', @(~, ~) delete(app), ...
                'DeleteFcn', @(~, ~) delete(app));

            layout = uigridlayout(app.Figure, [7, 1], ...
                'RowHeight', {64, 126, 42, '1x', 80, 36, 24}, ...
                'Padding', [24, 18, 24, 18], 'RowSpacing', 12, ...
                'BackgroundColor', background, 'Scrollable', 'on');

            header = uigridlayout(layout, [2, 2], ...
                'RowHeight', {34, 22}, 'ColumnWidth', {'1x', 235}, ...
                'Padding', [0, 0, 0, 0], 'RowSpacing', 4, ...
                'BackgroundColor', background);
            titleLabel = uilabel(header, 'Text', 'ResQTwin', ...
                'FontSize', 28, 'FontWeight', 'bold', 'FontColor', ink);
            titleLabel.Layout.Row = 1;
            titleLabel.Layout.Column = 1;
            subtitle = uilabel(header, ...
                'Text', 'Shallow landslide  /  One slope, one road', ...
                'FontSize', 14, 'FontColor', muted);
            subtitle.Layout.Row = 2;
            subtitle.Layout.Column = 1;
            badge = uilabel(header, 'Text', 'SIMULATED SCENARIO', ...
                'FontSize', 12, 'FontWeight', 'bold', ...
                'FontColor', [0.16, 0.34, 0.58], ...
                'HorizontalAlignment', 'right');
            badge.Layout.Row = [1, 2];
            badge.Layout.Column = 2;

            cards = uigridlayout(layout, [1, 4], ...
                'Padding', [0, 0, 0, 0], 'ColumnSpacing', 12, ...
                'BackgroundColor', background);
            [app.RoadValue, app.RoadDetail, app.RoadPanel] = ...
                app.createCard(cards, 'ROAD ACCESS', 'RoadStatus', 'Road segment 01');
            app.StateValue = app.createCard(cards, 'SLOPE STATE', ...
                'SlopeState', 'Illustrative warning thresholds');
            app.FactorValue = app.createCard(cards, 'FACTOR OF SAFETY', ...
                'FactorOfSafety', 'Dimensionless  /  Closure below 1.0');
            app.PressureValue = app.createCard(cards, 'PORE-WATER PRESSURE', ...
                'PorePressure', 'Emulated observation');

            app.StatusMessage = uilabel(layout, 'Text', '', ...
                'FontSize', 15, 'FontWeight', 'bold', ...
                'FontColor', ink, 'Tag', 'StatusMessage');

            plots = uigridlayout(layout, [1, 2], ...
                'Padding', [0, 0, 0, 0], 'ColumnSpacing', 20, ...
                'BackgroundColor', background);
            safetyAxes = app.createAxes(plots, ...
                'Slope stability', 'Factor of safety', [0.8, 1.6]);
            pressureAxes = app.createAxes(plots, ...
                'Pore-water pressure', 'Pressure (kPa)', [0, 13]);
            yline(safetyAxes, app.Parameters.watchThreshold, '--', 'WATCH 1.3', ...
                'Color', [0.57, 0.36, 0.04], 'LabelHorizontalAlignment', 'left');
            yline(safetyAxes, 1.0, '--', 'UNSAFE 1.0', ...
                'Color', [0.72, 0.13, 0.17], 'LabelHorizontalAlignment', 'left');
            app.SafetyHistory = plot(safetyAxes, NaN, NaN, ...
                'Color', [0.12, 0.35, 0.68], 'LineWidth', 2.5, ...
                'Tag', 'SafetyHistory');
            app.PressureHistory = plot(pressureAxes, NaN, NaN, ...
                'Color', [0.04, 0.44, 0.51], 'LineWidth', 2.5, ...
                'Tag', 'PressureHistory');
            app.SafetyPoint = plot(safetyAxes, NaN, NaN, 'o', ...
                'MarkerSize', 7, 'MarkerFaceColor', [0.12, 0.35, 0.68], ...
                'MarkerEdgeColor', 'white');
            app.PressurePoint = plot(pressureAxes, NaN, NaN, 'o', ...
                'MarkerSize', 7, 'MarkerFaceColor', [0.04, 0.44, 0.51], ...
                'MarkerEdgeColor', 'white');
            app.SafetyCursor = xline(safetyAxes, 0, ':', 'Color', muted);
            app.PressureCursor = xline(pressureAxes, 0, ':', 'Color', muted);

            timelineLayout = uigridlayout(layout, [2, 2], ...
                'RowHeight', {24, 44}, 'ColumnWidth', {'1x', 150}, ...
                'Padding', [12, 0, 12, 0], 'RowSpacing', 6, ...
                'BackgroundColor', background);
            uilabel(timelineLayout, 'Text', 'SCENARIO TIME', ...
                'FontSize', 12, 'FontWeight', 'bold', 'FontColor', muted);
            app.TimeValue = uilabel(timelineLayout, 'Text', '', ...
                'FontSize', 17, 'FontWeight', 'bold', 'FontColor', ink, ...
                'HorizontalAlignment', 'right', 'Tag', 'SimulationTime');
            app.Timeline = uislider(timelineLayout, ...
                'Limits', [0, app.Observations.TimeSeconds(end)], ...
                'Value', 0, 'MajorTicks', 0:10:60, 'MinorTicks', [], ...
                'FontColor', muted, 'Tag', 'Timeline', ...
                'ValueChangingFcn', @(~, event) app.selectTime(event.Value, false), ...
                'ValueChangedFcn', @(~, event) app.seek(event.Value));
            app.Timeline.Layout.Row = 2;
            app.Timeline.Layout.Column = [1, 2];

            controls = uigridlayout(layout, [1, 4], ...
                'ColumnWidth', {104, 104, 104, '1x'}, ...
                'Padding', [0, 0, 0, 0], 'ColumnSpacing', 10, ...
                'BackgroundColor', background);
            app.PlayButton = uibutton(controls, 'Text', 'Play', ...
                'FontSize', 14, 'FontWeight', 'bold', 'FontColor', 'white', ...
                'BackgroundColor', [0.12, 0.35, 0.68], 'Tag', 'PlayButton', ...
                'ButtonPushedFcn', @(~, ~) app.play());
            app.PauseButton = uibutton(controls, 'Text', 'Pause', ...
                'FontSize', 14, 'Tag', 'PauseButton', ...
                'ButtonPushedFcn', @(~, ~) app.pause());
            uibutton(controls, 'Text', 'Reset', 'FontSize', 14, ...
                'Tag', 'ResetButton', 'ButtonPushedFcn', @(~, ~) app.reset());
            app.PlaybackLabel = uilabel(controls, 'Text', 'Ready', ...
                'FontSize', 13, 'FontColor', muted, ...
                'HorizontalAlignment', 'right', 'Tag', 'PlaybackStatus');

            uilabel(layout, ...
                'Text', 'Illustrative soil values and simulated pressure. For demonstration only.', ...
                'FontSize', 12, 'FontColor', muted);
        end

        function render(app, updateTimeline)
            if nargin < 2
                updateTimeline = true;
            end
            observation = app.Observations(app.SampleIndex, :);
            app.CurrentTime = observation.TimeSeconds;
            switch observation.State
                case "SAFE"
                    stateColor = [0.06, 0.40, 0.29];
                    message = 'Slope is stable in this scenario. Road remains open.';
                case "WATCH"
                    stateColor = [0.57, 0.36, 0.04];
                    message = 'Slope stability is decreasing. Road remains open in this prototype.';
                otherwise
                    stateColor = [0.72, 0.13, 0.17];
                    message = 'Factor of safety is below 1.0. Road is closed in this scenario.';
            end
            if observation.RouteOpen
                app.RoadValue.Text = 'OPEN';
                app.RoadValue.FontColor = [0.06, 0.40, 0.29];
                app.RoadPanel.BackgroundColor = [0.87, 0.95, 0.91];
                app.RoadDetail.Text = 'Road segment 01  /  Open';
            else
                app.RoadValue.Text = 'CLOSED';
                app.RoadValue.FontColor = [0.72, 0.13, 0.17];
                app.RoadPanel.BackgroundColor = [0.99, 0.90, 0.90];
                app.RoadDetail.Text = 'Road segment 01  /  Closed';
            end
            app.StateValue.Text = char(observation.State);
            app.StateValue.FontColor = stateColor;
            app.FactorValue.Text = sprintf('%.3f', observation.FactorOfSafety);
            app.PressureValue.Text = sprintf('%.1f kPa', observation.PorePressureKPa);
            app.StatusMessage.Text = message;
            app.StatusMessage.FontColor = stateColor;
            app.TimeValue.Text = sprintf('%02d / 60 s', app.CurrentTime);
            % A slider must not update its own Value during ValueChangingFcn.
            if updateTimeline
                app.Timeline.Value = app.CurrentTime;
            end

            history = app.Observations(1:app.SampleIndex, :);
            app.SafetyHistory.XData = history.TimeSeconds;
            app.SafetyHistory.YData = history.FactorOfSafety;
            app.PressureHistory.XData = history.TimeSeconds;
            app.PressureHistory.YData = history.PorePressureKPa;
            app.SafetyPoint.XData = app.CurrentTime;
            app.SafetyPoint.YData = observation.FactorOfSafety;
            app.PressurePoint.XData = app.CurrentTime;
            app.PressurePoint.YData = observation.PorePressureKPa;
            app.SafetyCursor.Value = app.CurrentTime;
            app.PressureCursor.Value = app.CurrentTime;

            app.PlayButton.Text = 'Play';
            if app.IsPlaying
                app.PlayButton.Enable = 'off';
                app.PauseButton.Enable = 'on';
                app.PlaybackLabel.Text = 'Playing  /  1x';
            else
                app.PlayButton.Enable = 'on';
                app.PauseButton.Enable = 'off';
                if app.SampleIndex == height(app.Observations)
                    app.PlaybackLabel.Text = 'Complete';
                    app.PlayButton.Text = 'Replay';
                elseif app.SampleIndex == 1
                    app.PlaybackLabel.Text = 'Ready';
                else
                    app.PlaybackLabel.Text = 'Paused';
                end
            end
        end

        function selectTime(app, timeSeconds, updateTimeline)
            if ~isnumeric(timeSeconds) || ~isscalar(timeSeconds) || ...
                    ~isreal(timeSeconds) || ~isfinite(timeSeconds) || ...
                    timeSeconds < 0 || ...
                    timeSeconds > app.Observations.TimeSeconds(end)
                error('resqtwin:dashboard:InvalidTime', ...
                    'Time must be a finite number between 0 and 60 seconds.');
            end
            app.IsPlaying = false;
            stop(app.PlaybackTimer);
            [~, app.SampleIndex] = min(abs( ...
                app.Observations.TimeSeconds - round(double(timeSeconds))));
            app.render(updateTimeline);
        end

        function advance(app)
            if ~isvalid(app) || app.Closing || ~app.IsPlaying
                return
            end
            app.SampleIndex = min(app.SampleIndex + 1, height(app.Observations));
            if app.SampleIndex == height(app.Observations)
                app.IsPlaying = false;
                stop(app.PlaybackTimer);
            end
            app.render();
        end

        function playbackError(app)
            if isvalid(app) && ~app.Closing
                app.IsPlaying = false;
                app.render();
                app.PlaybackLabel.Text = 'Playback stopped after an error';
            end
        end
    end

    methods (Static, Access = private)
        function [value, detail, card] = createCard(parent, heading, tag, detailText)
            panel = uipanel(parent, 'BorderType', 'none', 'BackgroundColor', 'white');
            card = uigridlayout(panel, [3, 1], ...
                'RowHeight', {20, '1x', 22}, ...
                'Padding', [14, 12, 14, 10], 'RowSpacing', 3, ...
                'BackgroundColor', 'white');
            uilabel(card, 'Text', heading, 'FontSize', 11, ...
                'FontWeight', 'bold', 'FontColor', [0.35, 0.41, 0.49]);
            value = uilabel(card, 'Text', '', 'FontSize', 34, ...
                'FontWeight', 'bold', 'FontColor', [0.09, 0.16, 0.25], 'Tag', tag);
            detail = uilabel(card, 'Text', detailText, 'FontSize', 11, ...
                'FontColor', [0.35, 0.41, 0.49]);
        end

        function ax = createAxes(parent, heading, verticalLabel, limits)
            ax = uiaxes(parent, 'Color', 'white', ...
                'XColor', [0.35, 0.41, 0.49], 'YColor', [0.35, 0.41, 0.49], ...
                'FontSize', 12, 'XLim', [0, 60], 'YLim', limits, ...
                'XGrid', 'on', 'YGrid', 'on', 'GridAlpha', 0.10, 'Box', 'off');
            ax.Toolbar.Visible = 'off';
            disableDefaultInteractivity(ax);
            hold(ax, 'on');
            title(ax, heading, 'FontSize', 15, 'Color', [0.09, 0.16, 0.25]);
            xlabel(ax, 'Simulation time (s)');
            ylabel(ax, verticalLabel);
        end
    end
end
