function [fids,fidset] = ioReadFidsFile(filename)
% FUNCTION [fids,fidset] = ioReadFidsFile(filename)
%
% DESCRIPTION
% function for reading '.fids' files
% the function returns the fids and fidset structures which
% correspond to the fids file
%
% INPUT
% filename     the filename of the fids-file (no checking on extension)
%
% OUTPUT
% fids         fidset broken down in pieces
% fidset       array stating where the fidset came from
%
% SEE ALSO ioReadFids

FID = fopen(filename,'r');
if (FID==0),
    msgError('Could not open fids-file',3);
    return
end    

values = fscanf(FID,'%d',7);
types = [18 2 3 4 5 6 7];
fclose(FID);    

fidset{1}.filename = filename;   					% Where do the fiducials come from
fidset{1}.label = sprintf('FIDSFILE: %s',filename);			% Generate a new label
fidset{1}.audit = sprintf('MATLAB GENERATED:  ioReadFids()');		% Generate an audit log

    
for p=1:6,								% Store the fiducials
    fids(p).value = values(p+1);
    fids(p).type = types(p+1);
    fids(p).fidset = 1;
end

return    