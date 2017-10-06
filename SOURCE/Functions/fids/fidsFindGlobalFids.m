function values = fidsFindGlobalFids(TSindex,type,fidset)
% FUNCTION values = fidsFindGlobalFids(TSindex,type,[fidset])
% OR       values = fidsFindGlobalFids(TSdata,type,[fidset])
%
% DESCRIPTION
% Finds fiducials in a time series
%
% INPUT
% TSindex       The index into the TS cell array that contains the data
% TSdata        A struct or cell-array containing the data
% type          The type of fiducial
% fidset        The fidset to search in
%
% OUTPUT
% value         A [1xm] vector with global fiducials 
%
% SEE ALSO fidsType

global TS;

fids = [];
fidset = {};
values = [];

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

if isempty(fids), return; end

if ischar(type), type = fidsType(type); end

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
    if length(fids(p).value) == 1,
        globalf = [globalf fids(p).value];
    end
end


values = globalf;


return