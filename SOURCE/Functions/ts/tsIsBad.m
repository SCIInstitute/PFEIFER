% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


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