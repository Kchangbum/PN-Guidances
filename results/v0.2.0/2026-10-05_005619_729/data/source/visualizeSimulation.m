function visualizeSimulation(SimulationResults)
% SimulationResult.name = guidanceType;
% SimulationResult.time = time(1:endStep);
% SimulationResult.data.target.stateHistory = Target.stateHistory(1:endStep,:);
% SimulationResult.data.missile.stateHistory = Missile.stateHistory(1:endStep,:);
% SimulationResult.data.geometryHistory = geometryHistory(1:endStep,:);
% SimulationResult.data.missile.bankCmdHistory = missileBankCmdHistory(1:endStep,:);
% SimulationResult.data.lateralAccelCmdHistory = lateralAccelCmdHistory(1:endStep,:);

%% Data (V0.0.0)
% missileX       = missileStateHistory(:,1);
% missileY       = missileStateHistory(:,2);
% missileHeading = rad2deg(missileStateHistory(:,3));
% 
% targetX       = targetStateHistory(:,1);
% targetY       = targetStateHistory(:,2);
% % targetHeading = rad2deg(targetStateHistory(:,3));
% 
% range     = geometryHistory(:,1);
% rangeRate = geometryHistory(:,2);
% losAngle  = rad2deg(geometryHistory(:,3));
% losRate   = rad2deg(geometryHistory(:,4));
% 
% bankAngleHistory = rad2deg(bankAngleHistory);

missileColors = lines(numel(SimulationResults));
targetColors = lines(numel(SimulationResults));

guidanceName = cell(1, numel(SimulationResults));
for iResult = 1:numel(SimulationResults)
    guidanceName{iResult} = char(SimulationResults(iResult).name);
end

%% Trajectories
figure('Name','XY Trajectories','Position',[200, 570, 500, 400]);

trajectoryAxes = axes;
hold(trajectoryAxes,'on');
grid(trajectoryAxes,'on');
% axis(trajectoryAxes,'on');
axis(trajectoryAxes, 'equal');

for iResult = 1:numel(SimulationResults)

    Missile = SimulationResults(iResult).data.missile;
    Target = SimulationResults(iResult).data.target;

    % Missile
    missileTrajectory = line(trajectoryAxes, Missile.stateHistory(:,1), ...
        Missile.stateHistory(:,2), 'Color', missileColors(iResult,:), 'LineWidth',0.5);
    missileStart       = line(trajectoryAxes, Missile.stateHistory(1,1), ...
        Missile.stateHistory(1,2), 'Marker','o', 'MarkerFaceColor', missileColors(iResult,:));
    missileEnd         = line(trajectoryAxes, Missile.stateHistory(end,1), ...
        Missile.stateHistory(end,2), 'Marker','x', 'MarkerFaceColor', missileColors(iResult,:), 'MarkerSize',10, 'LineWidth',2);

    % Target
    targetTrajectory = line(trajectoryAxes, Target.stateHistory(:,1), ...
        Target.stateHistory(:,2), 'Color',targetColors(iResult,:), 'LineWidth',1.5);
    targetStart       = line(trajectoryAxes, Target.stateHistory(1,1), ...
        Target.stateHistory(1,2), 'Marker','o', 'MarkerFaceColor',targetColors(iResult,:));
    targetEnd         = line(trajectoryAxes, Target.stateHistory(end,1), ...
        Target.stateHistory(end,2), 'Marker','x', 'MarkerFaceColor',targetColors(iResult,:), 'MarkerSize',10, 'LineWidth',2);

    % guidanceName = char(SimulationResults(iResult).name);
    set(missileTrajectory, ...
        'DisplayName', sprintf('Missile:%s', guidanceName{iResult}));    
    set(missileStart, ...
        'DisplayName', sprintf('Start Missile:%s', guidanceName{iResult}));    
    set(missileEnd, ...
        'DisplayName', sprintf('End Missile:%s', guidanceName{iResult}));    
    set(targetTrajectory, ...
        'DisplayName', sprintf('Target:%s', guidanceName{iResult}));    
    set(targetStart, ...
        'DisplayName', sprintf('Start Target:%s', guidanceName{iResult}));    
    set(targetEnd, ...
    'DisplayName', sprintf('End Target:%s', guidanceName{iResult}));

end

