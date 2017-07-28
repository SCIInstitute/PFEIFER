function [Order,IOrder] = triReOrderPts(PtsOld,PtsNew)

% function [Order,IOrder] = triReOrderPts(PtsOld,PtsNew)
%
% This function matches by looking at the minimum distance
% which column of the old pts-file matches the new one
%
% Order the way the PtsNew file is order assuming the OldOne as standard
%

% JG Stinstra 2002

% Do so checking

%if size(PtsOld,2) ~= size(PtsNew,2),
%    error('Both pts-matrices have a different number of nodes');
%end

if size(PtsOld,1) ~=3,
    error('Three cartesian coordinates are required');
end

if size(PtsNew,1) ~=3,
    error('Three cartesian coordinates are required');
end


O = ones(1,size(PtsNew,2)); % just a simple help vector
Order = zeros(1,size(PtsOld,2)); % Just make me an empty array

for p = 1:size(PtsOld,2),
    distance = sum(((PtsOld(:,p)*O-PtsNew).^2),1); % just a complex writing of determining the distance to all points in NewPts, without bothering for the sqrt
    index = find(distance == min(distance));
    Order(p) = index(1); % just take the first one in case more are close
end

% check order whether there are number assigned twice

for p = 1:length(PtsNew),
    index = find(Order == p);
    if length(index) > 1,
        err = sprintf('%5d : is assigned never or more than once',p);
        error(err);
    elseif length(index) == 0,
        Order(end+1) = p;
    end
end

if nargout >1,
    IOrder = zeros(1,length(Order));
    IOrder(Order) = 1:length(Order);
end



return
