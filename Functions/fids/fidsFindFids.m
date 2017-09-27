function values = fidsFindFids(TSindex,type,fidset)
% FUNCTION values = fidsFindFids(TSindex,type,[fidset])
% OR       values = fidsFindFids(TSdata,type,[fidset])
%
% DESCRIPTION
% Finds fiducials in a time series. For finding only local/global fiducials
% use fidsFindLocalFids/fidsFindGlobalFids. A local fiducial has an entry for each
% channel, whereas a global one has only one fiducial for all channels.
%
% INPUT
% TSindex       The index into the TS cell array that contains the data
% TSdata        A struct or cell-array containing the data
% type          The type of fiducial
% fidset        The fidset to search in
%
% OUTPUT
% value         A [1xm] vector for global fiducials or a [nxm] matrix in
%               case local fiducials are defined as well
%
% SEE ALSO fidsType fidsFindGlobalFids fidsFindLocalFids

fids = [];
fidset = {};
global TS;

if iscell(TSindex),
    if length(TSindex) > 1, msgError('This function only works with one timeseries only',5); return; end
    TSindex = TSindex{1};
end

if isstruct(TSindex),
    if isfield(TSindex,'fids'), fids  = TSindex.fids; end
    if isfield(TSindex,'fidset'), fidset = TSindex.fidset; end
end

if isnumeric(TSindex)
   
    if TSindex > length(TS), msgError('TSindex out of range',5); return; end
    if isfield(TS{TSindex},'fids'), fids  = TS{TSindex}.fids; end
    if isfield(TS{TSindex},'fidset'), fidset = TS{TSindex}.fidset; end
end

% Now print the fiducials

values = [];

if isempty(fids), return; end
if ischar(type), type = fidsType(type); end

localf = [];
globalf = [];

for p=1:length(fids),
    if (nargin == 3),
        if ((fids(p).type ~= type)|(fids(p).fidset ~= fidset)),
            continue;
        end
    else
        if (fids(p).type ~= type),
            continue;
        end
    end
    if length(fids(p).value) == 1,   %if only one value is given, it must be a global one
        globalf = [globalf fids(p).value];
    else   %local fids
        localf(1:length(fids(p).value),end+1) = reshape(fids(p).value,length(fids(p).value),1);
    end
end

if ~isempty(localf),
    values = localf;
    if ~isempty(globalf),
        values = [values ones(size(values,1),1)*globalf];
    end
else
    values = globalf;
end


return