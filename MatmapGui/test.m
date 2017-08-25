
load(fullfile(matlabroot,'examples','signal','Ring.mat'))

load(fullfile(matlabroot,'examples','signal','Ring.mat'))

Time = 0:1/Fs:(length(y)-1)/Fs; 

m = min(y);
M = max(y);

Full_sig = double(y);

timeA = 7;
timeB = 8;
snip = timeA*Fs:timeB*Fs;

Fragment = Full_sig(snip);

% To hear, type soundsc(Fragment,Fs)

plot(Time,Full_sig,[timeA timeB;timeA timeB],[m m;M M],'r--')
xlabel('Time (s)')
ylabel('Clean')
axis tight