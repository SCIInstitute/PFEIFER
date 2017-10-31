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


function TSindices = fidsAddFiducial(TSindices,fidvalue,fidtype,fidset)

% FUNCTION fidsAddFiducial(TSindices,fidvalue,fidtype,[fidset])
% OR       TSdata = fidsAddFiducial(TSdata,fidvalue,fidtype,[fidset])
%
% DESCRIPTION
% This function adds a fiducial to a timeseries.
%
% INPUT
% TSindices         Index numbers into the TS cell-array
% TSdata            TS cell-array or TS-structure 
% fidvalue          Value of the new fiducial
% fidtype           Type of the fiducial (strinf or number)
% [fidset]          To which fidset this fiducial belongs (default: matlab generated fiducials)
%
% OUTPUT
% TSdata            In case of direct data access the data is returned with
%                   the new fiducial added
%
% SEE ALSO fidsType

if nargin == 3
    fidset = 0;
end

global TS;

if ischar(fidtype)
    fidtype = fidsType(fidtype);
end


for p=TSindices
    if ~isfield(TS{p},'fids')
        TS{p}.fids =[];
    end
    if ~isfield(TS{p},'fidset')
        TS{p}.fidset = {};
    end
    TS{p}.fids(end+1).value = fidvalue;
    TS{p}.fids(end).type = fidtype;
    TS{p}.fids(end).fidset = fidset;
    return;
end




