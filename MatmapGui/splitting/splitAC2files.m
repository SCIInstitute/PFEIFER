function splitAC2files(handle)
% callback to 'Split Files'

%%%% get all necessary inputs. If you plan to use this function outside of matmap, this (and 'frames', see getFrames function) is all you need to change:

global myScriptData
inputdir=myScriptData.ACQDIR;
outputdir=myScriptData.SPLITDIR;
allInputFiles=myScriptData.ACQFILENAME; %cell array of all files that are converted into .mat files, not just the ones to be splitted
calfile=myScriptData.CALIBRATIONFILE;  % path to .cal8 file
DO_CALIBRATION=myScriptData.CALIBRATE_SPLIT;  % do you want to calibrate files as you convert them into .mat files?
idx2beSplitted=myScriptData.FILES2SPLIT;  % indices of the files in allInputFiles, that will be splitted..


%%%% start here, first check input:
if isempty(outputdir)
    errordlg('No output dir for matfiles given.')
    return
elseif DO_CALIBRATION && isempty(calfile)
    errordlg('No calfile for calibration provided.')
    return
elseif isempty(myScriptData.SPLITINTERVAL)
    errordlg('The length of a splitted file was not given.')
    return
end



%%%% set up stuff
clear global TS  % just to be sure
global TS


h=waitbar(0,'loading & splitting files..');

fileCount = 1;
%%%% read in, split and save files
for p=1:length(allInputFiles)
    TS={};
    
    %%%% load file
    olddir=cd(inputdir);
    if DO_CALIBRATION
        TSindex=ioReadTS(allInputFiles{p},calfile);
    else
        TSindex=ioReadTS(allInputFiles{p});
    end
    cd(olddir);
    
    
    
    
    if isgraphics(h), waitbar(p/length(allInputFiles),h), end
    
    
    %%%% split if file is to be splitted
    splitted = false;
    if ismember(p, idx2beSplitted)
        splitted = true;
        %%%% determine where you want to split file
        frames=getFrames(TSindex);
        
        %%%% split TSindex into newTsIndices
        newTSindices=splitUnprocTS(TSindex, frames);
        
        %%%% add origin to newTSindices
        for q=1:length(newTSindices)
            TS{newTSindices(q)}.origin=[TS{newTSindices(q)}.filename '_' sprintf('%03d',q)];
        end
    else
        TS{TSindex}.origin = TS{TSindex}.filename;
    end
    
    
    %%%% now save the file
    
    if splitted
        for spltTSIdx = newTSindices
            ts=TS{spltTSIdx};
            TS{spltTSIdx} = 1;  % make it empty
            ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];
            fname=fullfile(outputdir,ts.filename);
           
            %get ts_info
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end   

            save(fname,'ts','ts_info','-v6')
            clear ts ts_info
            fileCount = fileCount + 1;
        end
    else
        ts=TS{TSindex};
        TS{TSindex} = 1;
        ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];
        fname=fullfile(outputdir,ts.filename);

        %get ts_info
        fn=fieldnames(ts);
        for q=1:length(fn)
            if strcmp(fn{q},'potvals'), continue, end
            ts_info.(fn{q})=ts.(fn{q});
        end   

        save(fname,'ts','ts_info','-v6')
        clear ts ts_info 
        fileCount = fileCount + 1;
    end  
end

if isgraphics(handle), delete(handle), end
if isgraphics(h), delete(h), end



function newTSindices = splitUnprocTS(TSindex,frames)
%splits TS{TSindex} in length(channels) new ts and saves the new ts in
%newTSindices. Clears the old TS.
%input:
%   - channels:  eg { [1:30], [31:50], [51:100]}
%   - TSindex:  one index to the ts in TS, eg 2

global TS;
nsplits = length(frames);
newTSindices = tsNew(nsplits);
for p=1:nsplits
  TS{newTSindices(p)} = TS{TSindex};
  TS{newTSindices(p)}.potvals = TS{newTSindices(p)}.potvals(:,frames{p});
  TS{newTSindices(p)}.numframes = length(frames{p});
end
TS{TSindex}=1; % clear memory




function frames = getFrames(TSindex)
%frames = {[s1:e2],[s2:e2],...,[sn:en]}
%frames shorter then 70 frames are removed


global TS myScriptData
numframes=TS{TSindex}.numframes;
intervalLength=myScriptData.SAMPLEFREQ*myScriptData.SPLITINTERVAL;
numIntervals=ceil(numframes/intervalLength);

[frames{1:numIntervals}]=deal([]); % pre initialize
for p=1:numIntervals-1
    frames{p}=((p-1)*intervalLength+1):(p*intervalLength);
end
frames{end}=((numIntervals-1)*intervalLength+1):numframes;

% remove frames that are too short (<70)
idx2beRemoved=[];
for p=1:length(frames)
    if length(frames{p}) < 70
        idx2beRemoved=[idx2beRemoved, p];
    end
end
frames(idx2beRemoved)=[];
        













