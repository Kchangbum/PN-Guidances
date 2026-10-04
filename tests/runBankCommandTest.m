function outputDirectory = runBankCommandTest()
% Run the example test and preserve results in a new versioned directory.
projectDirectory = fileparts(fileparts(mfilename('fullpath')));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(fullfile(projectDirectory,'src'), fullfile(projectDirectory,'tests','unit'));
runId = char(datetime('now','TimeZone','Asia/Seoul', ...
    'Format','yyyy-MM-dd_HHmmss_SSS'));
outputDirectory = fullfile(projectDirectory,'results','v0.2.0',runId);
if exist(outputDirectory,'dir')
    error('Result directory already exists: %s', outputDirectory);
end
mkdir(outputDirectory);
mkdir(fullfile(outputDirectory,'data'));
mkdir(fullfile(outputDirectory,'figures'));
mkdir(fullfile(outputDirectory,'logs'));
reportPath = fullfile(outputDirectory,'report.md');
[reportFile,message] = fopen(reportPath,'w','n','UTF-8');
if reportFile < 0
    error('Cannot create report: %s',message);
end
reportCleanup = onCleanup(@() fclose(reportFile));
fprintf(reportFile,'# Bank command test\n\n');
fprintf(reportFile,'Version: v0.2.0 development\n\nRun ID (Asia/Seoul): %s\n\n',runId);
fprintf(reportFile,'MATLAB: %s\n\nScope: zero command and +/-45 degree limits only.\n\n',version);
fprintf(reportFile,'Tolerance: 1e-10 rad. No guidance performance verdict or simulation figures.\n\n');
% Preserve the exact tested function and test source alongside the data.
copyfile(fullfile(projectDirectory,'src','computeBankCommand.m'), ...
    fullfile(outputDirectory,'data','computeBankCommand.m'));
copyfile(fullfile(projectDirectory,'tests','unit','testBankCommand.m'), ...
    fullfile(outputDirectory,'data','testBankCommand.m'));
try
    TestResults = testBankCommand();
catch testError
    fprintf(reportFile,'Status: ERROR\n\n%s\n',testError.message);
    rethrow(testError);
end
writetable(TestResults,fullfile(outputDirectory,'data','test_results.csv'));
save(fullfile(outputDirectory,'data','test_results.mat'),'TestResults');
fprintf(reportFile,'| Test | Input (m/s^2) | Expected (deg) | Actual (deg) | Verdict |\n');
fprintf(reportFile,'|---|---|---|---|---|\n');
for iTest = 1:height(TestResults)
    verdict = 'FAIL';
    if TestResults.passed(iTest)
        verdict = 'PASS';
    end
    fprintf(reportFile,'| %s | %g | %.12g | %.12g | %s |\n', ...
        char(TestResults.name(iTest)),TestResults.accelInput(iTest), ...
        rad2deg(TestResults.expectedRad(iTest)), ...
        rad2deg(TestResults.actualRad(iTest)),verdict);
end
fprintf(reportFile,'\nHistorical figures: ../../legacy_2026-10-02/report.md\n');
disp(TestResults);
fprintf('Results: %s\n',outputDirectory);
assert(all(TestResults.passed),'Bank command verification failed; see saved report.');
end
