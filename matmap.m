function matmap(varargin)
    %this is the first function to be called from the command line
%         - Init ScriptData
%         - Init ProcessingData
%         - Open the mainMenu.fig ("the main menu")
%         - Open the Settings.fig ("settings menu")
%         - Update mainMenu.fig and Settings.fig with data from ScriptData
%         - Update/setup File list, (callback for "choose input directory)
%         - this script also contains all the callbacks of the main menu
%         and settings menu.  


%%%% check if this script is called as a callback or to start matmap
if nargin > 1 && ischar(varargin{1})  % if called as a callback
    feval(varargin{1},varargin{2:end});  % execute callback
    return
end

%%%% initianlize the globals ScriptData and ProcessingData
clear global ScriptData ProcessingData
initScriptData();   
initProcessingData();


%%%% open the main menu and the settings window and update them with data
main_handle=mainMenu();            % open the figure
updateFigure(main_handle);      % and update it 
setHelpMenus(main_handle)      % and set help buttons

setting_handle=SettingsDisplay();    %Open the settings Display
updateFigure(setting_handle);     % and update it
setHelpMenus(setting_handle);      % initialise help menus that pop up when you righ click on button
updateACQFiles      % get ACQ Files from input directory to display
end


function initScriptData()
    % - Sets up global ScriptData as empty struct
    % - initializes ScriptData with Default Values for everything
    
    global ScriptData;
    ScriptData = struct();
    ScriptData.TYPE = struct();
    ScriptData.DEFAULT = struct();

    defaultsettings=getDefaultSettings;

    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8)
            ScriptData.(defaultsettings{p})={};
        else
            ScriptData.(defaultsettings{p})=defaultsettings{p+1};
        end
        ScriptData.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        ScriptData.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
    end
end


function initProcessingData()
% init the global ProcessingData
global ProcessingData
ProcessingData = struct;
ProcessingData.SELFRAMES = {};
ProcessingData.REFFRAMES = {};
ProcessingData.AVERAGESTART = {};
ProcessingData.AVERAGEEND = {};
ProcessingData.FILENAME={};
end

function ExportUserSettings(filename,index,fields)
    % save the user selections stored in TS{index}.(fields) in ProcessingData.  fields could be e.g. 'fids' 
    % if fields dont exist in ts, it will be set to [] in ProcessingData. It's no
    % problem if field doesnt exist in ProcessingData at beginning
    
    global ProcessingData TS;
    %%%% first find filename
    filenum = find(strcmp(filename,ProcessingData.FILENAME));

    %%%% if no entry for the file exists so far, make one
    if isempty(filenum)
        ProcessingData.FILENAME{end+1} = filename;
        filenum = length(ProcessingData.FILENAME);
    end
    
    %%%% loop through fields and save data in ProcessingData
    for p=1:length(fields)
        if isfield(TS{index},lower(fields{p}))
            value = TS{index}.(lower(fields{p}));
            if isfield(ProcessingData,fields{p})
                data = ProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            ProcessingData.(fields{p})=data;
        else
            value = [];
            if isfield(ProcessingData,fields{p})
                data = ProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            ProcessingData.(fields{p})=data;
        end
    end
    
    %%%% save data in ProcessingData file
    saveProcessingData; 
end

function ImportUserSettings(filename,index,fields)
    % Imports the fields from ProcessingData in the corresponding ts structure of
    % TS. Identification via filename. 

    global ProcessingData TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,ProcessingData.FILENAME'));
    % THEN RETRIEVE THE DATA FROM THE DATABASE
    
    if ~isempty(filenum)
        for p=1:length(fields)
            if isfield(ProcessingData,fields{p})
                data = ProcessingData.(fields{p});
                if length(data) >= filenum(1)
                    if ~isempty(data{filenum(1)})
                        TS{index}.(lower(fields{p}))=data{filenum(1)};
                    end
                end
            end
        end
    end
end

function saveProcessingData()
global ScriptData ProcessingData;
save(ScriptData.DATAFILE,'ProcessingData');
end


function updateFigure(handle)
% changes all Settings in the figure ( that belongs to handle) according to
% ScriptData.  
%Updates everything in the gui figures, including File Listbox etc..
% handle is gui figure object
    
global ScriptData;

%%%% loop through all fieldnames of ScriptData and make changes accourding to the fieldname
fn = fieldnames(ScriptData);
for p=1:length(fn)
    %%%% identify the uicontrol object in the gui figure ("handle") that is related to the fieldname. The uicontrol object are identified by there tag property
    obj = findobj(allchild(handle),'tag',fn{p});
    if ~isempty(obj) % if field is also Tag to a uicontroll object in the figure..
        %%%% change that uicontroll. Depending on type..  
        objtype = ScriptData.TYPE.(fn{p});
        switch objtype
            case {'file','string'}
                obj.String = ScriptData.(fn{p});
            case {'listbox'}
                cellarray = ScriptData.(fn{p});
                if ~isempty(cellarray) 
                    values = intersect(ScriptData.ACQFILENUMBER,ScriptData.ACQFILES);
                    set(obj,'string',cellarray,'max',length(cellarray),'value',values,'enable','on');
                else
                    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
                end
            case {'double','vector','listboxedit','integer'}
                obj.String = mynum2str(ScriptData.(fn{p}));
            case {'bool'}
                obj.Value = ScriptData.(fn{p});
            case {'select'}   % case of ScriptData.GROUPSELECT  
                value = ScriptData.(fn{p});    % int telling which group is selected
                if value == 0, value = 1; end  %if nothing was selected
                obj.Value = value;
                rungroup=ScriptData.RUNGROUPSELECT;
                if rungroup==0, continue; end
                selectnames = ScriptData.GROUPNAME{rungroup};  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectnames{end+1} = 'NEW GROUP';
                obj.String = selectnames;

            case {'selectR'}
                value = ScriptData.(fn{p});    % int telling which rungroup is selected
                if value == 0, value = 1; end  %if nothing was selected
                selectrnames = ScriptData.RUNGROUPNAMES;  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectrnames{end+1} = 'NEW RUNGROUP'; 
                obj.String = selectrnames;
                obj.Value = value;


            case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}   
                group = ScriptData.GROUPSELECT;
                if (group > 0)
                    set(obj,'enable','on','visible','on');
                    cellarray = ScriptData.(fn{p}){ScriptData.RUNGROUPSELECT};
                    if length(cellarray) < group   %if the 'new group' option is selected!
                        cellarray{group} = ScriptData.DEFAULT.(fn{p});      % if new group was added, fill emty array slots with default values
                    end
                    switch objtype(6:end)
                        case {'file','string'}
                            obj.String = cellarray{group};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{group});
                        case {'bool'}
                            obj.Value = cellarray{group};
                    end
                    ScriptData.(fn{p}){ScriptData.RUNGROUPSELECT}=cellarray;    
                else
                    set(obj,'enable','inactive','visible','off');
                end
            case {'rungroupstring', 'rungroupvector'}    %any of the rungroupbuttons
                rungroup = ScriptData.RUNGROUPSELECT;
                if (rungroup > 0)
                    set(obj,'enable','on','visible','on');
                    set(findobj(allchild(handle),'tag','GROUPSELECT'),'enable','on','visible','on')
                    set(findobj(allchild(handle),'tag','RUNGROUPFILESBUTTON'),'enable','on','visible','on')

                    cellarray = ScriptData.(fn{p});                     
                    switch objtype(9:end)
                        case {'file','string'}
                            obj.String = cellarray{rungroup};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{rungroup});
                        case {'bool'}
                            obj.Value = cellarray{rungroup};
                    end
                    ScriptData.(fn{p})=cellarray;
                else
                    set(obj,'enable','inactive','visible','off');
                    set(findobj(allchild(handle),'tag','GROUPSELECT'),'enable','off','visible','off')
                    set(findobj(allchild(handle),'tag','RUNGROUPFILESBUTTON'),'enable','off','visible','off')
                end
        end
    end
end
end


