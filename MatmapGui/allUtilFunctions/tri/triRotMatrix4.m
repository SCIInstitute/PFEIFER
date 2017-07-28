function RM = triRotMatrix4(Origin,Normal)

% function RM = triRotMatrix4(Origin,Normal)
%
% This function creates an opengl like matrix rotating
% around the origin and pointing the normal along the z-axis
%
% RM is the rotation matrix (4x4)

% Origin determines a point on the plane of intersection
% and Normal is the normal on the plane of intersection

% Assume algorithm works in z direction
% rotate system so it will be in the z-axis

if size(Origin,2) > 1, Origin = Origin'; end
if size(Normal,2) > 1, Normal = Normal'; end

% Translation matrix

% First determine the four dimensinal translation matrix
TrM = eye(4);
TrM([1:3],4) = -Origin;

% Rotation matrix

Normal = Normal/norm(Normal);
CosTheta0 = Normal(3);
SinTheta0 = sqrt(1-CosTheta0^2);
Rxy0 = norm(Normal([1 2]));
if Rxy0 > 0,
   CosPhi0 = Normal(1)/Rxy0;
   SinPhi0 = Normal(2)/Rxy0;
else
   CosPhi0 = 1;
   SinPhi0 = 0;
end
% rotate around z-axis with angle -Phi0
RPhi0 = [CosPhi0 SinPhi0 0;  -SinPhi0 CosPhi0 0; 0 0 1];
% rotate around y-axis with angle -Theta0
RTheta0 = [CosTheta0 0 (-SinTheta0); 0 1 0; SinTheta0 0 CosTheta0];
RotM = eye(4);
RotM([1:3],[1:3]) = RTheta0*RPhi0;

% first translation and then rotation
RM = RotM*TrM;
return
