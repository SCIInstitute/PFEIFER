function TSindices = fidsRemoveFiducial(TSindices,fidtype)

% FUNCTION fidsRemoveFiducial(TSindices,fidtype)
% OR       TSdata = fidsRemoveFiducial(TSdata,fidtype)
%
% DESCRIPTION
% This function adds a fiducial to a timeseries.
%
% INPUT
% TSindices         Index numbers into the TS cell-array
% TSdata            TS cell-array or TS-structure 
% fidtype           Type of the fiducial (strinf or number)
%
% OUTPUT
% TSdata            In case of direct data access the data is returned with
%                   the new fiducial added
%
% SEE ALSO fidsType

global TS;

if ischar(fidtype),
    fidtype = fidsType(fidtype);
end

if isnumeric(TSindices),
    for p=TSindices,
        if ~isfield(TS{p},'fids'),
            continue;
        end
       fids = TS{p}.fids;
        keep = [];
        for q=1:length(fids);
            if fids(q).type ~= fidtype, keep = [keep q]; end
        end
        TS{p}.fids = fids(keep);
    end
    return
end

if iscell(TSindices),
    for p=1:length(TSindices),
        if ~isfield(TSindices{p},'fids'),
            continue;
        end
        fids = TSindices{p}.fids;
        keep = [];
        for q=1:length(fids);
            if fids(q).type ~= fidtype, keep = [keep q]; end
        end
        TSindices{p}.fids = fids(keep);
    end 
    return
end

if isstruct(TSindices),
    if ~isfield(TSindices,'fids'),
        return;    
    end
     
    fids = TSindices.fids;
    keep = [];
    for q=1:length(fids);
        if fids(q).type ~= fidtype, keep = [keep q]; end
    end
    TSindices.fids = fids(keep);  
    return
end

