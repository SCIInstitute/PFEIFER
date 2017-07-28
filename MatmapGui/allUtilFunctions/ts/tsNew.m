function TSindices = tsNew(number)
%  if TS={[], ts1, ts2, [], []},   then tsNew(3) returns [1,4,5], tsNew(1)
%  returns 1.    this functin doesnt change TS in any way.



% function TSindices = tsNew(number)
% 
% This function scan the TS global and locates empty spots, if
% no empty spots are found places at the end of the list are 
% returned
%
% INPUT
%  number    number of cells needed
%
% OUTPUT
%  TSindices positions of empty cells
%
% SEE tsDelete

global TS;

tsempty = []; 

if ~isempty(TS)
    for p = 1:length(TS), if isempty(TS{p}), tsempty = [tsempty p]; end, end
end

if length(tsempty) < number
    tsnew = length(TS)+1:length(TS)+number-length(tsempty);
    TSindices = [tsempty tsnew];
else
    TSindices = tsempty(1:number);    
end

% make sure that the indices point to fields that are actually there

for p=TSindices
    TS{p} = [];
end