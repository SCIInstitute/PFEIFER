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




% TODO:this function needs to be refactored

function success = ProcessACQFile(inputfilename,inputfiledir)
success = 0;
olddir = pwd;
global SCRIPTDATA TS

%%%%% create cellaray files={full acqfilename, mappingfile, calibration file}, if the latter two are needed & exist    
filename = fullfile(inputfiledir,inputfilename);
files{1} = filename;
if contains(inputfilename,'.mat'), isMatFile=1; else, isMatFile=0; end


% load & check mappinfile
mappingfile = SCRIPTDATA.RUNGROUPMAPPINGFILE{SCRIPTDATA.CURRENTRUNGROUP};
if isempty(mappingfile)
    SCRIPTDATA.RUNGROUPMAPPINGFILE{SCRIPTDATA.CURRENTRUNGROUP} = '';
end
if ~exist(mappingfile,'file') && SCRIPTDATA.USE_MAPPINGFILE
    msg=sprintf('The .mapping file for the Rungroup %s does not exist.',SCRIPTDATA.RUNGROUPNAMES{SCRIPTDATA.CURRENTRUNGROUP});
    errordlg(msg);
    return
elseif SCRIPTDATA.USE_MAPPINGFILE
    files{end+1}=mappingfile;
end    

if SCRIPTDATA.DO_CALIBRATE == 1 && ~isMatFile     % mat.-files are already calibrated
    if ~isempty(SCRIPTDATA.CALIBRATIONFILE)
        if exist(SCRIPTDATA.CALIBRATIONFILE,'file')
            files{end+1} = SCRIPTDATA.CALIBRATIONFILE;
        end
    end
end
    

%%%% read in the files in TS.  index is index with TS{index}=current ts structure
if isMatFile
    [index, success] =ioReadMAT(files{:});
    if~success, return, end
else
    index = ioReadTS(files{:}); % if ac2 file
end



%%%% make ts.filename only the filename without the path
[~,filename,ext]=fileparts(TS{index}.filename);
TS{index}.filename=[filename ext];
    
    
    
    
    
%%%% check if dimensions of potvals are correct, issue error msg if not
if size(TS{index}.potvals,1) < SCRIPTDATA.MAXLEAD{SCRIPTDATA.CURRENTRUNGROUP}
    errordlg('Maximum lead in settings is greater than number of leads in file');
    cd(olddir);
    return
end
    

