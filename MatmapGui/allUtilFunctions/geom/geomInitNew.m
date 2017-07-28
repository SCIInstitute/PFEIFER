function GEOMindices = geomInitNew(number)
% FUCNTION GEOMindices = geomInitNew(number)
% 
% DESCRIPTION
% This function scans the GEOM global and locates empty spots, if
% no empty spots are found, places at the end of the list are 
% returned. The function creates an empty GEOM structure as well.
%
% INPUT
% number         number of new cells needed
%
% OUTPUT
% GEOMSindices      positions of empty cells in the GEOM cellarray
%
% SEE ALSO geomNew 

global GEOM;

tsempty = []; for p = 1:length(GEOM), if isempty(GEOM{p}), tsempty = [tsempty p]; end, end

if length(tsempty) < number, 
    tsnew = length(GEOM)+1:length(GEOM)+number-length(tsempty);
    GEOMindices = [tsempty tsnew];
else
    GEOMindices = tsempty(1:number);    
end

for p=GEOMindices,
    GEOM{p}.pts = [];
    GEOM{p}.fac = [];
    GEOM{p}.channels = [];
end
