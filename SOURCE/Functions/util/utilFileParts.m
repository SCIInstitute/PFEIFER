% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.


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