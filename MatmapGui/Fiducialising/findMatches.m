function matches=findMatches(signal, kernel, accuracy)
% finds kernel in signal.  retuns matches={[s1,e1], [s2,e2], ..[sn,en]} so that 
%  m=signal(si:ei) matches kernel for all i, "matches" means: xcorr(kernel,m,0,'coeff')>accuracy
% it also:
% - sorts the matches in order they appear in signal (s1 < s2 < .. < si)
% notes:
% - does not blank out everything - so overlap is ok! see blankfraction


blankfraction=0.4;   % only the middle 2*blankfraktion percentage part of match is blanked -> allows for overlap
blanklength=round(blankfraction*length(kernel));

matches={};


%%%% testing
global aaa
[xc_coef, lag]=coef_xcorr(signal,kernel);

aaa.xc_coef = xc_coef;

[xc_mm, lag]=xcorr(signal,kernel);
aaa.xc_mm = xc_mm;
aaa.signal =  signal;
aaa.kernel = kernel;
aaa.lags =  lag;
error('end it here')


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





%%%% additional functions, mostly for demonstration

function plotPartlyBlankedSignal(signal)
hFig = figure(1);
x =2;
y = 2;
width=13;
height=5;
set(hFig,'Units','Inches', 'Position', [x y width height])
plot(signal)

pause(0.3)








