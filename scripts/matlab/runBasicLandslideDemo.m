function observations = runBasicLandslideDemo(showPlot)
%RUNBASICLANDSLIDEDEMO Run and optionally plot the first vertical slice.
%   OBSERVATIONS = runBasicLandslideDemo() runs the locked deterministic
%   scenario and displays a factor-of-safety plot.
%
%   OBSERVATIONS = runBasicLandslideDemo(false) skips figure creation.

if nargin < 1
    showPlot = true;
end

validateattributes(showPlot, {'logical'}, {'scalar'}, mfilename, 'showPlot');

[observations, parameters] = resqtwin.scenarios.basicLandslide();

initialState = observations.State(1);
finalState = observations.State(end);
firstUnsafeIndex = find(observations.State == "UNSAFE", 1, 'first');

fprintf("Scenario status: %s\n", parameters.status);
fprintf("Initial state: %s (FS %.3f)\n", ...
    initialState, observations.FactorOfSafety(1));
fprintf("Final state: %s (FS %.3f)\n", ...
    finalState, observations.FactorOfSafety(end));

if isempty(firstUnsafeIndex)
    fprintf("The route remained open for the complete scenario.\n");
else
    fprintf("The route first closes at t = %.0f s.\n", ...
        observations.TimeSeconds(firstUnsafeIndex));
end

if ~showPlot
    return
end

figure('Name', 'ResQTwin Basic Landslide MVP');

yyaxis left
plot(observations.TimeSeconds, observations.FactorOfSafety, ...
    'LineWidth', 2);
yline(1.0, '--r', 'Unsafe threshold');
yline(parameters.watchThreshold, '--', 'Watch threshold');
ylabel('Factor of safety');

yyaxis right
plot(observations.TimeSeconds, observations.PorePressureKPa, ...
    'LineWidth', 1.5);
ylabel('Pore-water pressure (kPa)');

xlabel('Time (s)');
title('ResQTwin basic landslide scenario');
grid on
end
