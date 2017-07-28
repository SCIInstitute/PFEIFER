function TSindices = tsInitNew(number)
% FUCNTION TSindices = tsInitNew(number)
% 
% DESCRIPTION
% This function scans the TS global and locates empty spots, if
% no empty spots are found, places at the end of the list are 
% returned. The function creates an empty TS structure as well.
%
% INPUT
% number         number of new cells needed
%
% OUTPUT
% TSindices      positions of empty cells in the TS cellarray
%
% SEE ALSO tsNew tsDelete tsClear

global TS;

tsempty = []; for p = 1:length(TS), if isempty(TS{p}), tsempty = [tsempty p]; end, end

if length(tsempty) < number, 
    tsnew = length(TS)+1:length(TS)+number-length(tsempty);
    TSindices = [tsempty tsnew];
else
    TSindices = tsempty(1:number);    
end

for p=TSindices,
    TS{p}.filename = '';
    TS{p}.label = '';
    TS{p}.potvals = [];
    TS{p}.numleads = 0;
    TS{p}.numframes = 0;
    TS{p}.leadinfo = [];
    TS{p}.unit = 'mV';
    TS{p}.geom =[];
    TS{p}.geomfile = '';
    TS{p}.audit ='';
    TS{p}.expid ='';
    TS{p}.text  ='';
    TS{p}.newfileext = '';
    
    fids = struct('value',[],'type',[],'fidset',[]);
    fids(1) = [];
    TS{p}.fids = fids;
    TS{p}.fidset = {};
end
