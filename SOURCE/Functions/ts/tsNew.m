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


function TSindices = tsNew(number)
%  if TS={[], ts1, ts2, [], []},   then tsNew(3) returns [1,4,5], tsNew(1)
%  returns 1.    this functin doesnt change TS in any way.



% function TSindices = tsNew(number)
% 
% This function scan the TS global and locates empty spots, if
% no empty spots are found places at the end of the list are 
% returned
%
% INPUT
%  number    number of cells needed
%
% OUTPUT
%  TSindices positions of empty cells
%
% SEE tsDelete

global TS;

tsempty = []; 

if ~isempty(TS)
    for p = 1:length(TS), if isempty(TS{p}), tsempty = [tsempty p]; end, end
end

if length(tsempty) < number
    tsnew = length(TS)+1:length(TS)+number-length(tsempty);
    TSindices = [tsempty tsnew];
else
    TSindices = tsempty(1:number);    
end

% make sure that the indices point to fields that are actually there

for p=TSindices
    TS{p} = [];
end