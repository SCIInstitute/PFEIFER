% MIT License
% 
% Copyright (c) 2017 The Scientific Computing and Imaging Institute
% 
% Permission is hereby granted, free of charge, to any person obtaining a copy
% of this software and associated documentation files (the "Software"), to deal
% in the Software without restriction, including without limitation the rights
% to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
% copies of the Software, and to permit persons to whom the Software is
% furnished to do so, subject to the following conditions:
% 
% The above copyright notice and this permission notice shall be included in all
% copies or substantial portions of the Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
% IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
% FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
% AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
% LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
% OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
% SOFTWARE.






function success = autoProcessSignal()
% do all the autoprocessing.  Use the fiducials in the fiducialed beat to find all other beats of 
% that run and fiducialise those beats, too. Handle & save the autoprocessed beats just like the 
% beat done by the user.

%set up globals
clear global AUTOPROCESSING  % just in case, so previous stuff doesnt mess anything up
global TS SCRIPTDATA AUTOPROCESSING
crg=SCRIPTDATA.CURRENTRUNGROUP;
unslicedDataIndex=SCRIPTDATA.unslicedDataIndex;
nToBeFiducialised=SCRIPTDATA.NTOBEFIDUCIALISED;    % nToBeFiducialised  evenly spread leads from leadsOfAllGroups will be chosen for autoprocessing


%%%% get the leadsOfAllGroups and filter out badleads
badleads=find(TS{SCRIPTDATA.unslicedDataIndex}.leadinfo > 0);     % the global indices of bad leads
leadsOfAllGroups=[SCRIPTDATA.GROUPLEADS{crg}{:}];
leadsOfAllGroups=setdiff(leadsOfAllGroups,badleads);  %signal (where the beat is found) will constitute of those.  got rid of badleads

%%%% set leadsToAutoprocess, the leads to find fiducials for and plot.  Only these leads will be used to compute the global fids
idxs=round(linspace(1,length(leadsOfAllGroups),nToBeFiducialised));
%idxs=randi([1,length(leadsOfAllGroups)],1,nToBeFiducialised); % this is wrong, since it may create dublicates

AUTOPROCESSING.leadsToAutoprocess=leadsOfAllGroups(idxs);


%%%% get info from  already processed beat
AUTOPROCESSING.bsk=TS{SCRIPTDATA.CURRENTTS}.selframes(1);    % "beat start kernel"
AUTOPROCESSING.bek=TS{SCRIPTDATA.CURRENTTS}.selframes(2);  %beat end kernel
AUTOPROCESSING.oriFids=TS{SCRIPTDATA.CURRENTTS}.fids;

%%%% get signal, the RMS needed to find beats
signal = preprocessPotvals(TS{unslicedDataIndex}.potvals(leadsOfAllGroups,:));   % make signal out of leadsOfAllGroups

%%%% find allFids based on oriFids and signal
[AUTOPROCESSING.allFids, success]=findAllFids(TS{unslicedDataIndex}.potvals(AUTOPROCESSING.leadsToAutoprocess,:),signal);


if ~success, return, end
%%%% find AUTOPROCESSING.faultyBeatsIndeces and AUTOPROCESSING.faultyBeatInfo
getFaultyBeats;


%%%% plot the found fids, let the user check them and make corrections
if SCRIPTDATA.AUTOFID_USER_INTERACTION
    autoProcFig=plotAutoProcFids;
    waitfor(autoProcFig);  %do not proceed to processing until user is done
    
    %%%% if user pressed any navigation command, deal with it:
    switch SCRIPTDATA.NAVIGATION
        case {'prev','next','stop','back'}
            tsClear(SCRIPTDATA.unslicedDataIndex);
            SCRIPTDATA.unslicedDataIndex=[];
            success = 1;
            return; 
    end  
    save(SCRIPTDATA.SCRIPTFILE,'SCRIPTDATA')  % save settings.. in case user made a change in autofiducializing window
end


%%%%% main loop: process each beat.
global times
times=struct();
times(1).count=1;

for beatNumber=2:length(AUTOPROCESSING.beats)    % skip the first beat, as this is the user fiducialized one
    b=tic;
    success = processBeat(beatNumber);
    t2=toc(b);
    times(times(1).count).processBeat=t2;
    if ~success, return, end
    times(1).count=times(1).count+1;
end

fn=fieldnames(times);
for p=1:length(fn)
    times(times(1).count).(fn{p}) = sum([times.(fn{p})]);
end
        


success = 1;
end
























%%%%%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function signal = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];

D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

%%%% do RMS
signal=sqrt(mean(potvals.^2));
signal=signal-min(signal);
end


