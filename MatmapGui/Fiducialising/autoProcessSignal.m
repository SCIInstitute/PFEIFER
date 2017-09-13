function autoProcessSignal()
% do all the autoprocessing.  Use the fiducials in the fiducialed beat to find all other beats of 
% that run and fiducialise those beats, too. Handle & save the autoprocessed beats just like the 
% beat done by the user.




%set up globals
clear global AUTOPROCESSING  % just in case, so previous stuff doesnt mess anything up
global TS myScriptData AUTOPROCESSING
crg=myScriptData.CURRENTRUNGROUP;
unslicedDataIndex=myScriptData.unslicedDataIndex;
nToBeFiducialised=myScriptData.NTOBEFIDUCIALISED;    % nToBeFiducialised  evenly spread leads from leadsOfAllGroups will be chosen for autoprocessing


%%%% get the leadsOfAllGroups and filter out badleads
badleads=find(TS{myScriptData.unslicedDataIndex}.leadinfo > 0);     % the global indices of bad leads
leadsOfAllGroups=[myScriptData.GROUPLEADS{crg}{:}];
leadsOfAllGroups=setdiff(leadsOfAllGroups,badleads);  %signal (where the beat is found) will constitute of those.  got rid of badleads

%%%% set leadsToAutoprocess, the leads to find fiducials for and plot.  Only these leads will be used to compute the global fids
idxs=round(linspace(1,length(leadsOfAllGroups),nToBeFiducialised));
%idxs=randi([1,length(leadsOfAllGroups)],1,nToBeFiducialised); % this is wrong, since it may create dublicates

AUTOPROCESSING.leadsToAutoprocess=leadsOfAllGroups(idxs);


%%%% get info from  already processed beat
AUTOPROCESSING.bsk=TS{myScriptData.CURRENTTS}.selframes(1);    % "beat start kernel"
AUTOPROCESSING.bek=TS{myScriptData.CURRENTTS}.selframes(2);  %beat end kernel
AUTOPROCESSING.oriFids=TS{myScriptData.CURRENTTS}.fids;

%%%% get signal, the RMS needed to find beats
signal = preprocessPotvals(TS{unslicedDataIndex}.potvals(leadsOfAllGroups,:));   % make signal out of leadsOfAllGroups

%%%% find allFids based on oriFids and signal
AUTOPROCESSING.allFids=findAllFids(TS{unslicedDataIndex}.potvals(AUTOPROCESSING.leadsToAutoprocess,:),signal);

%%%% find AUTOPROCESSING.faultyBeatsIndeces and AUTOPROCESSING.faultyBeatInfo
getFaultyBeats;


%%%% plot the found fids, let the user check them and make corrections
if myScriptData.AUTOFID_USER_INTERACTION
    autoProcFig=plotAutoProcFids;
    %do not proceed to processing until user is done
    waitfor(autoProcFig);
end

% return, if user pressed 'Stop','Prev', or 'next'
if ismember(myScriptData.NAVIGATION,{'prev','next','stop'})
    return
end


%%%%% main loop: process each beat.
for beatNumber=2:length(AUTOPROCESSING.beats)    % skip the first beat, as this is the user fiducialized one
    processBeat(beatNumber)
end

    
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
signal=rms(potvals,1);
signal=signal-min(signal);
end


function getFaultyBeats
% determine the beats, where autoprocessing didn't quite work ( eg those with very high variance)
% fill AUTOPROCESSING.faultyBeatInfo and AUTOPROCESSING.faultyBeatIndeces with info

global AUTOPROCESSING

%%%% if not set yet, set default for treshold variance
if ~isfield(AUTOPROCESSING, 'TRESHOLD_VAR')
    AUTOPROCESSING.TRESHOLD_VAR = 50;
end


%%%% set up variables
treshold_variance = AUTOPROCESSING.TRESHOLD_VAR;
faultyBeatIndeces =[]; % the indeces of faulty beats
faultyBeatInfo = {};    % which fiducials in the beat are bad?
faultyBeatValues = {};
numBeats = length(AUTOPROCESSING.beats);