%%%% ImportUserSettings (put Data from PROCESSINGDATA in TS{currentTS} %%%%%%%%%%    
fieldstoload = {'SELFRAMES','AVERAGEMETHOD','AVERAGESTART','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES'};      
ImportUserSettings(inputfilename,index,fieldstoload);

    
%%%%  store the GBADLEADS also in the ts structure (in ts.leadinfo)%%%% 
badleads=SCRIPTDATA.GBADLEADS{SCRIPTDATA.CURRENTRUNGROUP};
TS{index}.leadinfo(badleads) = 1;

%%%%% do the temporal filter of current file %%%%%%%%%%%%%%%%
if SCRIPTDATA.DO_FILTER      % if 'apply temporal filter' is selected
    if isempty(SCRIPTDATA.FILTER_OPTIONS)
        errordlg('There are not filter functions in the TOOLS/temporal_filter folder. Could not filter data. Aborting...')
        return
    end
    
    %%%% get filterFunction (the function selected to do temporal filtering) and check if it is valid
    filterFunctionString = SCRIPTDATA.FILTER_OPTIONS{SCRIPTDATA.FILTER_SELECTION};
    if nargin(filterFunctionString)~=1 || nargout(filterFunctionString)~=1
        msg=sprintf('the provided temporal filter function ''%s'' does not have the right number of input and output arguments. Cannot filter data. Aborting..',filterFunctionString);
        errordlg(msg)
        return
    end
    filterFunction = str2func(filterFunctionString);
    [oldNumLeads, oldNumFrames] =  size(TS{index}.potvals);
    
    %%%% try catch to filter the data using filterFunction
    h = waitbar(0,'Filtering signal please wait...');
    try
        TS{index}.potvals = filterFunction(TS{index}.potvals);
    catch
        msg = sprintf('Something wrong with the provided temporal filter function ''%s''. Using it to filter the data failed. Aborting..',filterFunctionString);
        errordlg(msg)
        return
    end
    if isgraphics(h), close(h); end
    
    %%%%  check if potvals still have the right format and the filterFunction worked correctly
    if oldNumFrames ~= size(TS{index}.potvals,2) || oldNumLeads ~= size(TS{index}.potvals,1)
        msg = sprintf('The provided temporal filter function ''%s'' does not work as supposed. It changes the dimensions of the potvals. Using it to filter the data failed. Aborting..',filterFunctionString);
        errordlg(msg)
        return
    end
    
    
    %%%% add an audit string
    auditString = sprintf('|used the temporal filter ''%s'' on the data',filterFunctionString);
    tsAddAudit(index,auditString);
end
        

%%%%%  call SliceDisplay (if UserInterface is selected) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this block does the following:
% - call SliceDisplay
% - some Navigation stuff
% -  does some upgrades to bad leads 
% - calls sigSlice, which in this case:  updates TS{currentIndex} bei
% keeping only the timeframe-window specified in ts.selframes
if SCRIPTDATA.DO_SLICE_USER == 1  %if 'user interaction' button is pressed
    handle = sliceDisplay(index); % this only changes selframes I think it also uses ts.averageframes (and all from export userlist bellow?)
    waitfor(handle);

    switch SCRIPTDATA.NAVIGATION  % if any of these was clicked in sliceDisplay
        case {'prev','next','stop','back'}
            cd(olddir);
            tsClear(index);
            success = 1;
            return; 
    end
end

%%%% store all the SETTINGS/CHANGES done by the user
ExportUserSettings(inputfilename,index,{'SELFRAMES','LEADINFO'});

%%%%%% if 'blank bad leads' button is selected,   set all values of the bad leads to 0   
if SCRIPTDATA.DO_BLANKBADLEADS == 1
    badleads = tsIsBad(index);
    TS{index}.potvals(badleads,:) = 0;
    tsSetBlank(index,badleads);
    tsAddAudit(index,'|Blanked out bad leads');
end

%%%% if autofid user interaction is activated, to autofidicializing
if SCRIPTDATA.AUTOFID_USER_INTERACTION
    SCRIPTDATA.DO_AUTOFIDUCIALISING = 1;
end

%%%% save the ts as it is now in TS{unslicedDataIndex} for autofiducialicing
if SCRIPTDATA.DO_AUTOFIDUCIALISING
    unslicedDataIndex=tsNew(1);
    TS{unslicedDataIndex}=TS{index};        
    SCRIPTDATA.unslicedDataIndex=unslicedDataIndex;
end

%%%% slice the current TS{index} and work with that one
sigSlice(index);   % keeps only the selected timeframes in the potvals, using ts.selframes as start and endpoint


 %%%%%% import more Usersettings from PROCESSINGDATA into TS{index} %%%%
fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
ImportUserSettings(inputfilename,index,fieldstoload);



%%%%%%%%%% start baseline stuff %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if SCRIPTDATA.DO_BASELINE_USER, SCRIPTDATA.DO_BASELINE = 1; end
if (SCRIPTDATA.DO_BASELINE == 1)
%%%% shift ficucials to the new local frame %%%%%%%%%%%%
% fids are always in local frame, but because user selected new local
% frame (the selframe), the local frame changed!

    if ~isfield(TS{index},'selframes')
        msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a PROCESSINGDATA file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame. Aborting...',TS{index}.filename);
        errordlg(msg)
        TS{index}=[];
        success  = 0;
        return
    end
    if ~isfield(TS{index},'startframe'), TS{index}.startframe = 1; end
    newstartframe = TS{index}.selframes(1);  
    oldstartframe = TS{index}.startframe(1);          
    fidsShiftFids(index,oldstartframe-newstartframe);    
    TS{index}.startframe = newstartframe; 
 
    %%%%  get baseline (the intervall ) from TS (so default or from ImportSettings. If values are weird, set to [1, numframes]
    % and set that as new fiducial
    baseline = fidsFindFids(index,'baseline');
    framelength = size(TS{index}.potvals,2);
    baselinewidth = SCRIPTDATA.BASELINEWIDTH;       % also upgrade baselinewidth
    TS{index}.baselinewidth = baselinewidth;
    if length(baseline) < 2
        fidsRemoveFiducial(index,'baseline');
        fidsAddFiducial(index,1,'baseline');
        fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
    end
    %%%% if 'Pre-RMS Baseline correction' button is pressed, do baseline
    %%%% corection of current index (before user selects anything..
    if SCRIPTDATA.DO_BASELINE_RMS == 1
        success = baseLineCorrectSignal(index);
        if ~success, return, end
    end
    
    %%%%   open Fidsdisplay in mode 2, (baseline mode)
    if SCRIPTDATA.DO_BASELINE_USER == 1
        handle = fidsDisplay(index,2);    % this changes fids, but nothing else
        waitfor(handle);

        switch SCRIPTDATA.NAVIGATION
            case {'prev','next','stop','back'}
                cd(olddir);
                tsClear(index);
                success = 1;
                return; 
        end     
    end
    %%%% and save user selections in PROCESSINGDATA    
    ExportUserSettings(inputfilename,index,{'SELFRAMES','LEADINFO','FIDS','STARTFRAME'});
     
    %%%% now do the final baseline correction
    if SCRIPTDATA.DO_BASELINE == 1
        if length(fidsFindFids(index,'baseline')) < 2 
            han = errordlg('At least two baseline points need to be specified, skipping baseline correction');
            waitfor(han);
        else
            success = baseLineCorrectSignal(index);
            if ~success, return, end
        end
    end    
end
    
    


%%%%%%%% now detect the rest of fiducials, if 'detect fids' was selected   
if SCRIPTDATA.DO_DETECT_USER, SCRIPTDATA.DO_DETECT=1; end
if SCRIPTDATA.DO_DETECT == 1
    fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
    ImportUserSettings(inputfilename,index,fieldstoload);


    %%% fids shift, same as in baseline stuff, to get to local frame?!
    if ~isfield(TS{index},'selframes')
        msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a PROCESSINGDATA file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame. Aborting...',TS{index}.filename);
        errordlg(msg)
        TS{index}=[];
        return
    end
    if ~isfield(TS{index},'startframe'), TS{index}.startframe = 1; end      
    newstartframe = TS{index}.selframes(1);
    oldstartframe = TS{index}.startframe(1);        
    fidsShiftFids(index,oldstartframe-newstartframe);    
    TS{index}.startframe = newstartframe;


    %%% check if baseline values are correct. if not, choose [1,
    %%% lastframe] (why is this here again?)
    baseline = fidsFindFids(index,'baseline');
    framelength = size(TS{index}.potvals,2);
    baselinewidth = SCRIPTDATA.BASELINEWIDTH;
    if length(baseline) < 2
        fidsRemoveFiducial(index,'baseline');
        fidsAddFiducial(index,1,'baseline');
        fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
    end


    %%%%%% open FidsDisplay again, this time to select fiducials

    if SCRIPTDATA.DO_DETECT_USER == 1
        handle = fidsDisplay(index);    

        waitfor(handle);
        switch SCRIPTDATA.NAVIGATION
            case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); success = 1; return; 
        end     
    end    
    % save the user selections (stored in ts) in PROCESSINGDATA
    ExportUserSettings(inputfilename,index,{'SELFRAMES','LEADINFO','FIDS','STARTFRAME'});
end

%%%% now we have a fiducialed beat - use it as template to autoprocess the rest of the data in TS{unslicedDataIndex}
if SCRIPTDATA.DO_AUTOFIDUCIALISING
    SCRIPTDATA.CURRENTTS = index;

    success = autoProcessSignal;
    
    
    if ~success, return, end
    
    switch SCRIPTDATA.NAVIGATION
        case {'prev','next','stop','back'}
            success = 1;
            return; 
    end  
end









%%%% this part does the splitting. In detail it
% - creates numgroups new ts structures (one for each group) using
% tsSplitTS
% - it sets ts.'tsdfcfilename' to SCRIPTDATA.GROUPTSDFC(splitgroup)
% - it sets ts.filename to  exact the same..  'including some tsdf
% stuff
% - original ts (the one thats splittet) is cleared
% - index is now index array of the splittet sub ts!!

%%%% split TS{index} into numGroups smaller ts
splitgroup = [];
for p=1:length(SCRIPTDATA.GROUPNAME{SCRIPTDATA.CURRENTRUNGROUP})
    if SCRIPTDATA.GROUPDONOTPROCESS{SCRIPTDATA.CURRENTRUNGROUP}{p} == 0
        splitgroup = [splitgroup p]; 
    end
end

if isempty(splitgroup)
    errordlg('no groups to process.  Perhaps they have all been marked: ''do not process''.')
    return
end

% splitgroup is now eg [1 3] if there are 3 groups but the 2 should
% not be processed
channels=SCRIPTDATA.GROUPLEADS{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup);
splittedTSindices = tsSplitTS(index, channels);    
tsDeal(splittedTSindices,'filename',ioUpdateFilename('.mat',inputfilename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup))); 
tsClear(index);        



%%%% save the new ts structures

tsDeal(splittedTSindices,'filename',ioUpdateFilename('.mat',inputfilename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup)));

