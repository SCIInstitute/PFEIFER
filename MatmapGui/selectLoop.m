function selectLoop(varargin)

if nargin > 0 && ischar(varargin{1})    
    feval(varargin{1},varargin{2:end});
    return
end

handle=winSelectLoopOrder;
setLoopOrderWindow(handle)

end


function setLoopOrderWindow(handle)
% set the LoopOrdernWindow. Mainly: set the edit text window accordingly to
% myScriptData.LOOPORDER
global myScriptData
myScriptData.LOOP_ORDER
loopString=num2str(myScriptData.LOOP_ORDER);

obj=findobj(allchild(handle), 'Tag', 'LOOP_ORDER');

set(obj,'String', loopString)
end


function set_LOOP_ORDER(handle)
%callback, sets myScriptData.LOOP_ORDER according to user input
global myScriptData 
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
myScriptData.LOOP_ORDER=userInput;
end


