function tsindex = sigDetectPacing(tsindex,pacinglead)

% FUNCTION sigDetectPacing(TSindex,pacinglead)
% OR       TSdata = sigDetectPacing(TSdata,pacinglead)
%
% DESCRIPTION
% This function detects the pacing stimulus in a channel recording this
% stimulus. It converts all simuli into fiducials and adds that to the 
% datastructure. A field pacing is created as well containing pacing
% timeintervals (.pacing).
%
% INPUT
% TSindex     index into the TS array
% TSdata      a struct or cell array containing the timeseries data
% pacinglead  number of the lead on which the pacing is recorded
%
% OUTPUT
% TSdata      a struct or cell array containing the timeseries data
%
% SEE ALSO
% -s

    if isempty(pacinglead),
        return;
    end


    for p=1:length(tsindex),
        
        fids = [];
        fidset = {};
        
        if isstruct(tsindex),
            pacing = tsindex(p).potvals(pacinglead,:);
            if isfield(tsindex(p),'fids'),
                fids = tsindex(p).fids;
                fidset = tsindex(p).fidset;
            end
        end
        if iscell(tsindex),
            pacing = tsindex{p}.potvals(pacinglead,:);
            if isfield(tsindex{p},'fids'),
                fids = tsindex{p}.fids;
                fidset = tsindex{p}.fidset;
            end
        end
        if isnumeric(tsindex),
            global TS;
            pacing = TS{tsindex(p)}.potvals(pacinglead,:);
            if isfield(TS{tsindex(p)},'fids'),
                fids = TS{tsindex(p)}.fids;
                fidset = TS{tsindex(p)}.fidset;
            end
        end
    
        times = DetectPacing(pacing);
        
        if isempty(times), return; end
        
        if length(times) > 0,
            fidset{end+1}.label = 'Pacing Fiducials';
            fidset{end}.audit = sprintf('|sigDetectPacing in lead %d',pacinglead);
            newfidset = length(fidset);
        end
        
        for q=1:length(times)
            fids(end+1).value = times(q);
            fids(end).type = fidsType('pacing');
            fids(end).fidset = newfidset;
        end
        
        if isnumeric(tsindex),
            global TS;
            TS{tsindex(p)}.fids = fids;
            TS{tsindex(p)}.fidset = fidset;
            TS{tsindex(p)}.pacing = times;
        end
 
        if iscell(tsindex),
            tsindex{p}.fids = fids;
            tsindex{p}.fidset = fidset;
            tsindex{p}.pacing = times;
        end
           
        if isstruct(tsindex),
            tsindex(p).fids = fids;
            tsindex(p).fidset = fidset;
            tsindex(p).pacing = times;
        end
    end
    return
    
function times = DetectPacing(pacing)

    maxp = max(pacing);
    minp = min(pacing);
    mean = (maxp+minp)/2;
    
    ulim = length(find(pacing > mean));
    llim = length(pacing)-ulim;
    
    if ulim > llim,
        threshold = maxp - 0.9*(maxp-minp); 
        times = DPeaks(-pacing,-threshold);
    else
        threshold = minp + 0.9*(maxp-minp);
        times = DPeaks(pacing,threshold);
    end
    
    % 50ms is minimum pacing rate
    if length(times) > (length(pacing)*0.02),
        fprintf(1,'WARNING: Could not detect pacing')
        times = [];
    end
    
    
    return

function events = DPeaks(signal,threshold,detectionwidth);

    if nargin == 2,
        detectionwidth = 0;
    end
    
    nsamples = size(signal,2);
   
    if detectionwidth > 0,
   
        L = (detectionwidth -1);
        N = 2*L+1;
        X = -L:L;
        C2 = sum(X.*X);
        C4 = sum(X.*X.*X.*X);

        % define matched filters
        MF1 = ones(1,N);  
        MF2 = X.*X;

        % Make a convolution with the matched filter

        Conv1 = conv(signal,MF1);
        Conv2 = conv(signal,MF2);
        Conv1 = Conv1((L+1):(L+nsamples));
        Conv2 = Conv2((L+1):(L+nsamples));

        signal = (Conv2 - ((C4/C2)*Conv1))*(C2/(C2*C2-N*C4));
    end

    % C is now a filtered signal containing the value when
    % a second order function is fitted on to the data in a region
    % between -L and L points from the centre. L is a kind of detection
    % width

    N = size(signal,2);
    index = find(signal >= threshold);
    I2 = zeros(1,N+2);
    I2(index+1) = ones(size(index,1));
    I2 = I2(2:N+2) - I2(1:N+1);

    % Detect the intervals in which a maximum has to detected

    intervalstart = find(I2 == 1);
    intervalend = find(I2 == -1);
    intervalend = intervalend -1;

    % detect maxima

    events = [];

    for i = 1:size(intervalstart,2),
        S = signal(intervalstart(i):intervalend(i));
        [dummy,ind] = max(S);
        events(i) = ind(max([1 round(length(ind)/2)])) + intervalstart(i) - 1;
    end
    
    return



