function tests = testLandslideDashboard
%TESTLANDSLIDEDASHBOARD Check displayed decisions and playback lifecycle.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFile = mfilename("fullpath");
projectRoot = fileparts(fileparts(fileparts(testFile)));
testCase.TestData.OriginalPath = path;
run(fullfile(projectRoot, "scripts", "setupProject.m"));
end

function teardownOnce(testCase)
path(testCase.TestData.OriginalPath);
end

function setup(testCase)
timersBefore = timerfindall;
testCase.TestData.App = runLandslideDashboard('Visible', 'off');
timersAfter = timerfindall;
existing = false(size(timersAfter));
for index = 1:numel(timersBefore)
    existing = existing | timersAfter == timersBefore(index);
end
testCase.TestData.OwnedTimers = timersAfter(~existing);
end

function teardown(testCase)
if isfield(testCase.TestData, 'App') && isvalid(testCase.TestData.App)
    delete(testCase.TestData.App);
end
end

function testInitialDisplay(testCase)
app = testCase.TestData.App;
verifyEqual(testCase, app.CurrentTime, 0);
verifyFalse(testCase, app.IsPlaying);
verifyEqual(testCase, component(app, 'RoadStatus').Text, 'OPEN');
verifyEqual(testCase, component(app, 'SlopeState').Text, 'SAFE');
verifyEqual(testCase, component(app, 'FactorOfSafety').Text, '1.403');
verifyEqual(testCase, component(app, 'PorePressure').Text, '0.0 kPa');
verifyEqual(testCase, component(app, 'PlaybackStatus').Text, 'Ready');
verifyEqual(testCase, component(app, 'SafetyHistory').XData, 0);
verifyEqual(testCase, string(component(app, 'PauseButton').Enable), "off");
end

