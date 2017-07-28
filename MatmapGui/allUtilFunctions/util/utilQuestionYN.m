function result = utilQuestionYN(question)
% FUNCTION result = utilQuestionYN(question)
% 
% DESCRIPTION
% This function puts a question to user and wants a yes or no as answer.
% If 'y', 'Y', 'yes' or 'YES' is replied a positive answer is assumed.
% Otherwise a negative response is assumed
%
% INPUT
% Question            String with the question to be answered
%
% OUTPUT
% result              Boolean which is one if the response is positive
%                     and 0 if it is negative.
%                     In case the user quits the function will return to
%                     matlab
%
% SEE ALSO

% Put the question and wait for an answer

result = [];

while (isempty(result)),
    disp(question);
    resultstr = input('y/n/q >> ','s');
    switch lower(resultstr)
    case {'y','yes'},
        result = 1;
    case {'q','quit','exit'}
        error('User quit the program');
    case {'n','no'},
        result = 0;
    otherwise
        result = 1;
%        disp('You should give a valid answer');
%        result = [];
    end
end    

return    
