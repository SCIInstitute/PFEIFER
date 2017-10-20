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
global TS;

%%%% get the fids structures
if isnumeric(TSindex)
    if TSindex > length(TS), msgError('TSindex out of range',5); return; end
    if isfield(TS{TSindex},'fids'), fids  = TS{TSindex}.fids; end
end


% Now print the fiducials

values = [];

if isempty(fids), return; end
if ischar(type), type = fidsType(type); end

localf = [];
globalf = [];


%%%% loop through fids structure to find type
for p=1:length(fids)
    if (fids(p).type ~= type)
        continue;
    end
    
    if length(fids(p).value) == 1  %if only one value is given, it must be a global one
        globalf = [globalf fids(p).value];
    else   %local fids
        localf(1:length(fids(p).value),end+1) = reshape(fids(p).value,length(fids(p).value),1);
    end
end

if ~isempty(localf)
    values = localf;
    if ~isempty(globalf)
        values = [values ones(size(values,1),1)*globalf];
    end
else
    values = globalf;
end


return