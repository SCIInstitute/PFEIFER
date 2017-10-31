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





function [globFid, indivFids, variance] = findFid(windows,kernels)
% inputs:
%   - windows:  a nLeads x length(window) - array with all the windows of a beat
%   - kernels: a nLeads x length(kernel) - array with all the kernels of one fiducial
%
% outputs:
%   - gobalFid: idx of global fids, determined by taking mode from indivFids 
%   - indivFids: indeces of individual fids,    indivFids=lag(index))+1 (= index!)   this way   windows(indivFids:indivFids+length(kernel)-1) matches kernel best;
%     this means, indivFids still needs to be shiftet to the point in kernel, where the actuall fid is.
%   - indivXcorr: nLeads x 1 array with normalised xcorr values of matches


nLeads=size(kernels,1);
indivFids=zeros(nLeads,1);
indivXcorr=zeros(nLeads,1);

length_kernel=size(kernels,2);
lagshift=0;
numlags=size(windows,2)-length_kernel+1;   %only the lags with "no overlapping"

xc=zeros(nLeads,numlags);   %the cross correlation values
for leadNumber=1:nLeads 
    for lag=1:numlags
        xc(leadNumber,lag)=xcorr(windows(leadNumber,lag:lag+length_kernel-1), kernels(leadNumber,:),lagshift,'coef');
    end 
end
[~,indivFids]=max(xc,[],2);

% now compute the globalFid by computing the "Mode": sum up all xc-values of a lag and find the max of the summed up xc-values
[~,globFid]=max(sum(xc,1),[],2);
% variance
variance=var(indivFids);