function getACQFiles
% this function finds all files in ScriptData.ACQDIR (the input directory) and updates the following fields of ScriptData accordingly:
% - ScriptData.ACQFILENUMBER     double array of the form
% - [1:NumberOfFilesDisplayedInListbox]
% - ScriptData.ACQLISTBOX        cellarray with strings for the listbox
% - ScriptData.ACQFILENAME       cellarray with all filenames in ACQDIR
% - ScriptData.ACQINFO           cellarray with a label for each file
% - ScriptData.ACQFILES          double array of selected files in the
% - listbox obj in main menu gui figure

global ScriptData TS;

if isempty(ScriptData.ACQDIR), return, end  % if no input directory selected so far, just return

%%%% create a cell array with all the filenames in the listbox, that are at the moment selected. This is needed to select them again in case they are also in the new input dir
oldfilenames = {};
if ~isempty(ScriptData.ACQFILES)
    for p=1:length(ScriptData.ACQFILES)
        if ScriptData.ACQFILES(p) <= length(ScriptData.ACQFILENAME)
            oldfilenames{end+1} = ScriptData.ACQFILENAME{ScriptData.ACQFILES(p)};
        end
    end
end
%oldfilenames is now  cellarray with filenamestrings of only the
%selected files in listbox, eg {'Run0005.mat','Run0012.mat' }, not of all files in dir





%%%% change into ScriptData.ACQDIR,if it exists and is not empty
olddir = pwd;
try
    cd(ScriptData.ACQDIR);
catch
    errordlg('input directory doesn''t exist. No files loaded..')
    return
end


%%%% set up a cell array filenames with all the filenames in folder
filenames = {};
exts = commalist(ScriptData.ACQEXT);  % create cellarray with all the allowed file extensions specified by the user
for p=1:length(exts)
    d = dir(sprintf('*%s',exts{p}));
    for q= 1:length(d)
        filenames{end+1} = d(q).name;
    end
end
% filenames is cellarray with all the filenames of files in folder, like 
%{'Ran0001.ac2'    'Ru0009.ac2'}


%%%% get rid of files that don't belong here, also sort files
filenames(strncmp('._',filenames,2))=[];  % necessary to get rid of weird ghost files on server
filenames = sort(filenames);


%%%% initialize/clear old entries
ScriptData.ACQFILENUMBER = [];
ScriptData.ACQLISTBOX= {};
ScriptData.ACQFILENAME = {};
ScriptData.ACQINFO = {};
ScriptData.ACQFILES = [];

if isempty(filenames)
    cd(olddir)
    return
end
h = waitbar(0,'INDEXING AND READING FILES','Tag','waitbar'); drawnow;
nFiles=length(filenames);
for p = 1:nFiles  
    %%%% load filename in various ways, depending if .mat .ac2..
    %%%% with/without 'ts_info...,  adds ts_info if its missing
    clear ts ts_info
    [~,~,ext]=fileparts(filenames{p});
    if strcmp(ext,'.mat')
        warning('off','all')  % supress warning, if 'ts_info' not in mat
        load(filenames{p},'ts_info')
        warning('on','all')
        if exist('ts_info','var')
            ts=ts_info;

        else  % if no 'ts_info', load ts, but append 'ts_info' to mat file
            load(filenames{p},'ts')
            if ~exist('ts','var')
                msg=sprintf('The file %s in the input directory does not contain a ''ts'' or ''ts_info'' structure. Aborting file loading..',filenames{p});
                errordlg(msg)
                return
            end

            % create and append ts_info to .mat file
            fn=fieldnames(ts);
            for q=1:length(fn)
                if strcmp(fn{q},'potvals'), continue, end
                ts_info.(fn{q})=ts.(fn{q});
            end   
            save(filenames{p},'ts_info','-append')  
        end
    elseif strcmp(ext,'.ac2')
        index=ioReadTS(filenames{p});
        ts=TS{index};
        TS{index}=[];
    else
        msg=sprintf('The file %s cannot be loaded, since it''s not a .mat or .ac2 file. Aborting file loading...',filenames{p});
        errordlg(msg)
        return
    end


    if ~isfield(ts,'time'), ts.time = 'none'; end
    if ~isfield(ts,'label'), ts.label = 'no label'; end
    if ~isfield(ts,'filename')
        errordlg(sprintf('Problems occured reading file %s. This file does not have the filename field.  Aborting to load files...',filenames{p}));
        return
    end

    ts.label=myStrTrim(ts.label); %necessary, because original strings have weird whitespaces that are not recognized as whitespaces.. really weird!
    ScriptData.ACQFILENUMBER(p) = p;      

    %%%% find out which rungroup p belongs to
    rungroup='';
    for rungroupIdx=1:length(ScriptData.RUNGROUPNAMES)
        if ismember(p, ScriptData.RUNGROUPFILES{rungroupIdx})
            rungroup=ScriptData.RUNGROUPNAMES{rungroupIdx};
            break
        end
    end

    ts.time=myStrTrim(ts.time);   % use of myStrTrim for the same reason as above..     

    ScriptData.ACQLISTBOX{p} = sprintf('%04d %15s %15s %13s %20s',ScriptData.ACQFILENUMBER(p),ts.filename,rungroup, ts.time,ts.label);

    ScriptData.ACQFILENAME{p} = ts.filename;
    ScriptData.ACQINFO{p} = ts.label;

    if isgraphics(h), waitbar(p/nFiles,h); end
end

[~,~,ScriptData.ACQFILES] = intersect(oldfilenames,ScriptData.ACQFILENAME);
ScriptData.ACQFILES = sort(ScriptData.ACQFILES);

if isgraphics(h), waitbar(1,h); end
drawnow;
if isgraphics(h), delete(h); end
cd(olddir);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback functions %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CloseFcn(~)
%callback function for the 'close' buttons.
global ScriptData ProcessingData FIDSDISPLAY SLICEDISPLAY TS

%%%% save setting
if ~isempty(ScriptData.SCRIPTFILE)
 saveSettings
 disp('Saved SETTINGS before closing matmap')
else
 disp('matmap closed without saving SETTINGs')
end

%%%% delete all gui figures
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS')); 
delete(findobj(allchild(0),'tag','SLICEDISPLAY'));
delete(findobj(allchild(0),'tag','FIDSDISPLAY'));

%%%% delete all waitbars
waitObjs = findall(0,'type','figure','tag','waitbar');
delete(waitObjs);

%%%% delete all error dialog windows
errordlgObjs = findall(0,'type','figure','tag','Msgbox_Error Dialog');
delete(errordlgObjs);

%%%% clear globals
clear global ProcessingData ScriptData FIDSDISPLAY SLICEDISPLAY TS
end

function Browse(handle,ext,mode)
% callback to all the browse buttons.  mode is either 'file' or 'folder'
    global ScriptData
    if nargin == 1
        ext = 'mat';
        mode = 'file';
    end
    
    if nargin == 2
        mode = 'file';
    end
    
    tag = handle.Tag;
    tag = tag(8:end);
    
    if strcmp(tag,'RUNGROUPMAPPINGFILE')
        filename = ScriptData.(tag){ScriptData.RUNGROUPSELECT};
    else
        filename = ScriptData.(tag);
    end
    
    switch mode
        case 'file'
            [fn,pn] = uigetfile(['*.' ext],'SELECT FILE',filename);
            if (fn == 0), return; end
            newFileString=fullfile(pn,fn);
        case 'dir'
            pn  = uigetdir(pwd,'SELECT DIRECTORY');
            if (pn == 0), return; end
            newFileString=pn;         
    end
    
    
    switch tag
        case 'ACQDIR'
            ScriptData.(tag)=newFileString;
            updateACQFiles(handle)
        case 'SCRIPTFILE'  
            success = loadScriptData(newFileString);
            if success
                ScriptData.SCRIPTFILE = newFileString;
            else
                return
            end
            %%%% update stuff
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
            getACQFiles
        case 'DATAFILE'
            success = loadProcessingData(newFileString);
            if success
                ScriptData.DATAFILE=newFileString;
            end
        case 'RUNGROUPMAPPINGFILE'
           ScriptData.(tag){ScriptData.RUNGROUPSELECT}=newFileString; 
        otherwise
           ScriptData.(tag)=newFileString;
    end
    updateFigure(handle.Parent);
end

function selectRunGroupFiles(~)
%callback function to 'select Rungroup files'

selectRungroupFiles