function getFaultyBeats
% determine the beats, where autoprocessing didn't quite work ( eg those with very high variance)
% fill AUTOPROCESSING.faultyBeatInfo and AUTOPROCESSING.faultyBeatIndeces with info

global AUTOPROCESSING SCRIPTDATA

%%%% if not set yet, set default for treshold variance
if ~isfield(SCRIPTDATA, 'TRESHOLD_VAR')
    SCRIPTDATA.TRESHOLD_VAR = 50;
end


%%%% set up variables
treshold_variance = SCRIPTDATA.TRESHOLD_VAR;
faultyBeatIndeces =[]; % the indeces in .Beats of faulty beats
faultyBeatInfo = {};    % which fiducials (which types) in the beat are bad?     of format { [2 4], [5 6],.. }  
faultyBeatValues = {};
numBeats = length(AUTOPROCESSING.beats);
if ~isempty(AUTOPROCESSING.allFids)
    numFids = length(AUTOPROCESSING.allFids{1})/2;
end

%%%% loop through beats and find faulty ones
for beatNumber = 1:numBeats
    variances =[AUTOPROCESSING.allFids{beatNumber}.variance];
    types = [AUTOPROCESSING.allFids{beatNumber}.type];
    faultyIndeces = find(variances > treshold_variance);
    faultyFids = types(faultyIndeces); % get fids of beat with to high variance
    
    if isempty(faultyFids) % if all fids of that beat are fine
        continue
    else
        faultyBeatIndeces(end+1) = beatNumber;
        faultyBeatInfo{end+1} = faultyFids;
        
        %%%% get the faultyValues of that faulty beat
        faultyIndeces = faultyIndeces + numFids;  % now faultyIndeces are indeces of global bad fiducials
        faultyValues = [AUTOPROCESSING.allFids{beatNumber}(faultyIndeces).value];
        faultyBeatValues{end+1}=faultyValues;
    end   
end


%%%% save stuff in AUTOPROCESSING
AUTOPROCESSING.faultyBeatInfo = faultyBeatInfo;
AUTOPROCESSING.faultyBeatIndeces = faultyBeatIndeces;
AUTOPROCESSING.faultyBeatValues = faultyBeatValues;

end
    
    


function success = processBeat(beatNumber)
success = 0;

global TS SCRIPTDATA AUTOPROCESSING


global times

%%%% slice "complete ts" into beat (in TS{newBeatIdx} )
a=tic;
newBeatIdx=tsNew(1);
beatframes=AUTOPROCESSING.beats{beatNumber}(1):AUTOPROCESSING.beats{beatNumber}(2);  % all time frames of the beat

TS{newBeatIdx}=TS{SCRIPTDATA.unslicedDataIndex};
TS{newBeatIdx}.potvals=TS{newBeatIdx}.potvals(:,beatframes);
TS{newBeatIdx}.numframes=length(beatframes);
TS{newBeatIdx}.selframes=[beatframes(1),beatframes(end)];
t=toc(a);
times(times(1).count).a_sliceIntoBeat=t;

%%%% put the new fids in the "local beat frame" and save them in newBeatIdx

a=tic;
fids=AUTOPROCESSING.allFids{beatNumber};
reference=beatframes(1);
for fidNumber=1:length(fids)
    fids(fidNumber).value=fids(fidNumber).value-reference+1;  % fids now in local frame
end
if isfield(fids,'variance'),  fids=rmfield(fids,'variance'); end  %variance not wanted in the output
TS{newBeatIdx}.fids=fids;
t=toc(a);
times(times(1).count).b_MakeFidsLocalAndRemvoeVariance=t;

%%%%%% if 'blank bad leads' button is selected,   set all values of the bad leads to 0
a=tic;
if SCRIPTDATA.DO_BLANKBADLEADS == 1
    badleads = tsIsBad(newBeatIdx);
    TS{newBeatIdx}.potvals(badleads,:) = 0;
    tsSetBlank(newBeatIdx,badleads);
    tsAddAudit(newBeatIdx,'|Blanked out bad leads');
end
t=toc(a);
times(times(1).count).c_blankBadLeads=t;

%%%%  baseline correction
a=tic;
if SCRIPTDATA.DO_BASELINE
    % first add the default baseline fids (=start/endframe) to the beat
    TS{newBeatIdx}.fids(end+1).type=16;
    TS{newBeatIdx}.fids(end).value=1;
    TS{newBeatIdx}.fids(end+1).type=16;
    TS{newBeatIdx}.fids(end).value=length(beatframes)-SCRIPTDATA.BASELINEWIDTH;
    % now do the baseline correction
    success = baseLineCorrectSignal(newBeatIdx);
    if ~success, return, end
end
t=toc(a);
times(times(1).count).d_BaselineCorrection=t;


