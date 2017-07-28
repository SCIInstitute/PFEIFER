function newTSindices = tsSliceTS(TSindices,fstart,fend)
% FUNCTION [newTSindices] = tsSliceTS(TSindices,fstart,fend)
%          [newTSindices] = tsSliceTS(TSindices,[fstart:fend])
%          newdata = tsSliceTS(data,fstart,fend) 
%          newdata = tsSliceTS(data,[fstart:fend]) 
%
% DESCRIPTION
% This function takes a subset of the slices from the data. It works in various modes: 1)
% supplying indices in the TS array will do the operation in the TS array, 2) if you request
% an output argument new entries will be made in the TS array with the sliced data, 3) You can
% supply the timeseries data directly and get back the data directly. 
%
% INPUT
% TSindices/data   You can provide the data directly or as indices of the TS array
% fstart           Frame to start with
% fend             Frame to end with
%
% OUTPUT 
% newTSindices     In case there is an output argument a new data set will be created
%                  with the sliced data, otherwise the original TS series will be sliced
% newdata          In case of providing the data directly the sliced data will be put on
%                  the output
%   
% SEE ALSO tsSplitTS

    if nargin == 2
        fend = fstart(end);
        fstart = fstart(1);
    end
    if nargin < 1
       msgError('You need to enter the frames you want to keep',5);
       return;
    end

    if isnumeric(TSindices)
        global TS;
        if nargout == 1
            newTSindices = tsNew(length(TSindices));
            for p=1:length(TSindices)
                TS{newTSindices(p)} = TS{TSindices(p)};  
            end
            TSindices = newTSindices;
        end
        
        for p=1:length(TSindices)
            if nargin == 1
                if isfield(TS{TSindices(p)},'selframes')
                    frames = TS{TSindices(p)}.selframes;
                    fstart = frames(1);
                    fend   = frames(end);
                else
                    fstart = 1;
                    fend = TS{TSindices(p)}.numframes;
                end
                if isfield(TS{TSindices(p)},'averagestart')
                    if ~isempty(TS{TSindices(p)}.averagestart)&&(TS{TSindices(p)}.averagemethod > 1)
                        fstart = TS{TSindices(p)}.averagestart;
                        fend   = TS{TSindices(p)}.averageend;
                    end
                end
            end
            
            if isempty(fstart)||isempty(fend)||(length(fstart)~=length(fend))
                msgError('The framestart and frameend do not have the same dimensions',5);
                return
            end
            
            numframes = fend(1)-fstart(1)+1;
            numleads = size(TS{TSindices(p)}.potvals,1);
            data = zeros(numleads,numframes);
            for q=1:length(fstart)
                if (fend(q)-fstart(q)+1) ~= numframes
                     msgError('Number of frames for averaging is NOT the same',5);
                    return
                end
                data = data+TS{TSindices(p)}.potvals(:,fstart(q):fend(q));
            end
            if length(fstart) > 1, data = data*(1/length(fstart)); end
            
            TS{TSindices(p)}.potvals = data;
            TS{TSindices(p)}.numframes = numframes;
            audit = [sprintf('|sigSlice Slice/Average data, startframe: ') sprintf('%d ',fstart) 'endframe: ' sprintf('%d ',fend)];
            TS{TSindices(p)}.audit = [TS{TSindices(p)}.audit audit];
            
            if isfield(TS{TSindices(p)},'fids')
                fids = TS{TSindices(p)}.fids;
                keep = [];
                for q=1:length(fids)
                    if (fids(q).value >= fstart(1)) && (fids(q).value <= fend(1))
                        keep = [keep q];
                        fids(q).value = fids(q).value - fstart(1)+1;
                    end
                end
                TS{TSindices(p)}.fids = fids(keep);
            end
            if isfield(TS{TSindices(p)},'pacing')
                pacing = TS{TSindices(p)}.pacing;
                pacing = pacing(find((pacing>=fstart(1))&(pacing<=fend(1))));
                pacing = pacing -fstart(1)+1;
                TS{TSindices(p)}.pacing = pacing;
            end
              
        end
    end

    
    if isstruct(TSindices)
        nTSindices{1} = TSindices;
        TSindices = nTSindices;
        clear nTSindices;
    end
   
    if iscell(TSindices)
       for p=1:length(TSindices)
            if nargin == 1
                if isfield(TSindices{p},'selframes')
                    frames = TSindices{p}.selframes;
                    fstart = frames(1);
                    fend   = frames(end);
                else
                    msgError('You need to enter the frames you want to keep',5);
                    return;
                end
                if isfield(TSindices{p},'averagestart')
                    if ~isempty(TSindices{p}.averagestart)&&(TSindices{p}.averagemethod > 1)
                        fstart = TSindices{p}.averagestart;
                        fend   = TSindices{p}.averageend;
                    end
                end
            end
            
            if isempty(fstart)||isempty(fend)||(length(fstart)~=length(fend))
                msgError('The framestart and frameend do not have the same dimensions',5);
                return
            end
            
            numframes = fend(1)-fstart(1)+1;
            numleads = size(TS{TSindices(p)}.potvals,1);
            data = zeros(numleads,numframes);
            for q=1:length(fstart)
                if (fend(q)-fstart(q)+1) ~= numframes
                     msgError('Number of frames for averaging is NOT the same',5);
                    return
                end
                data = data+TSindices{p}.potvals(:,fstart(q):fend(q));
            end
            if length(fstart) > 1, data = data*(1/length(fstart)); end
            
            TSindices{p}.potvals = data;
            TSindices{p}.numframes = numframes;
            audit = [sprintf('|sigSlice Slice/Average data, startframe: ') sprintf('%d ',fstart) 'endframe: ' sprintf('%d ',fend)];
            TSindices{p}.audit = [TSindices{p}.audit audit];
            
            if isfield(TSindices{p},'fids')
                fids = TSindices{p}.fids;
                keep = [];
                for q=1:length(fids)
                    if (fids(q).value >= fstart(1)) && (fids(q).value <= fend(1))
                        keep = [keep q];
                        fids(q).value = fids(q).value - fstart(1)+1;
                    end
                end
                TSindices{p}.fids = fids(keep);
            end
            if isfield(TSindices{p},'pacing')
                pacing = TSindices{p}.pacing;
                pacing = pacing(find((pacing>=fstart(1))&(pacing<=fend(1))));
                pacing = pacing -fstart(1)+1;
                TSindices{p}.pacing = pacing;
            end
        end
    end
    newTSindices = TSindices;
       

    return