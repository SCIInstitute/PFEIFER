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



function filteredPotvals = temporal60hzAggressiveFilter(potvals)

global TS;
%global SCRIPTDATA;
%global PROCESSINGDATA;
%%%% filter Parameters, targeting 60 hz noise and its harmonics (120 and 240
%%%% hz)
f1 = designfilt('bandstopiir','FilterOrder',20, ...
         'HalfPowerFrequency1',55,'HalfPowerFrequency2',65,'SampleRate',TS{1}.sampleFreq);
f2 = designfilt('bandstopiir','FilterOrder',20, ...
         'HalfPowerFrequency1',115,'HalfPowerFrequency2',125,'SampleRate',TS{1}.sampleFreq);

f3 = designfilt('bandstopiir','FilterOrder',20, ...
         'HalfPowerFrequency1',235,'HalfPowerFrequency2',245,'SampleRate',TS{1}.sampleFreq);

%%%% do the filtering
filteredPotvals = filtfilt(f3,filtfilt(f2,filtfilt(f1,potvals')))';
