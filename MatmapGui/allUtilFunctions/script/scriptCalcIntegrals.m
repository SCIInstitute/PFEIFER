function scriptCalcIntegrals(varargin)
% FUNCTION scriptCalcIntegrals([filenames],[options])
%
% DESCRIPTION
% This script helps in creating integral maps. The script will help you select the files which
% need to be converted into integralmaps. You will be prompted to determine which integrals you
% want to compute. Subsequently the fiducials will be retrieved from the timeseries structure to
% determine the starting point and the ending point of the integration. Each integral will be 
% stored in a new timeseries data structure. If you supply more than one timeseries, the integrals
% will be computed for each timeseries you supply. The maps will be sorted by type and all maps of
% the same type (say QRST-map) will be put in one file. So when processing an experiment consisting 
% of multiple measurements in a row, the map will have all subsequent maps in one files.
% The script will ask you for filenames, please supply a TSDF-filename(s) and a TSDFC-filename.
% After computing the maps, you will be asked to supply a name for the integralmaps. An extension
% will be added to this name, determing the type of integral. You do not need to worry about this
% extension, it will be added automaticly. 
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
% EXAMPLES
%
% >> scriptCalcIntegrals
% This will ask you for the filenames in the program and uses default options
%
% >> options.leadmap = [1:128]
% >> scriptCalcIntegrals(options)
% This will do the script only for the first 128 leads in the files, of course this option can be
% specified through the menu as well.
%
% test.files contains:
%  tsdffile1.tsdf
%  tsdffile2.tsdf
%  tsdfcontainer.tsdfc
%  tsdffile3.tsdf
%
% >> scriptCalcIntegrals('test.files')
% This will load the three tsdf-files and assumes tsdfcontainer to have the fiducials
%
% SEE ALSO -

format long;  % print long strings as well, just for convenient displaying

% define some vectors for storing pointers to the timeseries

[filenames,options] = utilFilterInput(varargin); 

timeseries = [];
intindex = [];

% catch any error/ so I can clean up afterwards. If  an error occurs matlab will jump to catch. (try/catch/end)-statement.
% In the catch statement the files loaded in the globals will be discarded.
try

clc
disp('-------------------------------------------------');
disp('SCRIPT CALCULATE INTEGRALS');
disp(' ');
disp('This script helps you generating various integralmaps');
disp('The script is subdivided into a couple of steps');
disp(' ');
disp('STEP 1 - Get the filenames of the experiment');
disp('STEP 2 - Determine whether the files need to be remapped');
disp('STEP 3 - Deterine the number of output files');
disp('STEP 4 - Determine the output directory');
disp('STEP 5 - Specify which integrals need to be computed');
disp('STEP 6 - Specify an output name');

disp('--------------------------------------------------');
disp('In order to make an integralmap several timeseries files can be used');
disp(' ')
disp('In order to make a map in which each frame represents a successive timeinstant');
disp('you must specify the files in the correct order (chronologically), thus first');
disp('the integral map that must appear at frame one and so on');
disp(' ');
disp('Wildcards may be used, if you working on a unix compatible system');
disp('See an unix handbook on the use of wildcards');
disp(' ');
disp('In order to retrieve the fiducials, please specify the tsdfc file in');
disp('which the fiducials can be found. A dfc-file is allowed as well');
disp(' ');
disp('Files may be entered through a file as well, specify a .files file, which');
disp('lists the files you want to process');
disp(' ');
disp('Before going to the next step, the files you supplied will be listed and');
disp('you will be asked whether the list is correct');

% Do the input stuff with the user
% The code should be easy to read

fileopt.readtsdfc = 1;  % if no tsdf is supplied get the names from the tsdfc

if nargin == 0,
    filenames = utilGetFilenames(fileopt);
else
    filenames = utilExpandFilenames(filenames,fileopt); 
end

disp('The filenames are');    
disp(filenames);

while (~utilQuestionYN('Is this list correct?'))
    disp('Please supply the filenames again...');
    filenames = utilGetFilenames(fileopt);
    disp('The filenames are');    
    disp(filenames);
end

%%%%%%%%%%%% Ask for remapping options %%%%%%%%%%%%%

clc
disp('-----------------------------------------------------------------------------------')
options = subscriptRemapping(options);


%%%%%%%%%%%% Put some questions %%%%%%%%%%%%%%%%%%%%

