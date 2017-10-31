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


function result = ioWriteCal8(filename,cal)

% FUNCTION ioWriteCal(filename,cal)
%
% DESCRIPTION
% This function writes a .cal8 file.
% A cal8 file has 8 calibration values per channels (one for each gain setting)
%
% INPUT
% filename   The filename to be used for the .cal file
%            The extension .cal is automatically added
% cal        The vector containing the calibrations
%
% OUTPUT
% -
%
% SEE ALSO ioReadCal8

    [pn,fn,ext] = fileparts(filename);
    filename = fullfile(pn,[fn '.cal8']);
    
    FID = fopen(filename,'w');
    
    if FID < 1
       err = sprintf('Could not open file : %s\n',filename);
       errordlg(err);
       result = 0;
       return
    end
    
    fprintf(FID,'%d\n8\n%d\n',size(cal,1),size(cal,1));
    fprintf(FID,'%7.8f %7.8f %7.8f %7.8f %7.8f %7.8f %7.8f %7.8f\n',cal');
    
    fclose(FID);
    