function newfilenames= ioWriteTSdata(varargin)

% function newfilenames = ioWriteTS(filenames,TSindices,[options],[overwrite],[noprompt],[oworiginal])
%
% DESCRIPTION
%  This function writes TSDF and TSDFC-files. It is a copy ioWriteTS (both do the same thing) 
%
% INPUT
% filenames      An cellarray of strings or a string specifying the files to be loaded. The function requires
%                that you specify the filename complete with extension. The use of wildcards in the filenames
%                is allowed. The filenames can be contained in one or more input arguments. The order of the
%                filenames determines the order in which they are written.
%                Files that can be written are .tsdfc and .tsdf.
%		 If you want to write the geometry files (.geom/.fac/.pts/.channels) use ioWriteGeom. 
%                1) Specifying a TSDFC-file without any TSDF-files will try to store each timeseries in a new file.
%		 The newfile name will be the filename with the newfileext attached to it.
%		 If the field newfileext is empty  a statement '_copy' will be added. In this way no source tsdf
%		 file will be overwriten. If you want to determine the filename completely, delete the field
%                filename and put the new filename in newfileext. This way you control the filenames.
%		 However if the new file already exists the function will not allow you to overwrite any tsdf
%                file. In order to unlock this savety feature, state 'overwrite' at the end of the statement.
%		 This will cause the function to prompt for each file you are about to overwrite  
%		 2) Specifying a series of TSDF-filenames will overrule the standard generated names and saves
%		 your files with these names. Be sure to put 'overwrite' if you want to be able to overwrite 
%                existing files and take care that the list of tsdf filenames equals the dimension of TSindices.	
%		 3) if you want multiple timeseries in one file, use ioWriteTSDF instead. This function will not
%                allow more than one timeseries per file. 		 
%		 Note if you want to write fiducials you have to supply a tsdfcfilename. Ohterwise no fiducials will
%                be saved.
%			
%
% TSindices      Specify which timeseries need to be saved
%
% OPTIONS        
% .tsdfconly     Only write the fiducials to the original or a new tsdfc-file
%
% OPTIONS TO BE SPECIFIED AS EXTRA ARGUMENTS (SO NO MISTAKES ARE MADE AND NO HIDDEN OPTIONS ARE LOCATED IN THE OPTIONS ARGUMENT) 
% 'overwrite'    Unlock overwriting of tsdf-files (originals: the filename in the fieldfilename are not overwritten)
% 'oworiginal'   Unlock overwriting of the original files. If no newfileext is specified the old file will be overwritten
%                With noprompt off a confirmation will be required before replacing the original file.
% 'noprompt'	 Disable prompting a savety check before saving the file (In case a file is overwritten)
%
%
% SEE ioReadTSdata

% Just call ioWriteTS
newfilenames = ioWriteTS(varargin{:});

