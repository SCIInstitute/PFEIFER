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
intervalLength=myScriptData.SAMPLEFREQ*myScriptData.SPLITINTERVAL;

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
    
  
    %%%% split the file
    if ismember(p, idx2beSplitted)  % if file should be splitted
        %%%% determine where file is to be splitted;
        nFrames = TS{TSindex}.numframes;
        nSplitIntervals = floor(nFrames/intervalLength);  % file will be splitted into nSplitIntervals + 1 files
        
        for interval = 1:nSplitIntervals
            %%%% set up the new ts structure
            fn=fieldnames(TS{TSindex});
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts.(fn{q})=TS{TSindex}.(fn{q});
            end   
            ts.numframes = intervalLength;
            ts.origin = [TS{TSindex}.filename '_' sprintf('%03d',interval)];
            ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];  % the new filename          
            fileCount = fileCount + 1; 
            
            
            %%%%% put potvals in new ts and delte them in old ts
            ts.potvals = TS{TSindex}.potvals(:,1:intervalLength);  
            TS{TSindex}.potvals(:,1:intervalLength) = [];
            
            
            %%%% get ts_info
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end   
            
            
            %%%% save the new ts and ts_info and clear them   
            fname=fullfile(outputdir,ts.filename);
            save(fname,'ts','ts_info','-v6')
        end
        
        %%%%% now also save the last part of old ts (which has length < intervalLength)
        nRemindingFrames = size(TS{TSindex}.potvals,2);
        
        if nRemindingFrames > 300  % if there are enough reminding frames so it makes sense to save them..
            ts.potvals =  TS{TSindex}.potvals;
            
            ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];  % the new filename          
            fileCount = fileCount + 1;
            ts_info.filename = ts.filename;
            
            ts.origin = [TS{TSindex}.filename '_' sprintf('%03d',interval)];
            ts_info.origin = ts.origin;
            
            TS{TSindex} = 1; % free memory
        
            %%%% save the new ts and ts_info and clear them   
            fname=fullfile(outputdir,ts.filename);
            save(fname,'ts','ts_info','-v6')
        end
    else  % if file is not to be splitted;
        ts=TS{TSindex};
        ts.origin =  ts.filename;
        TS{TSindex} = 1;
        ts.filename = ['Run' sprintf('%04d',fileCount) '.mat'];
        fileCount = fileCount + 1;
        

        %get ts_info
        fn=fieldnames(ts);
        for q=1:length(fn)
            if strcmp(fn{q},'potvals'), continue, end
            ts_info.(fn{q})=ts.(fn{q});
        end
        
        fname=fullfile(outputdir,ts.filename);
        save(fname,'ts','ts_info','-v6')
        clear ts ts_info
    end
    if isgraphics(h), waitbar(p/length(allInputFiles),h), end
end
clear global TS
clear ts ts_info
if isgraphics(handle), delete(handle), end
if isgraphics(h), delete(h), end


        










