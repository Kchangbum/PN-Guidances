function bankCmd = computeBankCommand(Environment, lateralAccelCmd)

    bankCmd = atan2(lateralAccelCmd, Environment.gravity);
    bankCmd = min(max(bankCmd, deg2rad(-45)), deg2rad(45));

end