%%%% make sure each file is associated with only one rungroup
global ScriptData
rungroup=ScriptData.RUNGROUPSELECT;
for s=1:length(ScriptData.RUNGROUPFILES{rungroup})
    rgFileID=ScriptData.RUNGROUPFILES{rungroup}(s);
    for t=1:length(ScriptData.RUNGROUPFILES)
        if t== rungroup, continue, end
        ScriptData.RUNGROUPFILES{t}=ScriptData.RUNGROUPFILES{t}(ScriptData.RUNGROUPFILES{t}~=rgFileID);
    end
end
        
        




updateACQFiles
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));


end




function updateACQFiles(~)
% callback function to "Choose Input Directory"


%   - loads data files and updates ACQFILENUMBER, ACQFILENAME, ACQINFO, ACQLISTBOX
%   - Update figure by calling updateFigure

    getACQFiles;    %update all the file related cellarrays, load files into TS cellarray
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end




function setScriptData(handle, mode)
% callback function to almost all buttons

% notes on how it works:
% the tag property of each object in the figure display is used to locate that object
% the tag of each each grafic object is also the fieldname of the
% corresponding fiel in ScriptData.  To further differentiate how each
% object is being dealt, the objecttype=ScriptData.TYPE.(tag) is used.



global ScriptData ProcessingData;
tag = handle.Tag; 
success = 0;
success = checkNewInput(handle, tag);
if ~success, return, end

if isfield(ScriptData.TYPE,tag)
    objtype = ScriptData.TYPE.(tag);
else
    objtype = 'string';
end
switch objtype
    case {'file','string'}
        ScriptData.(tag)= handle.String;
    case {'double','vector','integer'}
        ScriptData.(tag)=mystr2num(handle.String);
    case 'bool'
        ScriptData.(tag)=handle.Value;
    case 'select'
        ScriptData.(tag)=handle.Value;
    case 'selectR'
        value=handle.Value;
        ScriptData.(tag)=value;           
        if length(ScriptData.RUNGROUPNAMES) < value  %if NEW RUNGROUP is selected, make all group cells longer
            fn=fieldnames(ScriptData.TYPE);
            for p=1:length(fn)
                if strncmp(ScriptData.TYPE.(fn{p}),'group',5)
                    ScriptData.(fn{p}){end+1}={};
                end
                if strncmp(ScriptData.TYPE.(fn{p}),'rungroup',8)  %if NEW RUNGROUP is selected, make all rungroup cells one entry longer
                    ScriptData.(fn{p}){end+1} = ScriptData.DEFAULT.(fn{p});
                end                     
            end
            ScriptData.GROUPSELECT=0;
         end          
    case 'listbox'
        ScriptData.ACQFILES = ScriptData.ACQFILENUMBER(handle.Value);
    case {'listboxedit'}
        ScriptData.(tag)=mystr2num(handle.String);
    case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}      %if any of the groupstuff is changed
        group = ScriptData.GROUPSELECT;      %integer, which group is selected in dropdown
        if (group > 0)
            if isfield(ScriptData,tag)  
                cellarray = ScriptData.(tag){ScriptData.RUNGROUPSELECT};     % cellarray is eg {{'-gr1', '-gr2'}, .. } 
            else
                cellarray = {};
            end
            switch objtype(6:end)     %change individual entry of cellarray according to user input.
                case {'file','string'}
                    cellarray{group} = handle.String;
                case {'double','vector'}
                    cellarray{group} = mystr2num(handle.String);
                case {'bool'}
                    cellarray{group} = handle.Value;
            end
            ScriptData.(tag){ScriptData.RUNGROUPSELECT}=cellarray;
        end
    case {'rungroupstring', 'rungroupvector'}  
        rungroup=ScriptData.RUNGROUPSELECT;
        if rungroup > 0
            cellarray = ScriptData.(tag);     % cellarray is eg {{'-gr1', '-gr2'}, .. } 

            switch objtype(9:end)     %change individual entry of cellarray according to user input. 
                case {'file','string'}
                    cellarray{rungroup} = handle.String;
                case {'double','vector'}
                    cellarray{rungroup} = mystr2num(handle.String);
                case {'bool'}
                    cellarray{rungroup} = handle.Value;
            end
            ScriptData.(tag)=cellarray;
        end
        updateACQFiles;         
end

if strcmp(tag,'RUNGROUPFILES')
    %make sure each file is only associated with one rungroup
    rungroup=ScriptData.RUNGROUPSELECT;
    for s=1:length(ScriptData.RUNGROUPFILES{rungroup})
        rgFileID=ScriptData.RUNGROUPFILES{rungroup}(s);
        for t=1:length(ScriptData.RUNGROUPFILES)
            if t== rungroup, continue, end
            ScriptData.RUNGROUPFILES{t}=ScriptData.RUNGROUPFILES{t}(ScriptData.RUNGROUPFILES{t}~=rgFileID);
        end
    end
    updateACQFiles(handle);
end


if nargin == 2
    if strcmp(mode,'input')   %if call was by input bar
        getACQFiles;    %update all the file related cellarrays, load files into TS cellarray
    end
end
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 

if strcmp(tag,'ACQDIR')
    updateACQFiles(handle);
end
        
end



function editText_ScriptData_callback(handle)
% callback to ScriptData edit text bar
global ScriptData
%%%% get input string:
pathString = handle.String;


%%%% check if path exists, if not: set back to old path
if ~exist(pathString,'file')
    handle.String = ScriptData.SCRIPTFILE;
    errordlg('Specified path does not exist.')
    return
end

%%%% if pathString is path to correct ScriptData file, set new path, load file, else return
success = loadScriptData(pathString);
if success
    ScriptData.SCRIPTFILE = pathString;
else
    handle.String = ScriptData.SCRIPTFILE;
    return
end


%%%% update stuff
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
getACQFiles
end


function editText_ProcessingData_callback(handle)
% callback to ScriptData edit text bar
global ScriptData ProcessingData
%%%% get input string:
pathString = handle.String;

%%%% check if path exists, if not: set pack to old path
if ~exist(pathString,'file')
    handle.String = ScriptData.DATAFILE;
    errordlg('Specified path does not exist.')
    return
end

%%%% if path contains correct ProcessingData file, load it and set new path. Otherwise nothing is loaded and old one is kept.
succes = loadProcessingData(pathString);
if succes
    ScriptData.DATAFILE = pathString;
else
    handle.String = ScriptData.DATAFILE;
end
end


function success = loadProcessingData(pathString)
% update ProcessingData accourding to ScriptData in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but issues error if not a correct ProcessingData
success = 1;    

