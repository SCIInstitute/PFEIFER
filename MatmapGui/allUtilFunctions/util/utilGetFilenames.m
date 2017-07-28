function fnames = utilGetFilenames(options)
% FUNCTION fnames = utilGetFilenames(options)
%
% DESCRIPTION
% This utility returns a list of files the user supplied through the 
% keyboard. The list is returned as a cell array. The function also
% checks the integrity of the filenames. Only filenames that exists
% are returned to the user.
%
% INPUT

%
% OUTPUT
% fnames      Cellarray with the filenames
%
% SEE ALSO utilGetNewFilename, utilExpandFilenames

fnames = {};
disp('please supply the filenames, pressing enter will end the list');

% Use input to retrieve the filenames
% The while reads until an empty filename is supplied or
% until the maximum number of inputs is reached


number = inf; % maximum number
   
if nargin == 0,
    options = [];
end

newfilename = input('filename >> ','s');
numread = 1;

while(~isempty(newfilename)&(numread~=number))
    if ~isempty(newfilename), 
        fnames{end+1} = newfilename; 
        numread = numread + 1;
    end
    newfilename = input('filename >> ','s');
end

% just read the last one if the number of records to read is reached
if ~isempty(newfilename), 
    fnames{end+1} = newfilename; 
    numread = numread + 1;
end

fnames = utilExpandFilenames(fnames,options);

return
