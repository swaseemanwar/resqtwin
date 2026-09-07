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

% Hold at 0 kPa, rise from 10 to 50 seconds, then hold at 12 kPa.
timeSeconds = (0:60)';
porePressureKPa = 0.3 * (timeSeconds - 10);
porePressureKPa(timeSeconds < 10) = 0;
porePressureKPa(timeSeconds > 50) = 12;

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
