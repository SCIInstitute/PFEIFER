function [allFids success] = findAllFids(potvals,signal)
% returns allFids = {fidsBeat1, fidsBeat2, .... , FidsLastBeat}
% each fidsBeatN is a numFids - array - struct 'fids' with the fields: 'type' (the fiducial type) and  'value' (the values of the fid in global frame) 
% in short: fidsBeatN is just like the 'fids' struct as it is saved in ts,
% but in the global frame!!
% Fids are determined based on 'oriFids', die fids done by the user.

success = 0;
allFids = 'dummyValue'; % to make sure this function has a value to return, even if function returns earlier as planned due to error
%%%%% get paramters from ScriptData
global ScriptData AUTOPROCESSING
accuracy=ScriptData.ACCURACY;  % abort condition5
fidsKernelLength=ScriptData.FIDSKERNELLENGTH;  % the kernel indices will be from fidsValue-fidsKernelLength  until fidsValue+fidsKernelLength
kernel_shift=0;       % a "kernel shift", to shift the kernel by kernel_shift   % not used, just here as placeholder..
% reminder: it is kernel_idx=fid_start-fidsKernelLength+kernel_shift:fid_start+fidsKernelLength+kernel_shift
window_width=ScriptData.WINDOW_WIDTH;   % dont search complete beat, but only a window with width window_width,
% ws=bs+loc_fidsValues(fidNumber)-window_width;  
% we=bs+loc_fidsValues(fidNumber)+window_width;

totalKernelLength = 2*fidsKernelLength +1;   % the length of a kernel




%%%% clear any nonglobal fids from oriFids
oriFids=AUTOPROCESSING.oriFids;
toBeCleared=[];
for p=1:length(oriFids)
    if length(oriFids(p).value)~=1   % if not single global value
        toBeCleared=[toBeCleared p];
    end
end
oriFids(toBeCleared)=[];




%%%% beat kernel
bsk=AUTOPROCESSING.bsk;   %start and end of beat
bek=AUTOPROCESSING.bek;

%%%% make sure all needed fids are there and tehre are not to many of them
necFids =  [2 4 5 7 6];
fidNames = {'qrs-Wave', 'qrs-Wave','T-Wave','T-Wave','T-Peak'};
count=1;
for fidType = necFids
    idx = find([oriFids.type]==fidType);
    if length(idx)~=1  % if more then one ore no occurence of this necessary fiducial
        global TS
        filename = TS{ScriptData.CURRENTTS}.filename;
        fidName = fidNames{count};
        msg = sprintf('Problem to autofiducialise the file %s: There is either no Fiducial or to many fiducials of type %s in this file. Aborting..',filename, fidName);
        errordlg(msg)
        return
    end
    count = count +1;
end



%%%% get the the fids to be found
%local fids in the "local beat frame"
loc_qrs_start=round(oriFids([oriFids.type]==2).value);
loc_qrs_end=round(oriFids([oriFids.type]==4).value);
loc_t_start=round(oriFids([oriFids.type]==5).value);
loc_t_end=round(oriFids([oriFids.type]==7).value);
loc_t_peak=round(oriFids([oriFids.type]==6).value);



%%%% put fids in organised way, also get the globFidsValues, the fids in the "global complete signal frame"
fidsTypes=[2 4 5 7 6];   % oder here is important: start of a wave must be imediatly followed by end of same wave. otherwise FidsToEvents failes.
locFrFidsValues = [loc_qrs_start; loc_qrs_end; loc_t_start; loc_t_end; loc_t_peak];
globFrFidsValues = locFrFidsValues+bsk-1;
nFids=length(fidsTypes);

%%%% set up the fsk and fek and get the first kernels based on the user fiducialized beat
fsk=globFrFidsValues-fidsKernelLength+kernel_shift;   % fiducial start kernel,  the index in potvals where the kernel for fiducials starts
fek=globFrFidsValues+fidsKernelLength+kernel_shift;   % analog to fsk, but 'end'

nLeads=size(potvals,1);
kernels = zeros(nLeads,totalKernelLength, nFids);
for fidNumber = 1:nFids
    kernels(:,:,fidNumber) = potvals(:,fsk(fidNumber):fek(fidNumber));
end
% kernels is now nLeads x nTimeFramesOfKernel x nFids array containing all kernels for each lead for each fiducial
% example: kernel(3,:,5)  is kernel for the 3rd lead and the 5th fiducial (in fidsTypes)


%%%%% find the beats, get rid of beats before user fiducialiced beat



beats=findMatches(signal, signal(bsk:bek), accuracy);

% find oriBeatIdx, the index of the template beat
for beatNumber=1:length(beats)
    if (beats{beatNumber}(1)-AUTOPROCESSING.bsk) < 3  % if found beat "close enough" to original Beat 
        oriBeatIdx=beatNumber;
        break
    end
