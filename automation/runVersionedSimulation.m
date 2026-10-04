function outputDirectory = runVersionedSimulation()
% Execute the existing main and export the figures it actually generates.
projectDirectory = fileparts(fileparts(mfilename('fullpath')));
originalDirectory = pwd;
directoryCleanup = onCleanup(@() cd(originalDirectory));
cd(projectDirectory);
runId = char(datetime('now','TimeZone','Asia/Seoul','Format','yyyy-MM-dd_HHmmss_SSS'));
outputDirectory = fullfile(projectDirectory,'results','v0.2.0',runId);
if exist(outputDirectory,'dir')
    error('Result directory already exists.');
end
mkdir(outputDirectory);
mkdir(fullfile(outputDirectory,'figures'));
mkdir(fullfile(outputDirectory,'data'));
mkdir(fullfile(outputDirectory,'logs'));
diary(fullfile(outputDirectory,'logs','simulation.log'));
diaryCleanup = onCleanup(@() diary('off'));
sourceDirectory = fullfile(outputDirectory,'data','source');
mkdir(sourceDirectory);
sourceFiles = dir(fullfile(projectDirectory,'*.m'));
for iSource = 1:numel(sourceFiles)
    copyfile(fullfile(projectDirectory,sourceFiles(iSource).name),sourceDirectory);
end
% main clears its workspace; use the base workspace to protect export state.
evalin('base','main');
SimulationResults = evalin('base','SimulationResults');
Config = evalin('base','Config');
save(fullfile(outputDirectory,'data','simulation_results.mat'),'SimulationResults','Config');
figures = findall(groot,'Type','figure');
[~,order] = sort([figures.Number]);
figures = figures(order);
labels = ["xy_trajectories","heading","range","los","bank_command","lateral_acceleration"];
figureFiles = strings(numel(figures),1);
for iFigure = 1:numel(figures)
    label = "figure";
    if iFigure <= numel(labels), label = labels(iFigure); end
    fileName = sprintf('%02d_%s',iFigure,label);
    figureFiles(iFigure) = string(fileName) + ".png";
    exportgraphics(figures(iFigure),fullfile(outputDirectory,'figures',figureFiles(iFigure)), ...
        'Resolution',150);
    savefig(figures(iFigure),fullfile(outputDirectory,'figures',[fileName '.fig']));
end
[reportFile,message] = fopen(fullfile(outputDirectory,'report.md'),'w','n','UTF-8');
if reportFile < 0, error('%s',message); end
reportCleanup = onCleanup(@() fclose(reportFile));
fprintf(reportFile,'# v0.2.0 development simulation\n\n');
fprintf(reportFile,'Run ID (Asia/Seoul): %s\n\nMATLAB: %s\n\n',runId,version);
fprintf(reportFile,'Executed existing main.m and visualizeSimulation.m. Source snapshot: data/source/.\n\n');
fprintf(reportFile,'Status: execution and figure export completed; guidance accuracy is not certified.\n\n');
fprintf(reportFile,'## Figures\n\n');
for iFigure = 1:numel(figures)
    fprintf(reportFile,'- [%s](figures/%s)\n',figures(iFigure).Name,figureFiles(iFigure));
end
fprintf(reportFile,'\n## Closest saved sample\n\n| Guidance | Time (s) | Range (m) |\n|---|---|---|\n');
for iResult = 1:numel(SimulationResults)
    result = SimulationResults(iResult);
    relative = result.data.target.stateHistory(:,1:2) - result.data.missile.stateHistory(:,1:2);
    [minRange,iClosest] = min(hypot(relative(:,1),relative(:,2)));
    fprintf(reportFile,'| %s | %.6f | %.9f |\n',result.name,result.time(iClosest),minRange);
end
fprintf(reportFile,'\nThese are sampled distances, not continuous closest-approach or hit verdicts.\n');
fprintf(reportFile,'\nHistorical figures: [legacy report](../../legacy_2026-10-02/report.md).\n');
fprintf('Simulation results: %s\n',outputDirectory);
end
