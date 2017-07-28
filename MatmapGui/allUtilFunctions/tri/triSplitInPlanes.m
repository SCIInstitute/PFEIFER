function CPos = triSplitInPlanes(Pos, Origin, Normal, Step)

% function CPos = triSplitInPlanes(Pos, Origin, Normal, Step)
%
% this function splits the data into splices and just looks in which 
% slice the nodes should be.
%
% using a least squares fit the distance to planes is determined, and the point
% is grouped in the plane to which it is closest
%
% INPUT
% Pos - position file (pts file)
% Origin - Where to start (vector)
% Normal - Where are the vectors normal to (vector)
% Step   - Vector describing where along this normal planes have to be centered 
%
% OUTPUT
% CPos, Cell array with in each cell indeces to a group of points in the same plane


Pos4 = triVector4(Pos); % go to opengl like coordinate system

RM = triRotMatrix4(Origin,Normal); % Get a matrix for alignment with the specified coordinate system

Pos4 = RM*Pos4; % Align system

% translations and rotations have been done
% lets go back to a 3 cartensian coordinate system

Pos = triVector3(Pos4); % It is now aligned along the z-axis

Z = Pos(3,:); % get z-coordinates;  

CPos = cell(1,length(Step));

numPos = size(Pos,2);

% loop determining in which plane a point belongs
% I do not use the square of the least squares, but the modulus should give the same result
% Algorithm : determine the distance to each plane, choose the minimum one and add the index number to the cell

for p = 1:numPos,
	A = abs(Z(p)-Step);
	index = find(A == min(A));
	CPos{index(1)} = [CPos{index(1)} p];
end

return

