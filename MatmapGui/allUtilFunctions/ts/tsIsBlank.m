function result = tsIsBlank(TimeSeriesNum,Lead)

% FUNCTION result = tsIsBlank(TSindex,[lead])
%
% DESCRIPTION
% This function returns the indices of the blank leads or checks whether a lead is blank
%
% INPUT
% TSindex          number of timeseries you want to check
% lead             number(s) of lead(s). If none is specified the function 
%                  will return the indices of all the blank leads
%
% OUTPUT
% result           A vector with ones for the leads that are marked as blank.
%                  This vector corresponds to the lead vector in dimensions.
%                  In case no leads are specified all blank lead indices are returned
%
% SEE ALSO tsIsBad tsIsInterp

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
    result = bitand(TS{TimeSeriesNum}.leadinfo(Lead),2);
else
    result = find(bitand(TS{TimeSeriesNum}.leadinfo,2));
end
    