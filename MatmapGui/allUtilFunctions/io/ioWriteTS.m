function newfilenames= ioWriteTS(varargin)

% function newfilenames = ioWriteTS(filenames,TSindices,[options],[overwrite],[noprompt],[oworiginal])
%
% DESCRIPTION
%  This function writes TSDF and TSDFC-files 
%
% INPUT
% filenames      An cellarray of strings or a string specifying the files to be loaded. The function requires
%                that you specify the filename complete with extension. The use of wildcards in the filenames
%                is allowed. The filenames can be contained in one or more input arguments. The order of the
%                filenames determines the order in which they are written.
%                Files that can be written are .tsdfc and .tsdf.
%                If you want to write the geometry files (.geom/.fac/.pts/.channels) use ioWriteGeom. 
%                1) Specifying a TSDFC-file without any TSDF-files will try to store each timeseries in a new file.
%                The newfile name will be the filename with the newfileext attached to it.
%              	 If the field newfileext is empty  a statement '_copy' will be added. In this way no source tsdf
%                file will be overwriten. If you want to determine the filename completely, delete the field
%                filename and put the new filename in newfileext. This way you control the filenames.
%                However if the new file already exists the function will not allow you to overwrite any tsdf
%                file. In order to unlock this savety feature, state 'overwrite' at the end of the statement.
%                This will cause the function to prompt for each file you are about to overwrite  
%                2) Specifying a series of TSDF-filenames will overrule the standard generated names and saves
%                your files with these names. Be sure to put 'overwrite' if you want to be able to overwrite 
%                existing files and take care that the list of tsdf filenames equals the dimension of TSindices.	
%                3) if you want multiple timeseries in one file, use ioWriteTSDF instead. This function will not
%                allow more than one timeseries per file. 		 
%             	 Note if you want to write fiducials you have to supply a tsdfcfilename. Ohterwise no fiducials will
%                be saved.
%			
%
% TSindices      Specify which timeseries need to be saved
%
% OPTIONS        
% .tsdfconly     Only write the fiducials to an existing or a new tsdfc-file
%
% OPTIONS TO BE SPECIFIED AS EXTRA ARGUMENTS (SO NO MISTAKES ARE MADE AND NO HIDDEN OPTIONS ARE LOCATED IN THE OPTIONS ARGUMENT) 
% 'overwrite'    Unlock overwriting of tsdf-files (originals: the filename in the field filename is not overwritten)
% 'oworiginal'   Unlock overwriting of the original files. If no newfileext is specified the old file will be overwritten
%                With noprompt off a confirmation will be required before replacing the original file.
% 'noprompt'	 Disable prompting a savety check before saving the file (In case a file is overwritten)
%
%
% SEE ALSO ioReadTS ioWriteTSdata ioReadTSdata

% JG Stinstra, 2002

% Changed 2 Apr 2003: added the 'oworiginal' option

writematfiles = 0;
opt.write = 1;
[files,TSindices,options,overwrite,append,noprompt,oworiginal,tsRecord] = ioiInputParameters(varargin,opt); % process the input file names

if ~isfield(options,'tsdfconly'), options.tsdfconly = 0; end
if ~isfield(options,'scirunmat'), options.scirunmat = 0; end

% PS append is not used it is reserved for future usage


if ~isempty(TSindices) & ~isempty(tsRecord)
    msgError('This function needs or indices in the TS structure or structures representing the timeseries data, a combination is not supported yet');
    return;
end

global TS;							% need this one :)

% Here a small trick to support input that has not been stored in the TS database
% All the data that needs to be saved is temporily stored in this array and lateron
% removed again. So we can still use the same mex files. 

if ~isempty(tsRecord)
    TSindices = tsNew(length(tsRecord));
    for p=1:length(tsRecord)
        TS{TSindices(p)} = tsRecord{p};
    end
    tsRecord = 1;
end


if ~isempty(files.dfc)
    msgError('DFC support has not been implemented yet',2);
end

if length(files.tsdfc) > 1
    msgError('Only one tsdfc file can be used for writing fiducials',5);
    return
end    

if (isempty(files.tsdf))&(options.tsdfconly==0)&(isempty(files.mat))

    % Start building a vector with the new filenames
    
    newfilenames = {};
    
    for p =TSindices
    
        [filename,tsnumber] = utilStripNumber(TS{p}.filename);
        [pn,fn,ext] = fileparts(filename);				% remove file extension
        filename = fullfile(pn,fn);				% we know we want to save it as tsdf anyway
        if ~isempty(tsnumber)
            filename = sprintf('%s_%d',filename,tsnumber);	% put the timeseries number at the end if we need one
        end 

        isacq = 0;
        fileexist = 0;
        ismat = 0;
        if strcmp(ext,'.acq') == 1, isacq = 1; end
        if strcmp(ext,'.mat') == 1, ismat = 1; end
        
        if exist([filename '.tsdf'],'file'), fileexist = 1; end   
        
        if (~isfield(TS{p},'newfileext'))
	        if (oworiginal ~= 1) & (ismat ~= 1) & (isacq ~= 1) & (fileexist == 1)
             	TS{p}.newfileext = '_copy';				% if not there just fill out the default
            else
                TS{p}.newfileext = '';
            end
        end    
        newfileext = TS{p}.newfileext;
        
	    if (oworiginal ~= 1) & (ismat ~= 1) & (isacq ~= 1) & (fileexist == 1)				% if the original file is not to be overwritten, we always put a new extenstion at the end of the filename, so we never overwrite original data!
            if isempty(newfileext)
                newfileext = '_copy';
            end
        end
       
        [dummy,fn,ext2] = fileparts(newfileext);
        
        if (strcmp(ext2,'.tsdf') == 1)
            newfilename = [filename newfileext];    
        elseif (strcmp(ext2,'.mat') == 1)
            newfilename = [filename newfileext];
        elseif (strcmp(ext,'.mat') == 1)
            newfilename = [filename newfileext '.mat'];		% propose a new name     
        else
            newfilename = [filename newfileext '.tsdf'];		% propose a new name
        end
        
        newfilenames = [newfilenames {newfilename}];
    end
