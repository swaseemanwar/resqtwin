function [factorOfSafety, stresses] = infiniteSlopeFactorOfSafety( ...
        slopeAngleDeg, soilDepthM, soilUnitWeightKNPerM3, ...
        cohesionKPa, frictionAngleDeg, porePressureKPa)
%INFINITESLOPEFACTOROFSAFETY Calculate resisting stress / driving stress.
%   Angles are in degrees, vertical soil depth in m, and unit weight in
%   kN/m^3. Cohesion, pore pressure, and returned stresses are in kPa.
%   Pore pressure can be an array; the other inputs must be scalars.
%   This static, homogeneous slope prototype does not predict runout
%   and is not suitable for operational safety decisions.

% Check the inputs before calculating stresses.
validateattributes(slopeAngleDeg, {'numeric'}, ...
    {'real', 'finite', 'scalar', '>', 0, '<', 90}, mfilename, 'slopeAngleDeg');
validateattributes(soilDepthM, {'numeric'}, ...
    {'real', 'finite', 'scalar', 'positive'}, mfilename, 'soilDepthM');
validateattributes(soilUnitWeightKNPerM3, {'numeric'}, ...
    {'real', 'finite', 'scalar', 'positive'}, ...
    mfilename, 'soilUnitWeightKNPerM3');
validateattributes(cohesionKPa, {'numeric'}, ...
    {'real', 'finite', 'scalar', 'nonnegative'}, mfilename, 'cohesionKPa');
validateattributes(frictionAngleDeg, {'numeric'}, ...
    {'real', 'finite', 'scalar', '>=', 0, '<', 90}, mfilename, 'frictionAngleDeg');
validateattributes(porePressureKPa, {'numeric'}, ...
    {'real', 'finite', 'nonnegative'}, mfilename, 'porePressureKPa');

% Resolve the soil weight into stresses on the potential sliding plane.
sineSlope = sind(slopeAngleDeg);
cosineSlope = cosd(slopeAngleDeg);
soilWeightKPa = soilUnitWeightKNPerM3 * soilDepthM;
normalKPa = soilWeightKPa * cosineSlope^2;
drivingKPa = soilWeightKPa * sineSlope * cosineSlope;
effectiveNormalKPa = normalKPa - porePressureKPa;

if any(effectiveNormalKPa(:) < 0)
    error('resqtwin:infiniteSlopeFactorOfSafety:NegativeEffectiveStress', ...
        ['porePressureKPa must not exceed total normal stress for this ', ...
        'prototype model.']);
end

% Cohesion and friction resist sliding; gravity drives it.
resistingKPa = cohesionKPa + effectiveNormalKPa * tand(frictionAngleDeg);
factorOfSafety = resistingKPa / drivingKPa;

stresses.drivingKPa = drivingKPa;
stresses.totalNormalKPa = normalKPa;
stresses.effectiveNormalKPa = effectiveNormalKPa;
stresses.resistingKPa = resistingKPa;
end
