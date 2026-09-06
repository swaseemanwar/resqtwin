function tests = testClassifySlopeState
%TESTCLASSIFYSLOPESTATE Verify slope states and the road closure boundary.

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

function testDefaultThresholdBoundaries(testCase)
[state, routeOpen] = resqtwin.classifySlopeState( ...
    [0, 1 - eps(1), 1, 1.3 - eps(1.3), 1.3, 2]);

verifyEqual(testCase, state, ...
    ["UNSAFE", "UNSAFE", "WATCH", "WATCH", "SAFE", "SAFE"]);
verifyEqual(testCase, routeOpen, [false, false, true, true, true, true]);
end

function testCustomWatchThreshold(testCase)
[state, routeOpen] = resqtwin.classifySlopeState([0.9, 1, 1.3, 1.5], 1.5);

verifyEqual(testCase, state, ["UNSAFE", "WATCH", "WATCH", "SAFE"]);
verifyEqual(testCase, routeOpen, [false, true, true, true]);
end

function testPreservesMatrixShape(testCase)
[state, routeOpen] = resqtwin.classifySlopeState([0.8, 1; 1.3, 2]);

verifyEqual(testCase, state, ["UNSAFE", "WATCH"; "SAFE", "SAFE"]);
verifyEqual(testCase, routeOpen, [false, true; true, true]);
end

function testRejectsInvalidFactorOfSafety(testCase)
invalidInputs = {-1, NaN, Inf, 1 + 1i, "1.3"};
expectedErrors = {'expectedNonnegative', 'expectedFinite', ...
    'expectedFinite', 'expectedReal', 'invalidType'};

for index = 1:numel(invalidInputs)
    callClassifier = @() resqtwin.classifySlopeState(invalidInputs{index});
    errorId = ['MATLAB:classifySlopeState:', expectedErrors{index}];
    verifyError(testCase, callClassifier, errorId);
end
end

function testRejectsInvalidWatchThreshold(testCase)
invalidInputs = {1, 0.9, NaN, Inf, [1.3, 1.5], 1.3 + 1i, "1.3"};
expectedErrors = {'notGreater', 'notGreater', 'expectedFinite', ...
    'expectedFinite', 'expectedScalar', 'expectedReal', 'invalidType'};

for index = 1:numel(invalidInputs)
    callClassifier = @() resqtwin.classifySlopeState(1.2, invalidInputs{index});
    errorId = ['MATLAB:classifySlopeState:', expectedErrors{index}];
    verifyError(testCase, callClassifier, errorId);
end
end
