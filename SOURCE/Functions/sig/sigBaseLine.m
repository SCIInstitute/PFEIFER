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


function sigBaseLine(TSindices,blpts,blwin)
%blpts are either blpts from ts.fids, if there are any, or else [startframe
%endframe]
% addAudit is updated

% FUNCTION sigBaseLine(TSindices,baselinepoints,[baselinewindow])
%
% DESCRIPTION
% Do the baseline correction. This function needs two points being the
% points where the signal should be electrically silent. Additional a
% window can be specified that specifies the number of points at each
% position to be taken for the baseline correction, so a noise has a less
% dramtaic effect on this correction. In case of the window the positions
% defined in baselinepoints indicate the start of the window and basline-
% window determines the length of the window. The baseline correction is 
% done by a linear least squares fit of the points in both windows,
% subsequently the base line curve is subtracted from the data.
%
% INPUT
% TSindices     The indices into the TS array of all Timeseries that need
%               a baseline correction.
% 
% baselinepoints A vector of two points indicating the position of each
%               baseline fiducial. If empty, the start and endframe are
%               taken
% baselinewindow The number of points to take for each fiducial (default = 1)
% 
% OUTPUT
% Corrected signals are written back into the TS structure
%
% SEE ALSO -






global TS;

if nargin < 3
    blwin = 1;
end

if nargin == 1
    blpts = [];
    blwin = [];
end


for p=1:length(TSindices)
    
    numframes = TS{TSindices(p)}.numframes;
    numleads = TS{TSindices(p)}.numleads;
    
    if isempty(blpts)
        blpts = [1 numframes];
        if isfield(TS{TSindices(p)},'fids')
            blpts = round(fidsFindFids(TSindices(p),'baseline'));  % get blpts from fids
            if size(blpts,2) > 1
                blpts = blpts(:,1:2);
            else
                return;
            end
        end
        if isfield(TS{TSindices(p)},'baselinewidth')
            blwin = TS{TSindices(p)}.baselinewidth;
        end
    end
    
    e = ones(size(blpts,1),1);
    startframe = median([e blpts(:,1) e*(numframes-blwin+1)],2);
    endframe = median([e blpts(:,2) e*(numframes-blwin+1)],2);
   
    if (nnz(startframe-startframe(1))==0) && (nnz(endframe-endframe(1))==0)
        i = [[0:(blwin-1)]+startframe(1) endframe(1)+[0:(blwin-1)]];
        X = ones(numleads,1)*i;
        Y = TS{TSindices(p)}.potvals(:,i);
    else
        X = zeros(numleads,2*blwin);
        Y = zeros(numleads,2*blwin);
        for q=1:length(startframe)
            X(q,:) = [[0:(blwin-1)]+startframe(q) endframe(q)+[0:(blwin-1)]];
            Y(q,:) = TS{TSindices(p)}.potvals(q,X(q,:));  
        end
    end
    ymean = mean(Y,2);
    xmean = mean(X,2);
    Ymean = ymean*ones(1,length(i));
    Xmean = xmean*ones(1,length(i));
    B = sum(X.*(Y - Ymean),2)./sum((X-Xmean).^2,2);
    A = ymean - B.*xmean;
    e1 = 1:numframes;
    e0 = ones(1,numframes);
    Y = B*e1 + A*e0;
    TS{TSindices(p)}.potvals = TS{TSindices(p)}.potvals - Y;
    
    tsAddAudit(TSindices(p),sprintf('|sigBaseLine baseline correction: startframe %d endframe %d over a window of %d frames',startframe(1),endframe(1),blwin));
    
end










