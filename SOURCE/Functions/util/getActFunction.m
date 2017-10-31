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


function [functionHandle, success] = getActFunction
global SCRIPTDATA
functionHandle = 'dummy';

%%%% check if there is actually a function there to detect activation
if isempty(SCRIPTDATA.ACT_OPTIONS)
    errordlg('Cannot find activation, since no activation detection function is provided. Aborting...')
    success = 0;
    return
end

%%%% now get actFunction (the function selected to detect activation) and check if it is valid
actFunctionString = SCRIPTDATA.ACT_OPTIONS{SCRIPTDATA.ACT_SELECTION};
if nargin(actFunctionString)~=3 || nargout(actFunctionString)~=1
    msg=sprintf('the provided activation detection function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',actFunctionString);
    errordlg(msg)
    success = 0;
    return
end
functionHandle = str2func(actFunctionString);
success = 1;
