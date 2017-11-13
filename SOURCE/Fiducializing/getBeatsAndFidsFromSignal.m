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






function [beatEnvelopes, allLocFrFids, success] = getBeatsAndFidsFromSignal(fullUnslicedTS,templateBeatTS, settings)
% INPUTS:
%   - settings: a struct with all the settings that would normally be done by the user in the PFEIFER gui.
%     Settings musst have the following fields:
%           - leadsToAutofiducialize
%           - accuracy
%           - fidsKernelLength
%           - window_width



%%%% initialize outputs
beatEnvelopes = {};
allLocFrFids = {};
success = 0;



%%%% get the beatEnvelopes

rmsSignal = 
bsk = fullUnslicedTS.selframes(1);
bek = fullUnslicedTS.selframes(2);
beatEnvelopes = getBeatEnvelopes(rmsSignal, rmsSignal(bsk:bek), settings.accuracy);




