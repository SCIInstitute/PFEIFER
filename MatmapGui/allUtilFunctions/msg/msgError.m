function msgError(errormsg,level)

% function msgError(errormsg,level)
%
% This function displays an error to the user and halts if the
% error is severe enough.
%
% errormsg - a string telling the user what went wrong
% level - severity of the error
%
%       1 - just a warning program can continue
%       2 - have to skip some functionality/ data not present
%       3 - could not load files/so some data is not loaded
%       4 - data in files not ok cannot perform duty
%       5 - general error / no way of continuing
%
% for instance a script you can set the warning level to 3
%      if a file is misspelled it just ignores it and does not
%      load it. 
%     

functionname = dbstack;

% set defaults
errorlevel = 2;
errorwhere = 'cmdline';

global Program

if nargin < 2,
	level = 5;
end

% get settings if present
if isfield(Program,'msgError'),
    errorlevel = Program.msgError.errorlevel;
    errorwhere = Program.msgError.errorwhere;
end

switch errorwhere
case 'cmdline'
    if level >= errorlevel,
	fprintf(1,'FUNCTION : %s LINE : %d\n',functionname(2:end).name,functionname(2:end).line);
	fprintf(1,'ERROR : %s\n',errormsg);
	error('Stopping due to error');
    else
	fprintf(1,'FUNCTION : %s LINE : %d\n',functionname(2:end).name,functionname(2:end).line);
	fprintf(1,'WARNING : %s\n',errormsg);
    end
end



		

