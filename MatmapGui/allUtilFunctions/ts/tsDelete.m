function TSindices = tsDelete(number)
% FUNCTION TSindices = tsDelete(number)
% 
% DESCRIPTION
% This function deletes entries from the TS-structure
%
% INPUT
% TSindices           positions of cells to be deleted
%
% OUTPUT -
%
% SEE ALSO tsClear tsNew tsInitNew

global TS;
for p=number, TS{p} = []; end % empty matrix
return