function testTransitionsAndHistoryMatchScenario(testCase)
app = testCase.TestData.App;
times = [18, 19, 43, 44, 60];
states = ["SAFE", "WATCH", "WATCH", "UNSAFE", "UNSAFE"];
roads = ["OPEN", "OPEN", "OPEN", "CLOSED", "CLOSED"];
for index = 1:numel(times)
    app.seek(times(index));
    observation = app.Observations(times(index) + 1, :);
    verifyEqual(testCase, string(component(app, 'SlopeState').Text), states(index));
    verifyEqual(testCase, string(component(app, 'RoadStatus').Text), roads(index));
    verifyEqual(testCase, component(app, 'FactorOfSafety').Text, ...
        sprintf('%.3f', observation.FactorOfSafety));
    verifyEqual(testCase, component(app, 'PorePressure').Text, ...
        sprintf('%.1f kPa', observation.PorePressureKPa));
    verifyEqual(testCase, component(app, 'SimulationTime').Text, ...
        sprintf('%02d / 60 s', times(index)));
    verifyEqual(testCase, component(app, 'Timeline').Value, times(index));
    safety = component(app, 'SafetyHistory');
    pressure = component(app, 'PressureHistory');
    verifyEqual(testCase, safety.XData(:), (0:times(index))');
    verifyEqual(testCase, safety.YData(:), ...
        app.Observations.FactorOfSafety(1:times(index) + 1));
    verifyEqual(testCase, pressure.XData(:), safety.XData(:));
    verifyEqual(testCase, pressure.YData(:), ...
        app.Observations.PorePressureKPa(1:times(index) + 1));
end
end

function testTimelinePausesAndSelectsNearestSecond(testCase)
app = testCase.TestData.App;
press(app, 'PlayButton');
slider = component(app, 'Timeline');
slider.ValueChangingFcn(slider, struct('Value', 19.4));
verifyFalse(testCase, app.IsPlaying);
verifyEqual(testCase, app.CurrentTime, 19);
verifyEqual(testCase, slider.Value, 0);
slider.ValueChangedFcn(slider, struct('Value', 19.4));
verifyFalse(testCase, app.IsPlaying);
verifyEqual(testCase, app.CurrentTime, 19);
verifyEqual(testCase, component(app, 'PlaybackStatus').Text, 'Paused');
verifyEqual(testCase, get(testCase.TestData.OwnedTimers, 'Running'), 'off');
slider.ValueChangedFcn(slider, struct('Value', 43.6));
verifyEqual(testCase, app.CurrentTime, 44);
verifyEqual(testCase, component(app, 'RoadStatus').Text, 'CLOSED');
end

function testPlayPauseAndResume(testCase)
app = testCase.TestData.App;
press(app, 'PlayButton');
waitForTime(testCase, app, 1);
press(app, 'PauseButton');
pausedTime = app.CurrentTime;
pause(1.2);
drawnow;
verifyEqual(testCase, app.CurrentTime, pausedTime);
verifyFalse(testCase, app.IsPlaying);
press(app, 'PlayButton');
waitForTime(testCase, app, pausedTime + 1);
press(app, 'PauseButton');
verifyGreaterThan(testCase, app.CurrentTime, pausedTime);
end

function testResetWhilePlayingRestoresInitialView(testCase)
app = testCase.TestData.App;
app.seek(44);
press(app, 'PlayButton');
press(app, 'ResetButton');
verifyEqual(testCase, app.CurrentTime, 0);
verifyFalse(testCase, app.IsPlaying);
verifyEqual(testCase, component(app, 'RoadStatus').Text, 'OPEN');
verifyEqual(testCase, component(app, 'SlopeState').Text, 'SAFE');
verifyEqual(testCase, component(app, 'Timeline').Value, 0);
verifyEqual(testCase, component(app, 'SafetyHistory').XData, 0);
verifyEqual(testCase, component(app, 'PressureHistory').YData, 0);
verifyEqual(testCase, get(testCase.TestData.OwnedTimers, 'Running'), 'off');
end

function testCompletionStopsTimerAndReplayStartsAtZero(testCase)
app = testCase.TestData.App;
app.seek(59);
press(app, 'PlayButton');
waitForTime(testCase, app, 60);
verifyFalse(testCase, app.IsPlaying);
verifyEqual(testCase, component(app, 'PlaybackStatus').Text, 'Complete');
verifyEqual(testCase, component(app, 'PlayButton').Text, 'Replay');
verifyEqual(testCase, get(testCase.TestData.OwnedTimers, 'Running'), 'off');
press(app, 'PlayButton');
verifyEqual(testCase, app.CurrentTime, 0);
verifyTrue(testCase, app.IsPlaying);
verifyEqual(testCase, component(app, 'RoadStatus').Text, 'OPEN');
press(app, 'PauseButton');
end

function testInvalidSeekPreservesCurrentView(testCase)
app = testCase.TestData.App;
app.seek(19);
invalidTimes = {-1, 61, NaN, Inf, 1i, [], [19, 44], '19'};
for index = 1:numel(invalidTimes)
    verifyError(testCase, @() app.seek(invalidTimes{index}), ...
        'resqtwin:dashboard:InvalidTime');
end
verifyEqual(testCase, app.CurrentTime, 19);
verifyEqual(testCase, component(app, 'SlopeState').Text, 'WATCH');
end

function testClosingPlayingFigureDeletesOwnedTimer(testCase)
app = testCase.TestData.App;
ownedTimers = testCase.TestData.OwnedTimers;
assertNumElements(testCase, ownedTimers, 1);
press(app, 'PlayButton');
close(app.Figure);
verifyFalse(testCase, isvalid(app));
verifyFalse(testCase, isvalid(ownedTimers));
end

function testMultipleDashboardsAreIndependent(testCase)
app = testCase.TestData.App;
other = runLandslideDashboard('Visible', 'off');
cleanup = onCleanup(@() delete(other));
app.seek(44);
other.seek(19);
verifyEqual(testCase, component(app, 'RoadStatus').Text, 'CLOSED');
verifyEqual(testCase, component(other, 'RoadStatus').Text, 'OPEN');
delete(app);
other.play();
verifyTrue(testCase, other.IsPlaying);
verifyEqual(testCase, other.CurrentTime, 19);
end

function control = component(app, tag)
control = findall(app.Figure, 'Tag', tag);
end

function press(app, tag)
button = component(app, tag);
button.ButtonPushedFcn(button, []);
end

function waitForTime(testCase, app, expectedTime)
started = tic;
while app.CurrentTime < expectedTime && toc(started) < 8
    pause(0.05);
    drawnow;
end
assertGreaterThanOrEqual(testCase, app.CurrentTime, expectedTime, ...
    'Playback did not reach the expected observation within eight seconds.');
end
