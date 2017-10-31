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
    errordlg(err)
    error(err)
end

fgetl(FID); 					% We do need this info, matlab determines by it self how much data there is to read
mapping = fscanf(FID,'%d',[1,inf]);			% scan all numbers

fclose(FID);

return
