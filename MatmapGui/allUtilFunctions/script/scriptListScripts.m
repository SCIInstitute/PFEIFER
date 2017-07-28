function scriptListScripts
% FUNCTION scriptListScripts
%
% DESCRIPTION
% This function displays a list with all sccripts available.
%
% INPUT -
%
% OUTPUT -
%
% SEE ALSO -

global Program;

disp('---------------------------------------------')
disp('List of available scripts:')
disp(' ')

dir(fullfile(Program.Path,'script','script*.m'))
disp('---------------------------------------------')


return