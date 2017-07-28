function newTSindices = tsSliceTS(TSindices,fstart,fend)
% FUNCTION [newTSindices] = tsSliceTS(TSindices,fstart,fend)
%          [newTSindices] = tsSliceTS(TSindices,[fstart:fend])
%          newdata = tsSliceTS(data,fstart,fend) 
%          newdata = tsSliceTS(data,[fstart:fend]) 
%
% DESCRIPTION
% This function takes a subset of the slices from the data. In works in various modes: 1)
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

    if nargin == 3,
       frames = fstart:fend;
    end
    if nargin == 2,
       frames = fstart(1);fstart(end);
    end
    if nargin < 1,
       msgError('You need to enter the frames you want to keep',5);
       return;
    end

    

    if isnumeric(TSindices),
        global TS;
        if nargout == 1,
            newTSindices = tsNew(length(TSindices));
            for p=1:length(TSindices),
                TS{newTSindices(p)} = TS{TSindices(p)};  
            end
            TSindices = newTSindices;
        end
        
        for p=1:length(TSindices),
            if nargin == 1,
                if isfield(TS{TSindices(p)},'timeframe'),
                    frames = TS{TSindices(p)}.timeframe;
                    frames = [frames(1):frames(end)];
                else
                    msgError('You need to enter the frames you want to keep',5);
                    return;
                end
            end
            numframes= length(frames);
            TS{TSindices(p)}.potvals = TS{TSindices(p)}.potvals(:,frames);
            TS{TSindices(p)}.numframes = numframes;
            audit = sprintf('|tsSliceTS Slice data, startframe: %d endframe %d ',frames(1),frames(end));
            TS{TSindices(p)}.audit = [TS{TSindices(p)}.audit audit];
            
            if isfield(TS{TSindices(p)},'fids')
                fids = TS{TSindices(p)}.fids;
                keep = [];
                for q=1:length(fids),
                    if (fids(q).value >= frames(1)) & (fids(q).value <= frames(end)),
                        keep = [keep q];
                        fids(q).value = fids(q).value - frames(1)+1;
                    end
                end
                TS{TSindices(p)}.fids = fids(keep);
            end
            if isfield(TS{TSindices(p)},'pacing'),
                pacing = TS{TSindices(p)}.pacing;
                pacing = pacing(find((pacing>=frames(1))&(pacing<=frames(end))));
                pacing = pacing -frames(1)+1;
                TS{TSindices(p)}.pacing = pacing;
            end
              
        end
    end

    if isstruct(TSindices),
        nTSindices{1} = TSindices;
        TSindices = nTSindices;
        clear nTSindices;
    end
   
    if iscell(TSindices),
       for p=1:length(TSindices),
           if nargin == 1,
               if isfield(TSindices{p},'timeframe'),
                   frames = TSindices{p}.timeframe;
                   frames = [frames(1):frames(end)];
                   % TSindices{p} = rmfield(TSindices{p},'timeframe');
               else
                   msgError('You need to enter the frames you want to keep',5);
                   return;
               end
           end
           numframes= length(frames);
           TSindices{p}.potvals = TSindices{p}.potvals(:,frames);
           TSindices{p}.numframes = numframes;
           audit = sprintf('|tsSliceTS Slice data, startframe: %d endframe %d ',frames(1),frames(end));
           TSindices{p}.audit = [TSindices{p}.audit audit];
           if isfield(TSindices{p},'fids')
               fids = TSindices{p}.fids;
               keep = [];
               for q=1:length(fids),
                   if (fids(q).value >= frames(1)) & (fids(q).value <= frames(end)),
                       keep = [keep q];
                       fids(q).value = fids(q).value - frames(1)+1;
                   end
               end
               TSindices{p}.fids = fids(keep);
           end
           if isfield(TSindices{p},'pacing'),
               pacing = TSindices{p}.pacing;
               pacing = pacing(find((pacing>=frames(1))&(pacing<=frames(end))));
               pacing = pacing -frames(1)+1;
               TSindices{p}.pacing = pacing;
           end
       end
       newTSindices = TSindices;
    end

    return