clc
disp('-------------------------------------------------');
disp('You can put the selected files into one tsdf-file with every');
disp('frame being a integral map or you can put every integral map');
disp('into a single tsdf-file');
disp(' ');


onefile = utilQuestionYN('Do you want the maps to be put into one tsdf-file');

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

clc
disp('-------------------------------------------------');
disp('Select the integrals you want compute');
disp(' ');

qrsint = utilQuestionYN('Do you want to compute the QRS integral?');
qrstint = utilQuestionYN('Do you want to compute the QRST integral?');
st80int = utilQuestionYN('Do you want to compute the ST80 integral?');
sttint = utilQuestionYN('Do you want to compute the STT integral?');
stint = utilQuestionYN('Do you want to compute the ST integral?');

if onefile,


    % Load all timeseries into memory
    % timeseries will be index array to all of them

    % A more memory efficient scheme may be adapted in the future
    % Loading them one by one

    disp(' ');
    disp('Loading files..... ');

    timeseries = ioReadTS(filenames,options); 

    % create an empty index in which we will store the integralmaps

    intindex = [];

    % Check whether the user wants the QRS integral
    % if so compute it and add the indices to the intindex array
    % the latter we need to record which timeseries need to be written
        % to file

    if qrsint,  intindex = [intindex fidsIntQRS(timeseries)];  end
    if qrstint, intindex = [intindex fidsIntQRST(timeseries)]; end
    if st80int, intindex = [intindex fidsIntST80(timeseries)]; end
    if stint,   intindex = [intindex fidsIntST(timeseries)];   end
    if sttint,  intindex = [intindex fidsIntSTT(timeseries)];  end
       
    % So we got the integrals 
    % Now we need a name to save them
    
    clc
    disp('-------------------------------------------------');
    disp('The integrals have been computed');
    disp('You need to supply a filename for saving the files');
    disp('Note that each integral will be given an extension automaticly');
    disp('The filename supplied may be an existing tsdf file');
    disp('If the filename after adding the extension exists the script');
    disp('will not overwrite any existing files, but will ask you whether');
    disp('the file can be replaced');

    % set the filename of the integralmaps to a new name that the user decides

    filename = utilGetNewFilename; 
    tsSet(intindex,'filename',filename);		
    
    disp('Saving files.......');

    if ~nonewdir, cd(newdir); end
    ioWriteTS(intindex);

    cd(olddir);    
    
    % Clean up
    if ~isempty(intindex) tsClear(intindex); end
    if ~isempty(timeseries) tsClear(timeseries); end

else

    tsdffiles = utilSelectFilenames(filenames,'.tsdf');
    tsdfcfiles = utilSelectFilenames(filenames,'.tsdfc');
    
    disp('--------------------------------------------------');
    disp('You can choose between automatic filename generation and');
    disp('a new filename for each file, in the latter case you need to');
    disp('supply a new filename for each integral map');
    disp(' ');
    
    autoname = utilQuestionYN('Do you want to use automatic filename generation?');
    
    for p=1:length(tsdffiles),
    
        timeseries = ioReadTS(tsdffiles{p},tsdfcfiles,options);
        
        disp(' ');
        disp(sprintf('loading file %s',tsdffiles{p}));
        
        intindex = [];
        
        if qrsint,  intindex = [intindex fidsIntQRS(timeseries)];  end
        if qrstint, intindex = [intindex fidsIntQRST(timeseries)]; end
        if st80int, intindex = [intindex fidsIntST80(timeseries)]; end
        if stint,   intindex = [intindex fidsIntST(timeseries)];   end
        if sttint,  intindex = [intindex fidsIntSTT(timeseries)];  end

        if ~autoname,
            disp('Enter new filename (extensions are added automaticly)');
            filename = utilGetNewFilename; 
            tsSet(intindex,'filename',filename);	
        end

        disp('Saving files.......');

        if ~nonewdir, cd(newdir); end
        ioWriteTS(intindex);
        cd(olddir);    
            
        % Clean up
        if ~isempty(intindex) tsClear(intindex); end
        if ~isempty(timeseries) tsClear(timeseries); end
        
    end
end

disp('Files saved!!');
disp('-------------------------------------------------');
disp('End of script');


catch
% Clean up mess

disp('Failure, an error occured');
disp(lasterr);

if ~isempty(intindex) tsClear(intindex); end
if ~isempty(timeseries) tsClear(timeseries); end
end

