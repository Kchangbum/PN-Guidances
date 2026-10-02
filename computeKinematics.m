function stateDerivative = computeKinematics(~, state, Vehicle, Wind, Environment, bankCmd)
    %% State
    heading     = state(3);

    %% Kinematics
    if Vehicle.speed == 0
        xRate       = 0;
        yRate       = 0;
        headingRate = 0;
    else
        xRate       = Vehicle.speed*cos(heading) + Wind.speed*cos(Wind.direction);
        yRate       = Vehicle.speed*sin(heading) + Wind.speed*sin(Wind.direction);
        headingRate = Environment.gravity*tan(bankCmd)/Vehicle.speed;
    end

    %% State Derivative
    stateDerivative = [xRate; yRate; headingRate];

end