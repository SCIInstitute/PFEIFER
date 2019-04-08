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









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback functions %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








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
% corresponding field in SCRIPTDATA.  To further differentiate how each
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
















%%%%%%%%%%%%%%%%%%%%%%%% utility functions %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%








