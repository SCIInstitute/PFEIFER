function filelist = ioReadFiles(filename)
% FUNCTION filelist = ioReadFiles(filename)
%
% DESCRIPTION
% This function reads a filelist from a .files or .filelist file.
% Both files are ascii lists with one filename at each line.
% .files/.filelist files are used to ease the input of filenames
% In the reading process the files contained by the list are read
% The ioReadTS function allows for specifying the input files through
% a .files/.filelist file. 
%
% INPUT
% filename            the filename (no checking of extension)
%
% OUTPUT
% filelist            cellarray with filenames
%
% SEE ALSO ioReadTS

filelist = textread(filename,'%s','delimiter','\n');

% with a single input matlab often returns a string directly
% So in that case put it in a cell array for consistent output

if ischar(filelist),
    temp = filelist;
    filelist = {};
    filelist{1} =temp;
end    

return