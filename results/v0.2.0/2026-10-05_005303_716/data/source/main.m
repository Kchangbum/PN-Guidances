close all; clc; clear;

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