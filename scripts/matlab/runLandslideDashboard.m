function dashboard = runLandslideDashboard(varargin)
%RUNLANDSLIDEDASHBOARD Open the interactive, simulated landslide dashboard.
%   DASHBOARD = runLandslideDashboard() opens the dashboard paused at 0 s.
%   Use Play, Pause, Reset, or the timeline slider to explore the scenario.
%
%   DASHBOARD = runLandslideDashboard('Visible', 'off') creates a hidden
%   dashboard for automated checks. Delete it with delete(DASHBOARD).

dashboard = resqtwin.ui.LandslideDashboard(varargin{:});
end
