function mapping  = ioReadMapping(filename)

% FUNCTION mapping  = ioReadMapping(filename)
%
% DESCRIPTION
% This function reads a .mapping file into a matrix.
%
% INPUT
% filename     name of the file (with or without extension)
%
% OUTPUT
% mapping      vector with the mapping information
%
% SEE ALSO ioReadChannels

% JG Stinstra 2002


% First ensure that the file has the correct extension

mapping = [];

[pn,fn,ext] = fileparts(filename);

% Try to correct a faulty file name
switch ext
case {'.mapping','.mux'}
    % do nothing
otherwise    
    filename = fullfile(pn,[fn '.mapping']);
end

FID = fopen(filename,'r');

if FID < 1
    err = sprintf('Could not open file : %s\n',filename);
    msgError(err,3);
    return
end

fgetl(FID); 					% We do need this info, matlab determines by it self how much data there is to read
mapping = fscanf(FID,'%d',[1,inf]);			% scan all numbers

fclose(FID);

return
