function result = tsIsBad(TimeSeriesNum,Lead)
%returns result = find(bitand(TS{TimeSeriesNum}.leadinfo,1));  also alle
%index wo leadinfo ist 1

% FUNCTION result = tsIsBad(TSindex,lead)
%
% DESCRIPTION
% This function returns the indices of the bad leads or checks whether a lead is bad.
%
% INPUT
% TSindex          number of timeseries you want to check
% lead             number(s) of lead(s). If none is specified the function 
%                  will return the indices of the badleads
%
% OUTPUT
% result           A vector with ones for the leads that are marked as bad and zeros
%                  for the non-bad leads.
%                  In case no leads are specified all bad lead indices are returned.
%
% SEE ALSO tsIsBlank tsIsInterp

if isnumeric(TimeSeriesNum),
   global TS;
end

if isstruct(TimeSeriesNum),
   TS{1} = TimeSeriesNum;
   TimeSeriesNum = 1;
end

if iscell(TimeSeriesNum),
   TS = TimeSeriesNum;
   TimeSeriesNum = 1;
end


if nargin == 2,
    result = bitand(TS{TimeSeriesNum}.leadinfo(Lead),1);
else
    result = find(bitand(TS{TimeSeriesNum}.leadinfo,1));
end
    
return