function cal  = ioReadCal8(filename)

% FUNCTION cal = ioReadCal8(filename)
%
% DESCRIPTION
% This function reads a .cal8 file into a matrix.
% A .cal8 file contains the calibration for multiple gain settings
%
% INPUT
% filename     name of the file (with or without extension)
%
% OUTPUT
% cal          vector with the calibration information
%
% SEE ALSO ioReadMaping

% JG Stinstra 2002


% First ensure that the file has the correct extension

cal = [];

[pn,fn,ext] = fileparts(filename);

% Try to correct a faulty file name
switch ext
case {'.cal8'},
    % do nothing
otherwise    
    filename = fullfile(pn,[fn '.cal8']);
end

FID = fopen(filename,'r');

if FID < 1,
    err = sprintf('Could not open file : %s\n',filename);
    msgError(err,3);
    return
end

dummy = fgetl(FID); 					% We do need this info, matlab determines by it self how much data there is to read
dummy = fgetl(FID); dummy = fgetl(FID);                 % There are three lines with data we discard 
cal = fscanf(FID,'%f',[8,inf]);			% scan all numbers

fclose(FID);

cal = cal';

return
