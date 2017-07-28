function getFrames()
global TS
numframes=101;
intervalLength=2;


numIntervals=ceil(numframes/intervalLength);
[frames{1:numIntervals}]=deal([]); % pre initialize
for p=1:numIntervals-1
    frames{p}=((p-1)*intervalLength+1):(p*intervalLength);
end
frames{end}=((numIntervals-1)*intervalLength+1):numframes;