end
AUTOPROCESSING.beats = beats(oriBeatIdx:end);   % get rid if beats occuring before the user fiducialized beat
nBeats=length(AUTOPROCESSING.beats);





%%%% initialice/preallocate allFids
clear allFids % clear the dummy value from above
defaultFid(nFids).type=[];
[allFids{1:nBeats}]=deal(defaultFid);


%%%%%%%%%%%%% fill AllFids with values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=waitbar(0/nBeats,'Autofiducialicing Beats..');
for beatNumber=1:nBeats %for each beat
    bs=AUTOPROCESSING.beats{beatNumber}(1);  % start of beat

    for fidNumber=1:nFids

        
        %%%% set up windows
        ws=bs+locFrFidsValues(fidNumber)-window_width;  % dont search complete beat, only around fid
        we=bs+locFrFidsValues(fidNumber)+window_width;
        windows=potvals(:,ws:we);
        
        %%%% find fids
        [globFid, indivFids, variance] = findFid(windows,kernels(:,:,fidNumber));

        %put them in global frame
        indivFids=indivFids+fidsKernelLength-kernel_shift+bs-1+locFrFidsValues(fidNumber)-window_width;  % now  newIndivFids is in "complete potvals" frame.
        globFid=globFid+fidsKernelLength-kernel_shift+bs-1+locFrFidsValues(fidNumber)-window_width;      % put it into "complete potvals" frame


        %%%% put the found newIndivFids in allFids
        allFids{beatNumber}(fidNumber).type=fidsTypes(fidNumber);
        allFids{beatNumber}(fidNumber).value=indivFids;
        allFids{beatNumber}(fidNumber).variance=variance;


        %%%% add the global fid to allFids
        allFids{beatNumber}(nFids+fidNumber).type=fidsTypes(fidNumber);
        allFids{beatNumber}(nFids+fidNumber).value=globFid; 
    end
    if isgraphics(h), waitbar(beatNumber/nBeats,h), end
end

if isgraphics(h), delete(h), end
success = 1;



function kernels = getNewKernels(lastFoundFids,potvals, lastFoundBeats)
% returns: kernels, a nLeads x nTimeFramesOfKernel x nFids array containing all kernels for each lead for each fiducial
% example: kernel(3,:,5)  is kernel for the 3rd lead and the 5th fiducial (in fidsTypes)

% inputs:
% - lastFoundFids: the subset of the last nBeats2avrg beats in allFids:    allFids(currentBeat-mBeats2avrg : currentBeat)
% - lastFoundBeats:  the subset of .beats of the last nBeat2avrg:  beats(currentBeat-mBeats2avrg : currentBeat)
% - potvals:  the complete potential values of the whole range of .beats
global ScriptData AUTOPROCESSING


%%%% set up some stuff
nBeats2avrg = length(lastFoundFids);
totalKernelLength = 2*AUTOPROCESSING.FIDSKERNELLENGTH +1;   % the length of a kernel
nFids =length(lastFoundFids{1}) / 2;   % how many fids? divide by 2 because there are local and global fids
nLeads =size(1,potvals); % how many leads in potvals? 
beatLength = 1 + AUTOPROCESSING.beats{1}(2) - AUTOPROCESSING.beats{1}(1);   % the length of a beat %TODO: beatLength might change..



%%%% first get the new local fids to be found as average of the last nBeats2average beats
allLocalFids = zeros(nBeats2avrg,nFids);   % fids in local "beat frame". 
for beatNum = 1:nBeats2avrg % for each entry in lastFoundFids
    allLocalFids(beatNum,:) = [lastFoundFids{beatNum}(nFids+1:2*nFids).value];   % store the global fids of the already processed beats in allLocFids
end
% now get the average
locAvrgdFids = mean(allLocalFids,1);


%%%% now average the potential values of the last nBeats2average beats
allBeatsToAvrg = zeros(nLeads,beatLength,nBeats2avrg);
for beatNum = 1:nBeats2avrg
    timeFramesOfBeat = lastFoundBeats{beatNum}(1):lastFoundBeats{beatNum}(2);
    allBeatsToAvrg(:,:,beatNum) = potvals(:,timeFramesOfBeat);
end
% now average over the beats
avrgdPotvalsOfBeat = mean(allBeatsToAvrg, 3);



%%%% now that we have avrgdPtovalsOfBeat and locAvrgdFids, get the new kernels
fsk=locAvrgdFids-fidsKernelLength+kernel_shift;   % fiducial start kernel,  the index in avrgdPotvalsOfBeat where the kernel for fiducials starts
fek=locAvrgdFids+fidsKernelLength+kernel_shift;   % analog to fsk, but 'end'


kernels = zeros(nLeads,totalKernelLength, nFids);
for fidNumber = 1:nFids
    kernels(:,:,fidNumber) = avrgdPotvalsOfBeat(:,fsk(fidNumber):fek(fidNumber));
end



    
    
