%%%% check the file if it looks like a ProcessingData file, if it is wrong, simply return
global ProcessingData
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file. File not loaded..')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded ProcessingData.mat file contains not just one variable. File not loaded..')
        success = 0;
        return
    else
        newProcessingData=metastruct.(fn{1});
        necFields = {'SELFRAMES', 'FILENAME'};
        for p=1:3:length(necFields)
            if ~isfield(newProcessingData, necFields{p})
                errormsg = sprintf('The chosen file doesn''t seem to be a ScriptData file. \n It doesn''t have the %s field. File not loaded..', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
ProcessingData =  newProcessingData;
end


function success = loadScriptData(pathString)
% update ScriptData accourding to ScriptData in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but checks content of pathString and converst to new ScriptData format
success = 1;    
global ScriptData;
oldProcessingDataPath =ScriptData.DATAFILE;

%%%% check the file if it looks like a ScriptData file, if it is wrong, simply return
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file.')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded ScriptData.mat file contains not just one variable')
        success = 0;
        return
    else
        newScriptData=metastruct.(fn{1});
        necFields = get_necFields;
        for p=1:3:length(necFields)
            if ~isfield(newScriptData, necFields{p})
                errormsg = sprintf('The choosen file doesn''t seem to be a ScriptData file. \n It doesn''t have the %s field.', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
ScriptData =  newScriptData;
old2newScriptData
ScriptData.DATAFILE =  oldProcessingDataPath;
end


function save_create_callbacks(cbobj)
% callback to the two save buttons
global ScriptData ProcessingData

if strcmp(cbobj.Tag, 'SAVESCRIPTDATA')
    DialogTitle ='Save ScriptData';
    if ~isempty(ScriptData.SCRIPTFILE)
        FilterSpec = ScriptData.SCRIPTFILE;
    else
        FilterSpec ='ScriptData.mat';
    end
else
    DialogTitle = 'Save ProcessingData';
    if ~isempty(ScriptData.DATAFILE)
        FilterSpec = ScriptData.DATAFILE;
    else
        FilterSpec ='ProcessingData.mat';
    end
end


[FileName,PathName] = uiputfile(FilterSpec,DialogTitle);

if isequal(FileName,0), return, end  % if user selected 'cancel'

%%%% save helper file,  save path in ScriptData
fullFileName = fullfile(PathName,FileName);
if strcmp(cbobj.Tag, 'SAVESCRIPTDATA')
    ScriptData.SCRIPTFILE = fullFileName;
    save(fullFileName,'ScriptData')
else
    ScriptData.DATAFILE = fullFileName;
    save(fullFileName, 'ProcessingData')
end

updateFigure(cbobj.Parent)
end

    


function saveSettings()
%callback function for Save Settings Button
% save ScriptData as a matfile in the filename/path specified in
% ScriptData.SCRIPTFILE
try
    global ScriptData;
    save(ScriptData.SCRIPTFILE,'ScriptData','-mat');
catch
    disp('tried to save settings (ScriptData.mat), but was not able to do so..')
end
end


function removeGroup(handle)
%callback function to 'Remove this Group' button

    global ScriptData;
    group = ScriptData.GROUPSELECT;
    if group > 0
       fn = fieldnames(ScriptData.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               ScriptData.(fn{p}){ScriptData.RUNGROUPSELECT}(group)=[];
           end
       end
       ScriptData.GROUPSELECT =length(ScriptData.GROUPNAME{ScriptData.RUNGROUPSELECT});
   end
   updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function removeRunGroup(handle)
%callback to 'remove this rungroup'
    global ScriptData;
    rungroup = ScriptData.RUNGROUPSELECT;
    if rungroup > 0
       fn = fieldnames(ScriptData.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'RUNGROUP',8) && ~strcmp('RUNGROUPSELECT',fn{p})
               ScriptData.(fn{p})(rungroup)=[];
           end
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               ScriptData.(fn{p})(rungroup)=[];
           end
       end
       ScriptData.RUNGROUPSELECT=length(ScriptData.RUNGROUPNAMES);
       
       rungroupselect=ScriptData.RUNGROUPSELECT;
       if rungroupselect > 0
            ScriptData.GROUPSELECT = length(ScriptData.GROUPNAME{rungroupselect});
       else
           ScriptData.GROUPSELECT = 0;
       end
 
   end
   updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function selectAllACQ(~)
%callback function to "select all" button at file listbox
    global ScriptData;
    ScriptData.ACQFILES = ScriptData.ACQFILENUMBER;
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function selectNoneACQ(~)
%callback to 'clear selection' button
    global ScriptData;
    ScriptData.ACQFILES = [];
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function ACQselectLabel(~)
%callback to 'select label containing..' 
    
    global ScriptData;
    pat = ScriptData.ACQPATTERN;
    sel = [];
    for p=1:length(ScriptData.ACQINFO)
        if ~isempty(strfind(ScriptData.ACQINFO{p},pat)), sel = [sel ScriptData.ACQFILENUMBER(p)]; end
    end
    ScriptData.ACQFILES = sel;
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function openSettings(~)
%callback to 'Settings Windwow'
handle=SettingsDisplay;
updateFigure(handle)


end

function runScript(handle)
%callback to 'apply' button, this starts the whole processing process!

%this function
%   - saves all settings in msd.SCRIPTFILE, just in case programm crashes
%   - checks if all settings are correkt (in particular, if groups have
%     been selected
%   - loads ProcessingData
%   - calls PreLoopScript, which:
%       - find a individual label for each file (for MPD) (havent really
%       figuret that out yet
%       - checks if mapfile etc exist (I do that already earlier?!)
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - sets up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
%   - starts the MAIN LOOP: for each file:  Process file
%   - at very end when everything is processed: update figure and groups
%       
    global ScriptData

    h = [];   %for waitbar
    success = 0;
    success = PreLoopScript;
    if ~success, return, end
    
    %%%% make sure helper files are selected to save data
    if isempty(ScriptData.DATAFILE)
        errordlg('No Processing Data File given to save processing data. Provide a Processing Data File to run the script.')
        return
    end
    if isempty(ScriptData.SCRIPTFILE)
        errordlg('No Script Data File given to save settings. Provide a Script Data File to run the script.')
        return
    end
    
    %%%% save helper files 
    saveProcessingData;
    saveSettings;
    
    
    %%%% make sure a rungroup is defined for each selected file
    for rungroupIdx=1:length(ScriptData.RUNGROUPNAMES)
        if isempty(ScriptData.GROUPNAME{rungroupIdx})
            errordlg('you need to define groups for each defined rungroup in order to  process the data.');
            return
        end
    end

    %%%% MAIN LOOP %%%
    acqfiles = unique(ScriptData.ACQFILES);
    h  = waitbar(0,'SCRIPT PROGRESS','Tag','waitbar'); drawnow;
    
    
    p = 1;
    while (p <= length(acqfiles))

        ScriptData.ACQNUM = acqfiles(p);
        ScriptData.NAVIGATION = 'apply';
        
        %%%% find the current rungroup of processed file
        ScriptData.CURRENTRUNGROUP=[];
        for rungroupIdx=1:length(ScriptData.RUNGROUPNAMES)
            if ismember(acqfiles(p), ScriptData.RUNGROUPFILES{rungroupIdx})
                ScriptData.CURRENTRUNGROUP=rungroupIdx;
                break
            end
        end
        if isempty(ScriptData.CURRENTRUNGROUP)
            msg=sprintf('No Rungroup specified for %s. You need to specify a Rungroup for each file that you want to process.',ScriptData.ACQFILENAME{acqfiles(p)});
            errordlg(msg);
            return
        end
        
        success = 0;
        success = ProcessACQFile(ScriptData.ACQFILENAME{acqfiles(p)},ScriptData.ACQDIR);
        if ~success, return, end
        
        switch ScriptData.NAVIGATION
            case 'prev'
                p = p-1; 
                if p == 0, p = 1; end
                continue;
            case {'redo','back'}
                continue;
            case 'stop'
                break;
        end
        if isgraphics(h), waitbar(p/length(acqfiles),h); end
        p = p+1;
    end

    if isgraphics(h), close(h); end
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
end

function KeyPress(handle)
    global ScriptData;

    key = real(handle.CurrentCharacter);
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    switch key(1) 
        case 32    % spacebar
%            runScript(handle);
    end
end

%%%%%%%%%%%%%%script functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function success = PreLoopScript
    %this function is called right before main loop starts. Its jobs are: 
%       - checks if mapfile etc exist
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - set up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
    
success = 0;
global ScriptData ProcessingData   
ScriptData.ALIGNSTART = 'detect';
ScriptData.ALIGNSIZE = 'detect';


%%%% -create filenames, which holds all the filename-strings of only the files selected by user.  
% -create index, which holds all the indexes of filenames, that contain '-acq' or '.ac2'
filenames = ScriptData.ACQFILENAME(ScriptData.ACQFILES);    % only take the files selected by the user
index = [];
for r=1:length(filenames)
    if ~isempty(strfind(filenames{r},'.acq')) || ~isempty(strfind(filenames{r}, '.ac2')), index = [index r]; end
end   


%%%% check if input directory is provided and valid
if ~exist(ScriptData.MATODIR,'dir')
    errordlg('Provided output directory does not exist. Aborting...')
    return
end



if ~isempty(index)
    %%%%%%  generate a calibration file if neccessary %%%%%%%%%%%%%%%
    if ScriptData.DO_CALIBRATE == 1  % if 'calibrate Signall' button is on
        %%% if no calibration file and no CALIBRATIONACQ is given: exit
        %%% and make error message
        if isempty(ScriptData.CALIBRATIONACQ) && isempty(ScriptData.CALIBRATIONFILE)
            errordlg('Specify the filenumbers of the calibration measurements or a calibration file to do calibration. Aborting...');
            return; 
        end   

        %%%% create a calfile if DO_CALIBRATE is on, but no calfile is
        %%%% given
        if isempty(ScriptData.CALIBRATIONFILE) && ScriptData.DO_CALIBRATE
                % generate a cell array of the .ac2 files used for
                % calibration
                acqcalfiles=ScriptData.ACQFILENAME(ScriptData.CALIBRATIONACQ);
                if ~iscell(acqcalfiles), acqcalfiles = {acqcalfiles}; end 

                %find the mappingfile used for the acqcalfiles.
                mappingfile=[];
                for rg=1:length(ScriptData.RUNGROUPNAMES)
                    if ismember(ScriptData.CALIBRATIONACQ,ScriptData.RUNGROUPFILES{rg})
                        mappingfile=ScriptData.RUNGROUPMAPPINGFILE{rg};
                        break
                    end
                end
                if isempty(mappingfile)
                    errordlg('matmap can only create a .cal8 file, if all files used for calibration belong to the same rungroup. However, this does not seem to be the case. Aborting...');
                    return
                end


                for p=1:length(acqcalfiles)
                    acqcalfiles{p} = fullfile(ScriptData.ACQDIR,acqcalfiles{p});
                end

                pointer = get(gcf,'pointer'); set(gcf,'pointer','watch');
                calfile='calibration.cal8';
                sigCalibrate8(acqcalfiles{:},mappingfile,calfile,'displaybar');
                set(gcf,'pointer',pointer);

                ScriptData.CALIBRATIONFILE = fullfile(pwd,calfile);
        end 
    end
end    

%%%% RENDER A GLOBAL LIST OF ALL THE BADLEADS,  set msd.GBADLEADS%%%%
ScriptData.GBADLEADS={};
for rungroupIdx=1:length(ScriptData.RUNGROUPNAMES)
   badleads=[];
   for p=1:length(ScriptData.GROUPBADLEADS{rungroupIdx})           
        reference=ScriptData.GROUPLEADS{rungroupIdx}{p}(1)-1;    
        addBadleads = ScriptData.GROUPBADLEADS{rungroupIdx}{p} + reference;

        %%%% check if user input for badleads is correct
        diff=ScriptData.GROUPLEADS{rungroupIdx}{p}(end)-ScriptData.GROUPLEADS{rungroupIdx}{p}(1);
        if any(ScriptData.GROUPBADLEADS{rungroupIdx}{p} < 1) || any(ScriptData.GROUPBADLEADS{rungroupIdx}{p} > diff+1)
            msg=sprintf('Bad leads for the group %s in the rungroup %s are invalid. Bad leads must be between 1 and ( 1 + maxGrouplead - minGrouplead). Aborting...',ScriptData.GROUPNAME{rungroupIdx}{p}, ScriptData.RUNGROUPNAMES{rungroupIdx});
            errordlg(msg);
            return
        end


        %%%% read in badleadsfile, if there is one
        if ~isempty(ScriptData.GROUPBADLEADSFILE{rungroupIdx}{rungroupIdx}) 
            bfile = load(ScriptData.GROUPBADLEADSFILE{rungroupIdx}{p},'-ASCII');
            badleads = union(bfile(:)',badleads);
        end

        %%%% change format of addBadleads.. just in case. this can probably be ignored..
        if size(addBadleads,2) > 1
            addBadleads=addBadleads';
        end

        badleads=[badleads; addBadleads];
   end


    ScriptData.GBADLEADS{rungroupIdx} = badleads;
end
% GBADLEADS is now a nRungroup x 1 cellarray with the following entries for each rungroup:
% a nBadLeads x 1 array with the badleads in the "global frame" for the rungroup.

%%%% FIND MAXIMUM LEAD for each rg
ScriptData.MAXLEAD={};  %set to empty first, just in case
for rg=1:length(ScriptData.RUNGROUPNAMES)  
    maxlead = 1;
    for p=1:length(ScriptData.GROUPLEADS{rg})
        maxlead = max([maxlead ScriptData.GROUPLEADS{rg}{p}]);
    end
    ScriptData.MAXLEAD{rg} = maxlead;
end
success = 1;
end





function success = ProcessACQFile(inputfilename,inputfiledir)

%this function does all the processing, in particular:
% - checks if mappingfile and calibration file exist and loads
% inputfilename in TS using all available files
% - check if potvals are in accourdance with group lead choise 
% - do pacing stuff (get rid of???)
% - ImportUserSettings
% - store GBADLEADS in TS
% - DO Temporal Filter of ts
% - DO THE SCLICING STUFF:
%        - call SliceDisplay
%        - some Navigation stuff
%        -  does some upgrades to bad leads 
%        -  ExportUserSettings
%        - calls sigSlice, which in this case:  updates TS{currentIndex} bei
%           keeping only the timeframe-window specified
% - Do 'blank leads', if that option is selected
% - DO ALL THE BASELINE STUFF
%       - shift fiducials to local frame (I think?!)
%       - Do 'Pre-RMS baseline correction (call sigBaseline) if that button
%       is pressed
%       - if DO_BASELINE_USER:  open FidsDisplay. User chosses bl fids,
%       which are stored in .. fids of type 16!?
%       - some navigation stuff  & ExportUserSettings
%       - Do_DeltaFoverF if selected (get rid of??)
%       - Do baseline correction, call sigBaseLine(index,[],baselinewidth),
%       which asks for fidsFindFids(..'baseline') to get blpts..
% - DO_LABLACIAN_INTERPOLATE, if selected.
% - Detect the other fiducials, if user interaction is on
%       - do fids shift, same as before with baseline
%       - correct baseline values, just as before (why?)
%       - open FidsDisplay, in mode 1 this time, do navigation stuff and
%       Export User Settings
% - split current ts into n_groups sub-ts structures, delete original ts
% - Do_interpolation again, for each sub-ts
% - SAVE the ts structures, 
% - do integral maps, if selected and save them
% - do Activation maps, if that option is selected

success = 0;
olddir = pwd;
global ScriptData TS

%%%%% create cellaray files={full acqfilename, mappingfile, calibration file}, if the latter two are needet & exist    
filename = fullfile(inputfiledir,inputfilename);
files{1} = filename;
isMatFile=0;
if contains(inputfilename,'.mat'), isMatFile=1; end


% load & check mappinfile
mappingfile = ScriptData.RUNGROUPMAPPINGFILE{ScriptData.CURRENTRUNGROUP};
if isempty(mappingfile)
    ScriptData.RUNGROUPMAPPINGFILE{ScriptData.CURRENTRUNGROUP} = '';
elseif ~exist(mappingfile,'file')
    msg=sprintf('The provided .mapping file for the Rungroup %s does not exist.',ScriptData.RUNGROUPNAMES{ScriptData.CURRENTRUNGROUP});
    errordlg(msg);
    return
else
    files{end+1}=mappingfile;
end    

if ScriptData.DO_CALIBRATE == 1 && ~isMatFile     % mat.-files are already calibrated
    if ~isempty(ScriptData.CALIBRATIONFILE)
        if exist(ScriptData.CALIBRATIONFILE,'file')
            files{end+1} = ScriptData.CALIBRATIONFILE;
        end
    end
end
    

%%%%%%% read in the files in TS.  index is index with TS{index}=current ts
%%%%%%% structure
if isMatFile
    index=ioReadMAT(files{:});
else
    index = ioReadTS(files{:}); % if ac2 file
end
    
    
%%%%% make ts.filename only the filename without the path

[~,filename,ext]=fileparts(TS{index}.filename);
TS{index}.filename=[filename ext];
    
    
    
    
    
%%%%%% check if dimensions of potvals are correct, issue error msg if not
if size(TS{index}.potvals,1) < ScriptData.MAXLEAD{ScriptData.CURRENTRUNGROUP}
    errordlg('Maximum lead in settings is greater than number of leads in file');
    cd(olddir);
    return
end
    

%%%% ImportUserSettings (put Data from ProcessingData in TS{currentTS} %%%%%%%%%%    
fieldstoload = {'SELFRAMES','AVERAGEMETHOD','AVERAGESTART','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES'};      
ImportUserSettings(inputfilename,index,fieldstoload);

    
%%%%  store the GBADLEADS also in the ts structure (in ts.leadinfo)%%%% 
badleads=ScriptData.GBADLEADS{ScriptData.CURRENTRUNGROUP};
TS{index}.leadinfo(badleads) = 1;

%%%%% do the temporal filter of current file %%%%%%%%%%%%%%%%
if ScriptData.DO_FILTER      % if 'apply temporal filter' is selected
    ScriptData.FILTERSETTINGS.B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
    ScriptData.FILTERSETTINGS.A = 1;
    sigTemporalFilter(index);
end
        

%%%%%  call SliceDisplay (if UserInterface is selected) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this block does the following:
% - call SliceDisplay
% - some Navigation stuff
% -  does some upgrades to bad leads 
% - calls sigSlice, which in this case:  updates TS{currentIndex} bei
% keeping only the timeframe-window specified in ts.selframes
if ScriptData.DO_SLICE_USER == 1  %if 'user interaction' button is pressed
    handle = sliceDisplay(index); % this only changes selframes I think it also uses ts.averageframes (and all from export userlist bellow?)
    waitfor(handle);

    switch ScriptData.NAVIGATION  % if any of these was clicked in sliceDisplay
        case {'prev','next','stop','back'}, cd(olddir); tsClear(index); return; 
    end
end

%%%% store all the SETTINGS/CHANGES done by the user
ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO'});

%%%%%% if 'blank bad leads' button is selected,   set all values of the bad leads to 0   
if ScriptData.DO_BLANKBADLEADS == 1
    badleads = tsIsBad(index);
    TS{index}.potvals(badleads,:) = 0;
    tsSetBlank(index,badleads);
    tsAddAudit(index,'|Blanked out bad leads');
end

%%%% if autofid user interaction is activated, to autofid, even if it is not selected.
if ScriptData.AUTOFID_USER_INTERACTION
    ScriptData.DO_AUTOFIDUCIALISING = 1;
end

%%%% save the ts as it is now in TS{unslicedDataIndex} for autofiducialicing
if ScriptData.DO_AUTOFIDUCIALISING
    unslicedDataIndex=tsNew(1);
    TS{unslicedDataIndex}=TS{index};        
    ScriptData.unslicedDataIndex=unslicedDataIndex;
end

%%%% slice the current TS{index} and work with that one
sigSlice(index);   % keeps only the selected timeframes in the potvals, using ts.selframes as start and endpoint


 %%%%%% import more Usersettings from ProcessingData into TS{index} %%%%
fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
ImportUserSettings(inputfilename,index,fieldstoload);



%%%%%%%%%% start baseline stuff %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ScriptData.DO_BASELINE_USER, ScriptData.DO_BASELINE = 1; end
if (ScriptData.DO_BASELINE == 1)
%%%% shift ficucials to the new local frame %%%%%%%%%%%%
% fids are always in local frame, but because user selected new local
% frame (the selframe), the local frame changed!

    if ~isfield(TS{index},'selframes')
        msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a ProcessingData file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame. Aborting...',TS{index}.filename);
        errordlg(msg)
        TS{index}=[];
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
    baselinewidth = ScriptData.BASELINEWIDTH;       % also upgrade baselinewidth
    TS{index}.baselinewidth = baselinewidth;
    if length(baseline) < 2
        fidsRemoveFiducial(index,'baseline');
        fidsAddFiducial(index,1,'baseline');
        fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
    end
    %%%% if 'Pre-RMS Baseline correction' button is pressed, do baseline
    %%%% corection of current index (before user selects anything..
    if ScriptData.DO_BASELINE_RMS == 1
        baselinewidth = ScriptData.BASELINEWIDTH;
        sigBaseLine(index,[],baselinewidth);
    end
    
    %%%%   open Fidsdisplay in mode 2, (baseline mode)
    if ScriptData.DO_BASELINE_USER == 1
        handle = fidsDisplay(index,2);    % this changes fids, but nothing else
        waitfor(handle);

        switch ScriptData.NAVIGATION
            case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
        end     
    end
    %%%% and save user selections in ProcessingData    
    ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});
     
    %%%% now do the final baseline correction
    if ScriptData.DO_BASELINE == 1
        baselinewidth = ScriptData.BASELINEWIDTH;
        if length(fidsFindFids(index,'baseline')) < 2 
            han = errordlg('At least two baseline points need to be specified, skipping baseline correction');
            waitfor(han);
        else
            sigBaseLine(index,[],baselinewidth);
        end
    end    
end
    
    


%%%%%%%% now detect the rest of fiducials, if 'detect fids' was selected   
if ScriptData.DO_DETECT_USER, ScriptData.DO_DETECT=1; end
if ScriptData.DO_DETECT == 1
    fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
    ImportUserSettings(inputfilename,index,fieldstoload);


    %%% fids shift, same as in baseline stuff, to get to local frame?!
    if ~isfield(TS{index},'selframes')
        msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a ProcessingData file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame. Aborting...',TS{index}.filename);
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
    baselinewidth = ScriptData.BASELINEWIDTH;
    if length(baseline) < 2
        fidsRemoveFiducial(index,'baseline');
        fidsAddFiducial(index,1,'baseline');
        fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
    end


    %%%%%% open FidsDisplay again, this time to select fiducials

    if ScriptData.DO_DETECT_USER == 1
        handle = fidsDisplay(index);    

        waitfor(handle);
        switch ScriptData.NAVIGATION
            case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
        end     
    end    
    % save the user selections (stored in ts) in ProcessingData
    ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGERMSTYPE','AVERAGECHANNEL','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});
end

%%%% now we have a fiducialed beat - use it as template to autoprocess the rest of the data in TS{unslicedDataIndex}
if ScriptData.DO_AUTOFIDUCIALISING
    success = autoProcessSignal;
    if ~success, return, end
end
    

%%%% this part does the splitting. In detail it
% - creates numgroups new ts structures (one for each group) using
% tsSplitTS
% - it sets ts.'tsdfcfilename' to ScriptData.GROUPTSDFC(splitgroup)
% - it sets ts.filename to  exact the same..  'including some tsdf
% stuff
% - original ts (the one thats splittet) is cleared
% - index is now index array of the splittet sub ts!!

%%%% split TS{index} into numGroups smaller ts
splitgroup = [];
for p=1:length(ScriptData.GROUPNAME{ScriptData.CURRENTRUNGROUP})
    if ScriptData.GROUPDONOTPROCESS{ScriptData.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
end
% splitgroup is now eg [1 3] if there are 3 groups but the 2 should
% not be processed
channels=ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}(splitgroup);
indices = tsSplitTS(index, channels);    
tsDeal(indices,'filename',ioUpdateFilename('.mat',inputfilename,ScriptData.GROUPEXTENSION{ScriptData.CURRENTRUNGROUP}(splitgroup))); 
tsClear(index);        
index = indices;



%%%% save the new ts structures using ioWriteTS
olddir = cd(ScriptData.MATODIR);
tsDeal(index,'filename',ioUpdateFilename('.mat',inputfilename,ScriptData.GROUPEXTENSION{ScriptData.CURRENTRUNGROUP}(splitgroup)));
ioWriteTS(index,'noprompt','oworiginal');
cd(olddir);


%%%% do integral maps and save them  
if ScriptData.DO_INTEGRALMAPS == 1
    if ScriptData.DO_DETECT == 0
        msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s. Aborting', inputfilename);
        errordlg(msg)
        return
    end
    mapindices = fidsIntAll(index);
    if length(splitgroup)~=length(mapindices)
        msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups. Aborting...',inputfilename);
        errordlg(msg)
        return
    end

    olddir = cd(ScriptData.MATODIR); 
    fnames=ioUpdateFilename('.mat',inputfilename,ScriptData.GROUPEXTENSION{ScriptData.CURRENTRUNGROUP}(splitgroup),'-itg');

    tsDeal(mapindices,'filename',fnames); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);

    tsClear(mapindices);
end
    
    
 %%%%% Do activation maps   
    
if ScriptData.DO_ACTIVATIONMAPS == 1
    if ScriptData.DO_DETECT == 0 % 'Detect fiducials must be selected'
        errordlg('Fiducials needed to do Activationsmaps! Select the ''Do Fiducials'' button to do Activationmaps. Aborting...')
        return;
    end

    %%%% make new ts at TS(mapindices). That new ts is like the old
    %%%% one, but has ts.potvals=[act rec act-rec]
    mapindices = sigActRecMap(index);   


    %%%%  save the 'new act/rec' ts as eg 'Run0009-gr1-ari.mat
    % AND clearTS{mapindex}!
    olddir = cd(ScriptData.MATODIR);
    tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,ScriptData.GROUPEXTENSION{ScriptData.CURRENTRUNGROUP}(splitgroup),'-ari')); 
    tsSet(mapindices,'newfileext','');
    ioWriteTS(mapindices,'noprompt','oworiginal');
    cd(olddir);
    tsClear(mapindices);      
