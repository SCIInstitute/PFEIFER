function [files,indices,options,overwrite,append,noprompt,oworiginal,tsRecord] = ioiInputParameters(param,opt)

% FUNCTION [files,indices,options,overwrite,append,noprompt,oworiginal,TSrecord] = ioiInputParameters(param,options)
%
% INTERNAL FUNCTION
%
% DESCRIPTION
% This function processes the data parsed to the general ioReadTS and ioWriteTS.
% The function accepts a cell array in which the input parameters to these functions are
% stored. This function sorts the input and returns the five parameters these io functions
% need.
% This function sorts the files by file type and puts them in a structure. In case files
% are read the function unpacks dfc files and returns only tsdfc files.
%
% INPUT 
% param        input parameter-cell-array
% options      see options
%
% OPTIONS
% .read			check filenames (default)
% .write		skip the check on filenames and do no wildcards
% .readtsdfc    add the contents of the tsdfc-files to the filelist	
% .nocheck      don't check filenames and don't do wildcards
%
% OUTPUT
% files        structured array in which the time series files are sorted
% indices      the indices of the files to be read or the TSindices to be written
% options      the options that are passed to these functions
% overwrite    is one in case overwriting files is allowed
% append       is one in case appending files is allowed
% noprompt     do not prompt before overwriting files
% oworiginal   overwriting the original data is now allowed
% tsRecord    TS records supplied as full data structures
%
% SEE ALSO -

% JG Stinstra 2002 

nParam = length(param);

if nargin == 1
   opt = [];
end

if ~isfield(opt,'write')
    opt.write = 0;
end    

if isfield(opt,'nocheck')     % virtually the same option
    opt.write = 1;
end

% first scan the first cell/string parameters they contain the filenames
% the filenames are put in the cell array filenames.

% main param read loop

filenames = {};
indices = [];
options = [];
overwrite = 0; % do not allow overwrites
append = 0; % do not allow appending files
noprompt = 0; % do always prompt
oworiginal = 0; % do not allow to overwrite original files
tsRecord ={};

% read the parameters
% We are lucky since every parameter is identifiable by its type
% So the actual order of the parameters does not matter

for p = 1:nParam

    if ischar(param{p})
	switch param{p}
	case 'overwrite'
	    overwrite = 1;
	case 'append'
	    append  = 1;
    case 'noprompt'
        noprompt = 1;
	case 'oworiginal'
	    oworiginal = 1;
	otherwise    
	    fnames = utilExpandFilenames(param(p),opt);
	    filenames(end+1:end+length(fnames)) = fnames; 	 
	end
    end	    
	    
    if iscellstr(param{p})    
        fparam = param{p};
	for q = 1:length(fparam)
            fnames = utilExpandFilenames(fparam(q),opt);
	    filenames(end+1:end+length(fnames)) = fnames;
        end
    end

    if iscell(param{p})
        fparam = param{p};
        for q= 1:length(fparam)
            if isstruct(fparam{q})
             	if ((isfield(fparam{q},'filename')==1) || (isfield(fparam{q},'potvals')==1) || (isfield(fparam{q},'tsdfcfilename')==1)),
	            tsRecord{end+1} = fparam{q};
                end 
            end 
         end
    end	
  
    if isnumeric(param{p})
        if ~isempty(param{p})
            indices = [indices param{p}];				% *J Indices can now be passed as a comma separated list as well
        end
    end  
		
    if isstruct(param{p})
	if ((isfield(param{p},'filename')==1) || (isfield(param{p},'potvals')==1) || (isfield(param{p},'tsdfcfilename')==1)),
	    tsRecord{end+1} = param{p};
	else
	    options = param{p};
        end
    end

end

    

% This should have read all input parameters.
% Now sort out the files 

files.tsdf = {};
files.acq = {};
files.ac2 = {};
files.tsdfc = {};
files.dfc = {};   % only used for writing as one might link everyting to the central DFC file
files.fids = {};
files.geom = {};
files.leadlinks = {};
files.mapping = {};
files.cal = {};
files.cal8 = {};
files.mat = {};
files.acqcal = {};
files.bin = {};
files.optraw = {};

for p=1:length(filenames)

    file = filenames{p};

    filename = utilStripNumber(file);
    [~,fn,ext] = fileparts(filename);

    switch ext
        case {'.tsdf','.data','.pak'}
            files.tsdf{end+1} = file;
        case {'.acq'}
            files.acq{end+1} = file;
        case {'.ac2'}
            files.ac2{end+1} = file;
        case '.tsdfc'
            files.tsdfc{end+1} = file;
        case '.dfc'
            % In case of reading expand the dfc files to tsdfc files
            % The expanding is done here

            if opt.write == 0
                tsdfc = ioReadDFCFiles(file);
                files.tsdfc(end+1:end+length(tsdfc)) = tsdfc;
            else
                files.dfc{end+1} = file;
            end
        case {'.mapping','.mux'}
            files.mapping{end+1} = file;
        case '.fids'
            files.fids{end+1} = file;
        case {'.geom','.fac','.pts','.channels'}
            files.geom{end+1} = file;
        case '.leadlinks'
            files.leadlinks{end+1} = file;
        case '.cal'
            files.cal{end+1} = file;
        case '.cal8'
            files.cal8{end+1} = file;
        case '.mat'
            files.mat{end+1} = file;
        case '.acqcal'
            files.acqcal{end+1} = file;
        case '.bin'
            files.bin{end+1} = file;
        case ''
            if (strcmp(fn(1:3),'run'))
                files.optraw{end+1} = file;
            end
    end
end

return
