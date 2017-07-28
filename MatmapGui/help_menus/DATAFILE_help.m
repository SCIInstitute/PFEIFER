%% myProcessingScript
% in a Processing Data File matmap stores all the settings/user selections
% that are file specific, eg. fiducials, start/endframe or information
% about the baseline correction. 
% 
%% explanation
%
% * When matlab is started, it looks for a 'myProcessingData.mat' file in the
% current folder. If it finds one, all the settings from that file are
% imported. Any changes the user makes will also be saved in that file
% (overwriting previous user selections). If there is no
% 'myProcessingData.mat' file in the current folder at the start of matmap,
% matmap creates one and saves all future file specific user selections in
% that created file.
% * Whenever the path in the Processing Data File text bar is changed,
% matmap looks if the file specified by the path exists. If it does, all the file
% specific settings from that file are imported and future user selections
% saved in that file. If it doesn't, matmap creates a file at the specified
% path and from that point on uses that file as a Processing Data File.
%
%% notes
%
% * matmap links the chosen file specific user selections to the
% corresponding data input files (eg. .ac2 files) by their file name. Thus,
% if the filenames are changed, matmap cannot link the chosen settings to
% the rigth file anymore.
