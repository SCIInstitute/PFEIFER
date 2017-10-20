function [functionHandle, success] = getRecFunction
global ScriptData
functionHandle = 'dummy';

%%%% check if there is actually a function there to detect recovery
if isempty(ScriptData.REC_OPTIONS)
    errordlg('Cannot find recovery, since no recovery detection function is provided. Aborting...')
    success = 0;
    return
end

%%%% now get recFunction (the function selected to detect recovery) and check if it is valid
recFunctionString = ScriptData.REC_OPTIONS{ScriptData.REC_SELECTION};
if nargin(recFunctionString)~=4 || nargout(recFunctionString)~=1
    msg=sprintf('the provided recovery detection function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',recFunctionString);
    errordlg(msg)
    success = 0;
    return
end
functionHandle = str2func(recFunctionString);
success = 1;
