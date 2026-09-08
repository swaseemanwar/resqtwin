function results = runProjectTests()
%RUNPROJECTTESTS Run the deterministic MATLAB test suite.

thisFile = mfilename("fullpath");
projectRoot = fileparts(fileparts(fileparts(thisFile)));
testFolder = fullfile(projectRoot, "tests", "matlab");

results = runtests(testFolder, 'IncludeSubfolders', true);
assertSuccess(results);
end
