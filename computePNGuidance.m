function lateralAccelCmd = computePNGuidance(Guidance, Geometry, Missile)
    %% PPN guidance
    lateralAccelCmd = Guidance.navigationGain * Missile.speed * Geometry.losRate;

    %% TPN Guidance
    % losNormalAccelCmd = Guidance.navigationGain*Geometry.closingSpeed*Geometry.losRate;
    % lateralAccelCmd   = losNormalAccelCmd*cos(Missile.heading - Geometry.losAngle);
end