%%%% loop through beats and find faulty ones
for beatNumber = 1:numBeats
    variances =[AUTOPROCESSING.allFids{beatNumber}.variance];
    types = [AUTOPROCESSING.allFids{beatNumber}.type];
    faultyIndeces = find(variances > treshold_variance);
    
    faultyFids = types(faultyIndeces); % get fids with to high variance
    
    if isempty(faultyFids) % if all fids of that beat are fine
        continue
    else
        faultyBeatIndeces(end+1) = beatNumber;
        faultyBeatInfo{end+1} = faultyFids;
        
        %%%% get the faultyValues of that faulty beat
        faultyIndeces = faultyIndeces + 5;  % now faultyIndeces are indeces of global bad fiducials
        faultyValues = [AUTOPROCESSING.allFids{beatNumber}(faultyIndeces).value];
        faultyBeatValues{end+1}=faultyValues;
    end   
end


%%%% save stuff in AUTOPROCESSING
AUTOPROCESSING.faultyBeatInfo = faultyBeatInfo;
AUTOPROCESSING.faultyBeatIndeces = faultyBeatIndeces;
AUTOPROCESSING.faultyBeatValues = faultyBeatValues;

end
    
    


function processBeat(beatNumber)
%index: index to orignial ts obtained just before sigSlice in
%myProcessingScript -> mapping, calibration, temporal filter, badleads already done!
%selframes:  frames for slicing  [start:end]
global TS myScriptData AUTOPROCESSING


%%%% slice "complete ts" into beat (in TS{newBeatIdx} )
newBeatIdx=tsNew(1);
beatframes=AUTOPROCESSING.beats{beatNumber}(1):AUTOPROCESSING.beats{beatNumber}(2);  % all time frames of the beat

TS{newBeatIdx}=TS{myScriptData.unslicedDataIndex};
TS{newBeatIdx}.potvals=TS{newBeatIdx}.potvals(:,beatframes);
TS{newBeatIdx}.numframes=length(beatframes);
TS{newBeatIdx}.selframes=[beatframes(1),beatframes(end)];
    
%%%% put the new fids in the "local beat frame" and save them in newBeatIdx
fids=AUTOPROCESSING.allFids{beatNumber};
reference=beatframes(1);
for fidNumber=1:length(fids)
    fids(fidNumber).value=fids(fidNumber).value-reference+1;  % fids now in local frame
end
if isfield(fids,'variance'),  fids=rmfield(fids,'variance'); end  %variance not wanted in the output
TS{newBeatIdx}.fids=fids;


%%%%  baseline correction
if myScriptData.DO_BASELINE
    sigBaseLine(newBeatIdx,[1,length(beatframes)-myScriptData.BASELINEWIDTH],myScriptData.BASELINEWIDTH);
    % also add the baseline fid to ts.fids
    TS{newBeatIdx}.fids(end+1).type=16;
    TS{newBeatIdx}.fids(end).value=1;
    TS{newBeatIdx}.fids(end+1).type=16;
    TS{newBeatIdx}.fids(end).value=length(beatframes)-myScriptData.BASELINEWIDTH;
    
end


%%%%% do activation and deactivation
if myScriptData.FIDSAUTOACT == 1, DetectActivation(newBeatIdx); end
if myScriptData.FIDSAUTOREC == 1, DetectRecovery(newBeatIdx); end





%%%% construct the filename  (add eg '-b10' to filename)
[~,filename,~]=fileparts(TS{myScriptData.unslicedDataIndex}.filename);
filename=sprintf('%s-b%d',filename,beatNumber-1); 


