function [Pts,Fac,Channels] = triMergeNodes(Pts,Fac,Node1,Node2,Channels)
% FUNCTION [Pts,Fac,Channels] = triMergeNodes(Pts,Fac,Node1,Node2,Channels)
%
% DESCRIPTION
% Merge two points in an existing mesh.
%
% INPUT
%    Pts,Fac     define the original mesh
%    Node1,Node2 are the nodes to be merged, in the process Node2 will be removed
%
% OUTPUT
%    Pts,Fac     the new mesh

% Find Node2 entries

I2 = find(Fac==Node2);

% Set Node2 = Node1

Fac(I2) = Node1;

% Prepare to drop point Node2

I = 1:size(Pts,2);
I = find(I ~= Node2);

% I should be a vector with indices which contain every index except that one for Node2

Iinv = zeros(1,size(Pts,2));
Iinv(I) = 1:length(I);

% Iinv is the inverse vector for I, thus Iinv(I(A)) = A

% remove a point from Pts
% and renumber Fac at the same time

Pts = Pts(:,I);
Fac = Iinv(Fac);

if nargin > 4,
    Channels = Channels(I);
end    

% now discard the triangles with a double entry

I1 = find(Fac(1,:)==Fac(2,:)); I2 = find(Fac(1,:)==Fac(3,:)); I3 = find(Fac(2,:)==Fac(3,:));
I = [I1 I2 I3];

if ~isempty(I),

% some triangles need to be discarded
% the idea is to make vector with ones and set those to zero that represent the index
% of the triangles to be removed
% using find again only those indices remain that are non-zero

	index = ones(1,size(Fac,2));
	index(I) = 0;
	index = find(index);
	Fac = Fac(:,index);
end

% This should be it
