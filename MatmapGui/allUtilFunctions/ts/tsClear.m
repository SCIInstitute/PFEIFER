function tsClear(TSindices)
% FUNCTION tsClear([TSindices])
%
% DESCRIPTION
% Clears the TS-structure if no indices are supplied
% otherwise it just clears the indices specified.
%
% INPUT
% TSindices     The indices of the TS-structures that
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

% This function clears the TS-structure properly

global TS;

if nargin == 0
    TS = {};
else
    for p = TSindices
        TS{p} = [];
    end    
end    