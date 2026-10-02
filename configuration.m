%% Simulation
Config.simulation.timeStep  = 0.1;
Config.simulation.startTime = 0;
Config.simulation.endTime   = 60;

%% Missile
Config.missile.initialX         = -1000;
Config.missile.initialY         = 200;
Config.missile.initialHeading   = -deg2rad(25);
Config.missile.speed            = 100;

%% Target
Config.target.initialX          = 0;
Config.target.initialY          = 0;
Config.target.initialHeading    = deg2rad(0);
Config.target.speed             = 0;

%% Wind
Config.wind.speed       = 0;
Config.wind.direction   = deg2rad(0);

%% Environment
Config.environment.gravity = 9.81;

%% Guidance
Config.guidance.navigationGain = 3;