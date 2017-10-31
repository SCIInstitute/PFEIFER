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


function success = baseLineCorrectSignal(TSidx)
% a wrapper function for the actual baselineCorrection

global SCRIPTDATA TS


%%%% prepare the inputs
baselineWidth = SCRIPTDATA.BASELINEWIDTH;

% start and endframe for baseline correction
startframe =[];
endframe = [];
if isfield(TS{TSidx},'fids')  % first check if there are any 
    blpts = round(fidsFindFids(TSidx,'baseline'));  % get blpts from fids
    if size(blpts,2) > 1
        startframe = blpts(:,1);
        endframe = blpts(:,2);
    end
end
if isempty(startframe)
    startframe = 1;
    endframe = TS{TSidx}.ts.numframes;
end

%%%% check if there is actually a function there to do Baseline Correction
if isempty(SCRIPTDATA.BASELINE_OPTIONS)
    errordlg('Cannot do baseline correction, since no baseline correction function is provided. Aborting...')
    success = 0;
    return
end


%%%% now baselineFunction (the function selected to do baseline correction) and check if it is valid
baselineFunctionString = SCRIPTDATA.BASELINE_OPTIONS{SCRIPTDATA.BASELINE_SELECTION};
if nargin(baselineFunctionString)~=4 || nargout(baselineFunctionString)~=1
    msg=sprintf('the provided baseline correction function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end
baselineFunction = str2func(baselineFunctionString);

%%%% try catch to baseline the data
try
    TS{TSidx}.potvals = baselineFunction(TS{TSidx}.potvals,startframe,endframe,baselineWidth);
catch
    msg = sprintf('Something wrong with the provided baseline correction function ''%s''. Using it to baseline correct the data failed. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end

%%%%  check if potvals still have the right format and the filterFunction worked correctly
if TS{TSidx}.numframes ~= size(TS{TSidx}.potvals,2) || TS{TSidx}.numleads ~= size(TS{TSidx}.potvals,1)
    msg = sprintf('The provided baseline correction function ''%s'' does not work as supposed. It changes the dimensions of the potvals. Using it to baseline correct the data failed. Aborting..',baselineFunctionString);
    errordlg(msg)
    success = 0;
    return
end

%%%% add an audit string to ts.audit
tsAddAudit(TSidx,sprintf('| baseline correction using the function ''%s'': startframe %d endframe %d over a window of %d frames',startframe,endframe,baselineWidth));

success = 1;