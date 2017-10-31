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
case {'.cal8'}
    % do nothing
otherwise    
    filename = fullfile(pn,[fn '.cal8']);
end

FID = fopen(filename,'r');

if FID < 1
    err = sprintf('Could not open file : %s\n',filename);
    errordlg(err);
    error(err)
end

dummy = fgetl(FID); 					% We do need this info, matlab determines by it self how much data there is to read
dummy = fgetl(FID); dummy = fgetl(FID);                 % There are three lines with data we discard 
cal = fscanf(FID,'%f',[8,inf]);			% scan all numbers

fclose(FID);

cal = cal';

return