%%%% save the group ts structures
for splitIdx=splittedTSindices
    ts=TS{splitIdx};
    fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
    fprintf('Saving file: %s\n',ts.filename)
    save(fullFilename,'ts','-v6')
end    


%%%% do integral maps and save them  
if SCRIPTDATA.DO_INTEGRALMAPS == 1
    if SCRIPTDATA.DO_DETECT == 0
        msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s. Aborting', inputfilename);
        errordlg(msg)
        return
    end
    mapindices = fidsIntAll(splittedTSindices);
    if length(splitgroup)~=length(mapindices)
        msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups. Aborting...',inputfilename);
        errordlg(msg)
        return
    end
    fnames=ioUpdateFilename('.mat',inputfilename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup),'-itg');
    tsDeal(mapindices,'filename',fnames); 
    tsSet(mapindices,'newfileext','');
    
    %%%% save integral maps  and clear them
    for mapIdx=mapindices
        ts=TS{mapIdx};
        fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
        fprintf('Saving file: %s\n',ts.filename)
        save(fullFilename,'ts','-v6')
    end    
    tsClear(mapindices);
end
    
 %%%%% Do activation maps   
    
if SCRIPTDATA.DO_ACTIVATIONMAPS == 1
    if SCRIPTDATA.DO_DETECT == 0 % 'Detect fiducials must be selected'
        errordlg('Fiducials needed to do Activationsmaps! Select the ''Do Fiducials'' button to do Activationmaps. Aborting...')
        return;
    end

    %%%% make new ts at TS(mapindices). That new ts is like the old
    %%%% one, but has ts.potvals=[act rec act-rec]
    [mapindices, success] = sigActRecMap(splittedTSindices);   
    if ~success,return, end
    
    tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,SCRIPTDATA.GROUPEXTENSION{SCRIPTDATA.CURRENTRUNGROUP}(splitgroup),'-ari')); 
    tsSet(mapindices,'newfileext','');
    
    %%%% save integral maps  and clear them
    for mapIdx=mapindices
        ts=TS{mapIdx};
        fullFilename=fullfile(SCRIPTDATA.MATODIR, ts.filename);
        fprintf('Saving file: %s\n',ts.filename)
        save(fullFilename,'ts','-v6')
    end    
    tsClear(mapindices);
end

%%%%% save everything and clear TS
savePROCESSINGDATA;
saveSettings;
tsClear(splittedTSindices);
if SCRIPTDATA.DO_AUTOFIDUCIALISING
    tsClear(SCRIPTDATA.unslicedDataIndex);
    SCRIPTDATA.unslicedDataIndex=[];
end

success = 1;

end
