function fullAutoFiducializingOfFile
% this function will replace the 'processAcq' function in the main loop of myProcessing Script

global myScriptData TS XXX


%%%% set up stuff for testing %%%   stuff that will be removed later on
XXX.RunToStartWith = '0137';
XXX.FiducialTypes = [ 2 4 5 7 6]; 



%%%% if XXX not set up, set it up now
if ~isfield(XXX,'settedUp')
    XXX.settedUp = 1;
    setUpStuff
end



%%%% get the template beat for autofiducializing
if XXX.FirstFile % if first time, no templates set yet
    getBeatTemplate    
    XXX.FirstFile = 0;
elseif round(XXX.BeatCounter/XXX.BeatIntervall) == XXX.BeatCounter/XXX.BeatIntervall   % if it has been XXX.BeatIntervall beats since beat template has been updated
    updateBeatTemplate
end

    
    
%%%% load file into TS
index = loadAndPreprocessFiles;




















%%%%%%%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function getBeatTemplate
% get the first processed beat as template

%%%% load XXX.RunToStartWith
pathToProcessed = '/usr/sci/cibc/Maprodxn/InSitu/17-06-30/Data/Processed';  % not needed atm but nice to have

fullPathToTemplateFile = [pathToProcessed 'Run' XXX.RunToStartWith '-ns.mat'];
load(fullPathToTemplateFile)


%%%% get selframes  (start end index)

beatTemplateIndeces = [ts.selframes(1):ts.selframes(2)];










function updateBeatTemplate
% get a new beatTemplate (fids and beatkernel) based on the last XXX.NumToAverageOver beats



function setUpStuff
global XXX

XXX.BeatIntervall = 30;    % after how many beats should template be updated? 
XXX.NumToAverageOver = 5;  % how many beats to average over to get new beat template?



function index = loadAndPreprocessFiles
olddir = pwd;
global myScriptData TS myProcessingData;

%%%%% create cellaray files={full acqfilename, mappingfile, calibration file}, if the latter two are needet & exist    
filename = fullfile(inputfiledir,inputfilename);
files{1} = filename;
isMatFile=0;
if contains(inputfilename,'.mat'), isMatFile=1; end


% load & check mappinfile
mappingfile = myScriptData.RUNGROUPMAPPINGFILE{myScriptData.CURRENTRUNGROUP};
if isempty(mappingfile)
    myScriptData.RUNGROUPMAPPINGFILE{myScriptData.CURRENTRUNGROUP} = '';
elseif ~exist(mappingfile,'file')
    msg=sprintf('The provided .mapping file for the Rungroup %s does not exist.',myScriptData.RUNGROUPNAMES{myScriptData.CURRENTRUNGROUP});
    errordlg(msg);
    error('problem with mappinfile.')
else
    files{end+1}=mappingfile;  
end    

if myScriptData.DO_CALIBRATE == 1 && ~isMatFile     % mat.-files are already calibrated
    if ~isempty(myScriptData.CALIBRATIONFILE)
        if exist(myScriptData.CALIBRATIONFILE,'file')
            files{end+1} = myScriptData.CALIBRATIONFILE;
        end
    end
end
    

%%%%%%% read in the files in TS.  index is index with TS{index}=current ts
%%%%%%% structure
    if isMatFile
        index=ioReadMAT(files{:});
    else
        index = ioReadTS(files{:}); % if ac2 file
    end
    
    
%%%%% make ts.filename only the filename without the path

[~,filename,ext]=fileparts(TS{index}.filename);
TS{index}.filename=[filename ext];
    
    
    
    
    
%%%%%% check if dimensions of potvals are correct, issue error msg if not
if size(TS{index}.potvals,1) < myScriptData.MAXLEAD{myScriptData.CURRENTRUNGROUP}
    errordlg('Maximum lead in settings is greater than number of leads in file');
    cd(olddir);
    error('ERROR');
end
cd(olddir)


%%%%  store the GBADLEADS also in the ts structure (in ts.leadinfo)%%%% 
badleads=myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP};
TS{index}.leadinfo(badleads) = 1;

%%%%% do the temporal filter of current file %%%%%%%%%%%%%%%%
if myScriptData.DO_FILTER      % if 'apply temporal filter' is selected
    if 0 %isfield(myScriptData,'FILTER')     % this doesnt work atm, cause buttons for Filtersettings etc have been removed
        myScriptData.FILTERSETTINGS = [];
        for p=1:length(myScriptData.FILTER)
            if strcmp(myScriptData.FILTER(p).label,myScriptData.FILTERNAME)
                myScriptData.FILTERSETTINGS = myScriptData.FILTER(p);
            end
        end
    else
        myScriptData.FILTERSETTINGS.B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
        myScriptData.FILTERSETTINGS.A = 1;
    end
    temporalFilter(index);    % no add audit? shouldnt it be recordet somewhere that this was filtered??? TODO
end