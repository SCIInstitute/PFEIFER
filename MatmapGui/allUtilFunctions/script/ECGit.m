function ECGit

global TS;

d = dir('*.tsdf');

if ~exist(fullfile(pwd,'ecg'),'dir'),
    mkdir('ecg');
end

for q=1:length(d),
    
    fprintf(1,'Processing file: %s\n',d(q).name);
    
    index = ioReadTS(d(q).name);
    handle = plotgrid12x15(TS{index},fullfile('ecg',[TS{index}.filename(1:end-5) '-ecg']));
    close(handle);
    tsClear(index);
    
    fprintf(1,'Rendered ECG figures\n');
    
end

