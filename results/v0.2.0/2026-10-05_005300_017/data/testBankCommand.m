function TestResults = testBankCommand()
% Verify zero command and both bank limits. Angles are in radians.
Environment.gravity = 9.81;
testNames = ["Zero command"; "Upper limit"; "Lower limit"];
accelInputs = [0; 1000; -1000];
expected = deg2rad([0; 45; -45]);
actual = zeros(3,1);
for iTest = 1:numel(accelInputs)
    actual(iTest) = computeBankCommand(Environment, accelInputs(iTest));
end
tolerance = 1e-10;
passed = isfinite(actual) & abs(actual - expected) <= tolerance;
TestResults = table(testNames, accelInputs, expected, actual, passed, ...
    'VariableNames', {'name','accelInput','expectedRad','actualRad','passed'});
end
