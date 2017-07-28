function TS = ioiReadACQdata(varargin)

% FUNCTION TS = ioiReadACQFdata(tsdffilename,[indices],[options])
%
% INTERNAL FUNCTION
% Avoid using this function, as it might change in the future
% Use ioReadTS instead
%
% DESCRIPTION
% This function reads one ACQ file into a structure (not the TS-structure). The function is based on
% mexReadTSDF, but has some additional functionality, for instance it adds data on where
% the data originated from, so when using ioWriteTSDF it knows what filenames to use by
% default. 
% 
% INPUT
% acqfilename          A single acq-filename for reading
% indices               In case multiple timeseries are stored, select the ones needed
% options               For future usage
%
% OUTPUT
% TSindices             Cell with TS-structure where the data has been loaded
%
% SEE ALSO ioReadTS, ioWriteTSDF, ioWriteTS


[files,~,options] = ioiInputParameters(varargin);

acqfilename = files.acq{1};
TSindices = [];

if isempty(acqfilename),
    msgError('No ACQ-file specified',3);
    return;
end    

% Depending on whether a set of indices is specified all timeseries will be read
% or only the indicated ones

			 
      TS = mexReadACQ(acqfilename,options);				% load the timeseries into memory   
%%
% Add some more fields
% Since the sample frequency is not recorded in the data, matlab adds this datafield
% in the audit string. So here I scan whether I can retrieve  this data field.
% If not I assume the default samplefrequency. Lateron the user can change the field
% if he/she knows the actual one
% add as well a field to store an additional filename extesion, since we are not overwriting
% old files this option can be used to put an extension depending on the computation the 
% program did. This will help you to standardise names 


    TS{1}.newfileext = ''; % extension for the new filename
  

return