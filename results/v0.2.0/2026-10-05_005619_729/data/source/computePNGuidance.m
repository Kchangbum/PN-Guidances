function lateralAccelCmd = computePNGuidance(Guidance, Geometry, Missile, guidanceType)

    switch guidanceType
        case "PPN"
            %% PPN guidance
            lateralAccelCmd = Guidance.navigationGain * Missile.speed * Geometry.losRate;
        case "TPN"
            losNormalAccelCmd = Guidance.navigationGain*Geometry.closingSpeed*Geometry.losRate;
            lateralAccelCmd   = losNormalAccelCmd*cos(Missile.heading - Geometry.losAngle);

        case "APN"
            targetLateralAccel = 1;
            lateralAccelCmd = Guidance.navigationGain * Missile.speed * Geometry.losRate ...
            + (Guidance.navigationGain / 2) * targetLateralAccel;
    end

end
