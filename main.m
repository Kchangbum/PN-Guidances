close all; clc; clear;

projectDirectory = fileparts(mfilename('fullpath'));
addpath(fullfile(projectDirectory, 'src'));

%% Initialization
configuration;

%% Run simulation
guidanceTypes = ["TPN", "PPN", "APN"];

for iGuidance = 1:numel(guidanceTypes)
    SimulationResults(iGuidance) = ...
        runSimulation(Config, guidanceTypes(iGuidance));
end

%% Visualization
visualizeSimulation(SimulationResults);
