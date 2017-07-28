function msgSetErrorLevel(errorlevel,errorwhere)

% function msgSetErrorLevel(errorlevel,errorwhere)
%
% errorlevel - the error level you want to set
% errorwhere - 'cmdline'/'logfile'/'window'
%
% see msgError

% JG Stinstra 2002 

global Program;

if nargin < 1,
    errorlevel = 1;
elseif nargin < 2,
    errorwhere = 'cmdline';
end

if (errorlevel < 1)|(errorlevel > 5),
    msgError('errorlevel needs to be between 1 and 5',3);
    errorlevel = 1;
end

switch errorwhere
case {'cmdline','window','logfile'},
otherwise
    msgError('you need to specify where your error should go to',3);
    errorwhere = 'cmdline';
end

Program.msgError.errorlevel = errorlevel;
Program.msgError.errorwhere = errorwhere;

return