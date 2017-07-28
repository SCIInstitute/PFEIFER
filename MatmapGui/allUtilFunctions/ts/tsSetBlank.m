function TSindices = tsSetBlank(TSindices,lead)

% FUNCTION TSindices = tsSetBlank(TSindices,lead)
%          TSdata    = tsSetBlank(TSdata,lead)
%
% DESCRIPTION
% This function sets the blank lead markers. This function does not
% make a new copy of the data.
%
% INPUT
% TSindices        number of timeseries
% lead             number(s) of lead(s). 
%
% OUTPUT 
% -
% SEE ALSO tsSetBlank tsSetInterp

if isempty(lead), return; end

if isnumeric(TSindices)
    global TS;
    for p=TSindices
        TS{p}.leadinfo(lead) = bitor(TS{p}.leadinfo(lead),2);
    end
    TS{p}.leadinfo(lead)
end

if isstruct(TSindices)
    TSindices.leadinfo(lead) = bitor(TSindices.leadinfo(lead),2);
end

if iscell(TSindices)
    for p = 1:length(TSindices)
        TSindices{p}.leadinfo(lead) = bitor(TSindices{p}.leadinfo(lead),2);  
    end
end

return


