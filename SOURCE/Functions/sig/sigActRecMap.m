% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


function [TSmapindex, success] = sigActRecMap(TSindeces,~)
% - get act and rec from TS{TSindex}.fid
% - create datamap=[ act; rec; ari=act-rec]
% - place a new ts in TS, that is a copy of the input ts, but with
% potvals=datamap
% return index of the new 'act/rec' ts

TSmapindex = [];

global TS;

for TSidx=TSindeces

    %%%% get act, ref and rec: nx1 vectors that contain the fids                     
    
    if isfield(TS{TSidx},'fids')
        fids=TS{TSidx}.fids;
    else
        success=0; 
        msg=sprintf('There are no fiducials for the file %s. Cannot do activation/recovery maps. Aborting...',TS{TSidx}.filename);
        errordlg(msg)
        return
    end
    actIdx=find([fids.type] == 10);

    if ~isempty(actIdx)
        act = fids(actIdx).value;
    else
        success=0; 
        msg=sprintf('There are no activation values for the file %s. Cannot do activation/recovery maps. Select ''Auto Detect Activation'' or determine activations manually. Aborting...',TS{TSidx}.filename);
        errordlg(msg)
        return
    end
    recIdx=find([fids.type] == 13);

    if ~isempty(recIdx)
        rec = fids(recIdx).value;
    else
        success=0;
        msg=sprintf('There are no recovery values for the file %s. Cannot do recovery maps. Select ''Auto Detect Recovery'' or determine recoveries manually. Aborting..',TS{TSidx}.filename);
        errordlg(msg)
        return
    end

    if length(act) == length(rec)
        ari = rec-act; 
    else
        ari = [];    
    end


    %%%% create datamap=[ act; rec; ari=act-rec]
    numchannels = size(TS{TSidx}.potvals,1);
    datamap = zeros(numchannels,3);

    if ~isempty(act), if length(act) == numchannels, datamap(:,1) = act; end, end
    if ~isempty(rec), if length(rec) == numchannels, datamap(:,2) = rec; end, end
    if ~isempty(ari), if length(ari) == numchannels, datamap(:,3) = ari; end, end


    %%%% place a new ts in TS, that is a copy of the input ts,
    %%%% except that potvals are changed to datamap.
    q = tsNew(1);
    TS{q} = TS{TSidx};
    TS{q}.potvals = datamap;
    TS{q}.numleads = numchannels;
    TS{q}.numframes = 3;
    TS{q}.pacing  = [];
    TS{q}.fids = [];
    TS{q}.fidset = {};
    TS{q}.audit = [TS{q}.audit '| Activation/Recovery/ARInterval map'];

    TSmapindex = [TSmapindex q];
end

success = 1;