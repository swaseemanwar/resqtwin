function tests = testInfiniteSlopeFactorOfSafety
%TESTINFINITESLOPEFACTOROFSAFETY Verify the standalone slope calculation.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFile = mfilename("fullpath");
projectRoot = fileparts(fileparts(fileparts(testFile)));

testCase.TestData.OriginalPath = path;
addpath(fullfile(projectRoot, "src", "matlab"));
end

function teardownOnce(testCase)
path(testCase.TestData.OriginalPath);
end

function testFrictionOnlyNeutralCase(testCase)
factorOfSafety = resqtwin.infiniteSlopeFactorOfSafety( ...
    30, 2, 18, 0, 30, 0);

verifyEqual(testCase, factorOfSafety, 1, 'AbsTol', 1e-12);
end

function testPorePressureReducesStability(testCase)
factorOfSafety = resqtwin.infiniteSlopeFactorOfSafety( ...
    30, 2, 18, 5, 32, [0; 6; 12]);

verifyGreaterThan(testCase, factorOfSafety(1), 1.3);
verifyGreaterThan(testCase, factorOfSafety(2), 1.0);
verifyLessThan(testCase, factorOfSafety(2), 1.3);
verifyLessThan(testCase, factorOfSafety(3), 1.0);
verifyLessThan(testCase, diff(factorOfSafety), 0);
end

function testKnownStressValues(testCase)
% At 45 degrees, these inputs give normal and driving stresses of 10 kPa.
[factorOfSafety, stresses] = resqtwin.infiniteSlopeFactorOfSafety( ...
    45, 2, 10, 2, 45, [0; 5; 10]);

verifyEqual(testCase, factorOfSafety, [1.2; 0.7; 0.2], 'AbsTol', 1e-12);
verifyEqual(testCase, stresses.drivingKPa, 10, 'AbsTol', 1e-12);
verifyEqual(testCase, stresses.totalNormalKPa, 10, 'AbsTol', 1e-12);
verifyEqual(testCase, stresses.effectiveNormalKPa, [10; 5; 0], 'AbsTol', 1e-12);
verifyEqual(testCase, stresses.resistingKPa, [12; 7; 2], 'AbsTol', 1e-12);
end

function testRejectsNegativeEffectiveStress(testCase)
callModel = @() resqtwin.infiniteSlopeFactorOfSafety( ...
    30, 2, 18, 5, 32, 28);

verifyError(testCase, callModel, ...
    'resqtwin:infiniteSlopeFactorOfSafety:NegativeEffectiveStress');
end
