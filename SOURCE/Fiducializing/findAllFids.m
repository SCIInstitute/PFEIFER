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





function [allFidsGlFr, success] = findAllFids(potvals,signal)
% returns allFids = {fidsBeat1, fidsBeat2, .... , FidsLastBeat}
% each fidsBeatN is a numFids - array - struct 'fids' with the fields: 'type' (the fiducial type) and  'value' (the values of the fid in global frame) 
% in short: fidsBeatN is just like the 'fids' struct as it is saved in ts,
% but in the global frame!!
% Fids are determined based on 'oriFids', die fids done by the user.

allFidsGlFr = 'dummyValue'; % to make sure this function has a value to return, even if function returns earlier as planned due to error
%%%%% get paramters from ScriptData
global ScriptData AUTOPROCESSING TS
accuracy=ScriptData.ACCURACY;  % abort condition5
fidsKernelLength=ScriptData.FIDSKERNELLENGTH;  % the kernel indices will be from fidsValue-fidsKernelLength  until fidsValue+fidsKernelLength
kernel_shift=0;       % a "kernel shift", to shift the kernel by kernel_shift   % not used, just here as placeholder..
% reminder: it is kernel_idx=fid_start-fidsKernelLength+kernel_shift:fid_start+fidsKernelLength+kernel_shift
window_width=ScriptData.WINDOW_WIDTH;   % dont search complete beat, but only a window with width window_width,
% ws=bs+loc_fidsValues(fidNumber)-window_width;  
% we=bs+loc_fidsValues(fidNumber)+window_width;

totalKernelLength = 2*fidsKernelLength +1;   % the length of a kernel


%%%% beat kernel
bsk=AUTOPROCESSING.bsk;   %start and end of beat
bek=AUTOPROCESSING.bek;


%%%% clear any nonglobal fids from oriFids
oriFids=AUTOPROCESSING.oriFids;
toBeCleared=[];
for p=1:length(oriFids)
    if length(oriFids(p).value)~=1   % if not single global value
        toBeCleared=[toBeCleared p];
    end
end
oriFids(toBeCleared)=[];



%%%%% get the fids done by the user (in oriFids), that will be fiducialized

% these are the possible fiducials that might be done by the user
% corresponds to wave:   p    qrs   t     X               
possibleWaves =       [ 0 1   2 4  5 7  26 27 ];
% corresponds to peak: qrs    t    X
possiblePeaks =       [ 3     6    25 ];


% loop through possible Waves and see if the user did them. If yes, get their values from oriFids and add them to locFrFidsValues
fidsTypes = [];       % these will be the fid types... 
locFrFidsValues = []; % ...and corresponding fiducials that will be auto-fiducialised
for waveStartTypeIdx = 1:2:length(possibleWaves)
    waveStartType = possibleWaves(waveStartTypeIdx);
    waveEndType = possibleWaves(waveStartTypeIdx+1);
    
    startOriFidsIdx = find([oriFids.type]==waveStartType, 1);
    endOriFidsIdx = find([oriFids.type]==waveEndType, 1);
    
    if ~isempty(startOriFidsIdx) && ~isempty(endOriFidsIdx)   % if wave is in oriFids (ergo, was done by user)
        waveStartValue = round(oriFids(startOriFidsIdx(1)).value);  % get fids value
        waveEndValue = round(oriFids(endOriFidsIdx(1)).value);  
        fidsTypes = [fidsTypes waveStartType waveEndType];               % and put them in fidsTypes and locFrFidsValues
        locFrFidsValues = [locFrFidsValues waveStartValue waveEndValue];
    end
end
% now loop through possible peaks and do the same like with waves
for peakType = possiblePeaks    
    peakOriFidsIdx = find([oriFids.type]==peakType, 1);
    if ~isempty(peakOriFidsIdx)   % if peak is in oriFids (ergo, was done by user)
        peakValue = round(oriFids(peakOriFidsIdx(1)).value);  % get peak value
        fidsTypes = [fidsTypes peakType];               % and put them in fidsTypes and locFrFidsValues
        locFrFidsValues = [locFrFidsValues peakValue];
    end
end



%%%% get the globFidsValues, the fids in the "global complete signal frame"
globFrFidsValues = locFrFidsValues+bsk-1;
nFids=length(fidsTypes);

%%%% set up the fsk and fek and get the first kernels based on the user fiducialized beat
fsk=globFrFidsValues - fidsKernelLength + kernel_shift;   % fiducial start kernel,  the index in potvals where the kernel for fiducials starts
fek=globFrFidsValues + fidsKernelLength + kernel_shift;   % analog to fsk, but 'end'

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
oriBeatIdx = [];
for beatNumber=1:length(beats)    
    if (abs(beats{beatNumber}(1)-AUTOPROCESSING.bsk)) < 3  % if found beat "close enough" to original Beat 
        oriBeatIdx=beatNumber;
        break
    end
end

if isempty(oriBeatIdx)
    oriBeatEnvelope=[bsk,bek];
    AUTOPROCESSING.beats=[oriBeatEnvelope beats];
    disp('beat issue')
else
    AUTOPROCESSING.beats = beats(oriBeatIdx:end);   % get rid if beats occuring before the user fiducialized beat

end
nBeats=length(AUTOPROCESSING.beats);





%%%% initialice/preallocate allFids
clear allFidsGlFr % clear the dummy value from above
if nFids > 0
    defaultFid(nFids).type=[];
else
    defaultFid = struct('type',[],'value',[],'variance',[]);
end
[allFidsGlFr{1:nBeats}]=deal(defaultFid);


%%%%%%%%%%%%% fill AllFids with values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h=waitbar(0/nBeats,'Autofiducializing Beats..');
for beatNumber=1:nBeats %for each beat
    bs=AUTOPROCESSING.beats{beatNumber}(1);  % start of beat
    be=AUTOPROCESSING.beats{beatNumber}(2);  % end of beat
    
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

        
        %%%% if globFids are outside of beat, make beat larger to fit fiducial
        if globFid > be
            AUTOPROCESSING.beats{beatNumber}(2)=globFid;
        elseif globFid < bs
            AUTOPROCESSING.beats{beatNumber}(1)=globFid;
        end
        

        %%%% put the found newIndivFids in allFids
        allFidsGlFr{beatNumber}(fidNumber).type=fidsTypes(fidNumber);
        allFidsGlFr{beatNumber}(fidNumber).value=indivFids;
        allFidsGlFr{beatNumber}(fidNumber).variance=variance;


        %%%% add the global fid to allFids
        allFidsGlFr{beatNumber}(nFids+fidNumber).type=fidsTypes(fidNumber);
        allFidsGlFr{beatNumber}(nFids+fidNumber).value=globFid; 
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



    
    
























