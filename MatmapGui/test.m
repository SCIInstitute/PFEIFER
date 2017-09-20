function test
close all
figure


global aaa

xccoef=aaa.xc_coef;
xcmm=aaa.xc_mm;
signal = aaa.signal;
kernel = aaa.kernel;
lags = aaa.lags;

nLags=size(signal,2)-length(kernel)+1;
sidx=find(lags==0);

xcmm = xcmm(sidx:sidx+nLags-1);






signal=signal-min(signal);
kernel = kernel-min(kernel);
xcmm = xcmm - min(xcmm);

signal=signal/max(signal);
kernel = kernel/max(kernel);
xcmm = xcmm /max(xcmm);

l=500;
shift=20000;
st = 1+shift;
e = st+l;
xval=(1:length(xcmm))*0.001;
step = 1;

hold on
grid on

plot(xval(st:e),signal(st:e))

plot(xval(st:step:e),xccoef(st:step:e)+1)

plot(xval(st:e),xcmm(st:e)+2)

