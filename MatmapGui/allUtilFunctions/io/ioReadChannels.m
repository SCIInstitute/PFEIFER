function Channels  = ioReadChannels(filename)

% FUNCTION channels  = ioReadChannels(filename)
%
% DESCRIPTION
% This function reads a channels file into a matrix.
%
% INPUT
% filename     name of the file (with or without extension)
%
% OUTPUT
% channels     Matrix containing the translation matrix for channel numbers and geometry
%              The first column matches the geometry node number and the second the 
%              the leadnumber in the tsdf data file.
%              Hence every row in the matrix marks a link between a geometry node and a 
%              measurement channel 
%
% SEE ALSO ioWriteChannels

% JG Stinstra 2002


% First ensure that the file has the correct extension

[pn,fn,ext] = fileparts(filename);

% Try to correct a faulty file name
if strcmp(ext,'channels') == 0, 			% no match
    filename = fullfile(pn,[fn '.channels']);
end

FID = fopen(filename,'r');

if FID < 1,
    err = sprintf('Could not open file : %s\n',filename);
    msgError(err,3);
end

dummy = fgetl(FID); 					% We do need this info, matlab determines by it self how much data there is to read
Channels = fscanf(FID,'%d',[2,inf]);			% scan all numbers

fclose(FID);

Channels = Channels'; 					% Make it appear as in the text files

return
