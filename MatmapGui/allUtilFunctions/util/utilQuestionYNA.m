function result = utilQuestionYNA(question)
% FUNCTION result = utilQuestionYNA(question)
% 
% DESCRIPTION
% This function puts a question to user and wants a 'yes' or 'no' or 'all' as answer.
%
% INPUT
% Question            String with the question to be answered
%
% OUTPUT
% result              Boolean which is one if the response is positive
%                     and 0 if it is negative.
%                     In case the user quits the function will return to
%                     matlab
%                     If the user specifies 'all' the result will be 2
%
% SEE ALSO -

% Put the question and wait for an answer

result = [];

while (isempty(result)),
    disp(question);
    resultstr = input('y/n/q/a >> ','s');
    switch lower(resultstr)
    case {'y','yes'},
        result = 1;
    case {'q','quit','exit'}
        error('User quit the program');
    case {'n','no'},
        result = 0;
    case {'a','all'},    
    otherwise
        result = 1;
%        disp('You should give a valid answer');
%        result = [];
    end
end    

return    