%%%% split TS{newIdx} into numGroups smaller ts in grIndices
splitgroup = [];
for p=1:length(myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP})
    if myScriptData.GROUPDONOTPROCESS{myScriptData.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
end
% splitgroup is now eg [1 3] if there are 3 groups but the 2 should
% not be processed
channels=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}(splitgroup);
grIndices = mytsSplitTS(newBeatIdx, channels);    
% update the filenames (add '-groupextension' to filename)
tsDeal(grIndices,'filename',ioUpdateFilename('.mat',filename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup))); 
tsClear(newBeatIdx);


%%%% save the new ts structures using ioWriteTS
olddir = cd(myScriptData.MATODIR);
ioWriteTS(grIndices,'noprompt','oworiginal');
cd(olddir);


%%%% do integral maps and save them  
if myScriptData.DO_INTEGRALMAPS == 1
    if myScriptData.DO_DETECT == 0
        msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s.', filename);
        errordlg(msg)
        error('Need fiducials to do integral maps');
    end
    mapindices = fidsIntAll(grIndices);
    if length(splitgroup)~=length(mapindices)
        msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups.',filename);
        errordlg(msg)
        error('No fiducials for integralmaps.')
    end

    olddir = cd(myScriptData.MATODIR); 
    fnames=ioUpdateFilename('.mat',filename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-itg');

    tsDeal(mapindices,'filename',fnames); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);
    tsClear(mapindices);
end
       
%%%%% Do activation maps   

