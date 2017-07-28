function files = utilExpandFilenames(filearray,options)
% FUNCTION files = utilExpandFilenames(filename,options)
%
% DESCRIPTION
% This function decodes a filename (string) or a set of filenames (cellarray)
% It basicly decodes wildcards and returns the full list described by the
% string or cellarray. It also checks whether files exist. non-existing ones
% will be discarded.
%
% INPUT
% filename              the filename (string) or a set of filenames (cellarray)
% options		options structure
%
% OPTIONS
% .read			check filenames (default you not need to specify this one)
% .write		skip the check on filenames and do no wildcards
% .readtsdfc		add the contents of the tsdfc-files to the filelist if no tsdf files are supplied
%
% OUTPUT
% files                 The encoded filenames in a cell array
%
% SEE ALSO utilGetFilenames


% this function expands any wildcards they may have been entered and preprocesses the filenames
% the function returns a cell array

% if it is a string just convert it to a cellarray of dimension one

if nargin == 1,
    options = [];
end    

if ischar(filearray),
    filename = filearray;		% conserve filename
    filearray = {};			% make it a cellarray
    filearray{1} = filename;		% it is a cellarray now
end    

% initiate an empty array

files = {};
    
% Do the main loop over all cells

if ~isfield(options,'write'), options.write = 0; end
if ~isfield(options,'readtsdfc'), options.readtsdfc = 0; end

if options.write == 0,
    for r= 1:length(filearray)

        file = filearray{r};
    
        % first check whether it has been indicated that only one surface/timeseries has to be read
        % split the string using the '@' character. This extension does not belong to the filename and hence
        % has to be discarded first.

        [filename,pathname,ext] = utilFileParts(file);
    
        filename = fullfile(pathname,filename);
    
        % the filename has now been split in two parts
        % handle wildcards using the build in function dir


        % since dir only returns filenames, get the pathname separately

        filelist = {};

        if ~isunix,
            fnames = dir(filename); % handle wildcards using dir
            if length(fnames) == 0,
                msgError('could not find file',3);
            end
            p = 1;
            for q = 1:length(fnames),
                if fnames(q).isdir == 0,
                    filelist{p} = fullfile(pathname,[fnames(q).name ext]);
                    p = p + 1;
                end
            end
        else
            % command = sprintf('!ls -1 %s 2>/dev/null',filename); 	% use unix wildcards
            command = sprintf('!ls -1 %s',filename);
            fnames = evalc(command);			% let unix solve our problem
            if strncmp(fnames,'ls:',3), fnames = ''; end
            if isempty(fnames),				% since error is diverted, an empty string means an error
                filelist = {};
                fprintf(1,'Cannot decode filename (file does not exist): %s\n',filename);
            else						
                filelist = strread(fnames,'%s')';		% read all filenames into a matlab cell array'
                for q = 1:length(filelist),
                    filelist{q} = fullfile('',[filelist{q} ext]);
                end
            end    
        end

        % sort the from one filename expanded filelist alphabetically
        filelist = sort(filelist); 

        % add the list to the files list
    
        files = [files filelist]; 
    end
else
    files = filearray;
end    

% Since the user can supply a filelist using a .files file
% We need to scan whether such a filename is supplied

% The next loop filters the input for .files or .filelist 
% files, when one is found the filelist is read into memory
% The input is parsed to this function once again to be 
% certain that no .files or wildcards were specified in the
% filelist itself

newfiles = {}; 		% define an empty array

for r=1:length(files),
    file = files{r};
    
    % Remove any appended @number statement from the file name
    % We need to have the real filename
    
    filename = utilStripNumber(file);
    [pn,fn,ex] = fileparts(filename);
    
   filelist = {};
    
    switch ex
    case {'.files','.filelist'}
        filelist = ioReadFiles(filename);	% read filelist
        filelist = utilExpandFilenames(filelist,options); % process those names as well
    otherwise
        filelist{1} = file;
    end

    newfiles = [newfiles filelist];
end

files = newfiles;


if options.readtsdfc == 1,
    if isempty(utilSelectFilenames(files,'.tsdf')),
        tsdfcfiles = utilSelectFilenames(files,'.tsdfc');
        for p=1:length(tsdfcfiles),
            files = [ files ioiReadTSDFCFiles(tsdfcfiles{p})];
        end    
    end
end
return