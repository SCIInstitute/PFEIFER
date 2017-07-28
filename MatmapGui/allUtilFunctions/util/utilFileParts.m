function [filename,pathname,tsnumber] = utilFileParts(file)

% FUNCTION [filename,pathname,tsnumber] = utilFileParts(filename)
%
% DESCRIPTION
% Disassemble a filename into its filename the pathname and the
% extension that was added. In the formalism it is allowed to
% specify a timeseries or surface by add '@<number>' to the end 
% of the filename. For instance data.geom@2, points to the second
% surface in the file
%
% INPUT
% filename      The complete filename as entered by the user
%
% OUTPUT
% filename      The bare filename (with extension)
% pathname      The pathname
% tsnumber      The number specified behind @, include the @ (string)
%
% SEE ALSO utilExpandFilenames utilGetFilenames utilStripNumber

% Get the number extension
% This is used in the same way as map3d accesses geometries

index = findstr(file,'@');
if ~isempty(index),
    filename = file(1:index-1);
    tsnumber = file(index:end);
else
    filename = file;
    tsnumber = '';
end

[pn,fn,ext] = fileparts(filename);

pathname = pn;
filename = [fn ext];

return