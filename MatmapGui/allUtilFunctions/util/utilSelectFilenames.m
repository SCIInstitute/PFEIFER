function files = utilSelectFilenames(filename,extension,options)
% FUNCTION files = utilSelectFilenames(filename,extension,options)
%
% DESCRIPTION
% This function selects the files from the array with the specified extension.
%
% INPUT
% filename              the filename (string) or a set of filenames (cellarray)
% extension		extension (string) or cell array with extensions
% options		options structure
%
% OPTIONS
% .read			check filenames (default)
% .write		skip the check on filenames and do no wildcards
% .readtsdfc		add the contents of the tsdfc-files to the filelist
%
% OUTPUT
% files                 The selected filenames
%
% SEE ALSO utilGetFilenames

if nargin == 2,
    options = [];
end  

files = {};

for p = 1:length(filename)

    fn = utilFileParts(filename{p});
    [dummy,dummy2,ext] = fileparts(fn);

    switch ext
    case extension
        files{end+1} = filename{p};
    end
end