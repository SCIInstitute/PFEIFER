function scriptActivationMap(varargin)
% FUNCTION scriptActivationMap(filenames,[options])
%
% DESCRIPTION
% This script helps in creating an activation map. The script will help you select the files which
% need to be converted into an activationmap. Subsequently it will extract the activation fiducials
% and store them in a new timeseries. In case you have a series of timeseries data that all are part
% of the same experiment you can add the activationmaps of each in one frame of the activationmap
% data. The activationmap uses the same structure as the timeseries, only now each frame as a time-
% series. The newly created map will be saved as a TSDF-file. You will be asked to supply a name for
% it. As input you need to specify a TSDFC-file and optional the TSDF-filenames which will be used as
% keys. Since the contents of the TSDF-files is ignored they do not necessarily have to be in the same
% directory.  
%
% INPUT
% filenames     a string with a filename, a cellarray with multiple filenames, or a .files file
%               specifying the files you want to use. The filename list must include a tsdfc-file
%               or a list of fids-files and of course the tsdf-files you want to process.    
% options       addional options for loading such as remapping the leads or frames. In case you want
%               to specify options and no filenames, just put an empty array [] in filenames. This
%               will ignore this argument
%
% OUTPUT	
%  -
%
% OPTIONS
% Options can be defined as a structured array with fields specifying the options. Hence an option
% is a fieldname and its contents. Default options do not need to be specified (do not include the field)
% Here is a list of options you can use (will be extended in future)
%
% .framemap      specifies which frames you want to read e.g. [1:20] reads the first twenty
%                default is all.
% .leadmap       specifies which leads you want to read e.g [1 3 5 6 7] reads channels 1,3,5,6,7
%                default is all
%
% SEE ALSO -

format long;  % print long strings as well, just for convenient displaying

% define some vectors for storing pointers to the timeseries

[filenames,options] = utilFilterInput(varargin);

timeseries = [];
mapindex = [];

% catch any error/ so I can clean up afterwards. If an error occurs matlab will jump to catch. (try/catch/end)-statement

%try
										
clc
disp('-------------------------------------------------');
disp('SCRIPT MAKE ACTIVATIONMAP');
disp(' ');
disp('This script helps you generating an activation map');
disp('The script is subdivided into a couple of steps');
disp(' ');
disp('STEP 1 - Get the filenames of the experiment involved');
disp('STEP 2 - Determine whether the files need to be remapped');
disp('STEP 3 - Specify an output directory');
disp('STEP 4 - Specify an output name');

disp('--------------------------------------------------');
disp('In order to make an activationmap several timeseries files can be used which will');
disp('form each one frame in the activationmap tsdf')
disp(' ')
disp('In order to make a map in which each frame represents a successive timeinstant');
disp('you must specify the files in the correct order (chronologically), thus first');
disp('the activation map that must appear at frame one and so on...');
disp(' ');
disp('Wildcards may be used, if you working on a unix compatible system');
disp('See an unix handbook on the use of wildcards');
disp(' ');
disp('In order to retrieve the fiducials, please specify the tsdfc file in');
disp('which the fiducials can be found. A dfc-file is allowed as well');
disp('Specify the tsdf files as well, they will not be read, only the key will be retrieved')
disp(' ');
disp('Files may be entered through a file as well, specify a .files file, which');
disp('lists the files you want to process');
disp(' ');
disp('Before going to the next step, the files you supplied will be listed and');
disp('need your approval before continuing');

% Do the input stuff with the user
% The code should be easy to read

fileopt.readtsdfc = 1;  % if no tsdf is supplied get the names from the tsdfc

if isempty(filenames),
    filenames = utilGetFilenames(fileopt);
else
    filenames = utilExpandFilenames(filenames,fileopt); 
end

disp('The filenames are');    
disp(filenames);

while (~utilQuestionYN('Is this list correct?'))
    disp('Please supply the filenames again...');
    filenames = utilGetFilenames;
    disp('The filenames are');    
    disp(filenames);
end

%%%%%%%%%%%% Ask for remapping options %%%%%%%%%%%%%

clc
disp('-----------------------------------------------------------------------------------')
options = subscriptRemapping(options);


clc
disp('-------------------------------------------------');
disp('In which directory do you want to store the output');
disp(' ');

nonewdir = utilQuestionYN('Do you want to store the maps in the current directory');
olddir = pwd;

if ~nonewdir,
    disp('Enter file path');
    newdir = utilGetNewFilename;
    if ~exist(newdir,'file'),
        disp('Creating new directory');
        mkdir(newdir);
    end
end        

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Load all timeseries into memory
% timeseries will be index array to all of them

% A more memory efficient scheme may be adapted in the future
% Loading them one by one

clc
disp(' ');
disp('Loading files..... ');

options.skiptsdffile = 1; 	% Do not read the tsdffiles themselves use them as key only

timeseries = ioReadTS(filenames,options); 

% create an empty index in which we will store the activation-maps

mapindex = actActMap(timeseries);

disp('-------------------------------------------------');
disp('You need to supply a filename for saving the activationmap');
disp('Note that the activationmap will be given an extension automaticly');
disp('The filename supplied may be an existing tsdf file');
disp('If the filename after adding the extension exists the script');
disp('will not overwrite any existing files, you will be asked permission');
disp('for replacing files');

% set the filename of the integralmaps to a new name that the user decides

filename = utilGetNewFilename; 
tsSet(mapindex,'filename',filename);		% just get only the first as the user might trick me by supplying wildcards

disp('Saving files.......');

if ~nonewdir, cd(newdir); end
fnames = ioWriteTS(mapindex);
cd(olddir);

disp('The new files are');
disp(fnames);
disp('Files saved!!');
disp('-------------------------------------------------');
disp('End of script');

% Clean up
if ~isempty(mapindex) tsClear(mapindex); end
if ~isempty(timeseries) tsClear(timeseries); end

%catch

% Clean up mess

%disp('Failure, an error occured');
%disp(lasterr);

%if ~isempty(mapindex) tsClear(mapindex); end
%if ~isempty(timeseries) tsClear(timeseries); end

%end