%%%%% do activation and deactivation

a=tic;
if SCRIPTDATA.FIDSAUTOACT == 1
    success = DetectActivation(newBeatIdx); 
    if ~success, return, end
end
if SCRIPTDATA.FIDSAUTOREC == 1
    success = DetectRecovery(newBeatIdx); 
    if ~success, return, end
end
t=toc(a);
times(times(1).count).e_DetectActivationRecovery=t;




%%%% construct the filename  (add eg '-b10' to filename)
a=tic;

[~,filename,~]=fileparts(TS{SCRIPTDATA.unslicedDataIndex}.filename);
filename=sprintf('%s-b%d',filename,beatNumber-1); 


%%%% split TS{newIdx} into numGroups smaller ts in grIndices
splitgroup = [];
for p=1:length(SCRIPTDATA.GROUPNAME{SCRIPTDATA.CURRENTRUNGROUP})
    if SCRIPTDATA.GROUPDONOTPROCESS{SCRIPTDATA.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
end
% splitgroup is now eg [1 3] if there are 3 groups but the 2 should
% not be processed
channels=SCRIPTDATA.GROUPLEADS{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup);
grIndices = tsSplitTS(newBeatIdx, channels);    
% update the filenames (add '-groupextension' to filename)
tsDeal(grIndices,'filename',ioUpdateFilename('.mat',filename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup))); 
tsClear(newBeatIdx);

t=toc(a);
times(times(1).count).f_splitIntoGroups=t;


%%%% save the new ts structures
a=tic;
for grIdx=grIndices
    ts=TS{grIdx};
    fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
    fprintf('Saving file: %s\n',ts.filename)
    save(fullFilename,'ts','-v6')
end
t=toc(a);
times(times(1).count).g_saveGroups=t;



%%%% do integral maps and save them  


if SCRIPTDATA.DO_INTEGRALMAPS == 1
    a=tic;
    if SCRIPTDATA.DO_DETECT == 0
        msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s. Aborting..', filename);
        errordlg(msg)
        success = 0;
        return
    end
    mapindices = fidsIntAll(grIndices);
    if length(splitgroup)~=length(mapindices)
        msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups. Aborting...',filename);
        errordlg(msg)
        success = 0;
        return
    end


    fnames=ioUpdateFilename('.mat',filename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup),'-itg');

    tsDeal(mapindices,'filename',fnames); 
    tsSet(mapindices,'newfileext','');
    
    %%%% save integral maps and clear them
    for mapIdx=mapindices
        ts=TS{mapIdx};
        fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
        fprintf('Saving file: %s\n',ts.filename)
        save(fullFilename,'ts','-v6')
    end
    tsClear(mapindices);
    t=toc(a);
    times(times(1).count).h_IntegralMaps=t;
    
end


       
%%%%% Do activation maps   

if SCRIPTDATA.DO_ACTIVATIONMAPS == 1
    a=tic;
    
    if SCRIPTDATA.DO_DETECT == 0 % 'Detect fiducials must be selected'
        errordlg('Fiducials needed to do Activationsmaps! Select the ''Do Fiducials'' button to do Activationmaps. Aborting...')
        return
    end

    %%%% make new ts at TS(mapindices). That new ts is like the old
    %%%% one, but has ts.potvals=[act rec act-rec]
    [mapindices, success] = sigActRecMap(grIndices);   
    if ~success,return, end
    tsDeal(mapindices,'filename',ioUpdateFilename('.mat',filename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup),'-ari')); 
    tsSet(mapindices,'newfileext','');

    %%%%  save the 'new act/rec' ts as eg 'Run0009-gr1-ari.mat  and clearTS{mapindex}
    for mapIdx=mapindices
        ts=TS{mapIdx};
        fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
        fprintf('Saving file: %s\n',ts.filename)
        save(fullFilename,'ts','-v6')
    end
    tsClear(mapindices);
    t=toc(a);
    times(times(1).count).i_IntegralMaps=t;
end

%%%%% clear TS
a=tic;
tsClear(grIndices);
t=toc(a);
times(times(1).count).j_clearGRrIdxs=t;

success = 1;
end
    
function success = DetectActivation(newBeatIdx)
%%%% load globals and set mouse arrow to waiting
global TS SCRIPTDATA;


%%%% get current tsIndex,  set qstart=qend=zeros(numchannel,1),
%%%% act=(1/SCRIPTDATA.SAMPLEFREQ)*ones(numleads,1)
numchannels = size(TS{newBeatIdx}.potvals,1);
qstart = zeros(numchannels,1);
qend = zeros(numchannels,1);
act = ones(numchannels,1)*(1/SCRIPTDATA.SAMPLEFREQ);

