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


function TSindices = fidsRemoveFiducial(TSindices,fidtype)

% FUNCTION fidsRemoveFiducial(TSindices,fidtype)
% OR       TSdata = fidsRemoveFiducial(TSdata,fidtype)
%
% DESCRIPTION
% This function adds a fiducial to a timeseries.
%
% INPUT
% TSindices         Index numbers into the TS cell-array
% TSdata            TS cell-array or TS-structure 
% fidtype           Type of the fiducial (strinf or number)
%
% OUTPUT
% TSdata            In case of direct data access the data is returned with
%                   the new fiducial added
%
% SEE ALSO fidsType

global TS;

if ischar(fidtype)
    fidtype = fidsType(fidtype);
end

if isnumeric(TSindices)
    for p=TSindices
        if ~isfield(TS{p},'fids')
            continue;
        end
       fids = TS{p}.fids;
        keep = [];
        for q=1:length(fids)
            if fids(q).type ~= fidtype, keep = [keep q]; end
        end
        TS{p}.fids = fids(keep);
    end
    return
end

if iscell(TSindices)
    for p=1:length(TSindices)
        if ~isfield(TSindices{p},'fids')
            continue;
        end
        fids = TSindices{p}.fids;
        keep = [];
        for q=1:length(fids)
            if fids(q).type ~= fidtype, keep = [keep q]; end
        end
        TSindices{p}.fids = fids(keep);
    end 
    return
end

if isstruct(TSindices)
    if ~isfield(TSindices,'fids')
        return;    
    end
     
    fids = TSindices.fids;
    keep = [];
    for q=1:length(fids)
        if fids(q).type ~= fidtype, keep = [keep q]; end
    end
    TSindices.fids = fids(keep);  
    return
end

