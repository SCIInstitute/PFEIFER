function Pos3 = triVector3(Pos4)
% function Pos3 = triVector3(Pos4)
%
% Strip the fourth redundant coordinate
% and go back to the cartesian coordinate system
%
% INPUT
% Pos4 - matrix with four vectors
%
% OUTPUT
% Pos3 - matrix with three vectors

% get the cartesian coordinates and multiply by the scale factor

Pos3 = Pos4(1:3,:).*([1 1 1]'*Pos4(4,:));

% c'est tout   
return

