function string= utilGetString(statement,myprompt)
% FUNCTION string = utilGetString([statement],[prompt])
%
% DESCRIPTION
% This utility returns a string from the input. It prompts an input
% and retrieves the string the user entered 
%
% INPUT
% statement       string specifying what should be entered 
%                 (default = 'enter string')
% prompt          What should be shown at the prompt e.g 'path' or 'filename' etc.
%                 (default ='string')
%
% OUTPUT
% string       string containing the entered string
%
% SEE ALSO utilGetFilenames

if nargin < 1,
    statement = 'please enter string';
end

if nargin < 2,
    myprompt = 'string';
end

string = '';
disp(statement);
string = input(sprintf('%s >> ',myprompt),'s');

return