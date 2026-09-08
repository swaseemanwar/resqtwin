function tests = testBasicLandslideDemo
%TESTBASICLANDSLIDEDEMO Check the public demo command without opening figures.

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

function testHeadlessDemoReportsRoadClosure(testCase)
originalFigures = findall(groot, 'Type', 'figure');
summary = evalc('observations = runBasicLandslideDemo(false);');

verifyEqual(testCase, height(observations), 61);
verifyEqual(testCase, observations.State([1, end]), ["SAFE"; "UNSAFE"]);
verifyEqual(testCase, observations.RouteOpen, observations.TimeSeconds < 44);
verifyTrue(testCase, contains(summary, 'Scenario status: LOCKED'));
verifyTrue(testCase, contains(summary, 'Initial state: SAFE'));
verifyTrue(testCase, contains(summary, 'Final state: UNSAFE'));
verifyTrue(testCase, contains(summary, 'The route first closes at t = 44 s.'));
verifyEqual(testCase, findall(groot, 'Type', 'figure'), originalFigures);
end

function testRejectsInvalidPlotOptions(testCase)
verifyError(testCase, @() runBasicLandslideDemo(0), ...
    'MATLAB:runBasicLandslideDemo:invalidType');
verifyError(testCase, @() runBasicLandslideDemo([true, false]), ...
    'MATLAB:runBasicLandslideDemo:expectedScalar');
end