%%%% check if there is a t-wave to do recovery
qstart_indeces=find([TS{newBeatIdx}.fids.type]==2);
qend_indeces=find([TS{newBeatIdx}.fids.type]==4);
if isempty(qstart_indeces) || isempty(qend_indeces)
    msg = sprintf('There is no qrs-wave for the file %s. Therefore, activation detection cannot be done for this file. Aborting...',TS{newBeatIdx}.filename);
    errordlg(msg)
    success = 0;
    return
end


%%%% qstart/end=QRS-Komplex-start/end-timeframe as saved in the fids
for qstart_idx=qstart_indeces % loop trought to find global qrs
    if length(TS{newBeatIdx}.fids(qstart_idx).value) == 1
        qstart = TS{newBeatIdx}.fids(qstart_idx).value * ones(numchannels,1);
        break
    end
end
for qend_idx=qend_indeces % loop trought to find global qrs
    if length(TS{newBeatIdx}.fids(qend_idx).value) == 1
        qend = TS{newBeatIdx}.fids(qend_idx).value * ones(numchannels,1);
        break
    end
end



%%%% make sure that: qs and qe are qstart/qend, but 'sorted', thus qs(i)<qe(i) for all i
qs = min([qstart qend],[],2);
qe = max([qstart qend],[],2);



%%%% init win/deg/neg
win = SCRIPTDATA.ACTWIN;
deg = SCRIPTDATA.ACTDEG;

%%%% find act for all leads within QRS using the activation function selected by user() 

[actFktHandle, success]=getActFunction;
if ~success, return, end

try
    for leadNumber=1:numchannels
     %for each lead in each group = for all leads..  
       [act(leadNumber)] = (actFktHandle(TS{newBeatIdx}.potvals(leadNumber,qs(leadNumber):qe(leadNumber)),win,deg)-1)/SCRIPTDATA.SAMPLEFREQ + qs(leadNumber);
    end
catch
    errordlg('The selected function used to find the activations caused an error. Aborting...')
    success = 0;
    return
end

%%%% put the act in the fids
TS{newBeatIdx}.fids(end+1).type=10;
TS{newBeatIdx}.fids(end).value=act;
success = 1;
end


function success = DetectRecovery(newBeatIdx)
%callback for DetectRecovery

%%%% some initialisation, setting the mouse pointer..
global TS SCRIPTDATA

numchannels = size(TS{newBeatIdx}.potvals,1);


%%%% create [numchannel x 1] arrays qstart and qend is beginning/end of T-wave, 
%%%% initialise rec=zeroes(numchan,1)
tstart = zeros(numchannels,1);
tend = zeros(numchannels,1);
rec = ones(numchannels,1)*(1/SCRIPTDATA.SAMPLEFREQ);  

%%%% check if there is a t-wave to do recovery
tStartIndeces=find([TS{newBeatIdx}.fids.type]==5); 
tEndIndeces=find([TS{newBeatIdx}.fids.type]==7);
if isempty(tStartIndeces) || isempty(tEndIndeces)
    msg = sprintf('There is no t-wave for the file %s. Therefore, recovery detection cannot be done for this file. Aborting...',TS{newBeatIdx}.filename);
    errordlg(msg)
    success = 0;
    return
end

%%%% get tstart/end  values as saved in the fids
for tStartIdx=tStartIndeces % loop trought to find global t wave
    if length(TS{newBeatIdx}.fids(tStartIdx).value) == 1
        tstart = TS{newBeatIdx}.fids(tStartIdx).value * ones(numchannels,1);
        break
    end
end
for tEndIdx=tEndIndeces % loop trought to find global t wave
    if length(TS{newBeatIdx}.fids(tEndIdx).value) == 1
        tend = TS{newBeatIdx}.fids(tEndIdx).value * ones(numchannels,1);
        break
    end
end


%%%% sort values
ts = min([tstart tend],[],2);
te = max([tstart tend],[],2);

%%%% set up some stuff
win = SCRIPTDATA.RECWIN;
deg = SCRIPTDATA.RECDEG;

%%%% get the recovery values for each lead

[recFktHandle, success] = getRecFunction;
if ~success, return, end
try
    for leadNumber=1:numchannels
        rec(leadNumber) = recFktHandle(TS{newBeatIdx}.potvals(leadNumber,ts(leadNumber):te(leadNumber)),win,deg)/SCRIPTDATA.SAMPLEFREQ + ts(leadNumber);
    end
catch
    errordlg('The selected function used to find the recoveries caused an error. Aborting...')
    success = 0;
    return
end

%%%% put the recovery values in fids
TS{newBeatIdx}.fids(end+1).type=13;
TS{newBeatIdx}.fids(end).value=rec;

success = 1;
end