if myScriptData.DO_ACTIVATIONMAPS == 1
    if myScriptData.DO_DETECT == 0 % 'Detect fiducials must be selected'
        error('Need fiducials to do activation maps');
    end

    %%%% make new ts at TS(mapindices). That new ts is like the old
    %%%% one, but has ts.potvals=[act rec act-rec]
    mapindices = sigActRecMap(grIndices);   


    %%%%  save the 'new act/rec' ts as eg 'Run0009-gr1-ari.mat
    % AND clearTS{mapindex}!
    olddir = cd(myScriptData.MATODIR);
    tsDeal(mapindices,'filename',ioUpdateFilename('.mat',filename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-ari')); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);
    tsClear(mapindices);
end

   %%%%% save everything and clear TS
%    saveSettings();          TODO
    tsClear(grIndices);

end
    
function DetectActivation(newBeatIdx)
%%%% load globals and set mouse arrow to waiting
global TS myScriptData;


%%%% get current tsIndex,  set qstart=qend=zeros(numchannel,1),
%%%% act=(1/myScriptData.SAMPLEFREQ)*ones(numleads,1)
numchannels = size(TS{newBeatIdx}.potvals,1);
qstart = zeros(numchannels,1);
qend = zeros(numchannels,1);
act = ones(numchannels,1)*(1/myScriptData.SAMPLEFREQ);


%%%% qstart/end=QRS-Komplex-start/end-timeframe as saved in the fids
qstart_indeces=find([TS{newBeatIdx}.fids.type]==2);  % TODO: if no qrs exists?qend_idx=[TS{newBeatIdx}.fids.type]==4;
qend_indeces=find([TS{newBeatIdx}.fids.type]==4);
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
win = myScriptData.ACTWIN;
deg = myScriptData.ACTDEG;
neg = myScriptData.ACTNEG;

%%%% find act for all leads within QRS using ARdetect() 
for leadNumber=1:numchannels
 %for each lead in each group = for all leads..  
    if isfield(TS{newBeatIdx},'noisedrange')
        act(leadNumber) = (ARdetect(TS{newBeatIdx}.potvals(leadNumber,qs(leadNumber):qe(leadNumber)),win,deg,neg,TS{newBeatIdx}.noisedrange(leadNumber))-1)/myScriptData.SAMPLEFREQ + qs(leadNumber);
    else
        [act(leadNumber)] = (ARdetect(TS{newBeatIdx}.potvals(leadNumber,qs(leadNumber):qe(leadNumber)),win,deg,neg)-1)/myScriptData.SAMPLEFREQ + qs(leadNumber);
    end
end

%%%% put the act in the fids
TS{newBeatIdx}.fids(end+1).type=10;
TS{newBeatIdx}.fids(end).value=act;
end


function DetectRecovery(newBeatIdx)
%callback for DetectRecovery


%%%% some initialisation, setting the mouse pointer..
global TS myScriptData

numchannels = size(TS{newBeatIdx}.potvals,1);


%%%% create [numchannel x 1] arrays qstart and qend is beginning/end of T-wave, 
%%%% initialise rec=zeroes(numchan,1)
tstart = zeros(numchannels,1);
tend = zeros(numchannels,1);
rec = ones(numchannels)*(1/myScriptData.SAMPLEFREQ);  

%%%% get tstart/end as saved in the fids
tstart_indeces=find([TS{newBeatIdx}.fids.type]==5);  % TODO: if no qrs exists?qend_idx=[TS{newBeatIdx}.fids.type]==4;
tend_indeces=find([TS{newBeatIdx}.fids.type]==7);
for tstart_idx=tstart_indeces % loop trought to find global t wave
    if length(TS{newBeatIdx}.fids(tstart_idx).value) == 1
        tstart = TS{newBeatIdx}.fids(tstart_idx).value * ones(numchannels,1);
        break
    end
end
for tend_idx=tend_indeces % loop trought to find global t wave
    if length(TS{newBeatIdx}.fids(tend_idx).value) == 1
        tend = TS{newBeatIdx}.fids(tend_idx).value * ones(numchannels,1);
        break
    end
end



%%%% sort values
ts = min([tstart tend],[],2);
te = max([tstart tend],[],2);

%%%% set up some stuff
win = myScriptData.RECWIN;
deg = myScriptData.RECDEG;
neg = myScriptData.RECNEG;

%%%% get the recovery values for each lead
for leadNumber=1:numchannels
    rec(leadNumber) = ARdetect(TS{newBeatIdx}.potvals(leadNumber,ts(leadNumber):te(leadNumber)),win,deg,neg)/myScriptData.SAMPLEFREQ + ts(leadNumber);
end

%%%% put the recovery values in fids
TS{newBeatIdx}.fids(end+1).type=13;
TS{newBeatIdx}.fids(end).value=rec;

end

function x = ARdetect(sig,win,deg,pol,ndrange)
if nargin == 4
    ndrange = 0;
end

%%%% if sigdrange to small compared to noisedrange (ndrange), return
%%%% x=len(sig)
sigdrange = max(sig)-min(sig);  
if (sigdrange <= 1.75*ndrange)
    x = length(sig);
    return;   % TODO: this shouldn just return, but issue an error msg..
end

%make sure win is uneven
if mod(win,2) == 0, win = win + 1; end

%%%% return x=1, if len(sig)<win
if length(sig) < win, x=1; return; end

% Detection of the minimum derivative
% Use a window of 5 frames and fit a 2nd order polynomial

cen = ceil(win/2);
X = zeros(win,(deg+1));
L = [-(cen-1):(cen-1)]';
for p=1:(deg+1)
    X(:,p) = L.^((deg+1)-p);
end

E = (X'*X)\X';

sig = [sig sig(end)*ones(1,cen-1)];

a = filter(E(deg,[win:-1:1]),1,sig);
dy = a(cen:end);

if pol == 1
    [mv,mi] = min(dy(cen:end-cen));
else
    [mv,mi] = max(dy(cen:end-cen));
end
mi = mi(1)+(cen-1);

% preset values for peak detector

win2 = 5;
deg2 = 2;

cen2 = ceil(win2/2);
L2 = [-(cen2-1):(cen2-1)]';
for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
c = inv(X2'*X2)*X2'*(dy(L2+mi)');

if abs(c(1)) < 100*eps, dx = 0; else dx = -c(2)/(2*c(1)); end

dvdt = 2*c(1)*dx+c(2);

dx = median([-0.5 dx 0.5]);

x = mi+dx-1;

end






