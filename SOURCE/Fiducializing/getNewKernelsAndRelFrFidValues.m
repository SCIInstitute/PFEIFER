function [newFidKernels,newRelFrFidValues] = getNewKernelsAndRelFrFidValues(limPotvals, lastFoundFids, lastFoundBeats, fidTypes, fidsKernelLength)
% this function averages over the last nBeats2avrg found beats to get new kernels and locFidValues
%
% OUTPUT: 
%   - fidKernels, a nLeadsToAutofiducialize x nTimeFramesOfKernel x nFids array containing all kernels for each lead for each fiducial
%     example: kernel(3,:,5)  is kernel for the 3rd lead and the 5th fiducial (in fidTypes)
%   - locFidValues: the values where to search for fids in local 'beat frame' of beatKernel

% INPUT:
%   - limPotvals:   'limitted' potvals, the potvals with only the leads that are autofiducialized. So limPotvals musst have only nLeadsToAutofiducialize
%     leads
%     limPotvals = FullPotvals(leadsToAutoprocess,:)  (plus possibly one RMS lead)
%   - lastFoundFids: a [1 x nBeats2avrg cell array] containing the fids ( = the fids structure with fields 'type' and 'value') to average over.
%     fids can contain individual fids (those will be ignored). The fids must contain all global Fids that are in fidsTypes. The order of fiducials in fids
%     does not matter, but all fids in lastFoundFids musst be the same. The fiducials musst be in the same absolute frame to match limPotvals (not in
%     relative beat frame)
%     intended use: lastFoundFids = allFidsAbsFr( currentBeat-nBeats2avrg:currentBeat )
%   - lastFoundBeats:  [1 x nBeats2avrg cell array] containing the beat envelopes of the beats to average over. A beat envelope is a [1 x 2 integer
%     array] containing the start and endframe of the beat: beatEnvelope =  [beatStartFrame, beatEndFrame]
%     intended use: lastFoundBeats = beats(currentBeat-mBeats2avrg : currentBeat)
%   - fidTypes: [1 x nFids array] containing the fid types in the right order we want them to be in kernels

%%%% set up some stuff
nBeats2avrg = length(lastFoundFids);  % how many beats to average over?
totalKernelLength = 2 * fidsKernelLength +1;   % the length of a kernel
nFids =length(lastFoundFids{1}) / 2;   % how many fids? divide by 2 because there are local and global fids
nLeads =size(limPotvals,1); % how many leads in potvals? 


%%%% get the fidsIdx, the indeces of the fidTypes (in the same order) in the fid structures
fids = lastFoundFids{1};
fidsIdxs = [];
for fidType = fidTypes
    idxs = find([fids.type] == fidType);
    for idx = idxs
        if length(fids(idx).value) == 1  % if global fiducial
            fidsIdxs(end+1) = idx;
            break
        end
    end
end
if length(fidsIdxs) ~= length(fidTypes)
    error('not all fidTypes are in fids')
end


%%%% extract the fiducial values from lastFoundFids
allRelFrFids = zeros(nBeats2avrg,nFids);   % fids in "relative beat frame". 
allAbsFrFids = zeros(nBeats2avrg,nFids);   % fids in "relative beat frame". 
for beatIdx = 1:nBeats2avrg % for each entry in lastFoundFids
    absFrFidValues = [lastFoundFids{beatIdx}(fidsIdxs).value]; % get fid values of the last already processed beats in global frame
    RelFrFidValues = 1 + absFrFidValues - lastFoundBeats{beatIdx}(1);  % put them in relative beat frame
    allRelFrFids(beatIdx,:) = RelFrFidValues;   % and store them in allRelFrFids  , the relative frame fid values of the last processed beats
    allAbsFrFids(beatIdx,:) = absFrFidValues;
end
allAbsFrFids = round(allAbsFrFids);  % we want to use them as indeces, so they have to be integers

newRelFrFidValues = round(mean(allRelFrFids,1));  % the new averaged local fid values, these will be the new 'relative frame original fiducial values', 


%%%% get the new fsk and fek (fiducial start/end kernel time frame) for each beat. So we need to add a new dimension (telling you "which beat") to fsk/fek 
kernelShift = zeros(1,nFids);
kernelShift(fidTypes == 5) =  floor(fidsKernelLength/2);
all_fsk = allAbsFrFids - fidsKernelLength + kernelShift;    % to do: make sure this is not out of range of potvals! also: fsk is used for absFr - relFr shift.. does this matter?
all_fek = allAbsFrFids + fidsKernelLength + kernelShift;
% indeces for all_fsk/fek work like this:    kernel_start_frame_for_specific_beat_and_fiducial_type = all_fsk('which beat?', 'which fiducial?') 

%%%% set up the kernels for each beat 
allKernels = zeros(nBeats2avrg, nLeads, totalKernelLength, nFids); % just like normal kernels, but with one dimension added for the beats
for beatIdx = 1:nBeats2avrg % for each entry in lastFoundFids
    for fidIdx = 1:nFids
        allKernels(beatIdx,:,:,fidIdx) = limPotvals(:,all_fsk(beatIdx,fidIdx):all_fek(beatIdx,fidIdx));        
    end
end

newFidKernels = mean(allKernels,1);   % average the kernels across beats
newFidKernels = permute(newFidKernels,[2 3 4 1]);  % get rid of singleton dimension




