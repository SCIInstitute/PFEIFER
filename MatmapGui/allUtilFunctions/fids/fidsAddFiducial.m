function TSindices = fidsAddFiducial(TSindices,fidvalue,fidtype,fidset)

% FUNCTION fidsAddFiducial(TSindices,fidvalue,fidtype,[fidset])
% OR       TSdata = fidsAddFiducial(TSdata,fidvalue,fidtype,[fidset])
%
% DESCRIPTION
% This function adds a fiducial to a timeseries.
%
% INPUT
% TSindices         Index numbers into the TS cell-array
% TSdata            TS cell-array or TS-structure 
% fidvalue          Value of the new fiducial
% fidtype           Type of the fiducial (strinf or number)
% [fidset]          To which fidset this fiducial belongs (default: matlab generated fiducials)
%
% OUTPUT
% TSdata            In case of direct data access the data is returned with
%                   the new fiducial added
%
% SEE ALSO fidsType

if nargin == 3,
    fidset = 0;
end

global TS;

if ischar(fidtype),
    fidtype = fidsType(fidtype);
end

if isnumeric(TSindices),
    for p=TSindices,
        if ~isfield(TS{p},'fids'),
            TS{p}.fids =[];
        end
        if ~isfield(TS{p},'fidset'),
            TS{p}.fidset = {};
        end
        TS{p}.fids(end+1).value = fidvalue;
        TS{p}.fids(end).type = fidtype;
        TS{p}.fids(end).fidset = fidset;
        return;
    end
end

if iscell(TSindices),
    for p=1:length(TSindices),
        if ~isfield(TSindices{p},'fids'),
            TSindices{p}.fids =[];
        end
        if ~isfield(TSindices{p},'fidset'),
            TSindices{p}.fidset = {};
        end
        TSindices{p}.fids(end+1).value = fidvalue;
        TSindices{p}.fids(end).type = fidtype;
        TSindices{p}.fids(end).fidset = fidset;
        return
    end 
end

if isstruct(TSindices),
    if ~isfield(TSindices,'fids'),
        TSindices.fids =[];
    end
    if ~isfield(TSindices,'fidset'),
        TSindices.fidset = {};
    end
    TSindices.fids(end+1).value = fidvalue;
    TSindices.fids(end).type = fidtype;
    TSindices.fids(end).fidset = fidset;
    return
end

return
