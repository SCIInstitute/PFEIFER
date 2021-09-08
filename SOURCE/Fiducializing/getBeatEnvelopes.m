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





function [beatEnvelopes, corrVals] = getBeatEnvelopes(signal, kernel, accuracy,bsk)
% finds kernel in signal.  retuns beatEnvelopes={[s_1,e_1], [s_2,e_2], ..[s_n,e_n]} so that 
%  m=signal(s_i:e_i) matches kernel for all i, "matches" means:  xcorr(signal(s_i:e_i),kernel,0,'coeff') has a maximum peak value (at least accuracy)  (and matches dont overlap)
% it also:
% - sorts the beatEnvelopes in order they appear in signal (s1 < s2 < .. < si)

%%%% hardcoded:
stepSize  = 20;
accuracyForFirstEstimate = 0.7;


%%%% set up stuff
sigLength = length(signal);
kernelLength = length(kernel);
estNumBeats = floor(sigLength/330);    % very rough estimation of numBeats in signal.. a beat is usually 330 frames long

%%%% get stepLags: the evenly spaced lags (with distance stepSize) to go through. First possible lag would be 0! ("lag frame")
stStepLag = 0.5 * stepSize;  % first lag
endStepLag = sigLength  - kernelLength - 0.5 * stepSize; % last lag
nStepLags = ceil((endStepLag - stStepLag)/stepSize) + 1;
stepLags = round(linspace(stStepLag, endStepLag, nStepLags));


if estNumBeats < 1 || sigLength < kernelLength ||  endStepLag < stStepLag
    beatEnvelopes = {};
    return
end



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
    if count == 1 && bsk~=0  % if we want to find the original beat (if bsk~=0) and it is first peak, make sure this one is the original kernel peak. this is to make sure the actual peak is not "planked out"
        difLag = abs(stepLags - bsk);  % find closest peak to beat start kernel, the time frame where kernel starts.
        [~,pidx] = min(difLag);
        pval = stepXCs(pidx);
        plag = stepLags(pidx);
    else
        [pval, pidx] = max(stepXCs);
        plag =  stepLags(pidx);
    end
        
    
    % clear valus around pidx  ("blank out values")
    s = pidx - 13;
    e = pidx + 13;
    if s < 1, s=1; end
    if e > nStepLags, e = nStepLags; end,
    stepXCs(s:e) = 0;
    
    % save peak value pval und peak lag plag:
    estimatedPeakLags(count) =  plag;   
    estimatedPeakXCVals(count) = pval;
    
%    plotEstiPeak(plag)               % for testing only

%    plotBlankedSteppedXcor(stepXCs,stepLags)                     % for testing only

    count = count +1;
end

% get rid of zeros at the end of peakLags and peakXCs  (in case estNumBeats was to high)
idx=find(estimatedPeakXCVals == 0);
if ~isempty(idx)
    estimatedPeakXCVals(idx(1):end)=[];
    estimatedPeakLags(idx(1):end)=[];
end


% plotAllEstimatedPeaks(estimatedPeakLags, kernel, signal)       % for testing only


%%%% for each estimated peak, find the real precise peak, which must be somewhere close to estimatedPeakXCVal.   fill matches accourdingly
count=0;
beatEnvelopes = cell(1,length(estimatedPeakXCVals));
start_values=zeros(1,length(estimatedPeakXCVals)); % needed for sorting only
corrVals = cell(1,length(estimatedPeakXCVals));
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
        beatEnvelopes{count} = [sl+1, sl+kernelLength] ;
        start_values(count) = sl+1;  % for sorting
        corrVals{count} = sv;
    end
end


%%%% sort matches & get rid of empty slots
[~,I]=sort(start_values);
beatEnvelopes=beatEnvelopes(I);
corrVals = corrVals(I);
toBeDeleted = [];
for p=1:length(beatEnvelopes)
    if isempty(beatEnvelopes{p})
        toBeDeleted(end+1)=p;
    end
end
beatEnvelopes(toBeDeleted)=[];
corrVals(toBeDeleted) = [];
%%%% make sure beats don't overlap

for p=1:length(beatEnvelopes)-1
    if beatEnvelopes{p}(2) > beatEnvelopes{p+1}(1)
        beatEnvelopes{p}(2) = beatEnvelopes{p+1}(1) - 1;
    end
end




%%%% optional: testing..  plot results, see if they look good
% plotFoundMatches(signal, matches)


%%%%%%%%%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xc, lags] = coef_xcorr(window,kernel)  % only needed for testing
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

load('xc_coef')    % run the plottAllEstimatedPeaks function to get 'xc_coeff'


xval= 1:length(xc_coef);

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
s=1;
e=3000;

figure
idx=find( and(stepLags < e, stepLags > s));

plot(stepLags(idx),stepXCs(idx))
title('plotBlankedSteppedXcor')
pause(1)

function plotAllEstimatedPeaks(estimatedPeakLags, kernel, signal)

% [xc_coef, ~] = coef_xcorr(signal,kernel);
% save('xc_coef','xc_coef');

load('xc_coef','xc_coef')

xval= 1:length(xc_coef);



s=1;  % start end time frames to plot
e=2172;


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
xlabel('lag')
ylabel('cross correlation')



function plotFoundMatches(signal, matches)

time=1:length(signal);

figure
plot(time,signal)
set(gcf,'Units', 'Inches','Position',[1 1 13 7])
hold on
% plot matches
yshift=0.3*max(signal);
for p=1:length(matches)
    idx=matches{p}(1):matches{p}(2);
    plot(time(idx),signal(idx)+1+yshift, 'r')
    yshift=-yshift;
end


% plot the real kernel
global AUTOPROCESSING
bsk=AUTOPROCESSING.bsk;   %start and end of beat
bek=AUTOPROCESSING.bek;
kernelTime=bsk:bek;
kernel = signal(kernelTime);
plot(kernelTime,kernel,'color','k')

hold off

title('all found beats (in red ) in signal (blue) and the actual original beat (black)')
ylabel('potvals')
xlabel('timeframe')










