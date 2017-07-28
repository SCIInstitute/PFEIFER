function Slices = triSortSlices(Pos,Slices,Normal,Origin)
% function Slices = triSortSlices(Pos,Slices,Normal,[Origin])
%
% This function sorts the points collected in one slice to rotate in an orderly fashion
% around a central point.
%
% INPUT
%  Pos    - Matrix containing the node positions;
%  Slices - the cell array that contains the indices of the nodes that form one contour
%  Normal - Normal to the plane in which the the nodes need to be ordered
%  Origin - Origin from which the rotation and radius of the points of the curve should be calculated
%           default - The gravitational center of the cloud of points contained in one slice
%
% OUTPUT
%  Slices - A cell array in which the indices are nicely ordered
%
% The algorithm is pretty easy. It just determines the angle and the radius of the points and
% uses the angle to sort the points



if nargin < 3,
    Normal = [0 0 1]; % Just assume the slices to be in the horizontal plane
end

for p=1:length(Slices),
    S = Slices{p}; % get the index array
    P = Pos(:,S); % get the corresponding position of the nodes
    if nargin < 4,
        Origin = mean(P,2); % compute the gravitational center of the cloud
    end
    P = triVector4(P); % go to 4-vector space / so I can align the data to the coordinate system I want
    RM = triRotMatrix4(Origin,Normal); % Get a matrix transformation for aligning data along prefered axis
    P = RM*P; % align data with origin and normal
    P = triVector3(P); % go back to cartesian space
    angle = atan(P(2,:)./P(1,:)); % determine the angle up to a factor pi
    
    index = find(P(1,:) < 0); % find angles where the angle is outside the range -pi/2 to pi/2 (range of atan)
    angle(index) = angle(index) + pi; % here add just pi to the number to the angles that need them
    
    [dummy,index] = sort(angle); % reuse index and sort the angle
                            % do not need the sorted numbers just their order
    S = S(index); % resort the data
    Slices{p} = S; % put data back in array and continue to the next one
end

return
    
