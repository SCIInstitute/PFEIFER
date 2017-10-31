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


function tsClear(TSindices)
% FUNCTION tsClear([TSindices])
%
% DESCRIPTION
% Clears the TS-structure if no indices are supplied
% otherwise it just clears the indices specified.
%
% INPUT
% TSindices     The indices of the TS-structures that
%               need to be cleared.
%
% OUTPUT -
%
% NOTE
% There is nothing special to this function. Clearing fields
% yourself will work as well. Only this way you can clear
% multiple fields at once directly from an TSindices vector.
%
% SEE ALSO -

% This function clears the TS-structure properly

global TS;

if nargin == 0
    TS = {};
else
    for p = TSindices
        TS{p} = [];
    end    
end    