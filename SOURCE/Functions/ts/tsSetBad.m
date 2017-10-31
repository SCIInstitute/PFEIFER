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


function TSindices = tsSetBad(TSindices,lead)



% FUNCTION TSindices = tsSetBad(TSindices,lead)
%          TSdata    = tsSetBad(TSdata,lead)
%
% DESCRIPTION
% This function sets the bad lead markers. This function does not
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
        TS{p}.leadinfo(lead) = 1;
        
        disp('size of lead')
        size(lead)
        disp('size of leadinfor')
        size(TS{p}.leadinfo)
    end
end

if isstruct(TSindices)
    TSindices.leadinfo(lead) = 1;
end

if iscell(TSindices)
    for p = 1:length(TSindices)
        TSindices{p}.leadinfo(lead) = 1;  
    end
end

return