end

if ~isempty(files.tsdf)
    newfilenames = files.tsdf;
    if length(newfilenames) ~= length(TSindices)
        msgError('The number of filenames and the number of timeseries should be equal',5);
        return
    end    
end


if ~isempty(files.mat)
    newfilenames = files.mat;
    if length(newfilenames) ~= length(TSindices)
        msgError('The number of filenames and the number of timeseries should be equal',5);
        return
    end    
    writematfiles = 1;
end

% SHOULD ADD SOMETHING TO CHECK FOR DUPLICATE NAMES

% Now start writing the files to disk
% We are creating new files and no rewrites

if options.tsdfconly == 0

    for p=1:length(TSindices)

        if ~isempty(files.tsdfc)
            tsdfcfilename = files.tsdfc{1};  % only one tsdfc file is supported
        else
            tsdfcfilename = [];
        end
        
        newfilename = newfilenames{p};
        TSindex = TSindices(p);

        if isempty(tsdfcfilename)
            if isfield(TS{TSindex},'fids')
%                 if isfield(TS{TSindex},'tsdfcfilename')
%                     tsdfcfilename = TS{TSindex}.tsdfcfilename;
%                 else   
%                     fprintf(1,'FIDUCIALS will not be written, no filename available');
%                 end
            elseif isfield(TS{TSindex},'tsdfcfilename')
                tsdfcfilename = TS{TSindex}.tsdfcfilename;
            end
        end        
    
        if exist(newfilename,'file')
            if noprompt ~= 1						% be careful altering these statements as they allow for overwriting files
                question = sprintf('Do you want to replace: %s ?',newfilename);
                result = utilQuestionYN(question);
            else
                result = 1;
            end       
            if (result==1),
                delete(newfilename);					% deletion is done here as the mex functions cannot replace files
                [dummy,dummy2,ext] = fileparts(newfilename);
                if strcmp(ext,'.mat') == 1
                    if options.scirunmat == 1
                        potvals = TS{TSindex}.potvals;
                        scirunWriteMatrix(newfilename,potvals);             % write a scirun file
                    else
                        ts = TS{TSindex};
                        if (sscanf(version,'%d')<7)
                            save(newfilename,'ts');                             % store a matlab file
                        else
                            save(newfilename,'ts','-v6');
                        end    
                    end
                else
                    mexWriteTSDF(newfilename,TS(TSindex));				% store the new file
                    ioWriteTSDFC(tsdfcfilename,newfilename,TSindex);		% store the fiducials
                end
                fprintf(1,'Saving file: %s\n',newfilename);
            else
                fprintf(1,'Could not store file, skipping this one\n');
                newfilenames{p} = ''; 					% delete it so I cannot render a key for it
            end
        else
            [dummy,dummy2,ext] = fileparts(newfilename);
            if strcmp(ext,'.mat') == 1
                if options.scirunmat == 1
                    potvals = TS{TSindex}.potvals;
                    scirunWriteMatrix(newfilename,potvals);             % write a scirun file
                else
                    ts = TS{TSindex};
                    if (sscanf(version,'%d') < 7)
                        save(newfilename,'ts'); % store a matlab file
                    else
                        save(newfilename,'ts','-v6');
                    end
                end
            else
                mexWriteTSDF(newfilename,TS(TSindex));  				% new file
                ioWriteTSDFC(tsdfcfilename,newfilename,TSindex);		% store fiducials
            end
	        fprintf(1,'Saving file: %s\n',newfilename);
        end
    end
else    

    for p=1:length(TSindices)

        TSindex= TSindices(p);
    

        if ~isempty(files.tsdfc)
            tsdfcfilename = files.tsdfc{1};  % only one tsdfc file is supported
        else
            tsdfcfilename = [];
        end
        
       
       if isempty(tsdfcfilename)
            if isfield(TS{TSindex},'fids')
                if isfield(TS{TSindex},'tsdfcfilename')
                    tsdfcfilename = TS{TSindex}.tsdfcfilename;
                else   
                    fprintf(1,'FIDUCIALS will not be written, no filename available\n');    
                end
                
            elseif isfield(TS{TSindex},'tsdfcfilename')
                tsdfcfilename = TS{TSindex}.tsdfcfilename;
            end
        end        
 
        ioWriteTSDFC(tsdfcfilename,TS{TSindex}.filename,TSindex);
    end
    
end            
    
if ~isempty(tsRecord)        % Clear the records once more
    tsClear(TSindices);
end

return    