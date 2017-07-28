function result = tsIsInterp(TimeSeriesNum,Lead)

% FUNCTION result = tsIsInterp(TSindex,[lead])
%
% DESCRIPTION
% This function returns the indices of the interpolated leads or checks whether a lead is interpolated
%
% INPUT
% TSindex          number of timeseries you want to check
% lead             number(s) of lead(s). If none is specified the function 
%                  will return the indices of the interpolated leads
%
% OUTPUT
% result           A vector with ones for the leads that are marked as interpolated. In case no
%                  leads are specified all interpolated lead indices are returned
%
% SEE ALSO tsIsBlank tsIsBad

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
    result = bitand(TS{TimeSeriesNum}.leadinfo(Lead),4);
else
    result = find(bitand(TS{TimeSeriesNum}.leadinfo,4));
end