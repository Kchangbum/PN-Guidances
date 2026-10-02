clear; clc; close all;

dt = 0.1;
t_start = 0;
t_end = 30;
t_span = t_start:dt:t_end;

V = 25; % m/s
g = 9.806;
phi = deg2rad(20);
V_w = 1; psi_w = deg2rad(5);
wind_data_off = [0; 0];        % without wind
wind_data_on  = [V_w; psi_w];   % with wind
UAV_data = V;

K = 1;

y0 = [0, 0, 0]';
% psi_cmd = 0;

%% Without wind
[t_out,states_out] = ode45(@(t,Y) Kinematics(t,Y, UAV_data, wind_data_off, K, g, phi), t_span, y0);
x = states_out(:,1);
y = states_out(:,2);
psi = states_out(:,3);

%% With wind
[w_t_out,w_states_out] = ode45(@(t,Y) Kinematics(t,Y, UAV_data, wind_data_on, K, g, phi), t_span, y0);
xw = w_states_out(:,1);
yw = w_states_out(:,2);
psiw = w_states_out(:,3);

%% XY
figure('Name','XY Trajectories','Position',[200, 300, 500, 400]);
ax1 = axes;
hold(ax1,'on');
grid(ax1, 'on');
axis(ax1, 'on');

h1 = line(ax1, x, y, 'Color', [0 0 0], 'LineWidth', 0.5, 'DisplayName','WindOff', 'LineStyle', '--');
start1 = line(ax1, x(t_start+1), y(t_start+1), 'Marker', 'o', 'MarkerFaceColor', [0 1 0]);
end1 = line(ax1, x(end), y(end), 'Marker', 'x', 'MarkerFaceColor', [1 0 0],'MarkerSize', 10, 'LineWidth', 2);

h2 = line(ax1, xw, yw, 'Color', [0 1 0], 'LineWidth', 1.5, 'DisplayName', 'WindOn');
start2 = line(ax1, xw(t_start+1), yw(t_start+1), 'Marker', 'o', 'MarkerFaceColor', [0 1 0]);
end2 = line(ax1, xw(end), yw(end), 'Marker', 'x', 'MarkerFaceColor', [1 0 0],'MarkerSize', 10, 'LineWidth', 2);

legend([h1, h2, start1, start2, end1, end2], {'WindOff', 'WindOn', 'StartWindOff', 'EndWindOff', 'StartWindON', 'EndWindON'}, 'Location','best');

xlabel(ax1,'x[m]');
ylabel(ax1, 'y[m]');
title(ax1, 'XY trajectories');

%% psi
figure('Name','Comparison of the psi', 'Position',[710, 300, 500, 400]);
ax2 = axes;
hold(ax2,'on');
grid(ax2, 'on');
axis(ax2, 'on');
psi1 = line(ax2, t_out, psi, 'Color', 'b', 'LineWidth', 3, 'LineStyle', '--');
psi2 = line(ax2, w_t_out, psiw, 'Color', 'r', 'LineWidth', 1);
% line(ax2, [t_out(1) t_out(end)], [psi_cmd psi_cmd], 'Color', 'r', 'LineWidth', 2, 'LineStyle', '--');

legend([psi1, psi2], {'WindOff', 'WindOn'}, 'Location', 'best')
xlabel(ax2,'Time');
ylabel(ax2, '\psi');
title(ax2, 'PsiWindOff vs PsiWindOn');

%% UAV Kinematics
function dY = Kinematics(~, Y, UAV_data, wind_data, ~, g, phi)
    % x = Y(1);
    % y = Y(2);
    psi = Y(3);

    % x_target = 0;
    % y_target = 0;
    % 
    % dx = x_target - x;
    % dy = y_target - y;
    % psi_cmd = atan2(dx, dy);   % 주의: atan2(y,x)가 아니라 atan2(dx,dy) 순서 — 이 컨벤션에서는!

    V = UAV_data(1);

    V_w = wind_data(1);
    psi_w = wind_data(2);

    xdot = V*cos(psi) + V_w*cos(psi_w);
    ydot = V*sin(psi) + V_w*sin(psi_w);
    % psi_err = psi_cmd - psi;
    % psi_err = atan2(sin(psi_err), cos(psi_err));   % wrap to [-pi, pi]
    R = 100;
    psidot = g*tan(phi)/V;% = V/R;% K * psi_err;

    dY = [xdot, ydot, psidot]';
end