legend(trajectoryAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
% [trajectoryAxesMinX, trajectoryAxesMaxX] = plotLimit(missileX, targetX);
% [trajectoryAxesMinY, trajectoryAxesMaxY] = plotLimit(missileY, targetY);
% xlim(trajectoryAxes, [trajectoryAxesMinX - 100, trajectoryAxesMaxX + 100]);
% ylim(trajectoryAxes, [trajectoryAxesMinY - 10, trajectoryAxesMaxY + 10]);

xlabel(trajectoryAxes,'$x$ [m]','Interpreter','latex');
ylabel(trajectoryAxes,'$y$ [m]','Interpreter','latex');

title(trajectoryAxes,'XY Trajectories');

clear("iResult");

%% Heading
figure('Name','Heading','Position',[200 + 520, 570, 500, 400]);

headingAxes = axes;
hold(headingAxes,'on');
grid(headingAxes,'on');
axis(headingAxes,'on');

for iResult = 1:numel(SimulationResults)
    missileHeading = SimulationResults(iResult).data.missile.stateHistory(:,3);

    missileHeadingLine = line(headingAxes, SimulationResults(iResult).time, ...
        rad2deg(missileHeading), 'Color',missileColors(iResult,:), 'LineWidth',1);
    % targetHeadingLine  = line(headingAxes, targetTime, targetHeading, 
    % 'Color','r', 'LineWidth',1);

    set(missileHeadingLine, 'DisplayName', sprintf('%s', guidanceName{iResult}))
end

% [headingAxesMinY, headingAxesMaxY] = plotLimit(missileHeading, targetHeading);
% ylim(headingAxes, [headingAxesMinY - 1, headingAxesMaxY + 1]);

legend(headingAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
xlabel(headingAxes,'Time [s]');
ylabel(headingAxes,'$\psi$ [deg]','Interpreter','latex');
title(headingAxes,'Heading');

%% Range
figure('Name','Range','Position',[200, 70, 500, 400]);

rangeAxes = subplot(2,1,1);
hold(rangeAxes,'on');
grid(rangeAxes,'on');
axis(rangeAxes,'on');

for iResult = 1:numel(SimulationResults)
    range = line(rangeAxes, SimulationResults(iResult).time, ...
        SimulationResults(iResult).data.geometryHistory(:,1), 'Color',missileColors(iResult,:), 'LineWidth',1);
    set(range, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(rangeAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
ylabel(rangeAxes,'$R$ [m]','Interpreter','latex');
title(rangeAxes,'Range');

rangeRateAxes = subplot(2,1,2);
hold(rangeRateAxes,'on');
grid(rangeRateAxes,'on');
axis(rangeRateAxes,'on');

for iResult = 1:numel(SimulationResults)
    range = line(rangeRateAxes, SimulationResults(iResult).time, ...
        SimulationResults(iResult).data.geometryHistory(:,2), 'Color',missileColors(iResult,:), 'LineWidth',1);
    set(range, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(rangeRateAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
xlabel(rangeRateAxes,'Time [s]');
ylabel(rangeRateAxes,'$\dot{R}$ [m/s]','Interpreter','latex');
title(rangeRateAxes,'Range Rate');

%% LOS
figure('Name','LOS','Position',[200 + 520, 70, 500, 400]);

% LOS
losAngleAxes = subplot(2,1,1);
hold(losAngleAxes,'on');
grid(losAngleAxes,'on');
axis(losAngleAxes,'on');

for iResult = 1:numel(SimulationResults)
    los = line(losAngleAxes, SimulationResults(iResult).time, ...
        rad2deg(SimulationResults(iResult).data.geometryHistory(:,3)), 'Color',missileColors(iResult,:), 'LineWidth',1);
    set(los, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(losAngleAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
ylabel(losAngleAxes,'$\lambda$ [deg]','Interpreter','latex');
title(losAngleAxes,'LOS Angle');

% LOS rate
losRateAxes = subplot(2,1,2);
hold(losRateAxes,'on');
grid(losRateAxes,'on');
axis(losRateAxes,'on');

for iResult = 1:numel(SimulationResults)
    losRate = line(losRateAxes, SimulationResults(iResult).time, ...
        rad2deg(SimulationResults(iResult).data.geometryHistory(:,4)), 'Color',missileColors(iResult,:), 'LineWidth',1);
    set(losRate, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(losRateAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');

xlabel(losRateAxes,'Time [s]');
ylabel(losRateAxes,'$\dot{\lambda}$ [deg/s]','Interpreter','latex');
title(losRateAxes,'LOS Rate');

%% Bank angle Cmd
figure('Name','LOS','Position',[200 + 520*2, 570, 500, 400]);

BankAngleCommandAxes = axes;
hold(BankAngleCommandAxes,'on');
grid(BankAngleCommandAxes,'on');
axis(BankAngleCommandAxes,'on');

for iResult = 1:numel(SimulationResults)
    bankAngle = line(BankAngleCommandAxes, SimulationResults(iResult).time, ...
        rad2deg(SimulationResults(iResult).data.missile.bankCmdHistory) , 'Color',missileColors(iResult,:), 'LineWidth',1);
    set(bankAngle, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(BankAngleCommandAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
ylabel(BankAngleCommandAxes,'Bank angle command [deg]','Interpreter','latex');
title(BankAngleCommandAxes,'Bank angle command ');

%% lateral Acceleration Cmd 
figure('Name','LOS','Position',[200 + 520*2, 70, 500, 400]);

lateralAccelCmdAxes = axes;
hold(lateralAccelCmdAxes,'on');
grid(lateralAccelCmdAxes,'on');
axis(lateralAccelCmdAxes,'on');

for iResult = 1:numel(SimulationResults)
    lateralAccel = line(lateralAccelCmdAxes, SimulationResults(iResult).time, ...
        SimulationResults(iResult).data.lateralAccelCmdHistory, 'Color', missileColors(iResult,:), 'LineWidth',1);
    set(lateralAccel, 'DisplayName', sprintf('%s', guidanceName{iResult}));
end

legend(lateralAccelCmdAxes, 'show', 'Location', 'best', 'Interpreter', 'none', 'AutoUpdate', 'off');
ylabel(lateralAccelCmdAxes,'lateral acceleration command $[m/s^2]$','Interpreter','latex');
title(lateralAccelCmdAxes,'lateral acceleration command');
end

% function [minX,maxX] = plotLimit(x1, x2)
%     minX = min([x1; x2]);
%     maxX = max([x1; x2]);
% end