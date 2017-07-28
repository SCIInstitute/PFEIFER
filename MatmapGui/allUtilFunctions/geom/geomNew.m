function GEOMindices = geomNew(number)
% function GEOMindices = geomNew(number)
% 
% DESCRIPTION
% This function scans the GEOM global and locates empty spots, if
% no empty spots are found, places at the end of the list are 
% returned
%
% INPUT
% number          number of cells needed
%
% OUTPUT
% GEOMindices     positions of empty cells
%
% SEE ALSO geomDelete

global GEOM;

geomempty = []; 

if ~isempty(GEOM),
    for p = 1:length(GEOM), if isempty(GEOM{p}), geomempty = [geomempty p]; end, end, 
end

if length(geomempty) < number, 
    geomnew = length(GEOM)+1:length(GEOM)+number-length(geomempty);
    GEOMindices = [geomempty geomnew];
else
    GEOMindices = geomempty(1:number);    
end

% make sure that the indices point to fields that are actually there

for p=GEOMindices,
    GEOM{p} = [];
end

return