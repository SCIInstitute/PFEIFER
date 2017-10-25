function [functionHandle, success] = getActFunction
global ScriptData
functionHandle = 'dummy';

%%%% check if there is actually a function there to detect activation
if isempty(ScriptData.ACT_OPTIONS)
    errordlg('Cannot find activation, since no activation detection function is provided. Aborting...')
    success = 0;
    return
end

%%%% now get actFunction (the function selected to detect activation) and check if it is valid
actFunctionString = ScriptData.ACT_OPTIONS{ScriptData.ACT_SELECTION};
if nargin(actFunctionString)~=3 || nargout(actFunctionString)~=1
    msg=sprintf('the provided activation detection function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',actFunctionString);
    errordlg(msg)
    success = 0;
    return
end
functionHandle = str2func(actFunctionString);
success = 1;
