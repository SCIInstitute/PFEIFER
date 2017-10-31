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



function values = fidsFindFids(TSindex,type,~)
% FUNCTION values = fidsFindFids(TSindex,type,[fidset])
% OR       values = fidsFindFids(TSdata,type,[fidset])
%
% DESCRIPTION
% Finds fiducials in a time series. For finding only local/global fiducials
% use fidsFindLocalFids/fidsFindGlobalFids. A local fiducial has an entry for each
% channel, whereas a global one has only one fiducial for all channels.
%
% INPUT
% TSindex       The index into the TS cell array that contains the data
% TSdata        A struct or cell-array containing the data
% type          The type of fiducial
% fidset        The fidset to search in
%
% OUTPUT
% value         A [1xm] vector for global fiducials or a [nxm] matrix in
%               case local fiducials are defined as well
%
% SEE ALSO fidsType fidsFindGlobalFids fidsFindLocalFids

fids = [];
global TS;

%%%% get the fids structures
if isnumeric(TSindex)
    if isfield(TS{TSindex},'fids'), fids  = TS{TSindex}.fids; end
end


% Now print the fiducials

values = [];

if isempty(fids), return; end
if ischar(type), type = fidsType(type); end

localf = [];
globalf = [];


%%%% loop through fids structure to find type
for p=1:length(fids)
    if (fids(p).type ~= type)
        continue;
    end
    
    if length(fids(p).value) == 1  %if only one value is given, it must be a global one
        globalf = [globalf fids(p).value];
    else   %local fids
        localf(1:length(fids(p).value),end+1) = reshape(fids(p).value,length(fids(p).value),1);
    end
end

if ~isempty(localf)
    values = localf;
    if ~isempty(globalf)
        values = [values ones(size(values,1),1)*globalf];
    end
else
    values = globalf;
end


return