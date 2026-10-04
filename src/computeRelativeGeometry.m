function Geometry = computeRelativeGeometry(Target, Missile)

    %% Relative Position
    relativeX   = Target.x - Missile.x;
    relativeY   = Target.y - Missile.y;
    range       = sqrt(relativeX^2 + relativeY^2);

    %% Relative Velocity
    relativeVelocityX = Target.speed*cos(Target.heading) - Missile.speed*cos(Missile.heading);
    relativeVelocityY = Target.speed*sin(Target.heading) - Missile.speed*sin(Missile.heading);

    %% Range Rate & Closing Speed
    rangeRate       = (relativeX*relativeVelocityX + relativeY*relativeVelocityY) / range;
    closingSpeed    = -rangeRate;

    %% LOS Angle & Rate
    losAngle    = atan2(relativeY, relativeX);
    losRate     = (relativeX*relativeVelocityY - relativeY*relativeVelocityX) / range^2;

    %% Outputs
    Geometry.range          = range;
    Geometry.rangeRate      = rangeRate;
    Geometry.closingSpeed   = closingSpeed;
    Geometry.losAngle       = losAngle;
    Geometry.losRate        = losRate;

end