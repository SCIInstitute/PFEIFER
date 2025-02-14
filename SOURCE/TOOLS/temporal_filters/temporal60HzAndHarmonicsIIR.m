function [filteredPotvals] = temporal60HzAndHarmonicsIIR(potvals)
%TEMPORAL60HZANDHARMONICSIIR Summary of this function goes here
%   Detailed explanation goes here
 denominator = 1;
numerator = 1;
freqs = [60,120,180,240];
rvals =[.98,.98,.98,.98];

global SCRIPTDATA;

fs = SCRIPTDATA.SAMPLEFREQ;

for notchIx = 1:length(freqs)
    freq = freqs(notchIx);
    rval = rvals(notchIx);
    [bf,af] = iirCoeffs(freq,fs,rval);
    numerator = conv(numerator,bf);
    denominator = conv(denominator,af);
end
filteredPotvals = filtfilt(numerator,denominator,potvals')';




end

function [num,denom] = iirCoeffs(freqOfNotch,fs,Rval)
    w = 2*pi * freqOfNotch/fs;
    num = [1, -2*cos(w), 1];
    denom = [1, -2*Rval*cos(w), Rval*Rval];
end