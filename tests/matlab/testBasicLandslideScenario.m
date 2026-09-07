function tests = testBasicLandslideScenario
%TESTBASICLANDSLIDESCENARIO Check pressure, slope safety, and road closure.

tests = functiontests(localfunctions);
end

function setupOnce(testCase)
testFile = mfilename("fullpath");
projectRoot = fileparts(fileparts(fileparts(testFile)));

testCase.TestData.OriginalPath = path;
addpath(fullfile(projectRoot, "src", "matlab"));
addpath(fullfile(projectRoot, "simulation", "matlab"));
end

function teardownOnce(testCase)
path(testCase.TestData.OriginalPath);
end

function testPressureSchedule(testCase)
observations = resqtwin.scenarios.basicLandslide();
time = observations.TimeSeconds;
pressure = observations.PorePressureKPa;

verifyEqual(testCase, time, (0:60)');
verifyEqual(testCase, pressure(time <= 10), zeros(11, 1));
verifyEqual(testCase, pressure(time >= 50), 12 * ones(11, 1));

% Pressure rises by 0.3 kPa each second during the ramp.
risingPressure = pressure(time >= 10 & time <= 50);
verifyEqual(testCase, diff(risingPressure), 0.3 * ones(40, 1), ...
    'AbsTol', 1e-12);
end

function testKnownSafetyValues(testCase)
observations = resqtwin.scenarios.basicLandslide();
samples = ismember(observations.TimeSeconds, [0, 30, 60]);

% Reference values at 0, 6, and 12 kPa of pore pressure.
expected = [1.403055615149; 1.162543289461; 0.922030963772];
verifyEqual(testCase, observations.FactorOfSafety(samples), expected, ...
    'AbsTol', 1e-10);
verifyLessThanOrEqual(testCase, diff(observations.FactorOfSafety), zeros(60, 1));
end

function testStateAndRoadChanges(testCase)
[observations, parameters] = resqtwin.scenarios.basicLandslide();

verifyEqual(testCase, parameters.status, "LOCKED");
verifyEqual(testCase, unique(observations.State, 'stable'), ...
    ["SAFE"; "WATCH"; "UNSAFE"]);

firstWatch = find(observations.State == "WATCH", 1);
firstUnsafe = find(observations.State == "UNSAFE", 1);
verifyEqual(testCase, observations.TimeSeconds(firstWatch), 19);
verifyEqual(testCase, observations.TimeSeconds(firstUnsafe), 44);
verifyEqual(testCase, observations.RouteOpen, observations.TimeSeconds < 44);
end
