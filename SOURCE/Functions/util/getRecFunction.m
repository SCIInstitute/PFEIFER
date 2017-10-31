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


function [functionHandle, success] = getRecFunction
global SCRIPTDATA
functionHandle = 'dummy';

%%%% check if there is actually a function there to detect recovery
if isempty(SCRIPTDATA.REC_OPTIONS)
    errordlg('Cannot find recovery, since no recovery detection function is provided. Aborting...')
    success = 0;
    return
end

%%%% now get recFunction (the function selected to detect recovery) and check if it is valid
recFunctionString = SCRIPTDATA.REC_OPTIONS{SCRIPTDATA.REC_SELECTION};
if nargin(recFunctionString)~=3 || nargout(recFunctionString)~=1
    msg=sprintf('the provided recovery detection function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',recFunctionString);
    errordlg(msg)
    success = 0;
    return
end
functionHandle = str2func(recFunctionString);
success = 1;
