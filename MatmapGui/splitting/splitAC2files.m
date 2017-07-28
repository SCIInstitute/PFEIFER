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

tAll=tic;

%%%% start here, first check input:
if isempty(outputdir)
    errordlg('No output dir for matfiles given.')
    return
elseif DO_CALIBRATION && isempty(calfile)
    errordlg('No calfile for calibration provided.')
    return
elseif isempty(myScriptData.SPLITINTERVAL)
    errordlg('The desired length of a splitted file was not given.')
    return
end



%%%% set up stuff
clear global TS  % just to be sure
global TS
olddir=cd(inputdir);

h=waitbar(0,'loading & splitting files..');

%%%% read in and split files
tic
for p=1:length(allInputFiles)
    if DO_CALIBRATION
        TSindex=ioReadTS(allInputFiles{p},calfile);
    else
        TSindex=ioReadTS(allInputFiles{p});
    end
    
    if isgraphics(h), waitbar(0.6*p/length(allInputFiles),h), end
    
    
    if ismember(p, idx2beSplitted)
        %%%% determine where you want to split file
        frames=getFrames(TSindex);
        %%%% split TSindex into newTsIndices
        newTSindices=splitUnprocTS(TSindex, frames);
        %%%% change the filenames of newTSindices
        for q=1:length(newTSindices)
            TS{newTSindices(q)}.origin=[TS{newTSindices(q)}.filename '_' sprintf('%03d',q)];
        end
    end
        
end
cd(olddir);
toc

%%%% rename ts.filename, make sure they all have ts.origin
tic
renameTS()
toc

%%%% save all files of current TS
tic
for p=1:length(TS)
    ts=TS{p};
    fname=fullfile(outputdir,TS{p}.filename);
    save(fname, 'ts')
    clear ts
    if isgraphics(h), waitbar(0.6+0.4*p/length(TS),h,'saving files'), end
end
toc
%%%% clean up & close figure
clear global TS
if isgraphics(handle), delete(handle), end
if isgraphics(h), delete(h), end

tAll=toc(tAll);
fprintf('total time: %s \n', tAll);


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
TS{TSindex}=1;



function renameTS()
% - 'cleans up' TS,
% - makes sure there is ts.origin everywhere,
% - renames ts.filename from 'Run001.mat' to 'Run(lenghtTS).mat'

global TS
count=1;
toBeCleared=[];
for p=1:length(TS)
    if isempty(TS{p}) || isfloat(TS{p})
        toBeCleared(end+1)=p;
    else
        if ~isfield(TS{p},'origin')
            TS{p}.origin=TS{p}.filename;
        end
        TS{p}.filename=['Run' sprintf('%04d',count) '.mat'];
        count=count+1;
    end
end
TS(toBeCleared)=[];



function frames = getFrames(TSindex)
global TS myScriptData
numframes=TS{TSindex}.numframes;
intervalLength=myScriptData.SAMPLEFREQ*myScriptData.SPLITINTERVAL;
numIntervals=ceil(numframes/intervalLength);

[frames{1:numIntervals}]=deal([]); % pre initialize
for p=1:numIntervals-1
    frames{p}=((p-1)*intervalLength+1):(p*intervalLength);
end
frames{end}=((numIntervals-1)*intervalLength+1):numframes;













