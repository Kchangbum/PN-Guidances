function SimulationResult = runSimulation(Config, guidanceType)
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
Target.stateHistory      = zeros(nSteps,3);
Missile.stateHistory     = zeros(nSteps,3);
geometryHistory         = zeros(nSteps,4);
missileBankCmdHistory   = zeros(nSteps,1);
lateralAccelCmdHistory  = zeros(nSteps,1); 

Target.stateHistory(1,:)  = targetState';
Missile.stateHistory(1,:) = missileState';
Target.lateralAccel = 1;

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
    Target.x        = targetState(1);
    Target.y        = targetState(2);
    Target.heading  = targetState(3);
    Target.speed    = Config.target.speed; 
    %% Relative Geometry
    Geometry                = computeRelativeGeometry(Target, Missile);

    geometryHistory(iStep,:) = [Geometry.range, Geometry.rangeRate, Geometry.losAngle, Geometry.losRate];

    %% Termination
    if ~isnan(previousRangeRate)
        if previousRangeRate < 0 && Geometry.rangeRate >= 0
            endStep = iStep - 1;
            break;
        end
    end

    previousRangeRate = Geometry.rangeRate;

    %% PN Guidance
    switch guidanceType
        case "PPN"
            lateralAccelCmd = computePNGuidance(Config.guidance, Geometry, Missile, guidanceType);
        case "TPN"
            lateralAccelCmd = computePNGuidance(Config.guidance, Geometry, Missile, guidanceType);

        case "APN"
            lateralAccelCmd = computePNGuidance(Config.guidance, Geometry, Missile, guidanceType);
        otherwise
            error('No %s', guidanceType);
    end
    lateralAccelCmdHistory(iStep) = lateralAccelCmd;

    %% Command Mapping
    missileBankCmd = computeBankCommand(Config.environment, lateralAccelCmd);
    missileBankCmdHistory(iStep) = missileBankCmd;
    targetBankCmd  = computeBankCommand(Config.environment, Target.lateralAccel);

    %% Kinematics
    timeSpan = [time(iStep), time(iStep+1)];

    [~, targetStateTemp]  = ode45(@(t,y) computeKinematics(t, y, Config.target, Config.wind, Config.environment, targetBankCmd), timeSpan, targetState);
    [~, missileStateTemp] = ode45(@(t,y) computeKinematics(t, y, Config.missile, Config.wind, Config.environment, missileBankCmd), timeSpan, missileState);

    %% State Update
    targetState  = targetStateTemp(end,:)';
    missileState = missileStateTemp(end,:)';

    %% Save
    Target.stateHistory(iStep+1,:)  = targetState';
    Missile.stateHistory(iStep+1,:) = missileState';
end

%% Outputs
SimulationResult.name = guidanceType;
SimulationResult.time = time(1:endStep);
SimulationResult.data.target.stateHistory = Target.stateHistory(1:endStep,:);
SimulationResult.data.missile.stateHistory = Missile.stateHistory(1:endStep,:);
SimulationResult.data.geometryHistory = geometryHistory(1:endStep,:);
SimulationResult.data.missile.bankCmdHistory = missileBankCmdHistory(1:endStep,:);
SimulationResult.data.lateralAccelCmdHistory = lateralAccelCmdHistory(1:endStep,:);
end
