function GEOMindices = geomDelete(number)
% FUNCTION GEOMindices = geomDelete(number)
% 
% DESCRIPTION
% This function deletes entries from the GEOM-structure
%
% INPUT
% TSindices           positions of cells to be deleted
%
% OUTPUT -
%
% SEE ALSO geomClear geomNew 

global GEOM;

for p=number, GEOM{p} = []; end % empty matrix

return
