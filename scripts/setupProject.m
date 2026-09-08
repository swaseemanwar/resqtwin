% setupProject Add ResQTwin development folders to the MATLAB path.
%
% From the repository root, run:
%   run("scripts/setupProject.m")
% From another working directory, use the full path to this script.

setupFile = mfilename("fullpath");
projectRoot = fileparts(fileparts(setupFile));

pathsToAdd = [ ...
    fullfile(projectRoot, "src", "matlab")
    fullfile(projectRoot, "simulation", "matlab")
    fullfile(projectRoot, "scripts", "matlab")
];

for pathIndex = 1:numel(pathsToAdd)
    addpath(pathsToAdd(pathIndex));
end

fprintf("ResQTwin paths configured from %s\n", projectRoot);

clear pathIndex pathsToAdd projectRoot setupFile
