function [observations, parameters] = basicLandslide()
%BASICLANDSLIDE Run a 60-second slope and road example.
%   Returns one row per second and the example soil settings.

% Example values; LOCKED refers to the MVP scope.
parameters.status = "LOCKED";
parameters.slopeAngleDeg = 30;
parameters.soilDepthM = 2;
parameters.soilUnitWeightKNPerM3 = 18;
parameters.cohesionKPa = 5;
parameters.frictionAngleDeg = 32;
parameters.watchThreshold = 1.3;

% FLASH FLOOD SCENARIO: Assess slope stability under extreme environmental conditions
timeSeconds = (0:60)';
porePressureKPa = zeros(61, 1); % Base safe condition

% Inject a severe flash flood pressure spike at t = 30 seconds
porePressureKPa(31:46) = linspace(0, 25, 16)'; % Rapid build-up to 25 kPa
porePressureKPa(47:61) = linspace(25, 15, 15)'; % Gradual receding water

% Calculate slope safety and whether the road stays open.
factorOfSafety = resqtwin.infiniteSlopeFactorOfSafety( ...
    parameters.slopeAngleDeg, ...
    parameters.soilDepthM, ...
    parameters.soilUnitWeightKNPerM3, ...
    parameters.cohesionKPa, ...
    parameters.frictionAngleDeg, ...
    porePressureKPa);

[state, routeOpen] = resqtwin.classifySlopeState( ...
    factorOfSafety, parameters.watchThreshold);

observations = table(timeSeconds, porePressureKPa, ...
    factorOfSafety, state, routeOpen, ...
    'VariableNames', {'TimeSeconds', 'PorePressureKPa', ...
    'FactorOfSafety', 'State', 'RouteOpen'});
end
