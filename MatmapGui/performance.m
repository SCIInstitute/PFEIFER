function performance()

file3='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\Run0003.ac2';
cal='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\calibration.cal8';
map='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10\34needles_247sock_192torso_channels.mapping';
outputdir='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\einzelneTestfiles_Tank_10';

global TS
index=ioReadTS(file3, cal, map);


ts=TS{index};
tsCopy_info=whos('ts');
ts_mbytes=tsCopy_info.bytes/10^6;          % bytes of variable in workspace


MatFilename=fullfile(outputdir,'Testfile.mat');
save(MatFilename, 'ts')

matFileInfo=dir(MatFilename);
mat_mytes=matFileInfo.bytes/10^6;


%%%% load a matfile again 
% clear ts
% 
% metastruct=load(MatFilename);
% ts=metastruct.ts;
% tsCopy_info=whos('ts');
% tsCopyMbytes=tsCopy_info.bytes/10^6;
% 
% %%% and save matfile again
% MatCopyFilename=fullfile(outputdir,'TestfileCopy.mat');
% save(MatCopyFilename,'ts')


%%%%% test different versions %%%%%%%%%%%%
clear ts
metastruct=load(MatFilename);
ts=metastruct.ts;

% create different versions of file in current folder
save('v73','ts','-v7.3')
save('v73nocompres','ts','-v7.3','-nocompression')
save('v7','ts','-v7')
save('v6','ts','-v6')


% now load and save them all a view times and measure times
nRuns=10;
loadtime_v73=0;
savetime_v73=0;

loadtime_v73nocompr=0;
savetime_v73nocompr=0;

loadtime_v7=0;
savetime_v7=0;

loadtime_v6=0;
savetime_v6=0;

for p=1:nRuns
    disp('start new run')
    % check v73
    clear ts
    s1=tic;
    metastruct=load('v73');
    loadtime_v73=loadtime_v73 + toc(s1);
    ts=metastruct.ts;
    
    s2=tic;
    save('v73','ts','-v7.3')
    savetime_v73=savetime_v73 + toc(s2);
    
    % check v73nocompress
    clear ts
    s1=tic;
    metastruct=load('v73nocompres');
    loadtime_v73nocompr=loadtime_v73nocompr + toc(s1);
    ts=metastruct.ts;
    
    s2=tic;
    save('v73nocompres','ts','-v7.3','-nocompression')
    savetime_v73nocompr=savetime_v73nocompr + toc(s2);
    
    % check v7
    clear ts
    s1=tic;
    metastruct=load('v7');
    loadtime_v7=loadtime_v7 + toc(s1);
    ts=metastruct.ts;
    
    s2=tic;
    save('v7','ts','-v7')
    savetime_v7=savetime_v7 + toc(s2);

    % check v6
    clear ts
    s1=tic;
    metastruct=load('v6');
    loadtime_v6=loadtime_v6 + toc(s1);
    ts=metastruct.ts;
    
    s2=tic;
    save('v6','ts','-v6')
    savetime_v6=savetime_v6 + toc(s2);
end
loadtime_v73=loadtime_v73/nRuns
savetime_v73=savetime_v73/nRuns

loadtime_v73nocompr=loadtime_v73nocompr/nRuns
savetime_v73nocompr=savetime_v73nocompr/nRuns

loadtime_v7=loadtime_v7/nRuns
savetime_v7=savetime_v7/nRuns

loadtime_v6=loadtime_v6/nRuns
savetime_v6=savetime_v6/nRuns

%%%% Notes/Results

% size of file5:   30 MB         as shown in file explorer
% size of variable ts: 122 MB ??    
% size of matfile: 91 MB !!  as shown in file explorer, 94MB as shown b

% loadtime_v73=0.6280
% savetime_v73=2.8474
% filesize: 72 MB
% 
% loadtime_v73nocompr=0.1375
% savetime_v73nocompr=0.5731
% filesize: 120MB
% 
% loadtime_v7=0.7569
% savetime_v7=2.8831
% filesize: 72MB
% 
% loadtime_v6=0.0637
% savetime_v6=0.3276
% filesize: 120MB

