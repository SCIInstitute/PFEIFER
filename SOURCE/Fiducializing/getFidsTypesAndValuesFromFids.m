function [fidsTypes, fidsValues] = getFidsTypesAndValuesFromFids(fids)
% input:
%   - fids:  any normal ts.fids structure
% output:
%   - fidsTypes = [ fidTypeNumber1, fidTypeNumber1, ...],   an array with all the fidstypes in fids, but only global fids and only qrs-, t- and p-wave/peak
%   - fidsValues =[ fidValue1,      fidValue1,      ...]    the corresponding values of fidTypes


%%%% clear any non-global fids from oriFids
toBeCleared=[];
for p=1:length(fids)
    if length(fids(p).value)~=1   % if not single global value
        toBeCleared=[toBeCleared p];
    end
end
fids(toBeCleared)=[]; 

%%%%% get the fids done by the user (in oriFids), that will be fiducialized
% these are the possible fiducials that will be fiducialized if the user has done them
% corresponds to wave:   p    qrs   t     X               
possibleWaves =       [ 0 1   2 4  5 7  26 27 ];

% corresponds to peak: qrs    t    X
possiblePeaks =       [ 3     6    25 ];


% loop through possible Waves and see if the user did them. If yes, get their values from oriFids and add them to locFrFidsValues
fidsTypes = [];       % these will be the fid types that will be autofiduciailized... 
fidsValues = []; % ...and corresponding fiducials that will be auto-fiducialized
for waveStartTypeIdx = 1:2:length(possibleWaves)
    waveStartType = possibleWaves(waveStartTypeIdx);
    waveEndType = possibleWaves(waveStartTypeIdx+1);
    
    startOriFidsIdx = find([fids.type]==waveStartType, 1);
    endOriFidsIdx = find([fids.type]==waveEndType, 1);
    
    if ~isempty(startOriFidsIdx) && ~isempty(endOriFidsIdx)   % if wave is in oriFids (ergo, was done by user)
        waveStartValue = round(fids(startOriFidsIdx(1)).value);  % get fids value
        waveEndValue = round(fids(endOriFidsIdx(1)).value);  
        fidsTypes = [fidsTypes waveStartType waveEndType];               % and put them in fidsTypes and locFrFidsValues
        fidsValues = [fidsValues waveStartValue waveEndValue];
    end
end
% now loop through possible peaks and do the same like with waves
for peakType = possiblePeaks    
    peakOriFidsIdx = find([fids.type]==peakType, 1);
    if ~isempty(peakOriFidsIdx)   % if peak is in oriFids (ergo, was done by user)
        peakValue = round(fids(peakOriFidsIdx(1)).value);  % get peak value
        fidsTypes = [fidsTypes peakType];               % and put them in fidsTypes and locFrFidsValues
        fidsValues = [fidsValues peakValue];
    end
end