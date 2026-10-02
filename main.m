close all; clc; clear;

configuration;

timeStep = Config.simulation.timeStep;
time     = Config.simulation.startTime:timeStep:Config.simulation.endTime;
nSteps   = length(time);

%% Initialization
% Target
targetState = [
    Config.target.initialX;
    Config.target.initialY;
    Config.target.initialHeading
    ];

% Missile
missileState = [
    Config.missile.initialX;
    Config.missile.initialY;
    Config.missile.initialHeading
    ];

% History
targetStateHistory  = zeros(nSteps,3);
missileStateHistory = zeros(nSteps,3);
geometryHistory     = zeros(nSteps,4);
missileBankCmdHistory   = zeros(nSteps,1);
lateralAccelCmdHistory         = zeros(nSteps,1); 

targetStateHistory(1,:)  = targetState';
missileStateHistory(1,:) = missileState';

% Termination
previousRangeRate = NaN;
endStep           = nSteps;

%% Simulation Manager
for iStep = 1:nSteps-1

    %% Current States
    % Missile
    Missile.x       = missileState(1);
    Missile.y       = missileState(2);
    Missile.heading = missileState(3);
    Missile.speed   = Config.missile.speed;

    % Target
    Target.x       = targetState(1);
    Target.y       = targetState(2);
    Target.heading = targetState(3);
    Target.speed   = Config.target.speed;

    %% Relative Geometry
    Geometry                = computeRelativeGeometry(Target, Missile);

    geometryHistory(iStep,:) = [Geometry.range, Geometry.rangeRate, Geometry.losAngle, Geometry.losRate];

    %% Termination
    if ~isnan(previousRangeRate)
        if previousRangeRate < 0 && Geometry.rangeRate >= 0
            endStep = iStep;
            break;
        end
    end

    previousRangeRate = Geometry.rangeRate;

    %% PN Guidance
    % PPN lateralAccelCmd
    lateralAccelCmd = computePNGuidance(Config.guidance, Geometry, Missile);

    lateralAccelCmdHistory(iStep) = lateralAccelCmd; 
    %% Command Mapping
    missileBankCmd = computeBankCommand(Config.environment, lateralAccelCmd);
    missileBankCmdHistory(iStep) = missileBankCmd;
    targetBankCmd  = 0;

    %% Kinematics
    timeSpan = [time(iStep), time(iStep+1)];

    [~, targetStateTemp]  = ode45(@(t,y) computeKinematics(t, y, Config.target, Config.wind, Config.environment, targetBankCmd), timeSpan, targetState);
    [~, missileStateTemp] = ode45(@(t,y) computeKinematics(t, y, Config.missile, Config.wind, Config.environment, missileBankCmd), timeSpan, missileState);

    %% State Update
    targetState  = targetStateTemp(end,:)';
    missileState = missileStateTemp(end,:)';

    %% Save
    targetStateHistory(iStep+1,:)  = targetState';
    missileStateHistory(iStep+1,:) = missileState';

end

%% Data Trimming
time                = time(1:endStep);
targetStateHistory  = targetStateHistory(1:endStep,:);
missileStateHistory = missileStateHistory(1:endStep,:);
geometryHistory     = geometryHistory(1:endStep,:);
missileBankCmdHistory   = missileBankCmdHistory(1:endStep,:);
lateralAccelCmdHistory  = lateralAccelCmdHistory(1:endStep,:); 

%% Visualization
visualizeSimulation(time, targetStateHistory, missileStateHistory, geometryHistory, missileBankCmdHistory, lateralAccelCmdHistory);