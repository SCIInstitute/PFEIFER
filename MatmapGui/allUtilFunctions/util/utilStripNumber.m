function [filename,tsnumber] = utilStripNumber(file)

% FUNCTION [filename,tsnumber] = utilStripNumber(filename)
%
% DESCRIPTION
% Just strip any number specified at the end of a filename
% The number is specified after the '@' character
%
%
% INPUT
% filename      The complete filename as entered by the user
%
% OUTPUT
% filename      The bare filename (with extension and pathname)
% tsnumber      Number of the extension (double not a string)
%
% SEE ALSO utilExpandFilenames utilGetFilenames utilFileParts

% Get the number extension
% This is used in the same way as map3d accesses geometries

index = findstr(file,'@');
if ~isempty(index),
    filename = file(1:index-1);
    tsnumber = sscanf(file(index+1:end),'%d');
else
    filename = file;
    tsnumber = [];
end

return