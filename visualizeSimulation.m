function visualizeSimulation(time, targetStateHistory, missileStateHistory, geometryHistory,  bankAngleHistory, lateralAccelCmdHistory)

%% Data
missileX       = missileStateHistory(:,1);
missileY       = missileStateHistory(:,2);
missileHeading = rad2deg(missileStateHistory(:,3));

targetX       = targetStateHistory(:,1);
targetY       = targetStateHistory(:,2);
% targetHeading = rad2deg(targetStateHistory(:,3));

range     = geometryHistory(:,1);
rangeRate = geometryHistory(:,2);
losAngle  = rad2deg(geometryHistory(:,3));
losRate   = rad2deg(geometryHistory(:,4));

bankAngleHistory = rad2deg(bankAngleHistory);

%% Trajectories
figure('Name','XY Trajectories','Position',[200, 570, 500, 400]);

trajectoryAxes = axes;
hold(trajectoryAxes,'on');
grid(trajectoryAxes,'on');
% axis(trajectoryAxes,'on');
missileTrajectory = line(trajectoryAxes, missileX, missileY, 'Color',[1 0 0], 'LineWidth',0.5);
missileStart       = line(trajectoryAxes, missileX(1), missileY(1), 'Marker','o', 'MarkerFaceColor',[0 1 0]);
missileEnd         = line(trajectoryAxes, missileX(end), missileY(end), 'Marker','x', 'MarkerFaceColor',[1 0 0], 'MarkerSize',10, 'LineWidth',2);

targetTrajectory = line(trajectoryAxes, targetX, targetY, 'Color',[0 1 0], 'LineWidth',1.5);
targetStart       = line(trajectoryAxes, targetX(1), targetY(1), 'Marker','o', 'MarkerFaceColor',[1 0 0]);
targetEnd         = line(trajectoryAxes, targetX(end), targetY(end), 'Marker','x', 'MarkerFaceColor',[1 0 0], 'MarkerSize',10, 'LineWidth',2);

axis(trajectoryAxes, 'equal');
legend([missileTrajectory, targetTrajectory, missileStart, targetStart, missileEnd, targetEnd], {'Missile','Target','Start Missile','Start Target','End Missile','End Target'}, 'Location','best');

% [trajectoryAxesMinX, trajectoryAxesMaxX] = plotLimit(missileX, targetX);
% [trajectoryAxesMinY, trajectoryAxesMaxY] = plotLimit(missileY, targetY);
% xlim(trajectoryAxes, [trajectoryAxesMinX - 100, trajectoryAxesMaxX + 100]);
% ylim(trajectoryAxes, [trajectoryAxesMinY - 10, trajectoryAxesMaxY + 10]);
% 
xlabel(trajectoryAxes,'$x$ [m]','Interpreter','latex');
ylabel(trajectoryAxes,'$y$ [m]','Interpreter','latex');

title(trajectoryAxes,'XY Trajectories');

%% Heading
figure('Name','Heading','Position',[200 + 520, 570, 500, 400]);

headingAxes = axes;
hold(headingAxes,'on');
grid(headingAxes,'on');
axis(headingAxes,'on');

missileHeadingLine = line(headingAxes, time, missileHeading, 'Color','b', 'LineWidth',1);
% targetHeadingLine  = line(headingAxes, targetTime, targetHeading, 'Color','r', 'LineWidth',1);

legend(missileHeadingLine, 'Missile', 'Location','best');

% [headingAxesMinY, headingAxesMaxY] = plotLimit(missileHeading, targetHeading);
% ylim(headingAxes, [headingAxesMinY - 1, headingAxesMaxY + 1]);

xlabel(headingAxes,'Time [s]');
ylabel(headingAxes,'$\psi$ [deg]','Interpreter','latex');
title(headingAxes,'Heading');

%% Range
figure('Name','Range','Position',[200, 70, 500, 400]);

rangeAxes = subplot(2,1,1);
hold(rangeAxes,'on');
grid(rangeAxes,'on');
axis(rangeAxes,'on');

line(rangeAxes, time, range, 'Color','b', 'LineWidth',1);

ylabel(rangeAxes,'$R$ [m]','Interpreter','latex');
title(rangeAxes,'Range');

rangeRateAxes = subplot(2,1,2);
hold(rangeRateAxes,'on');
grid(rangeRateAxes,'on');
axis(rangeRateAxes,'on');

line(rangeRateAxes, time, rangeRate, 'Color','b', 'LineWidth',1);

xlabel(rangeRateAxes,'Time [s]');
ylabel(rangeRateAxes,'$\dot{R}$ [m/s]','Interpreter','latex');
title(rangeRateAxes,'Range Rate');

%% LOS
figure('Name','LOS','Position',[200 + 520, 70, 500, 400]);

losAngleAxes = subplot(2,1,1);
hold(losAngleAxes,'on');
grid(losAngleAxes,'on');
axis(losAngleAxes,'on');

line(losAngleAxes, time, losAngle, 'Color','b', 'LineWidth',1);

ylabel(losAngleAxes,'$\lambda$ [deg]','Interpreter','latex');
title(losAngleAxes,'LOS Angle');

losRateAxes = subplot(2,1,2);
hold(losRateAxes,'on');
grid(losRateAxes,'on');
axis(losRateAxes,'on');

line(losRateAxes, time, losRate, 'Color','b', 'LineWidth',1);

xlabel(losRateAxes,'Time [s]');
ylabel(losRateAxes,'$\dot{\lambda}$ [deg/s]','Interpreter','latex');
title(losRateAxes,'LOS Rate');

%% Bank angle Cmd
figure('Name','LOS','Position',[200 + 520*2, 570, 500, 400]);

BankAngleCommandAxes = axes;
hold(BankAngleCommandAxes,'on');
grid(BankAngleCommandAxes,'on');
axis(BankAngleCommandAxes,'on');

line(BankAngleCommandAxes, time, bankAngleHistory, 'Color','b', 'LineWidth',1);

ylabel(BankAngleCommandAxes,'Bank angle command [deg]','Interpreter','latex');
title(BankAngleCommandAxes,'Bank angle command ');

%% lateral Acceleration Cmd 
figure('Name','LOS','Position',[200 + 520*2, 70, 500, 400]);

lateralAccelCmdAxes = axes;
hold(lateralAccelCmdAxes,'on');
grid(lateralAccelCmdAxes,'on');
axis(lateralAccelCmdAxes,'on');

line(lateralAccelCmdAxes, time, lateralAccelCmdHistory, 'Color','b', 'LineWidth',1);

ylabel(lateralAccelCmdAxes,'lateral acceleration command $[m/s^2]$','Interpreter','latex');
title(lateralAccelCmdAxes,'lateral acceleration command');
end

function [minX,maxX] = plotLimit(x1, x2)
    minX = min([x1; x2]);
    maxX = max([x1; x2]);
end