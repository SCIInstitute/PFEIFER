function matches=findMatches(signal, kernel, accuracy)
% finds kernel in signal.  retuns matches={[s_1,e_1], [s_2,e_2], ..[s_n,e_n]} so that 
%  m=signal(s_i:e_i) matches kernel for all i, "matches" means:  xcorr(signal(s_i:e_i),kernel,0,'coeff') has a maximum peak value (at least accuracy)  (and matches dont overlap)
% it also:
% - sorts the matches in order they appear in signal (s1 < s2 < .. < si)

%%%% hardcoded:
stepSize  = 20;
accuracyForFirstEstimate = 0.7;


%%%% set up stuff
sigLength = length(signal);
kernelLength = length(kernel);
estNumBeats = round(sigLength/330);    % very rough estimation of numBeats in signal.. a beat is usually 330 frames long

%%%% get stepLags: the evenly spaced lags (with distance stepSize) to go through. First possible lag would be 0! ("lag frame")
stStepLag = 0.5 * stepSize;   % first lag
endStepLag = sigLength  - kernelLength - 0.5 * stepSize; % last lag
nStepLags = ceil((endStepLag - stStepLag)/stepSize) + 1;
stepLags = round(linspace(stStepLag, endStepLag, nStepLags));


%%%% get stepXC - the corresponding correlations for each stepLag
count = 1;
stepXCs = zeros(1,nStepLags);
for lag = stepLags
    stepXCs(count)=xcorr(signal(lag:lag+kernelLength-1), kernel,0,'coef');
    count = count +1;
end

%%%% get the peakLags and corresponding peakXCs,  the correlations values and corresponding lags with high peak values
estimatedPeakLags = zeros(1,estNumBeats);
estimatedPeakXCVals = estimatedPeakLags;

count=1;
pval = 1;  %peak value
while pval > accuracyForFirstEstimate
    %get max val and corresponding lag
    [pval, pidx] = max(stepXCs);
    plag =  stepLags(pidx);
    
    % clear valus around pidx
    s = pidx - 13;
    e = pidx + 13;
    if s < 1, s=1; end
    if e > nStepLags, e = nStepLags; end,
    stepXCs(s:e) = 0;
    
    % save peak value pval und peak lag plag:
    estimatedPeakLags(count) =  plag;
    estimatedPeakXCVals(count) = pval;
    
%    plotEstiPeak(plag)               % for testing only

    count = count +1;
end

%plotBlankedSteppedXcor(stepXCs,stepLags)                     % for testing only

% get rid of zeros at the end of peakLags and peakXCs  (in case estNumBeats was to high)
idx=find(estimatedPeakXCVals == 0);
if ~isempty(idx)
    estimatedPeakXCVals(idx(1):end)=[];
    estimatedPeakLags(idx(1):end)=[];
end


%plotAllEstimatedPeaks(estimatedPeakLags, kernel, signal)                       % for testing only


