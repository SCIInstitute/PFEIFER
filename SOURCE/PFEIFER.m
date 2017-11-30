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





function PFEIFER(varargin)
    %this is the first function to be called from the command line
%         - Init SCRIPTDATA
%         - Init PROCESSINGDATA
%         - Open the workbench.fig ("the main menu")
%         - Open the Settings.fig ("settings menu")
%         - Update workbench.fig and Settings.fig with data from SCRIPTDATA
%         - Update/setup File list, (callback for "choose input directory)
%         - this script also contains all the callbacks of the main menu
%         and settings menu.  


%%%% check if this script is called as a callback or to start PFEIFER
if nargin > 1 && ischar(varargin{1})  % if called as a callback
    feval(varargin{1},varargin{2:end});  % execute callback
    return
end

%%%% initianlize the globals SCRIPTDATA and PROCESSINGDATA
clear global SCRIPTDATA PROCESSINGDATA
initSCRIPTDATA();   
initPROCESSINGDATA();


%%%% open the main menu and the settings window and update them with data
workbenchFigObj=workbench();            % open the figure
setupToolSelectionDropdownmenus(workbenchFigObj); % set up the tools dropdown menus
setHelpMenus(workbenchFigObj)      % and set help buttons

dataOrgFigHandle=DataOrganisation();    %Open the settings Display
updateFigure(dataOrgFigHandle);     % and update it
setHelpMenus(dataOrgFigHandle);      % initialise help menus that pop up when you righ click on button
updateACQFiles      % get ACQ Files from input directory to display
end


function initSCRIPTDATA()
    % - Sets up global SCRIPTDATA as empty struct
    % - initializes SCRIPTDATA with Default Values for everything
    
    global SCRIPTDATA;
    SCRIPTDATA = struct();
    SCRIPTDATA.TYPE = struct();
    SCRIPTDATA.DEFAULT = struct();

    defaultsettings=getDefaultSettings;

    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8)
            SCRIPTDATA.(defaultsettings{p})={};
        else
            SCRIPTDATA.(defaultsettings{p})=defaultsettings{p+1};
        end
        SCRIPTDATA.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        SCRIPTDATA.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
    end
end


function initPROCESSINGDATA()
% init the global PROCESSINGDATA
global PROCESSINGDATA
PROCESSINGDATA = struct;
PROCESSINGDATA.SELFRAMES = {};
PROCESSINGDATA.REFFRAMES = {};
PROCESSINGDATA.AVERAGESTART = {};
PROCESSINGDATA.AVERAGEEND = {};
PROCESSINGDATA.FILENAME={};
end

function ExportUserSettings(filename,index,fields)
    % save the user selections stored in TS{index}.(fields) in PROCESSINGDATA.  fields could be e.g. 'fids' 
    % if fields dont exist in ts, it will be set to [] in PROCESSINGDATA. It's no
    % problem if field doesnt exist in PROCESSINGDATA at beginning
    
    global PROCESSINGDATA TS;
    %%%% first find filename
    filenum = find(strcmp(filename,PROCESSINGDATA.FILENAME));

    %%%% if no entry for the file exists so far, make one
    if isempty(filenum)
        PROCESSINGDATA.FILENAME{end+1} = filename;
        filenum = length(PROCESSINGDATA.FILENAME);
    end
    
    %%%% loop through fields and save data in PROCESSINGDATA
    for p=1:length(fields)
        if isfield(TS{index},lower(fields{p}))
            value = TS{index}.(lower(fields{p}));
            if isfield(PROCESSINGDATA,fields{p})
                data = PROCESSINGDATA.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            PROCESSINGDATA.(fields{p})=data;
        else
            value = [];
            if isfield(PROCESSINGDATA,fields{p})
                data = PROCESSINGDATA.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            PROCESSINGDATA.(fields{p})=data;
        end
    end
    
    %%%% save data in PROCESSINGDATA file
    savePROCESSINGDATA; 
end

function ImportUserSettings(filename,index,fields)
    % Imports the fields from PROCESSINGDATA in the corresponding ts structure of
    % TS. Identification via filename. 

    global PROCESSINGDATA TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,PROCESSINGDATA.FILENAME'));
    % THEN RETRIEVE THE DATA FROM THE DATABASE
    
    if ~isempty(filenum)
        for p=1:length(fields)
            if isfield(PROCESSINGDATA,fields{p})
                data = PROCESSINGDATA.(fields{p});
                if length(data) >= filenum(1)
                    if ~isempty(data{filenum(1)})
                        TS{index}.(lower(fields{p}))=data{filenum(1)};
                    end
                end
            end
        end
    end
end

function savePROCESSINGDATA()
global SCRIPTDATA PROCESSINGDATA;
save(SCRIPTDATA.DATAFILE,'PROCESSINGDATA');
end


function updateFigure(figObj)
% changes all Settings in the figure ( that belongs to handle) according to
% SCRIPTDATA.  
%Updates everything in the gui figures, including File Listbox etc..
% handle is gui figure object

global SCRIPTDATA;

