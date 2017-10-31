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