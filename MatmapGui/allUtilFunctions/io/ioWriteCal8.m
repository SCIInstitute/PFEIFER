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
       msgError(err,3);
       result = 0;
       return
    end
    
    fprintf(FID,'%d\n8\n%d\n',size(cal,1),size(cal,1));
    fprintf(FID,'%7.8f %7.8f %7.8f %7.8f %7.8f %7.8f %7.8f %7.8f\n',cal');
    
    fclose(FID);
    