function [globFid, indivFids, variance] = findFid(windows,kernels,method)
% inputs:
%   - windows:  a nLeads x length(beat) - array with all the windows of a beat
%   - kernels: a nLeads x length(kernel) - array with all the kernels of one fiducial
%
% outputs:
%   - gobalFid: idx of global fids, determined from indivFids using "method"
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