%%%% loop through all fieldnames of SCRIPTDATA and make changes accourding to the fieldname
fn = fieldnames(SCRIPTDATA);
for p=1:length(fn)
    %%%% identify the uicontrol object in the gui figure ("handle") that is related to the fieldname. The uicontrol object are identified by there tag property
    obj = findobj(allchild(figObj),'tag',fn{p});
    if ~isempty(obj) % if field is also Tag to a uicontroll object in the figure..
        %%%% change that uicontroll. Depending on type..  
        objtype = SCRIPTDATA.TYPE.(fn{p});
        switch objtype
            case {'file','string'}
                obj.String = SCRIPTDATA.(fn{p});
            case {'listbox'}
                cellarray = SCRIPTDATA.(fn{p});
                if ~isempty(cellarray) 
                    values = intersect(SCRIPTDATA.ACQFILENUMBER,SCRIPTDATA.ACQFILES);
                    
                    if length(cellarray) == 1
                        maxVal=3;
                    else
                        maxVal = length(cellarray);
                    end
                    set(obj,'string',cellarray,'max',maxVal,'value',values,'enable','on');
                else
                    set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
                end
            case {'double','vector','listboxedit','integer'}
                obj.String = mynum2str(SCRIPTDATA.(fn{p}));
            case {'bool','toolsdropdownmenu'}
                [obj.Value] = deal(SCRIPTDATA.(fn{p}));
            case {'select'}   % case of SCRIPTDATA.GROUPSELECT  
                value = SCRIPTDATA.(fn{p});    % int telling which group is selected
                if value == 0, value = 1; end  %if nothing was selected
                obj.Value = value;
                rungroup=SCRIPTDATA.RUNGROUPSELECT;
                if rungroup==0, continue; end
                selectnames = SCRIPTDATA.GROUPNAME{rungroup};  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectnames{end+1} = 'NEW GROUP';
                obj.String = selectnames;

            case {'selectR'}
                value = SCRIPTDATA.(fn{p});    % int telling which rungroup is selected
                if value == 0, value = 1; end  %if nothing was selected
                selectrnames = SCRIPTDATA.RUNGROUPNAMES;  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                selectrnames{end+1} = 'NEW RUNGROUP'; 
                obj.String = selectrnames;
                obj.Value = value;


            case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}   
                group = SCRIPTDATA.GROUPSELECT;
                if (group > 0)
                    set(obj,'enable','on','visible','on');
                    cellarray = SCRIPTDATA.(fn{p}){SCRIPTDATA.RUNGROUPSELECT};
                    if length(cellarray) < group   %if the 'new group' option is selected!
                        cellarray{group} = SCRIPTDATA.DEFAULT.(fn{p});      % if new group was added, fill emty array slots with default values
                    end
                    switch objtype(6:end)
                        case {'file','string'}
                            obj.String = cellarray{group};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{group});
                        case {'bool'}
                            obj.Value = cellarray{group};
                    end
                    SCRIPTDATA.(fn{p}){SCRIPTDATA.RUNGROUPSELECT}=cellarray;    
                else
                    set(obj,'enable','inactive','visible','off');
                end
            case {'rungroupstring', 'rungroupvector'}    %any of the rungroupbuttons
                rungroup = SCRIPTDATA.RUNGROUPSELECT;
                if (rungroup > 0)
                    set(obj,'enable','on','visible','on');
                    set(findobj(allchild(figObj),'tag','GROUPSELECT'),'enable','on','visible','on')
                    set(findobj(allchild(figObj),'tag','RUNGROUPFILESBUTTON'),'enable','on','visible','on','BackgroundColor',[0.28 0.28 0.28])
                    
                    set(findobj(allchild(figObj),'tag','BROWSE_RUNGROUPMAPPINGFILE'),'enable','on','visible','on','BackgroundColor',[0.28 0.28 0.28])
                    set(findobj(allchild(figObj),'tag','USE_MAPPINGFILE'),'enable','on','visible','on')
                    set(findobj(allchild(figObj),'tag','mappingfileStaticTextObj'),'enable','on','visible','on')

                    cellarray = SCRIPTDATA.(fn{p});                     
                    switch objtype(9:end)
                        case {'file','string'}
                            obj.String = cellarray{rungroup};
                        case {'double','vector','integer'}
                            obj.String = mynum2str(cellarray{rungroup});
                        case {'bool'}
                            obj.Value = cellarray{rungroup};
                    end
                    SCRIPTDATA.(fn{p})=cellarray;
                else
                    set(obj,'enable','inactive','visible','off');
                    set(findobj(allchild(figObj),'tag','GROUPSELECT'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','RUNGROUPFILESBUTTON'),'enable','off','visible','off')
                    
                    set(findobj(allchild(figObj),'tag','BROWSE_RUNGROUPMAPPINGFILE'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','USE_MAPPINGFILE'),'enable','off','visible','off')
                    set(findobj(allchild(figObj),'tag','mappingfileStaticTextObj'),'enable','off','visible','off')
                end
        end
    end
end
end


function getInputFiles
% this function finds all files in SCRIPTDATA.ACQDIR (the input directory) and updates the following fields of SCRIPTDATA accordingly:
% - SCRIPTDATA.ACQFILENUMBER     double array of the form [1:NumberOfFilesDisplayedInListbox]
% - SCRIPTDATA.ACQLISTBOX        cellarray with strings for the listbox
% - SCRIPTDATA.ACQFILENAME       cellarray with all filenames in ACQDIR
% - SCRIPTDATA.ACQINFO           cellarray with a label for each file
% - SCRIPTDATA.ACQFILES          double array of selected files in the listbox in main menu gui figure

global SCRIPTDATA TS;

if isempty(SCRIPTDATA.ACQDIR), return, end  % if no input directory selected so far, just return

%%%% create a cell array with all the filenames in the listbox, that are at the moment selected. This is needed to select them again in case they are also in the new input dir
oldfilenames = {};
if ~isempty(SCRIPTDATA.ACQFILES)
    for p=1:length(SCRIPTDATA.ACQFILES)
        if SCRIPTDATA.ACQFILES(p) <= length(SCRIPTDATA.ACQFILENAME)
            oldfilenames{end+1} = SCRIPTDATA.ACQFILENAME{SCRIPTDATA.ACQFILES(p)};
        end
    end
end
%oldfilenames is now  cellarray with filenamestrings of only the
%selected files in listbox, eg {'Run0005.mat','Run0012.mat' }, not of all files in dir





%%%% change into SCRIPTDATA.ACQDIR,if it exists and is not empty
olddir = pwd;
if isempty(SCRIPTDATA.ACQDIR)
    errordlg('input directory doesn''t exist. No files loaded..')
    return
else
    cd(SCRIPTDATA.ACQDIR)
end


%%%% set up a cell array filenames with all the filenames in folder
filenames = {};
exts = commalist(SCRIPTDATA.ACQEXT);  % create cellarray with all the allowed file extensions specified by the user
for p=1:length(exts)
    d = dir(sprintf('*%s',exts{p}));
    for q= 1:length(d)
        filenames{end+1} = d(q).name;
    end
end
% filenames is cellarray with all the filenames of files in folder, e.g. {'Ran0001.ac2'    'Ru0009.ac2'}

%%%% get rid of files that don't belong here, also sort files
filenames(strncmp('._',filenames,2))=[];  % necessary to get rid of weird ghost files on server
filenames = sort(filenames);


%%%% initialize/clear old entries
SCRIPTDATA.ACQFILENUMBER = [];
SCRIPTDATA.ACQLISTBOX= {};
SCRIPTDATA.ACQFILENAME = {};
SCRIPTDATA.ACQINFO = {};
SCRIPTDATA.ACQFILES = [];

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
    
    
    %%%% update/check ts.filename and ts_info.filename
    ts.filename = filenames{p};


    if ~isfield(ts,'time'), ts.time = 'none'; end
    if ~isfield(ts,'label'), ts.label = 'no label'; end
    if ~isfield(ts,'filename')
        errordlg(sprintf('Problems occured reading file %s. This file does not have the filename field.  Aborting to load files...',filenames{p}));
        return
    end
    
    ts.label=myStrTrim(ts.label); %necessary, because original strings have weird whitespaces that are not recognized as whitespaces.. really weird!
    SCRIPTDATA.ACQFILENUMBER(p) = p;      

    %%%% find out which rungroup p belongs to
    rungroup='';
    for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
        if ismember(p, SCRIPTDATA.RUNGROUPFILES{rungroupIdx})
            rungroup=SCRIPTDATA.RUNGROUPNAMES{rungroupIdx};
            break
        end
    end

    ts.time=myStrTrim(ts.time);   % use of myStrTrim for the same reason as above..     

    SCRIPTDATA.ACQLISTBOX{p} = sprintf('%04d %20s %10s %10s %20s',SCRIPTDATA.ACQFILENUMBER(p),ts.filename,rungroup, ts.time,ts.label);
    SCRIPTDATA.ACQFILENAME{p} = ts.filename;
    SCRIPTDATA.ACQINFO{p} = ts.label;
    if isgraphics(h), waitbar(p/nFiles,h); end
end

[~,~,SCRIPTDATA.ACQFILES] = intersect(oldfilenames,SCRIPTDATA.ACQFILENAME);
SCRIPTDATA.ACQFILES = sort(SCRIPTDATA.ACQFILES);



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
global SCRIPTDATA PROCESSINGDATA FIDSDISPLAY SLICEDISPLAY TS

%%%% save setting
try
    if ~isempty(SCRIPTDATA.SCRIPTFILE)
     saveSettings
     disp('Saved SETTINGS before closing PFEIFER')
    else
     disp('PFEIFER closed without saving SETTINGS')
    end
catch
    %do nothing
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
clear global PROCESSINGDATA SCRIPTDATA FIDSDISPLAY SLICEDISPLAY TS
end



function setupToolSelectionDropdownmenus(figObj)
global SCRIPTDATA
[pathToPFEIFERfile,~,~] = fileparts(which('PFEIFER.m'));   % find path to PFEIFER.m

%%%% hardcoded lists of the tags of the dropdown menus and the folders corresponding to them
dropdownTags = {    'FILTER_SELECTION', 'BASELINE_SELECTION',   'ACT_SELECTION', 'REC_SELECTION'};     % the Tags of the dropdown uicontrol objects
toolsFoldernames = {'temporal_filters', 'baseline_corrections', 'act_detection', 'rec_detection'};    % these are the folder names of the folder in the TOOLS folder
toolsOptions = {    'FILTER_OPTIONS',   'BASELINE_OPTIONS',     'ACT_OPTIONS',   'REC_OPTIONS'};


%%%% loop through dropdown menus:
for p=1:length(dropdownTags)

    %%%% find the dropdown object
    dropdownObj = findobj(allchild(figObj),'Tag',dropdownTags{p});
    
    %%%% get the path to tools folder
    pathToTools = fullfile(pathToPFEIFERfile,'TOOLS',toolsFoldernames{p});
    
    %%%% get all the function.m names in that folder. these are the different options to choose from
    folderData = what(pathToTools);
    functionNames = folderData.m;
    % get rid of the '.m' at the end
    for q=1:length(functionNames)
        functionNames{q} = functionNames{q}(1:end-2);
    end
    
    
    %%%% set the dropdownObj.String
    if isempty(functionNames)
        [dropdownObj.String] = deal('no function found');
    else
        [dropdownObj.String] = deal(functionNames);      % deal and [  ] necessary here, because in case of 'BASELINE_SELECTION', there are two objects (since there are select baseline dropdown menus with the same tag)
    end
    
    %%%% set the dropdownObj.Value
    if SCRIPTDATA.(dropdownTags{p}) > length(functionNames)
        SCRIPTDATA.(dropdownTags{p}) = 1;
    end
    [dropdownObj.Value] = deal(SCRIPTDATA.(dropdownTags{p}));     % deal and [ ... ] necessary here, because in case of 'BASELINE_SELECTION', there are two objects (since both select baseline dropdown menus have that same tag)
    
    %%%% save the toolsOptions in SCRIPTDATA (for later use)
    SCRIPTDATA.(toolsOptions{p}) = functionNames;
end
    

end


function Browse(handle,ext,mode)
% callback to all the browse buttons.  mode is either 'file' or 'folder'
    global SCRIPTDATA
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
        filename = SCRIPTDATA.(tag){SCRIPTDATA.RUNGROUPSELECT};
    else
        filename = SCRIPTDATA.(tag);
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
            SCRIPTDATA.(tag)=newFileString;
            updateACQFiles(handle)
        case 'SCRIPTFILE'  
            success = loadSCRIPTDATA(newFileString);
            if success
                SCRIPTDATA.SCRIPTFILE = newFileString;
            else
                return
            end
            %%%% update stuff
            setupToolSelectionDropdownmenus(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
            getInputFiles
            return
        case 'DATAFILE'
            success = loadPROCESSINGDATA(newFileString);
            if success
                SCRIPTDATA.DATAFILE=newFileString;
            end
        case 'RUNGROUPMAPPINGFILE'
           SCRIPTDATA.(tag){SCRIPTDATA.RUNGROUPSELECT}=newFileString; 
        otherwise
           SCRIPTDATA.(tag)=newFileString;
    end
    updateFigure(handle.Parent);
end

function selectRunGroupFiles(~)
%callback function to 'select Rungroup files'

selectRungroupFiles

%%%% make sure each file is associated with only one rungroup
global SCRIPTDATA
rungroup=SCRIPTDATA.RUNGROUPSELECT;
for s=1:length(SCRIPTDATA.RUNGROUPFILES{rungroup})
    rgFileID=SCRIPTDATA.RUNGROUPFILES{rungroup}(s);
    for t=1:length(SCRIPTDATA.RUNGROUPFILES)
        if t== rungroup, continue, end
        SCRIPTDATA.RUNGROUPFILES{t}=SCRIPTDATA.RUNGROUPFILES{t}(SCRIPTDATA.RUNGROUPFILES{t}~=rgFileID);
    end
end
        
        




updateACQFiles
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));


end




function updateACQFiles(~)
% callback function to "Choose Input Directory"


%   - loads data files and updates ACQFILENUMBER, ACQFILENAME, ACQINFO, ACQLISTBOX
%   - Update figure by calling updateFigure

    getInputFiles;    %update all the file related cellarrays, load files into TS cellarray
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end




function setScriptData(hObject, mode)
% callback function to almost all buttons

% notes on how it works:
% the tag property of each object in the figure display is used to locate that object
% the tag of each each grafic object is also the fieldname of the
% corresponding fiel in SCRIPTDATA.  To further differentiate how each
% object is being dealt, the objecttype=SCRIPTDATA.TYPE.(tag) is used.
% inputs: - hObject: the obj that calls setSCRIPTDATA
%         - mode: either left out or a string 'input', if called by input directory editText bar


global SCRIPTDATA PROCESSINGDATA;
tag = hObject.Tag; 
success = checkNewInput(hObject, tag);
if ~success, return, end

if isfield(SCRIPTDATA.TYPE,tag)
    objtype = SCRIPTDATA.TYPE.(tag);
else
    objtype = 'string';
end
switch objtype
    case {'file','string'}
        SCRIPTDATA.(tag)= hObject.String;
    case {'double','vector','integer'}
        SCRIPTDATA.(tag)=mystr2num(hObject.String);
    case {'bool','select','toolsdropdownmenu'}
        SCRIPTDATA.(tag)=hObject.Value;
    case 'selectR'
        value=hObject.Value;
        SCRIPTDATA.(tag)=value;           
        if length(SCRIPTDATA.RUNGROUPNAMES) < value  %if NEW RUNGROUP is selected, make all group cells longer
            fn=fieldnames(SCRIPTDATA.TYPE);
            for p=1:length(fn)
                if strncmp(SCRIPTDATA.TYPE.(fn{p}),'group',5)
                    SCRIPTDATA.(fn{p}){end+1}={};
                end
                if strncmp(SCRIPTDATA.TYPE.(fn{p}),'rungroup',8)  %if NEW RUNGROUP is selected, make all rungroup cells one entry longer
                    SCRIPTDATA.(fn{p}){end+1} = SCRIPTDATA.DEFAULT.(fn{p});
                end                     
            end
            SCRIPTDATA.GROUPSELECT=0;
         end          
    case 'listbox'
        SCRIPTDATA.ACQFILES = SCRIPTDATA.ACQFILENUMBER(hObject.Value);
    case {'listboxedit'}
        SCRIPTDATA.(tag)=mystr2num(hObject.String);
    case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}      %if any of the groupstuff is changed
        group = SCRIPTDATA.GROUPSELECT;      %integer, which group is selected in dropdown
        if (group > 0)
            if isfield(SCRIPTDATA,tag)  
                cellarray = SCRIPTDATA.(tag){SCRIPTDATA.RUNGROUPSELECT};     % cellarray is eg {{'-gr1', '-gr2'}, .. } 
            else
                cellarray = {};
            end
            switch objtype(6:end)     %change individual entry of cellarray according to user input.
                case {'file','string'}
                    cellarray{group} = hObject.String;
                case {'double','vector'}
                    cellarray{group} = mystr2num(hObject.String);
                case {'bool'}
                    cellarray{group} = hObject.Value;
            end
            SCRIPTDATA.(tag){SCRIPTDATA.RUNGROUPSELECT}=cellarray;
        end
    case {'rungroupstring', 'rungroupvector'}  
        rungroup=SCRIPTDATA.RUNGROUPSELECT;
        if rungroup > 0
            cellarray = SCRIPTDATA.(tag);     % cellarray is eg {{'-gr1', '-gr2'}, .. } 

            switch objtype(9:end)     %change individual entry of cellarray according to user input. 
                case {'file','string'}
                    cellarray{rungroup} = hObject.String;
                case {'double','vector'}
                    cellarray{rungroup} = mystr2num(hObject.String);
                case {'bool'}
                    cellarray{rungroup} = hObject.Value;
            end
            SCRIPTDATA.(tag)=cellarray;
        end
        updateACQFiles;
        
end

if strcmp(tag,'RUNGROUPFILES')
    %make sure each file is only associated with one rungroup
    rungroup=SCRIPTDATA.RUNGROUPSELECT;
    for s=1:length(SCRIPTDATA.RUNGROUPFILES{rungroup})
        rgFileID=SCRIPTDATA.RUNGROUPFILES{rungroup}(s);
        for t=1:length(SCRIPTDATA.RUNGROUPFILES)
            if t== rungroup, continue, end
            SCRIPTDATA.RUNGROUPFILES{t}=SCRIPTDATA.RUNGROUPFILES{t}(SCRIPTDATA.RUNGROUPFILES{t}~=rgFileID);
        end
    end
    updateACQFiles(hObject);
end


if nargin == 2
    if strcmp(mode,'input')   %if call was by input bar
        getInputFiles;    %update all the file related cellarrays, load files into TS cellarray
    end
end


if strcmp(tag,'AUTO_UPDATE_KERNELS')
    disable_enable_TemplateUpdateButtons(hObject.Parent)
end
if strcmp(tag,'DoIndivFids')
    disable_enable_AutofidOptions(hObject.Parent)
end

updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 

if strcmp(tag,'ACQDIR')
    updateACQFiles(hObject);
end
        
end



function editText_SCRIPTDATA_callback(handle)
% callback to SCRIPTDATA edit text bar
global SCRIPTDATA
%%%% get input string:
pathString = handle.String;


%%%% check if path exists, if not: set back to old path
if ~exist(pathString,'file')
    handle.String = SCRIPTDATA.SCRIPTFILE; 
    errordlg('Specified path does not exist.');
    return
end

%%%% if pathString is path to correct SCRIPTDATA file, set new path, load file, else return
success = loadSCRIPTDATA(pathString);
if success
    SCRIPTDATA.SCRIPTFILE = pathString;
else
    handle.String = SCRIPTDATA.SCRIPTFILE;
    return
end


%%%% update stuff
setupToolSelectionDropdownmenus(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
getInputFiles
end


function editText_PROCESSINGDATA_callback(handle)
% callback to SCRIPTDATA edit text bar
global SCRIPTDATA PROCESSINGDATA
%%%% get input string:
pathString = handle.String;

%%%% check if path exists, if not: set pack to old path
if ~exist(pathString,'file')
    handle.String = SCRIPTDATA.DATAFILE;
    errordlg('Specified path does not exist.')
    return
end

%%%% if path contains correct PROCESSINGDATA file, load it and set new path. Otherwise nothing is loaded and old one is kept.
succes = loadPROCESSINGDATA(pathString);
if succes
    SCRIPTDATA.DATAFILE = pathString;
else
    handle.String = SCRIPTDATA.DATAFILE;
end
end


function success = loadPROCESSINGDATA(pathString)
% update PROCESSINGDATA accourding to SCRIPTDATA in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but issues error if not a correct PROCESSINGDATA
success = 1;    

%%%% check the file if it looks like a PROCESSINGDATA file, if it is wrong, simply return
global PROCESSINGDATA
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file. File not loaded..')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded PROCESSINGDATA.mat file contains not just one variable. File not loaded..')
        success = 0;
        return
    else
        newPROCESSINGDATA=metastruct.(fn{1});
        necFields = {'SELFRAMES', 'FILENAME'};
        for p=1:3:length(necFields)
            if ~isfield(newPROCESSINGDATA, necFields{p})
                errormsg = sprintf('The chosen file doesn''t seem to be a SCRIPTDATA file. \n It doesn''t have the %s field. File not loaded..', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
PROCESSINGDATA =  newPROCESSINGDATA;
end


function success = loadSCRIPTDATA(pathString)
% update SCRIPTDATA accourding to SCRIPTDATA in pathString
% if pathString is wrong, issue error
% basically just like load(pathString), but checks content of pathString and converst to new SCRIPTDATA format
success = 1;    
global SCRIPTDATA;
oldPROCESSINGDATAPath =SCRIPTDATA.DATAFILE;

%%%% check the file if it looks like a SCRIPTDATA file, if it is wrong, simply return
[~, ~, ext]=fileparts(pathString);
if ~strcmp('.mat',ext)
    errordlg('Not a  ''.mat'' file.')
    success = 0;
    return
else
    metastruct=load(pathString);
    fn=fieldnames(metastruct);

    if length(fn) ~=1
        errordlg('loaded SCRIPTDATA.mat file contains not just one variable')
        success = 0;
        return
    else
        newSCRIPTDATA=metastruct.(fn{1});
        necFields = get_necFields;
        for p=1:3:length(necFields)
            if ~isfield(newSCRIPTDATA, necFields{p})
                errormsg = sprintf('The choosen file doesn''t seem to be a SCRIPTDATA file. \n It doesn''t have the %s field.', necFields{p});
                errordlg(errormsg);
                success = 0;
                return
            end
        end
    end
end
    
%%%%  change the global, convert newFormat if necessary
SCRIPTDATA =  newSCRIPTDATA;
old2newSCRIPTDATA



%%%% check all paths and make them empty, if they don't exist.
pathTags = {'ACQDIR','MATODIR','CALIBRATIONFILE'};
for p=1:length(pathTags)
    pathTag= pathTags{p};
    path = SCRIPTDATA.(pathTag);
    if ~exist(path,'dir') && ~exist(path,'file')
        SCRIPTDATA.(pathTag) = '';
    end
end
% same for mapping files
for p=1:length(SCRIPTDATA.RUNGROUPMAPPINGFILE)
    if ~exist(SCRIPTDATA.RUNGROUPMAPPINGFILE{p},'file')
        SCRIPTDATA.RUNGROUPMAPPINGFILE{p} = '';
    end
end




SCRIPTDATA.DATAFILE =  oldPROCESSINGDATAPath;
end


function save_create_callbacks(cbobj,inputForUnitTesting)
% callback to the two save buttons
% inputForUnitTesting is eventdata, if this is called by user. It is the selected file, if this function is called by Unit Test for testing

global SCRIPTDATA PROCESSINGDATA      % PROCESSINGDATA must be loaded, too, in case it needs to be saved!

if strcmp(cbobj.Tag, 'SAVESCRIPTDATA')
    DialogTitle ='Save SCRIPTDATA';
    if ~isempty(SCRIPTDATA.SCRIPTFILE)
        FilterSpec = SCRIPTDATA.SCRIPTFILE;
    else
        FilterSpec ='SCRIPTDATA.mat';
    end
else
    DialogTitle = 'Save PROCESSINGDATA';
    if ~isempty(SCRIPTDATA.DATAFILE)
        FilterSpec = SCRIPTDATA.DATAFILE;
    else
        FilterSpec ='PROCESSINGDATA.mat';
    end
end

if strcmp(inputForUnitTesting,'noUnitTest') % if called 'the normal way' as a callback due to user mouseclick
    [FileName,PathName] = uiputfile(FilterSpec,DialogTitle);
else % if called in a UnitTest
    [PathName,FileName,~] = fileparts(inputForUnitTesting); % if called within Unit Test, unitTest is path to what user would have chosen..
end

if isequal(FileName,0), return, end  % if user selected 'cancel'

%%%% save helper file,  save path in SCRIPTDATA
fullFileName = fullfile(PathName,FileName);
if strcmp(cbobj.Tag, 'SAVESCRIPTDATA')
    SCRIPTDATA.SCRIPTFILE = fullFileName;
    save(fullFileName,'SCRIPTDATA')
else
    SCRIPTDATA.DATAFILE = fullFileName;
    save(fullFileName, 'PROCESSINGDATA')
end

updateFigure(cbobj.Parent)
end

    


function saveSettings()
%callback function for Save Settings Button
% save SCRIPTDATA as a matfile in the filename/path specified in
% SCRIPTDATA.SCRIPTFILE
try
    global SCRIPTDATA;
    save(SCRIPTDATA.SCRIPTFILE,'SCRIPTDATA','-mat');
catch
    disp('tried to save settings (SCRIPTDATA.mat), but was not able to do so..')
end
end


function removeGroup(handle)
%callback function to 'Remove this Group' button

    global SCRIPTDATA;
    groupIdx = SCRIPTDATA.GROUPSELECT;
    if groupIdx > 0
       fn = fieldnames(SCRIPTDATA.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               SCRIPTDATA.(fn{p}){SCRIPTDATA.RUNGROUPSELECT}(groupIdx)=[];
           end
       end
       SCRIPTDATA.GROUPSELECT =length(SCRIPTDATA.GROUPNAME{SCRIPTDATA.RUNGROUPSELECT});
   end
   updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function removeRunGroup(handle)
%callback to 'remove this rungroup'
    global SCRIPTDATA;
    rungroup = SCRIPTDATA.RUNGROUPSELECT;
    if rungroup > 0
       fn = fieldnames(SCRIPTDATA.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'RUNGROUP',8) && ~strcmp('RUNGROUPSELECT',fn{p})
               SCRIPTDATA.(fn{p})(rungroup)=[];
           end
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               SCRIPTDATA.(fn{p})(rungroup)=[];
           end
       end
       SCRIPTDATA.RUNGROUPSELECT=length(SCRIPTDATA.RUNGROUPNAMES);
       
       rungroupselect=SCRIPTDATA.RUNGROUPSELECT;
       if rungroupselect > 0
            SCRIPTDATA.GROUPSELECT = length(SCRIPTDATA.GROUPNAME{rungroupselect});
       else
           SCRIPTDATA.GROUPSELECT = 0;
       end
 
   end
   updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function selectAllACQ(~)
%callback function to "select all" button at file listbox
    global SCRIPTDATA;
    SCRIPTDATA.ACQFILES = SCRIPTDATA.ACQFILENUMBER;
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function selectNoneACQ(~)
%callback to 'clear selection' button
    global SCRIPTDATA;
    SCRIPTDATA.ACQFILES = [];
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function ACQselectLabel(~)
%callback to 'select label containing..' 
    
    global SCRIPTDATA;
    pat = SCRIPTDATA.ACQPATTERN;
    sel = [];
    for p=1:length(SCRIPTDATA.ACQINFO)
        if ~isempty(strfind(SCRIPTDATA.ACQINFO{p},pat)), sel = [sel SCRIPTDATA.ACQFILENUMBER(p)]; end
    end
    SCRIPTDATA.ACQFILES = sel;
    updateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function openSettings(~)
%callback to 'Settings Windwow'
figHandle=DataOrganisation;
updateFigure(figHandle)

end



function resetDefaultSettings(cbObj)
% callback to the 'default settings' pushbutton to restore the autofiducializing default settings
global SCRIPTDATA
fieldsToReset = {'ACCURACY','FIDSKERNELLENGTH','WINDOW_WIDTH','NTOBEFIDUCIALISED','USE_RMS','LEADS_FOR_AUTOFIDUCIALIZING','NUM_BEATS_TO_AVGR_OVER','NUM_BEATS_BEFORE_UPDATING'};
defaultSettings = getDefaultSettings;
for p = 1:3:length(defaultSettings)
    if ismember(defaultSettings{p}, fieldsToReset)
        SCRIPTDATA.(defaultSettings{p}) = defaultSettings{p+1};
    end
end
updateFigure(cbObj.Parent);
end


function disable_enable_TemplateUpdateButtons(fig)

global SCRIPTDATA
tagsToChange = {'NUM_BEATS_BEFORE_UPDATING','NUM_BEATS_TO_AVGR_OVER','text49','text48'};

for p = 1:length(tagsToChange)
    obj = findobj(allchild(fig),'Tag',tagsToChange{p});
    if SCRIPTDATA.AUTO_UPDATE_KERNELS
        set(obj,'enable','on','visible','on')
    else
        set(obj,'enable','inactive','visible','off')
    end
end
drawnow
end



function disable_enable_AutofidOptions(fig)

global SCRIPTDATA
tagsToChange = {'NTOBEFIDUCIALISED','LEADS_FOR_AUTOFIDUCIALIZING','USE_RMS','text45','text46'};

for p = 1:length(tagsToChange)
    obj = findobj(allchild(fig),'Tag',tagsToChange{p});
    if ~SCRIPTDATA.DoIndivFids
        set(obj,'enable','on','visible','on')
    else
        set(obj,'enable','inactive','visible','off')
    end
end
drawnow
end


function runScript(~)
%callback to 'apply' button, this starts the whole processing process!

%this function
%   - saves all settings in msd.SCRIPTFILE, just in case programm crashes
%   - checks if all settings are correkt (in particular, if groups have
%     been selected
%   - loads PROCESSINGDATA
%   - calls PreLoopScript, which:
%       - checks if mapfile etc exist (I do that already earlier?!)
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - sets up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
%   - starts the MAIN LOOP: for each file:  Process file
%   - at very end when everything is processed: update figure 
%       
    global SCRIPTDATA
    
    
    h = [];   %for waitbar
    success = PreLoopScript;
    if ~success, return, end
    
    %%%% make sure helper files are selected to save data
    if isempty(SCRIPTDATA.DATAFILE)
        errordlg('No Processing Data File given to save processing data. Provide a Processing Data File to run the script.')
        return
    end
    if isempty(SCRIPTDATA.SCRIPTFILE)
        errordlg('No Script Data File given to save settings. Provide a Script Data File to run the script.')
        return
    end
    
    %%%% save helper files 
    savePROCESSINGDATA;
    saveSettings;
    
    
    
    %%%% check some user inputs 
    if SCRIPTDATA.NUM_BEATS_TO_AVGR_OVER > SCRIPTDATA.NUM_BEATS_BEFORE_UPDATING
        errordlg('# Beats For Updating must not be greater than # Beats Before Updating.');
        return
    end
    if length(SCRIPTDATA.LEADS_FOR_AUTOFIDUCIALIZING) > SCRIPTDATA.NTOBEFIDUCIALISED
        errordlg('You cannot specify more Leads For Autofiducializing than there are Number of Leads.')
        return
    end
    
    
    
    %%%% make sure a rungroup is defined for each selected file
    for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
        if isempty(SCRIPTDATA.GROUPNAME{rungroupIdx})
            errordlg('you need to define groups for each defined rungroup in order to  process the data.');
            return
        end
    end

    %%%% MAIN LOOP %%%
    acqfiles = unique(SCRIPTDATA.ACQFILES);
    h  = waitbar(0,'SCRIPT PROGRESS','Tag','waitbar'); drawnow;
    
    
    p = 1;
    while (p <= length(acqfiles))

        SCRIPTDATA.ACQNUM = acqfiles(p);
        SCRIPTDATA.NAVIGATION = 'apply';
        
        %%%% find the current rungroup of processed file
        SCRIPTDATA.CURRENTRUNGROUP=[];
        for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
            if ismember(acqfiles(p), SCRIPTDATA.RUNGROUPFILES{rungroupIdx})
                SCRIPTDATA.CURRENTRUNGROUP=rungroupIdx;
                break
            end
        end
        if isempty(SCRIPTDATA.CURRENTRUNGROUP)
            msg=sprintf('No Rungroup specified for %s. You need to specify a Rungroup for each file that you want to process.',SCRIPTDATA.ACQFILENAME{acqfiles(p)});
            errordlg(msg);
            return
        end
        
        
%         try
            success = ProcessACQFile(SCRIPTDATA.ACQFILENAME{acqfiles(p)},SCRIPTDATA.ACQDIR);
%         catch
%             fprintf('ERROR: something went wrong procssing the file %s. Skipping this file...',SCRIPTDATA.ACQFILENAME{acqfiles(p)})
%         end
        
        if ~success, return, end
        
        switch SCRIPTDATA.NAVIGATION
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
    global SCRIPTDATA;

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
global SCRIPTDATA PROCESSINGDATA   
SCRIPTDATA.ALIGNSTART = 'detect';
SCRIPTDATA.ALIGNSIZE = 'detect';


%%%% -create filenames, which holds all the filename-strings of only the files selected by user.  
% -create index, which holds all the indexes of filenames, that contain '-acq' or '.ac2'
filenames = SCRIPTDATA.ACQFILENAME(SCRIPTDATA.ACQFILES);    % only take es selected by the user
index = [];
for r=1:length(filenames)
    if ~isempty(strfind(filenames{r},'.acq')) || ~isempty(strfind(filenames{r}, '.ac2')), index = [index r]; end
end   


%%%% check if input directory is provided and valid
if ~exist(SCRIPTDATA.MATODIR,'dir')
    errordlg('Provided output directory does not exist. Aborting...')
    return
end



%%%% check if at leat one lead is provided for each group
for RGIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
    for grIdx=1:length(SCRIPTDATA.GROUPNAME{RGIdx})
        if isempty(SCRIPTDATA.GROUPLEADS{RGIdx}{grIdx})
            success=0;
            errordlg('Not all groups in all Rungroups have their Lead Numbers specified.')
            return
        end
    end
end




if ~isempty(index)
    %%%%%%  generate a calibration file if neccessary %%%%%%%%%%%%%%%
    if SCRIPTDATA.DO_CALIBRATE == 1  % if 'calibrate Signall' button is on
        %%% if no calibration file and no CALIBRATIONACQ is given: exit
        %%% and make error message
        if isempty(SCRIPTDATA.CALIBRATIONACQ) && isempty(SCRIPTDATA.CALIBRATIONFILE)
            errordlg('Specify the filenumbers of the calibration measurements or a calibration file to do calibration. Aborting...');
            return; 
        end   

        %%%% create a calfile if DO_CALIBRATE is on, but no calfile is
        %%%% given
        if isempty(SCRIPTDATA.CALIBRATIONFILE) && SCRIPTDATA.DO_CALIBRATE
                % generate a cell array of the .ac2 files used for
                % calibration
                acqcalfiles=SCRIPTDATA.ACQFILENAME(SCRIPTDATA.CALIBRATIONACQ);
                if ~iscell(acqcalfiles), acqcalfiles = {acqcalfiles}; end 

                %find the mappingfile used for the acqcalfiles.
                mappingfile=[];
                for rg=1:length(SCRIPTDATA.RUNGROUPNAMES)
                    if ismember(SCRIPTDATA.CALIBRATIONACQ,SCRIPTDATA.RUNGROUPFILES{rg})
                        mappingfile=SCRIPTDATA.RUNGROUPMAPPINGFILE{rg};
                        break
                    end
                end
                if isempty(mappingfile) && SCRIPTDATA.USE_MAPPINGFILE
                    errordlg('No mappingfile given for the files used to create the calibration file...');
                    return
                end


                for p=1:length(acqcalfiles)
                    acqcalfiles{p} = fullfile(SCRIPTDATA.ACQDIR,acqcalfiles{p});
                end

                pointer = get(gcf,'pointer'); set(gcf,'pointer','watch');
                calfile='calibration.cal8';
                if SCRIPTDATA.USE_MAPPINGFILE
                    sigCalibrate8(acqcalfiles{:},mappingfile,calfile,'displaybar');
                else
                    sigCalibrate8(acqcalfiles{:},calfile,'displaybar');
                end
                set(gcf,'pointer',pointer);

                SCRIPTDATA.CALIBRATIONFILE = fullfile(pwd,calfile);
        end 
    end
end    

%%%% RENDER A GLOBAL LIST OF ALL THE BADLEADS,  set msd.GBADLEADS%%%%
SCRIPTDATA.GBADLEADS={};
for rungroupIdx=1:length(SCRIPTDATA.RUNGROUPNAMES)
   badleads=[];
   for p=1:length(SCRIPTDATA.GROUPBADLEADS{rungroupIdx})      
        reference=SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(1)-1;    

        addBadleads = SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} + reference;

        %%%% check if user input for badleads is correct
        diff=SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(end)-SCRIPTDATA.GROUPLEADS{rungroupIdx}{p}(1);
        if any(SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} < 1) || any(SCRIPTDATA.GROUPBADLEADS{rungroupIdx}{p} > diff+1)
            msg=sprintf('Bad leads for the group %s in the rungroup %s are invalid. Bad leads must be between 1 and ( 1 + maxGrouplead - minGrouplead). Aborting...',SCRIPTDATA.GROUPNAME{rungroupIdx}{p}, SCRIPTDATA.RUNGROUPNAMES{rungroupIdx});
            errordlg(msg);
            return
        end


        %%%% read in badleadsfile, if there is one
%         if ~isempty(SCRIPTDATA.GROUPBADLEADSFILE{rungroupIdx}{rungroupIdx}) 
%             bfile = load(SCRIPTDATA.GROUPBADLEADSFILE{rungroupIdx}{p},'-ASCII');
%             badleads = union(bfile(:)',badleads);
%         end

        %%%% change format of addBadleads.. just in case. this can probably be ignored..
        if size(addBadleads,2) > 1
            addBadleads=addBadleads';
        end

        badleads=[badleads; addBadleads];
   end


    SCRIPTDATA.GBADLEADS{rungroupIdx} = badleads;
end
% GBADLEADS is now a nRungroup x 1 cellarray with the following entries for each rungroup:
% a nBadLeads x 1 array with the badleads in the "global frame" for the rungroup.

%%%% FIND MAXIMUM LEAD for each rg
SCRIPTDATA.MAXLEAD={};  %set to empty first, just in case
for rg=1:length(SCRIPTDATA.RUNGROUPNAMES)  
    maxlead = 1;
    for p=1:length(SCRIPTDATA.GROUPLEADS{rg})
        maxlead = max([maxlead SCRIPTDATA.GROUPLEADS{rg}{p}]);
    end
    SCRIPTDATA.MAXLEAD{rg} = maxlead;
end
success = 1;
end





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
    if SCRIPTDATA.GROUPDONOTPROCESS{SCRIPTDATA.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
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
% whenever a SCRIPTDATA file is loaded, it is checked if these fields are in the loaded SCRIPTDATA struct
% if any of these necFields is missing, a warning is issued and the file is not loaded
necFields = {'SCRIPTFILE','','file',...
                'DATAFILE','','file',...
                'ACQDIR','','file',...
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
                'DO_FILTER',0,'bool'
        };
end


function   success = checkNewInput(handle, tag)
success = 0;
global SCRIPTDATA
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
        existingGroups=SCRIPTDATA.GROUPNAME{SCRIPTDATA.RUNGROUPSELECT};

        existingGroups(SCRIPTDATA.GROUPSELECT)=[];
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

function old2newSCRIPTDATA()
%convert old SCRIPTDATA without rungroups to the new format

    global SCRIPTDATA
    defaultsettings=getDefaultSettings;

    %%%%% remove unnecesary fields in the SCRIPTDATA file, that are not in the defaultsettings..
    mappingfile='';
    if isfield(SCRIPTDATA,'MAPPINGFILE'), mappingfile=SCRIPTDATA.MAPPINGFILE; end  %remember the mappingfile, before that information is deleted
    oldfields=fieldnames(SCRIPTDATA);
    fields2beRemoved=setdiff(oldfields,defaultsettings(1:3:end));
    SCRIPTDATA=rmfield(SCRIPTDATA,fields2beRemoved);
    
    
    %%%% now set .DEFAULT and TYPE and set/add missing fields with default values for all fields exept the ones related to (run)groups
    SCRIPTDATA.DEFAULT=struct();
    SCRIPTDATA.TYPE=struct();
    for p=1:3:length(defaultsettings)
        SCRIPTDATA.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
        SCRIPTDATA.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        if ~isfield(SCRIPTDATA,defaultsettings{p}) && ~(strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8))
            SCRIPTDATA.(defaultsettings{p})=defaultsettings{p+1};
        end
    end
    
    
    %%%% fix some problems with old SCRIPTDATA: in some cases there where e.g. 5 groups, but not all group related entries hat 5 entries.  This is fixed here by giving each group default values, if no values are provided yet
    if ~isempty(SCRIPTDATA.GROUPNAME)
        if ~iscell(SCRIPTDATA.GROUPNAME{1})  % if it is an old SCRIPTDATA
            len=length(SCRIPTDATA.GROUPNAME);
            for p=1:3:length(defaultsettings)
                if strncmp(SCRIPTDATA.TYPE.(defaultsettings{p}),'group',5) && (length(SCRIPTDATA.(defaultsettings{p})) < len)
                    SCRIPTDATA.defaultsettings{p}(1:len)=defaultsettings{p+1};
                end
            end
        end
    end
                    
 
    %%%% convert 'GROUP..' fields into new format
    fn=fieldnames(SCRIPTDATA.TYPE);
    rungroupAdded=0;
    for p=1:length(fn)                                    % for each group
        if strncmp(SCRIPTDATA.TYPE.(fn{p}),'group',5)          % if it is a group field  
            if ~isempty(SCRIPTDATA.(fn{p}))       % if there is an entry for it
                if ~iscell(SCRIPTDATA.(fn{p}){1}) % if old format
                    SCRIPTDATA.(fn{p})={SCRIPTDATA.(fn{p})};  % make it a cell  -> new SCRIPTDATA format
                    if ~rungroupAdded, rungroupAdded=1; end
                end
            end
        end   
    end
    

    %%%% create the 'RUNGROUP..'  fields, if they aren't there yet.
    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'rungroup',8)
            if ~isfield(SCRIPTDATA, defaultsettings{p})
                if rungroupAdded
                    SCRIPTDATA.(defaultsettings{p})={defaultsettings{p+1}};
                else
                    SCRIPTDATA.(defaultsettings{p})={};
                end
            end   
        end
    end
    
    if ~isempty(mappingfile) %if SCRIPTDATA.MAPPINFILE existed, make that mappinfile the mappinfile for all rungroups
            SCRIPTDATA.RUNGROUPMAPPINGFILE=cell(1,length(SCRIPTDATA.RUNGROUPNAMES));
            [SCRIPTDATA.RUNGROUPMAPPINGFILE{:}]=deal(mappingfile);
            
            SCRIPTDATA.RUNGROUPCALIBRATIONMAPPINGUSED=cell(1,length(SCRIPTDATA.RUNGROUPNAMES));
            [SCRIPTDATA.RUNGROUPCALIBRATIONMAPPINGUSED{:}]=deal('');
    end
    
    
    
    %%%% if there are no rungroups in old SCRIPTDATA, set all selected acq
    %%%% files as default for a newly created rungroup.
    if rungroupAdded
        SCRIPTDATA.RUNGROUPFILES={SCRIPTDATA.ACQFILES};
    end
    

    
    
    SCRIPTDATA.RUNGROUPSELECT=length(SCRIPTDATA.RUNGROUPNAMES);
    if SCRIPTDATA.RUNGROUPSELECT > 0
        SCRIPTDATA.GROUPSELECT=length(SCRIPTDATA.GROUPNAME{SCRIPTDATA.RUNGROUPSELECT});
    else
        SCRIPTDATA.GROUPSELECT=0;
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
                    'DO_DETECT_USER',1,'bool',...
                    'DO_INTEGRALMAPS',1,'bool',...
                    'DO_ACTIVATIONMAPS',1,'bool',...
                    'DO_FILTER',0,'bool',...
                    'DO_DETECT',0,'bool',...
                    'USE_MAPPINGFILE',1,'bool',...
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
                    'FIDSAUTOACT',1,'bool',...
                    'FIDSAUTOREC',1,'bool',...
                    'MATODIR','','string',...
                    'ACTWIN',7,'integer',...               
                    'ACTDEG',3,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'FILTER_SELECTION',1,'toolsdropdownmenu',...    % tools options
                    'BASELINE_SELECTION',1,'toolsdropdownmenu',...
                    'ACT_SELECTION',1,'toolsdropdownmenu',...
                    'REC_SELECTION',1,'toolsdropdownmenu',...
                    'RUNGROUPSELECT',0,'selectR',...            % rungroup options
                    'RUNGROUPNAMES','RUNGROUP', 'rungroupstring',...
                    'RUNGROUPFILES',[],'rungroupvector'... 
                    'RUNGROUPMAPPINGFILE','','rungroupstring',...
                    'RUNGROUPCALIBRATIONMAPPINGUSED','','rungroupstring',...
                    'RUNGROUPFILECONTAIN', '', 'rungroupstring',...
                    'DO_AUTOFIDUCIALISING', 0, 'bool',...      % autofiducialising
                    'AUTOFID_USER_INTERACTION', 0, 'bool',...
                    'ACCURACY', 0.9, 'double',...
                    'FIDSKERNELLENGTH',20,'integer',...
                    'WINDOW_WIDTH', 30, 'integer',...
                    'NTOBEFIDUCIALISED', 10, 'integer',...
                    'TRESHOLD_VAR', 50,'integer',...     
                    'USE_RMS',1,'bool',...
                    'AUTO_UPDATE_KERNELS',1,'bool',...
                    'NUM_BEATS_TO_AVGR_OVER', 5, 'integer',...
                    'NUM_BEATS_BEFORE_UPDATING', 5, 'integer',...
                    'LEADS_FOR_AUTOFIDUCIALIZING',[],'vector',...
                    'DoIndivFids',0,'bool'
            };
end


function str = myStrTrim(str)
%removes weird leading and trailing non-alphanum characters from str
if isempty(str), return, end

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
