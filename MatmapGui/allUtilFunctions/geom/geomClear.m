function geomClear(GEOMindices)
% FUNCTION geomClear([GEOMindices])
%
% DESCRIPTION
% Clears the GEOM-structure if no indices are supplied
% otherwise it just clears the indices specified.
%
% INPUT
% GEOMindices     The indices of the TS-structures that
%               need to be cleared.
%
% OUTPUT -
%
% NOTE
% There is nothing special to this function. Clearing fields
% yourself will work as well. Only this way you can clear
% multiple fields at once directly from an TSindices vector.
%
% SEE ALSO -

% This function clears the GEOM-structure properly

global GEOM;

if nargin == 0,
    GEOM = {};
else
    for p = GEOMindices,
        GEOM{p} = [];
    end    
end    
