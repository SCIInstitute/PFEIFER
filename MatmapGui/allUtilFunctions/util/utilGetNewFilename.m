function filename = utilGetNewFilename(statement,myprompt)
% FUNCTION filename = utilGetNewFilename([statement],[prompt])
%
% DESCRIPTION
% This utility returns a new filename. The function is used to get a new filename
% for writing back TSDF or TSDFC-files. It just prompts for a filename and returns
% the string the user entered. No checking is performed on the integrity of the
% filename.
%
% INPUT
% statement       string specifying what should be entered
% prompt          What should be shown at the prompt e.g 'path' or 'filename' etc.
%
% OUTPUT
% filename        string containing the new filename
%
% SEE ALSO utilGetFilenames

if nargin < 1,
    statement = 'please enter a new filename';
end

if nargin < 2,
    myprompt = 'filename';
end


filename = '';
disp(statement);

% Use input to retrieve the filenames
% The while reads until an empty filename is supplied or
% until the maximum number of inputs is reached

filename = input(sprintf('%s >> ',myprompt),'s');

% no wildcards