%%%% for each estimated peak, find the real precise peak, which must be somewhere close to estimatedPeakXCVal.   fill matches accourdingly
count=0;
matches = cell(1,length(estimatedPeakXCVals));
start_values=zeros(1,length(estimatedPeakXCVals)); % needed for sorting only
for pl = estimatedPeakLags  % for each "estimated" peak
    count = count + 1;
    %%%% first, get the sl ("start lag") and the el ("end lag"). The exact peak position is searched between el and sl
    % pl ("peak lag", pv ("peak value"),  av/bv ("after/before value")  al/bl ("after/before lag")
    bl = pl - 0.5*stepSize;
    bv = xcorr(signal(bl+1:bl+kernelLength), kernel,0,'coef');
    pv = estimatedPeakXCVals(count);
    if bv > pv
        sl = bl;
        el = pl;
        sv = bv;
        ev = pv;
    else
        al = pl + 0.5*stepSize; 
        av = xcorr(signal(al+1:al+kernelLength), kernel,0,'coef');
        
        if bv < av
            sl = pl;
            el = al;
            sv = pv;
            ev = av;
        else
            sl = bl;
            el = pl;
            sv = bv;
            ev = pv;
        end
    end
    

    %%%% now search for exact peak position between sl and el using "divide and conquer"
    while sl ~= el
        if sv < ev
            sl = ceil((el+sl)/2);
            sv = xcorr(signal(sl+1:sl+kernelLength), kernel,0,'coef');
        else
            el = floor((el+sl)/2);
            ev = xcorr(signal(el+1:el+kernelLength), kernel,0,'coef');
        end
    end
    
    
    %%%% check if peak value is higher than accuracy. Only then put found match in matches
    if sv < accuracy
        continue
    else
        matches{count} = [sl+1, sl+kernelLength] ;
        start_values(count) = sl+1;
    end
end


%%%% sort matches & get rid of empty slots
[~,I]=sort(start_values);
matches=matches(I);
toBeDeleted = [];
for p=1:length(matches)
    if isempty(matches{p})
        toBeDeleted(end+1)=p;
    end
end
matches(toBeDeleted)=[];



%%%% optional: testing..  plot results, see if they look good
%plotFoundMatches(signal, matches)








%%%%%%%

function matches=OldFindMatches(signal, kernel, accuracy)
% finds kernel in signal.  retuns matches={[s1,e1], [s2,e2], ..[sn,en]} so that 
%  m=signal(si:ei) matches kernel for all i, "matches" means: xcorr(kernel,m,0,'coeff')>accuracy
% it also:
% - sorts the matches in order they appear in signal (s1 < s2 < .. < si)
% notes:
% - does not blank out everything - so overlap is ok! see blankfraction

% this is the "old version" of this function, that is not used any more. it is saved here just in case..


blankfraction=0.4;   % only the middle 2*blankfraktion percentage part of match is blanked -> allows for overlap
blanklength=round(blankfraction*length(kernel));

matches={};




while 1
    %%%%  do correlation, find m1 and m2
    disp('starting ---------------')
    tic
    [xc, lag]=coef_xcorr(signal,kernel);
    toc
        
    
    [~,index]=max(abs(xc));
    m1=lag(index)+1;      %start of match
    m2=m1+length(kernel)-1;   %end of match
    
    plotPartlyBlankedSignal(signal)    % for demonstration only
    
    
    %%%% if signal is already completely blanked
    if ~any(signal),break, end
    m1
    m2
    %%%% if match is at the corners -> blank and continue
    if m1<1
        signal(1:m2)=0;
        continue
    elseif m2>length(signal)
        signal(m1:end)=0;
        continue
    end

    ac=xcorr(kernel,signal(m1:m2),0,'coeff'); %actual correlation with zero lag, normalized
    ac
    if ac > accuracy   %if match is good enough
        matches{end+1}=[m1,m2];
        % blank parts of it
        middle=round((m1+m2)/2);
        toBeBlanked=[(middle-blanklength):(middle+blanklength)];
        
        signal(toBeBlanked)=0;     
    else
        break
    end
    
end
%%%% sort matches
start_values=zeros(1,length(matches));
for p=1:length(matches)
    start_values(p)=matches{p}(1);
end
[~,I]=sort(start_values);
matches=matches(I);


function [xc, lags] = coef_xcorr(window,kernel)
% just like matlabs xcorr, but with the 'coef' option for every lag
kernelLength=size(kernel,2);
lagshift=0;
nLags=size(window,2)-kernelLength+1;   %only the lags with "no overlapping"
xc=zeros(1,nLags);   %the cross correlation values
for lag=1:nLags
    xc(lag)=xcorr(window(lag:lag+kernelLength-1), kernel,lagshift,'coef');
end 
lags = 0:nLags-1;





%%%% additional functions for plotting..  Needed only for testing, not actually part of findMatches %%%%%%%%%%%%%%%%%%%%%

function plotPartlyBlankedSignal(signal)
hFig = figure(1);
x =2;
y = 2;
width=13;
height=5;
set(hFig,'Units','Inches', 'Position', [x y width height])
plot(signal)

pause(0.3)



function plotEstiPeak(plag)
global aaa
xccoef = aaa.xc_coef;
xval= 1:length(xccoef);

idx=plag + 1;

s=idx-30;
e=idx+30;
if s<1, s=1;end
if e>length(xc_coef), e = length(xc_coef); end




plot(xvalues(s:e),xc_coef(s:e))
hold off
Y=ylim;
line([idx, idx], [Y(1), Y(2)], 'color','r')

title('plotEstiPeaks')
pause(0.5)




function plotBlankedSteppedXcor(stepXCs,stepLags)
s=25000;
e=30000;

figure
idx=find( and(stepLags < e, stepLags > s));

plot(stepLags(idx),stepXCs(idx))
title('plotBlankedSteppedXcor')

function plotAllEstimatedPeaks(estimatedPeakLags, kernel, signal)

% [xc_coef, ~] = coef_xcorr(signal,kernel);
% save('xc_coef','xc_coef');
load('xc_coef','xc_coef')
xval= 1:length(xc_coef);



s=1000;  % start end time frames to plot
e=6000;


figure
hold on
plot(xval(s:e),xc_coef(s:e))

%%%% plot peaks
Ylim=ylim;
for xval = estimatedPeakLags
    if xval < e && xval > s
        line([xval xval], [Ylim(1), Ylim(2)], 'Color','red')
    end
end
title('plotAllExtimatedPeaks')



function plotFoundMatches(signal, matches)
title('all found matches in signal')
time=1:length(signal);

figure
plot(time,signal)
set(gcf,'Units', 'Inches','Position',[1 1 13 7])
hold on
% plot matches
yshift=0.3;
for p=1:length(matches)
    idx=matches{p}(1):matches{p}(2);
    plot(time(idx),signal(idx)+1+yshift, 'r')
    yshift=-yshift;
end
hold off










