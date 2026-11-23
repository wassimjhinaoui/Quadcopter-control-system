%% Export mission figures and metrics from a logged Simulink run.
% Input: results/mission_logs.mat containing a variable named logsout.
% Required signal names:
% x_ref, x, z_ref, z, theta_ref, theta,
% F_wind, T_actual, tau_actual, F_plus, F_minus

rootDir = fileparts(fileparts(mfilename('fullpath')));
dataFile = fullfile(rootDir, 'results', 'mission_logs.mat');
docsDir = fullfile(rootDir, 'docs');
imageDir = fullfile(docsDir, 'images');

if ~isfile(dataFile)
    error('Missing %s. Save logsout from the final mission first.', dataFile);
end
if ~isfolder(imageDir)
    mkdir(imageDir);
end

S = load(dataFile, 'logsout');
if ~isfield(S, 'logsout')
    error('mission_logs.mat must contain logsout.');
end
logsout = S.logsout;

[t.xr, d.xr] = readSignal(logsout, 'x_ref');
[t.x,  d.x]  = readSignal(logsout, 'x');
[t.zr, d.zr] = readSignal(logsout, 'z_landing_ref');
[t.z,  d.z]  = readSignal(logsout, 'z');
[t.tr, d.tr] = readSignal(logsout, 'theta ref');
[t.th, d.th] = readSignal(logsout, 'theta');
[t.w,  d.w]  = readSignal(logsout, 'F_wind');
[t.T,  d.T]  = readSignal(logsout, 'T_actual');
[t.ta, d.ta] = readSignal(logsout, 'tau_actual');
[t.fp, d.fp] = readSignal(logsout, 'F_plus');
[t.fm, d.fm] = readSignal(logsout, 'F_minus');

fig = figure('Color', 'w', 'Position', [80 80 1120 800]);
tiledlayout(3, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot(t.xr, d.xr, '--', 'LineWidth', 1.7); hold on;
plot(t.x, d.x, 'LineWidth', 1.7);
xline(11, ':k', 'Wind applied');
grid on; ylabel('x (m)'); title('Lateral Position Tracking');
legend('Reference', 'Actual', 'Location', 'best');

nexttile;
plot(t.zr, d.zr, '--', 'LineWidth', 1.7); hold on;
plot(t.z, d.z, 'LineWidth', 1.7);
xline(30, ':k', 'Landing command');
grid on; ylabel('z (m)'); title('Altitude and Landing Tracking');
legend('Reference', 'Actual', 'Location', 'best');

nexttile;
plot(t.tr, d.tr, '--', 'LineWidth', 1.7); hold on;
plot(t.th, d.th, 'LineWidth', 1.7);
xline(11, ':k', 'Wind applied');
grid on; xlabel('Time (s)'); ylabel('\theta (rad)'); title('Pitch Tracking');
legend('Reference', 'Actual', 'Location', 'best');

formatFigure(fig);
exportgraphics(fig, fullfile(imageDir, 'mission_tracking.png'), 'Resolution', 220);
close(fig);

fig = figure('Color', 'w', 'Position', [80 80 1120 660]);
tiledlayout(2, 1, 'TileSpacing', 'compact', 'Padding', 'compact');

nexttile;
plot(t.fp, d.fp, 'LineWidth', 1.7); hold on;
plot(t.fm, d.fm, 'LineWidth', 1.7);
yline(6, '--r', 'Motor limit');
yline(0, ':k');
grid on; ylabel('Thrust per motor (N)'); title('Rotor-Pair Thrust Allocation');
legend('F_{+}', 'F_{-}', 'Location', 'best');

nexttile;
plot(t.T, d.T, 'LineWidth', 1.7); hold on;
plot(t.ta, d.ta, 'LineWidth', 1.5);
plot(t.w, d.w, 'LineWidth', 1.4);
grid on; xlabel('Time (s)'); ylabel('Value');
title('Delivered Inputs and Wind Disturbance');
legend('T_{actual} (N)', '\tau_{actual} (N m)', 'F_{wind} (N)', 'Location', 'best');

formatFigure(fig);
exportgraphics(fig, fullfile(imageDir, 'motor_thrust.png'), 'Resolution', 220);
close(fig);

metricsFile = fullfile(docsDir, 'mission_metrics.md');
fid = fopen(metricsFile, 'w');
fprintf(fid, '# Mission metrics\n\n');
fprintf(fid, '| Metric | Value |\n| --- | ---: |\n');
fprintf(fid, '| Final lateral error | %.4f m |\n', d.x(end) - d.xr(end));
fprintf(fid, '| Final altitude error | %.4f m |\n', d.z(end) - d.zr(end));
fprintf(fid, '| Peak lateral position | %.3f m |\n', max(d.x));
fprintf(fid, '| Peak altitude | %.3f m |\n', max(d.z));
windPeriod = t.th >= 20 & t.th <= 28;
fprintf(fid, '| Mean wind-rejection pitch (20-28 s) | %.4f rad |\n', mean(d.th(windPeriod)));
fprintf(fid, '| Maximum per-motor thrust | %.3f N |\n', max([d.fp(:); d.fm(:)]));
fprintf(fid, '| Minimum per-motor thrust | %.3f N |\n', min([d.fp(:); d.fm(:)]));
fclose(fid);

fprintf('Generated figures in %s\n', imageDir);
fprintf('Generated metrics in %s\n', metricsFile);

function [time, data] = readSignal(logsout, name)
    signal = logsout.getElement(name);
    values = signal.Values;
    if ~isa(values, 'timeseries')
        error('Signal %s is not stored as a timeseries.', name);
    end
    time = values.Time;
    data = squeeze(values.Data);
end

function formatFigure(fig)
    axesList = findall(fig, 'Type', 'axes');
    set(axesList, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', [0.65 0.65 0.65], 'GridAlpha', 0.35, ...
        'FontName', 'Arial', 'FontSize', 11);
    for ax = axesList'
        ax.Title.Color = 'k';
        ax.XLabel.Color = 'k';
        ax.YLabel.Color = 'k';
    end
    set(findall(fig, 'Type', 'legend'), 'Color', 'w', 'TextColor', 'k');
end

