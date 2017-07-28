function fidsListFids(TSindex)
% FUNCTION fidsListFids(TSindex)
% OR       fidsListFids(TSdata)
%
% DESCRIPTION
% List the fiducials in a time series on screen
%
% INPUT
% TSindex       The index into the TS cell array that contains the data
% TSdata        A struct or cell-array containing the data
%
% OUTPUT
% -
%
% SEE ALSO fidsType

fids = [];
fidset = {};

if iscell(TSindex),
    if length(TSindex) > 1, msgError('This function only works with one timeseries only',5); return; end
    TSindex = TSindex{1};
end

if isstruct(TSindex),
    if isfield(TSindex,'fids'), fids  = TSindex.fids; end
    if isfield(TSindex,'fidset'), fidset = TSindex.fidset; end
end

if isnumeric(TSindex)
    global TS;
    if TSindex > length(TS), msgError('TSindex out of range',5); return; end
    if isfield(TS{TSindex},'fids'), fids  = TS{TSindex}.fids; end
    if isfield(TS{TSindex},'fidset'), fidset = TS{TSindex}.fidset; end
end

% Now print the fiducials

if isempty(fids), return; end

fprintf(1,'Fiducial     - Type       - Fidset     \n');
for p=1:length(fids),
        if length(fids(p).value) > 1,
            fprintf(1,'[local values] ');
        else
            fprintf(1,' %8.4f  ',fids(p).value);
        end
        fprintf(1,'   %-10s  ',fidsType(fids(p).type));
        fprintf(1,'   %d   \n',fids(p).fidset);
end
   

return