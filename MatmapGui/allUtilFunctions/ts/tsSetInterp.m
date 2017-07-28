function TSindices = tsSetInterp(TSindices,lead)

% FUNCTION TSindices = tsSetInterp(TSindices,lead)
%          TSdata    = tsSetInterp(TSdata,lead)
%
% DESCRIPTION
% This function sets the interpolation lead markers. This function does not
% make a new copy of the data.
%
% INPUT
% TSindices        number of timeseries
% lead             number(s) of lead(s). 
%
% OUTPUT 
% -
% SEE ALSO tsSetBlank tsSetBad

if isempty(lead), return; end

if isnumeric(TSindices),
    global TS;
    for p=TSindices,
        TS{p}.leadinfo(lead) = bitor(TS{p}.leadinfo(lead),4);
     end
end

if isstruct(TSindices),
    TSindices.leadinfo(lead) = bitor(TSindices.leadinfo(lead),4);
end

if iscell(TSindices),
    for p = 1:length(TSindices),
        TSindices{p}.leadinfo(lead) = bitor(TSindices{p}.leadinfo(lead),4);  
    end
end

return


