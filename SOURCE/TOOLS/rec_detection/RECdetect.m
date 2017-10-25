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

function x = RECdetect(signal,win,deg)

%%%% make sure win is uneven
if mod(win,2) == 0, win = win + 1; end

%%%% return x=1, if len(sig)<win
if length(signal) < win, x=1; return; end


%%%% Detection of the minimum derivative using a window of 5 frames and fit a 2. order polynomial
cen = ceil(win/2);
X = zeros(win,(deg+1));
L = [-(cen-1):(cen-1)]';
for p=1:(deg+1)
    X(:,p) = L.^((deg+1)-p);
end


E = (X'*X)\X';



%%%% continue signal with last value
signal = [signal signal(end)*ones(1,cen-1)];

filteredSignal = filter( E(deg,(win:-1:1)), 1, signal );
trunctFiltSig = filteredSignal(cen:end);



%%%% get index maxIdx of maximum in truncFiltSig, but leave out maxima at borders
[~,maxIdx] = max(trunctFiltSig(cen:end-cen));
maxIdx = maxIdx(1)+(cen-1);




% preset values for peak detector
win2 = 5;
deg2 = 2;
cen2 = ceil(win2/2);
L2 = (-(cen2-1):(cen2-1))';


X2=zeros(length(L2),length((deg2+1)));
for p=1:(deg2+1)
    X2(:,p) = L2.^((deg2+1)-p);
end




c = (X2'*X2)\X2' * (trunctFiltSig(L2+maxIdx)');




if abs(c(1)) < 100*eps
    dx = 0;
else
    dx = -c(2)/(2*c(1));
end

dx = median([-0.5 dx 0.5]);

x = maxIdx+dx-1;

end



