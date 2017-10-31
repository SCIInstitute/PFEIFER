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





function selectLoop(varargin)

if nargin > 0 && ischar(varargin{1})    
    feval(varargin{1},varargin{2:end});
    return
end

handle=SmartCycling;
setLoopOrderWindow(handle)

end


function setLoopOrderWindow(handle)
% set the LoopOrdernWindow. Mainly: set the edit text window accordingly to
% SCRIPTDATA.LOOPORDER
global SCRIPTDATA
SCRIPTDATA.LOOP_ORDER
loopString=num2str(SCRIPTDATA.LOOP_ORDER);

obj=findobj(allchild(handle), 'Tag', 'LOOP_ORDER');

set(obj,'String', loopString)
end


function set_LOOP_ORDER(handle)
%callback, sets SCRIPTDATA.LOOP_ORDER according to user input
global SCRIPTDATA 
str=get(handle,'String');
try
    userInput = eval(['[' str ']']);
catch
    errordlg('invalid input for loop order')
    setLoopOrderWindow(handle.Parent)
    error('invalid input for loop order')
end
if ~isequal(sort(userInput), unique(userInput))
errordlg('Input must not contain dublicates!')
setLoopOrderWindow(findobj(allchild(0),'Tag','loopOrderWindow'))
error('ERROR')
end

if any(userInput > 10)
 errordlg('Numbers must not be greater than 10')
 setLoopOrderWindow(handle.Parent)
 error('Number in loop order to big')
end
SCRIPTDATA.LOOP_ORDER=userInput;
end


