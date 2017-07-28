function sigDeltaFoverF(TSindices,blpts)

% FUNCTION sigDeltaFoverF(TSindices,fbasepoints)
%
% DESCRIPTION
% Do the delta F over F base correction for the optical data
%
% INPUT
% TSindices     The indices into the TS array of all Timeseries that need
%               a baseline correction.
% fbasepoints   Onset and offset for interval defining fbase
% 
% OUTPUT
% Corrected signals are written back into the TS structure
%
% SEE ALSO -

global TS;

if nargin == 1,
    blpts = [];
end


for p=1:length(TSindices),
    
    numframes = TS{TSindices(p)}.numframes;
    numleads = TS{TSindices(p)}.numleads;
    
    if isempty(blpts),
        if isfield(TS{TSindices(p)},'fids'),
            p1 = round(fidsFindFids(TSindices(p),20));
            p2 = round(fidsFindFids(TSindices(p),21));
            blpts = [p1 p2];
            
            if size(blpts,2) > 1,
                blpts = blpts(:,1:2);
            else
                return;
            end
        end
    end
    
    e = ones(size(blpts,1),1);
    startframe = median([e blpts(:,1) e*(numframes+1)],2);
    endframe = median([e blpts(:,2) e*(numframes+1)],2);
   
    if (nnz(startframe-startframe(1))==0) & (nnz(endframe-endframe(1))==0),
        i = startframe(1):endframe(1);
        Y = TS{TSindices(p)}.potvals(:,i);
    else
        Y = zeros(numleads,1);
        for q=1:length(startframe),
            Y(q,:) = TS{TSindices(p)}.potvals(q,startframe(q):endframe(q));  
        end
    end
    
    Fbase = mean(Y,2);
    Fbase(find(Fbase == 0)) = 1;
    Fdelta = max(TS{TSindices(p)}.potvals,[],2) - min(TS{TSindices(p)}.potvals,[],2);
    DeltaFoverF = Fdelta./Fbase;
    
    TS{TSindices(p)}.potvals = (DeltaFoverF*ones(1,size(TS{TSindices(p)}.potvals,2))).*TS{TSindices(p)}.potvals;

     
    if (nnz(startframe-startframe(1))==0) & (nnz(endframe-endframe(1))==0),
        i = startframe(1):endframe(1);
        Y = TS{TSindices(p)}.potvals(:,i);
    else
        Y = zeros(numleads,1);
        for q=1:length(startframe),
            Y(q,:) = TS{TSindices(p)}.potvals(q,startframe(q):endframe(q));  
        end
    end  
    TS{TSindices(p)}.noisedrange = max(Y,[],2)-min(Y,[],2); 
    
    tsAddAudit(TSindices(p),sprintf('|deltafoverf: fbase=startframe %d endframe %d',startframe(1),endframe(1)));
    
end

return