end

%%%%% save everything and clear TS
saveProcessingData;
saveSettings;
tsClear(index);
if ScriptData.DO_AUTOFIDUCIALISING
    tsClear(ScriptData.unslicedDataIndex);
    ScriptData.unslicedDataIndex=[];
end

success = 1;

end









%%%%%%%%%%%%%%%%%%%%%%%% utility functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function str = mynum2str(vec)
    % converts vectoren in strings
    % also outputs special format for the listboxedit  ( mitte unten, wo
    % man [1:19] eingibt
    if length(vec) == 1
        str = num2str(vec);
    else
        if nnz(vec-round(vec)) > 0
            str = num2str(vec);
        else
            vec = sort(vec);
            str = '';
            ind = 1;
            len = length(vec);
            while (ind <= len)
                if (len-ind) > 0
                     step = vec(ind+1)-vec(ind);
                     k = 1;
                     while (k+ind+1 <= len)
                         if vec(ind+k+1)-vec(ind+k) == step
                             k = k + 1;
                         else
                             break;
                         end
                     end
                     if k > 1
                         if step == 1
                            str = [str sprintf('%d:%d ',vec(ind),vec(ind+k))]; ind = ind + k+1;
                        else
                            str = [str sprintf('%d:%d:%d ',vec(ind),step,vec(ind+k))]; ind = ind + k+1;
                        end
                     else
                         str = [str sprintf('%d ',vec(ind))]; ind = ind + 1;
                     end
                 else
                     for p = ind:len
                         str = [str sprintf('%d ',vec(p))]; ind = len + 1;
                     end
                 end
             end
         end
     end
end

function vec = mystr2num(str)
    vec = eval(['[' str ']']);
end

function strs = commalist(str)
    %converts input like 'a,b,c' or 'a, b, c' oder 'a;b, c' in a cell array
    %{'a', 'b', 'c'}
    str = str(find(isspace(str)==0));
    ind = [0 sort([strfind(str,',') strfind(str,';')]) length(str)+1];
    for p=1:(length(ind)-1)
        strs{p} = str((ind(p)+1):(ind(p+1)-1));
    end
    
end


function necFields = get_necFields
% whenever a ScriptData file is loaded, it is checked if these fields are in the loaded ScriptData struct
% if any of these necFields is missing, a warning is issued and the file is not loaded
necFields = {'CALIBRATIONFILE','','file', ...
                'CALIBRATIONACQ','','vector', ...
                'CALIBRATIONACQUSED','','vector',...
                'SCRIPTFILE','','file',...
                'ACQLISTBOX','','listbox',...
                'ACQFILES',[],'listboxedit',...
                'ACQPATTERN','','string',...
                'ACQFILENUMBER',[],'vector',...
                'ACQINFO',{},'string',...
                'ACQFILENAME',{},'string',...
                'ACQNUM',0,'integer',...
                'DATAFILE','','file',...
                'ACQDIR','','file',...
                'ACQCONTAIN','','string',...
                'BASELINEWIDTH',5,'integer',...
                'GROUPNAME','GROUP','groupstring',... 
                'GROUPLEADS',[],'groupvector',...
                'GROUPEXTENSION','-ext','groupstring',...
                'GROUPGEOM','','groupfile',...
                'GROUPCHANNELS','','groupfile',...
                'GROUPBADLEADSFILE','','groupfile',...
                'GROUPBADLEADS',[],'groupvector',...
                'GROUPDONOTPROCESS',0,'groupbool',...
                'GROUPSELECT',0,'select',...
                'DO_CALIBRATE',1,'bool',...
                'DO_BLANKBADLEADS',1,'bool',...
                'DO_SLICE',1,'bool',...
                'DO_SLICE_USER',1,'bool',...
                'DO_ADDBADLEADS',0,'bool',...
                'DO_SPLIT',1,'bool',...
                'DO_BASELINE',1,'bool',...
                'DO_BASELINE_RMS',0,'bool',...
                'DO_BASELINE_USER',1,'bool',...
                'DO_DETECT',1,'bool',...
                'DO_DETECT_USER',1,'bool',...
                'DO_INTEGRALMAPS',1,'bool',...
                'DO_ACTIVATIONMAPS',1,'bool',...
                'DO_FILTER',0,'bool',...
                'NAVIGATION','apply','string',...
                'DISPLAYTYPE',1,'integer',...
                'DISPLAYTYPEF',1,'integer',...
                'DISPLAYSCALING',1,'integer',...
                'DISPLAYSCALINGF',1,'integer',...
                'DISPLAYOFFSET',1,'integer',...
                'DISPLAYGRID',1,'integer',...
                'DISPLAYGRIDF',1,'integer',...
                'DISPLAYLABEL',1,'integer',...
                'DISPLAYLABELF',1,'integer',...
                'DISPLAYTYPEF1',1,'integer',...
                'DISPLAYTYPEF2',1,'integer',...
                'DISPLAYPACING',1,'integer',...
                'DISPLAYPACINGF',1,'integer',...
                'DISPLAYGROUP',1,'vector',...
                'DISPLAYGROUPF',1,'vector',...
                'DISPLAYSCALE',1,'integer',...
                'CURRENTTS',1,'integer',...
                'FIDSLOOPFIDS',1,'integer',...
                'FIDSAUTOACT',1,'integer',...
                'FIDSAUTOREC',1,'integer',...
                'MATODIR','mat','string',...
                'ACTWIN',7,'integer',...
                'ACTDEG',3,'integer',...
                'ACTNEG',1,'integer',...
                'RECWIN',7,'integer',...
                'RECDEG',3,'integer',...
                'RECNEG',0,'integer'
        };
end


function   success = checkNewInput(handle, tag)
success = 0;
global ScriptData
switch tag
    case {'ACQDIR', 'MATODIR'}
        pathstring=handle.String;
        if ~exist(pathstring,'dir')
            errordlg('Specified path doesn''t exist.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
    case {'CALIBRATIONFILE', 'RUNGROUPMAPPINGFILE'}
        pathstring=handle.String;
        if ~exist(pathstring,'file') && ~isempty(pathstring)
            errordlg('Specified file doesn''t exist.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
    case 'GROUPNAME'
        newGroupName=handle.String;
        existingGroups=ScriptData.GROUPNAME{ScriptData.RUNGROUPSELECT};

        existingGroups(ScriptData.GROUPSELECT)=[];
        if ~isempty(find(ismember(existingGroups,newGroupName), 1))
            errordlg('A group with the same groupname already exists.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
        if isempty(newGroupName)
            errordlg('Group name mustn''t be empty.')
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            return
        end
end 
success = 1;
end

function old2newScriptData()
%convert old ScriptData without rungroups to the new format

    global ScriptData
    defaultsettings=getDefaultSettings;

    %%%%% remove unnecesary fields in the ScriptData file, that are not in the defaultsettings..
    mappingfile='';
    if isfield(ScriptData,'MAPPINGFILE'), mappingfile=ScriptData.MAPPINGFILE; end  %remember the mappingfile, before that information is deleted
    oldfields=fieldnames(ScriptData);
    fields2beRemoved=setdiff(oldfields,defaultsettings(1:3:end));
    ScriptData=rmfield(ScriptData,fields2beRemoved);
    
    
    %%%% now set .DEFAULT and TYPE and set/add missing fields with default values for all fields exept the ones related to (run)groups
    ScriptData.DEFAULT=struct();
    ScriptData.TYPE=struct();
    for p=1:3:length(defaultsettings)
        ScriptData.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
        ScriptData.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        if ~isfield(ScriptData,defaultsettings{p}) && ~(strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8))
            ScriptData.(defaultsettings{p})=defaultsettings{p+1};
        end
    end
    
    
    %%%% fix some problems with old ScriptData: in some cases there where e.g. 5 groups, but not all group related entries hat 5 entries.  This is fixed here by giving each group default values, if no values are provided yet
    if ~isempty(ScriptData.GROUPNAME)
        if ~iscell(ScriptData.GROUPNAME{1})  % if it is an old ScriptData
            len=length(ScriptData.GROUPNAME);
            for p=1:3:length(defaultsettings)
                if strncmp(ScriptData.TYPE.(defaultsettings{p}),'group',5) && (length(ScriptData.(defaultsettings{p})) < len)
                    ScriptData.defaultsettings{p}(1:len)=defaultsettings{p+1};
                end
            end
        end
    end
                    
 
    %%%% convert 'GROUP..' fields into new format
    fn=fieldnames(ScriptData.TYPE);
    rungroupAdded=0;
    for p=1:length(fn)                                    % for each group
        if strncmp(ScriptData.TYPE.(fn{p}),'group',5)          % if it is a group field  
            if ~isempty(ScriptData.(fn{p}))       % if there is an entry for it
                if ~iscell(ScriptData.(fn{p}){1}) % if old format
                    ScriptData.(fn{p})={ScriptData.(fn{p})};  % make it a cell  -> new ScriptData format
                    if ~rungroupAdded, rungroupAdded=1; end
                end
            end
        end   
    end
    

    %%%% create the 'RUNGROUP..'  fields, if they aren't there yet.
    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'rungroup',8)
            if ~isfield(ScriptData, defaultsettings{p})
                if rungroupAdded
                    ScriptData.(defaultsettings{p})={defaultsettings{p+1}};
                else
                    ScriptData.(defaultsettings{p})={};
                end
            end   
        end
    end
    
    if ~isempty(mappingfile) %if ScriptData.MAPPINFILE existed, make that mappinfile the mappinfile for all rungroups
            ScriptData.RUNGROUPMAPPINGFILE=cell(1,length(ScriptData.RUNGROUPNAMES));
            [ScriptData.RUNGROUPMAPPINGFILE{:}]=deal(mappingfile);
            
            ScriptData.RUNGROUPCALIBRATIONMAPPINGUSED=cell(1,length(ScriptData.RUNGROUPNAMES));
            [ScriptData.RUNGROUPCALIBRATIONMAPPINGUSED{:}]=deal('');
    end
    
    
    
    %%%% if there are no rungroups in old ScriptData, set all selected acq
    %%%% files as default for a newly created rungroup.
    if rungroupAdded
        ScriptData.RUNGROUPFILES={ScriptData.ACQFILES};
    end
    

    
    
    ScriptData.RUNGROUPSELECT=length(ScriptData.RUNGROUPNAMES);
    if ScriptData.RUNGROUPSELECT > 0
        ScriptData.GROUPSELECT=length(ScriptData.GROUPNAME{ScriptData.RUNGROUPSELECT});
    else
        ScriptData.GROUPSELECT=0;
    end  

end


function defaultsettings=getDefaultSettings
    defaultsettings = {'FILES2SPLIT',[],'vector',...
                    'SPLITFILECONTAIN','','string',...
                    'SPLITDIR','','string',...
                    'SPLITINTERVAL','', 'string',...
                    'CALIBRATE_SPLIT',1,'integer',...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'CALIBRATIONACQUSED','','vector',...
                    'SCRIPTFILE','','file',...
                    'ACQLISTBOX','','listbox',...
                    'ACQFILES',[],'listboxedit',...
                    'ACQPATTERN','','string',...
                    'ACQFILENUMBER',[],'vector',...
                    'ACQINFO',{},'string',...
                    'ACQFILENAME',{},'string',...
                    'ACQNUM',0,'integer',...
                    'DATAFILE','','file',...
                    'ACQDIR','','file',...
                    'ACQCONTAIN','','string',...
                    'ACQCONTAINNOT','','string',...
                    'ACQEXT','.mat,.ac2','string',...   
                    'BASELINEWIDTH',5,'integer',...
                    'GROUPNAME','GROUP','groupstring',... 
                    'GROUPLEADS',[],'groupvector',...
                    'GROUPEXTENSION','-ext','groupstring',...
                    'GROUPGEOM','','groupfile',...
                    'GROUPCHANNELS','','groupfile',...
                    'GROUPBADLEADSFILE','','groupfile',...
                    'GROUPBADLEADS',[],'groupvector',...
                    'GROUPDONOTPROCESS',0,'groupbool',...
                    'GROUPSELECT',0,'select',...
                    'DO_CALIBRATE',1,'bool',...
                    'DO_BLANKBADLEADS',1,'bool',...
                    'DO_SLICE',1,'bool',...
                    'DO_SLICE_USER',1,'bool',...
                    'DO_ADDBADLEADS',0,'bool',...
                    'DO_SPLIT',1,'bool',...
                    'DO_BASELINE',1,'bool',...
                    'DO_BASELINE_RMS',0,'bool',...
                    'DO_BASELINE_USER',1,'bool',...
                    'DO_DELTAFOVERF',0,'bool',...
                    'DO_DETECT_USER',1,'bool',...
                    'DO_DETECT_LOADTSDFC',1,'bool',...
                    'DO_INTEGRALMAPS',1,'bool',...
                    'DO_ACTIVATIONMAPS',1,'bool',...
                    'DO_FILTER',0,'bool',...
                    'DO_DETECT',0,'bool',...
                    'SAMPLEFREQ', 1000, 'double',...
                    'NAVIGATION','apply','string',...
                    'DISPLAYTYPE',1,'integer',...
                    'DISPLAYTYPEF',1,'integer',...
                    'DISPLAYSCALING',1,'integer',...
                    'DISPLAYSCALINGF',1,'integer',...
                    'DISPLAYOFFSET',1,'integer',...
                    'DISPLAYGRID',1,'integer',...
                    'DISPLAYGRIDF',1,'integer',...
                    'DISPLAYLABEL',1,'integer',...
                    'DISPLAYLABELF',1,'integer',...
                    'DISPLAYTYPEF1',1,'integer',...
                    'DISPLAYTYPEF2',1,'integer',...
                    'DISPLAYPACING',1,'integer',...
                    'DISPLAYPACINGF',1,'integer',...
                    'DISPLAYGROUP',1,'vector',...
                    'DISPLAYGROUPF',1,'vector',...
                    'DISPLAYSCALE',1,'integer',...
                    'CURRENTTS',1,'integer',...
                    'FIDSLOOPFIDS',1,'integer',...
                    'LOOP_ORDER',1,'vector',...
                    'FIDSAUTOACT',1,'integer',...
                    'FIDSAUTOREC',1,'integer',...
                    'MATODIR','','string',...
                    'ACTWIN',7,'integer',...
                    'ACTDEG',3,'integer',...
                    'ACTNEG',1,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'RECNEG',0,'integer',...
                    'RUNGROUPSELECT',0,'selectR',... 
                    'RUNGROUPNAMES','RUNGROUP', 'rungroupstring',...
                    'RUNGROUPFILES',[],'rungroupvector'... 
                    'RUNGROUPMAPPINGFILE','','rungroupstring',...
                    'RUNGROUPCALIBRATIONMAPPINGUSED','','rungroupstring',...
                    'RUNGROUPFILECONTAIN', '', 'rungroupstring',...
                    'DO_AUTOFIDUCIALISING', 0, 'bool',...
                    'AUTOFID_USER_INTERACTION', 0, 'bool',...
                    'ACCURACY', 0.9, 'double',...
                    'FIDSKERNELLENGTH',10,'integer',...
                    'WINDOW_WIDTH', 20, 'integer',...
                    'NTOBEFIDUCIALISED', 10, 'integer'
            };
end

function str = myStrTrim(str)
%removes weird leading and trailing non-alphanum characters from str

for p = 1:length(str)
    if isstrprop(str(p),'alphanum')
        start=p;
        break
    end
end
for p=length(str):-1:1
    if isstrprop(str(p),'alphanum')
        ending=p;
        break
    end
end    
str=str(start:ending);
end
