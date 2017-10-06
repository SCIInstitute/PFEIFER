%% ProcessingScriptFile
% PFEIFER saves all permanent settings (= all settings that are not 'file
% specific'. These are pretty much all settings exept fiducials, leadinfo,
% selected start/endframe) in a scriptfile.mat file, which one can specify
% by the provided path in the 'Processing Script File' text bar.

%%% explanation
% * When you open PFEIFER, it looks for a 'ScriptData.mat' file in the
% current folder PFEIFER was opened. If it finds one, this file is loaded and all
% settings in that file are imported into PFEIFER. From now on, all settings
% are saved in that file (possibly overwriting old settings). If there is no ScriptData.mat file in the
% current start folder, then PFEIFER creates one and stores all settings in
% that file.
% * Whenever the path in the 'Processing Script File' text bar is changed
% PFEIFER does the same as described above: Check if the file of that path exists - if yes:
% import settings from that file and store future settings in that file. If
% no: Export current settings and following setting changes into that file.


%%% example inputs:
% * NameOfMyScriptFile.mat
% * ~/my/folder/names/NameOfMyScriptFile.mat

