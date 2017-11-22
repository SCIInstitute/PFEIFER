function [newBeatKernel, beatLengthAdjustedNewRelFrFidValues] = getNewBeatKernel(rmsSignal,lastFoundBeats,fidTypes, oldRelFrFidValues, newRelFrFidValues)

%%%%% first get some basics
nBeatsToAvrgOver = length(lastFoundBeats);

%%%% get old beat length and old/new qrsStart and tPeak values
oldQRSstart = oldRelFrFidValues(fidTypes == 2);
newQRSstart = newRelFrFidValues(fidTypes == 2);
oldTpeak = oldRelFrFidValues(fidTypes == 6);
newTpeak = newRelFrFidValues(fidTypes == 6);

%%%% compute old QT length and new QT length and the old beat length
oldBeatLength = 1 + lastFoundBeats{1}(2) - lastFoundBeats{1}(1);
oldQTlength = oldTpeak - oldQRSstart;
newQTlength = newTpeak - newQRSstart;

%%%% compute new beat length by adjusting old beat length by the same percentage that QT length changed
newBeatLength = round((newQTlength/oldQTlength) * oldBeatLength);
beatLengthChange = newBeatLength - oldBeatLength;

%%%% now get the new beat kernel
allRMSbeats = zeros(nBeatsToAvrgOver, newBeatLength);
for beatIdx=1:nBeatsToAvrgOver
    newBeatStart = lastFoundBeats{beatIdx}(1) - round((beatLengthChange/2));
    newBeatEnd = newBeatStart + newBeatLength-1;
    allRMSbeats(beatIdx,:) = rmsSignal(newBeatStart:newBeatEnd);
end
newBeatKernel = mean(allRMSbeats,1);


%%%% adjust the newRelFrFidValues to fit the new beat kernel
beatLengthAdjustedNewRelFrFidValues = newRelFrFidValues + round((beatLengthChange/2));

