
function myProcessingScript(varargin)
    %this is the first function to be called from the command line
    %jobs:
%         - Init myscriptdata
%         - Init myprocessingdata
%         - Open the mainMenu.fig (das hauptfenster), wo alle einstellungen gemacht werden
%         - Open the Settings.fig
%         - Update mainMenu.fig and Settings.fig with data from myscriptdata
%         - Update Groups with myUpdateGroups
%         - Update/setup File list, (callback for "choose input directory)
%         - if input is char (a callback function), then only that char is
%         evaluated
    
    
    if nargin > 1 && ischar(varargin{1})
        feval(varargin{1},varargin{2:end});
        return
    end
    
    
    initMyScriptData();    %init myScriptData mit default values or with data from scriptfile, if there is one.
    initMyProcessingData();  % initialise myScriptData with default values  
    loadMyProcessingData;    % load myProcessingData form MSD.DATAFILE (whose default is pwd)
    

    
    
    main_handle=mainMenu();            % open the figure
    myUpdateFigure(main_handle);      % and update it 
    setHelpMenus(main_handle)      % and set help buttons
    
    setting_handle=SettingsDisplay();    %Open the settings Display
    myUpdateFigure(setting_handle);     % and update it
    setHelpMenus(setting_handle);      
    
    myUpdateGroups        % analogous to UpdateGroups  (initialize Group Buttons)
    
    myUpdateACQFiles      % get ACQ Files from input directory to display them and get ACQ LABELS.
end


function initMyScriptData()
    % - Sets up global myScriptData as empty struct
    % - initializes myScriptData with Default Values for everything
    %                   -myScriptData.SCRIPTFILE='myScriptData.mat';
    %                   -myScriptData.DATAFILE='myProcessingData.mat'
    %                  
    % - check if myScriptData.SCRIPTFILE exists
    %       -> if yes: -load data from myScriptData.mat (and thus
    %                   overwrite/update current myScriptData)
    %       -> if no: save myScriptData as myScriptData.mat in current
    %       directory
    

    global myScriptData;

    myScriptData = struct();
    myScriptData.TYPE = struct();
    myScriptData.DEFAULT = struct();
    
    
    defaultsettings=getDefaultSettings;

    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8)
            myScriptData.(defaultsettings{p})={};
        else
            myScriptData.(defaultsettings{p})=defaultsettings{p+1};
        end
        myScriptData.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        myScriptData.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
    end

    % now check if myScriptData.mat exists in current Directory. If yes, load it (and thus
    % overwrite old myScriptData)
    
    if exist(fullfile(pwd,myScriptData.SCRIPTFILE), 'file')==2
        load(fullfile(pwd,myScriptData.SCRIPTFILE));
        old2newMyScriptData();
    else
        save('myScriptData','myScriptData');
    end
end


function initMyProcessingData()
% if myProcessingData.mat exists in current folder -> load it
% else: create with default and save that

    global myProcessingData myScriptData 
    if exist(fullfile(pwd,myScriptData.DATAFILE),'file')    % if mpd exists in current folder, load it
        loadMyProcessingData
    else                                      % else set default and save that
        myProcessingData = struct;
        myProcessingData.SELFRAMES = {};
        myProcessingData.REFFRAMES = {};
        myProcessingData.AVERAGESTART = {};
        myProcessingData.AVERAGEEND = {};
        myProcessingData.FILENAME={};
        save(myScriptData.DATAFILE,'myProcessingData')
    end
end

function loadMyProcessingData()
    % just load myProcessingData from a mat file. Thus the
    % old myProcessingData is overwritten
    global myScriptData; 
    load(myScriptData.DATAFILE,'-mat');
end

function ExportUserSettings(filename,index,fields)
    % save TS{index}.fids.(fields) in myProcessingData 
    % if fields doesnt exist in ts, it will be set to [] in mps. It's no
    % problem if field doesnt exist in mps at beginning
    
    global myProcessingData TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,myProcessingData.FILENAME));

    % IF ENTRY DOES NOT EXIST MAKE ONE
    if isempty(filenum)
        myProcessingData.FILENAME{end+1} = filename;
        filenum = length(myProcessingData.FILENAME);
    end
    
    for p=1:length(fields)
        if isfield(TS{index},lower(fields{p}))
            value = TS{index}.(lower(fields{p}));
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            myProcessingData.(fields{p})=data;
        else
            value = [];
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
            else
                data = {};
            end
            data{filenum(1)} = value;
            myProcessingData.(fields{p})=data;
        end
    end
    saveMyProcessingData; 
end

function ImportUserSettings(filename,index,fields)
    % Imports the fields from myProcessingData in the corresponding ts structure of
    % TS. Identification via filename. 

    global myProcessingData TS;
    % FIRST FIND THE FILENAME
    filenum = find(strcmp(filename,myProcessingData.FILENAME'));
    % THEN RETRIEVE THE DATA FROM THE DATABASE
    
    if ~isempty(filenum)
        for p=1:length(fields)
            if isfield(myProcessingData,fields{p})
                data = myProcessingData.(fields{p});
                if length(data) >= filenum(1)
                    if ~isempty(data{filenum(1)})
                        TS{index}.(lower(fields{p}))=data{filenum(1)};
                    end
                end
            end
        end
    end
end

function saveMyProcessingData()
% analogous to function SaveScriptData

    global myScriptData myProcessingData;
    
    save(myScriptData.DATAFILE,'myProcessingData');
end


function myUpdateFigure(handle)
% changes all Settings in the figure ( that belongs to handle) according to
% myScriptData.  
%Updates everything, including File Listbox etc..
    
    global myScriptData;
    if isempty(myScriptData)
        initMyScriptData;    
    end
    
    fn = fieldnames(myScriptData);
    for p=1:length(fn)
        obj = findobj(allchild(handle),'tag',fn{p});
        if ~isempty(obj)
            objtype = myScriptData.TYPE.(fn{p});
            switch objtype
                case {'file','string'}
                    set(obj,'string',myScriptData.(fn{p}));
                case {'listbox'}
                    cellarray = myScriptData.(fn{p});
                    if ~isempty(cellarray) 
                        values = intersect(myScriptData.ACQFILENUMBER,myScriptData.ACQFILES);
                        set(obj,'string',cellarray,'max',length(cellarray),'value',values,'enable','on');
                    else
                        set(obj,'string',{'NO ACQ or AC2 FILES FOUND','',''},'max',3,'value',[],'enable','off');
                    end
                case {'double','vector','listboxedit','integer'}
                    set(obj,'string',mynum2str(myScriptData.(fn{p})));
                case {'bool'}
                    set(obj,'value',myScriptData.(fn{p}));
                case {'select'}   % case of msd.GROUPSELECT  
                    value = myScriptData.(fn{p});    % int telling which group is selected
                    if value == 0, value = 1; end  %if nothing was selected
                    set(obj,'value',value);
                    rungroup=myScriptData.RUNGROUPSELECT;
                    if rungroup==0, continue; end
                    selectnames = myScriptData.GROUPNAME{rungroup};  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                    selectnames{end+1} = 'NEW GROUP';
                    set(obj,'string',selectnames);
                    
                case {'selectR'}
                    value = myScriptData.(fn{p});    % int telling which rungroup is selected
                    if value == 0, value = 1; end  %if nothing was selected
                    selectrnames = myScriptData.RUNGROUPNAMES;  %update dropdown with GROUPNAME, but add 'NEW GROUP' first
                    selectrnames{end+1} = 'NEW RUNGROUP'; 
                    set(obj,'string',selectrnames);
                    set(obj,'value',value);
                    
                    
                case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}   
                    group = myScriptData.GROUPSELECT;
                    if (group > 0)
                        set(obj,'enable','on','visible','on');
                        cellarray = myScriptData.(fn{p}){myScriptData.RUNGROUPSELECT};
                        if length(cellarray) < group   %if the 'new group' option is selected!
                            cellarray{group} = myScriptData.DEFAULT.(fn{p});      % if new group was added, fill emty array slots with default values
                        end
                        switch objtype(6:end)
                            case {'file','string'}
                                set(obj,'string',cellarray{group});
                            case {'double','vector','integer'}
                                set(obj,'string',mynum2str(cellarray{group}));
                            case {'bool'}
                                set(obj,'value',cellarray{group});
                        end
                        myScriptData.(fn{p}){myScriptData.RUNGROUPSELECT}=cellarray;    
                    else
                        set(obj,'enable','inactive','visible','off');
                    end
                case {'rungroupstring', 'rungroupvector'}    %any of the rungroupbuttons
                    rungroup = myScriptData.RUNGROUPSELECT;
                    if (rungroup > 0)
                        set(obj,'enable','on','visible','on');
                        set(findobj(allchild(handle),'tag','GROUPSELECT'),'enable','on','visible','on')
                        set(findobj(allchild(handle),'tag','RUNGROUPFILESBUTTON'),'enable','on','visible','on')
                        
                        cellarray = myScriptData.(fn{p});                     
                        switch objtype(9:end)
                            case {'file','string'}
                                set(obj,'string',cellarray{rungroup});
                            case {'double','vector','integer'}
                                set(obj,'string',mynum2str(cellarray{rungroup}));
                            case {'bool'}
                                set(obj,'value',cellarray{rungroup});
                        end
                        myScriptData.(fn{p})=cellarray;
                    else
                        set(obj,'enable','inactive','visible','off');
                        set(findobj(allchild(handle),'tag','GROUPSELECT'),'enable','off','visible','off')
                        set(findobj(allchild(handle),'tag','RUNGROUPFILESBUTTON'),'enable','off','visible','off')
                    end
            end
        end
    end
end


function getAC2Labels()  %TODO get rid of this stuff
% get individual label of each .ac2 file in input folder and store them in
% MSD.ACQLABEL, used for myProcessingData..
% orignial doesnt work, it always asigns msd.ASQLABEL='' 
% it should assign 'Run', (just takes the stuff from first file..)


global myScriptData;
myScriptData.ACQLABEL = 'Run';   %TODO..  leave this like that? ACQLABEL used in calfile stuff



% olddir = pwd;
% if ~isempty(myScriptData.ACQDIR)
%     if exist(myScriptData.ACQDIR,'dir')
%         cd(myScriptData.ACQDIR);
%     end
% end
% 
% d = dir('*.acq');
% if isempty(d)
%     d = dir('*.ac2');
%     if isempty(d)
%         cd(olddir); 
%         return; 
%     end
% end
% 
% for p=1:length(d)
%     t{p} = d(p).name(1:(strfind(d(p).name,'.')-1)); 
% end
% [B,I,J] = unique(t);
% [dummy,I] = max(hist(J,1:length(B)));
% 
% label = t{I};
% myScriptData.ACQLABEL = label;
% 
% label
% cd(olddir);
    


end




function myUpdateGroups()  %TODO get rid of this, pretty sure it's unneccesary
% not entirely sure..  like UpdateGroups, 
% sets default values for all the group cellarrays, if no values for a group have been set by the user
    global myScriptData;
    fn = fieldnames(myScriptData.TYPE);
    for q=1:length(myScriptData.RUNGROUPNAMES)
        len = length(myScriptData.GROUPNAME{q});
        for p=1:length(fn)
            if strncmp(myScriptData.TYPE.(fn{p}),'group',5)   % GROUPNAME, GROUPLEADS, GROUPEXTENSION, GROUPEXTENSION, GROUPBADLEADS etc.  
                cellarray = myScriptData.(fn{p}){q};
                default = myScriptData.DEFAULT.(fn{p});
                if length(cellarray) < len, cellarray{len} = default; end
                for s=1:len
                    if isempty(cellarray{s}), cellarray{s} = default; end
                end
            end
        end
    end
end

function GetACQFiles
% this function finds all files in ACQDIR and updates the following fields accordingly:
%     SCRIPT.ACQFILENUMBER     double array of the form
%     [1:NumberOfFilesDisplayedInListbox
%     SCRIPT.ACQLISTBOX        cellarray with strings for the listbox
%     SCRIPT.ACQFILENAME       cellarray with all filenames in ACQDIR
%     SCRIPT.ACQINFO           cellarray with a label for each file
%     SCRIPT.ACQFILES          double array of selected files in the
%     listbox
    

    global myScriptData;
   
    oldfilenames = {};
    if ~isempty(myScriptData.ACQFILES)
        for p=1:length(myScriptData.ACQFILES)
            if myScriptData.ACQFILES(p) <= length(myScriptData.ACQFILENAME)
                oldfilenames{end+1} = myScriptData.ACQFILENAME{myScriptData.ACQFILES(p)};
            end
        end
    end
    %oldfilenames is now  cellarray with filenamestrings of only the
    %selected files in listbox, eg {'Run0005.ac2'}, not of all files in dir
 
    
    
    
    olddir = pwd;
    %change into myScriptData.ACQDIR,if it exists and is not empty
    if ~isempty(myScriptData.ACQDIR)
        if exist(myScriptData.ACQDIR,'dir')
            if ~isempty(dir(myScriptData.ACQDIR))
                cd(myScriptData.ACQDIR);
            end
        end
    end
    
    
    filenames = {};
    exts = commalist(myScriptData.ACQEXT);  % create cellarray with all the allowed file extensions specified by the user
    for p=1:length(exts)
        d = dir(sprintf('*%s',exts{p}));
        for q= 1:length(d)
            filenames{end+1} = d(q).name;
        end
    end
    % filenames is cellarray with all the filenames of files in folder, like 
    %{'Ran0001.ac2'    'Ru0009.ac2'}
    
    filenames = sort(filenames);
    
    options.scantsdffile = 1;
   
    myScriptData.ACQFILENUMBER = [];
    myScriptData.ACQLISTBOX= {};
    myScriptData.ACQFILENAME = {};
    myScriptData.ACQINFO = {};
    myScriptData.ACQFILES = [];
    
    if isempty(filenames)
        cd(olddir)
        return
    end
    
    h = waitbar(0,'INDEXING AND READING FILES','Tag','waitbar'); drawnow;
    T = ioReadTSdata(filenames,options);    % read in all the file data in cellarray T
    if isgraphics(h), waitbar(0.8,h); end
    
    for p = 1:length(T)
        if ~isfield(T{p},'time'), T{p}.time = 'none'; end
        if ~isfield(T{p},'label'), T{p}.label = 'no label'; end
        T{p}.label=myStrTrim(T{p}.label); %necessary, because original strings have weird whitespaces that are not recognized as whitespaces.. really weird!
        myScriptData.ACQFILENUMBER(p) = p;      
        
        %%% find out which rungroup p belongs to
        rungroup='';
        for s=1:length(myScriptData.RUNGROUPNAMES)
            if ismember(p, myScriptData.RUNGROUPFILES{s})
                rungroup=myScriptData.RUNGROUPNAMES{s};
                break
            end
        end
        
        T{p}.time=myStrTrim(T{p}.time);   % use of myStrTrim for the same reason as above..     
        myScriptData.ACQLISTBOX{p} = sprintf('%04d %15s %15s %13s %20s',myScriptData.ACQFILENUMBER(p),T{p}.filename,rungroup, T{p}.time,T{p}.label);
        
        myScriptData.ACQFILENAME{p} = T{p}.filename;
        myScriptData.ACQINFO{p} = T{p}.label;
    end

    [~,~,myScriptData.ACQFILES] = intersect(oldfilenames,myScriptData.ACQFILENAME);
    myScriptData.ACQFILES = sort(myScriptData.ACQFILES);
    
    if isgraphics(h), waitbar(1,h); end
    drawnow;
    if isgraphics(h), close(h); end
    
    cd(olddir);
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Callback functions %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CloseFcn(~)
%callback function for the 'close' buttons.
 saveSettings([])
 delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
 delete(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS')); 
 delete(findobj(allchild(0),'tag','SLICEDISPLAY'));
 delete(findobj(allchild(0),'tag','FIDSDISPLAY'));
 close(findobj(allchild(0),'Tag','waitbar'))  %delete all waitbars
 
 global myScriptData FIDSDISPLAY SLICEDISPLAY
 clear myScriptdata FIDSDISPLAY SLICEDISPLAY
end

function Browse(handle,ext,mode)

    global myScriptData
    if nargin == 1
        ext = 'mat';
        mode = 'file';
    end
    
    if nargin == 2
        mode = 'file';
    end
    
    tag = get(handle,'tag');
    tag = tag(8:end);
    
    if strcmp(tag,'RUNGROUPMAPPINGFILE')
        filename = myScriptData.(tag){myScriptData.RUNGROUPSELECT};
    else
        filename = myScriptData.(tag);
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
            myScriptData.(tag)=newFileString;
            myUpdateACQFiles(handle)
        case 'SCRIPTFILE'
            dealWithNewMyScriptData(newFileString);
            myScriptData.(tag)=newFileString;
        case 'DATAFILE'
            if exist(newFileString,'file')
                if isCorrectFile(newFileString,'myProcessingData')
                    load(newFileString)
                else
                    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                    error('ERROR')
                end
            else
                save(newFileString,'myProcessingData')
            end
            myScriptData.(tag)=newFileString;
        case 'RUNGROUPMAPPINGFILE'
           myScriptData.(tag){myScriptData.RUNGROUPSELECT}=newFileString; 
        otherwise
           myScriptData.(tag)=newFileString;
    end
    parent = get(handle,'parent');
    myUpdateFigure(parent);
end

function selectRunGroupFiles(~)
%callback function to 'select Rungroup files'

selectRungroupFiles

%%%% make sure each file is associated with only one rungroup
global myScriptData
rungroup=myScriptData.RUNGROUPSELECT;
for s=1:length(myScriptData.RUNGROUPFILES{rungroup})
    rgFileID=myScriptData.RUNGROUPFILES{rungroup}(s);
    for t=1:length(myScriptData.RUNGROUPFILES)
        if t== rungroup, continue, end
        myScriptData.RUNGROUPFILES{t}=myScriptData.RUNGROUPFILES{t}(myScriptData.RUNGROUPFILES{t}~=rgFileID);
    end
end
        
        




myUpdateACQFiles
myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));


end




function myUpdateACQFiles(~)
% callback function to "Choose Input Directory"

% this function:
%   - Updates MSD.acqdir
%   - Updates MSD.FileLabels  (by calling getAC2Labels )
%   - calls GetAC2Files
%           - update ACQFILENUMBER, ACQFILENAME, ACQINFO, ACQLISTBOX  by
%           already initialising the TS cell!
%   - Update screen by calling myUpdateFigure

    getAC2Labels;   % upate msd.ACQLABEL
    GetACQFiles;    %update all the file related cellarrays, load files into TS cellarray
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));



end




function setScriptData(handle, mode)
% callback function to almost all buttons

% notes on how it works:
% the tag property of each object in the figure display is used to locate that object
% the tag of each each grafic object is also the fieldname of the
% corresponding fiel in myScriptData.  To further differentiate how each
% object is being dealt, the objecttype=myScriptData.TYPE.(tag) is used.

    %%%% first, set the focus on some dummy uicontrol. This ensures that
    % the hotkey 'spacebar' only affects the behaviour of the dummy
    % controll. There are two dummy controlls: one in the Settings and one
    % in the main menu (they are hidden underneath the pannels).
    
%     obj1=findobj(allchild(findobj(allchild(0),'Tag','PROCESSINGSCRIPTMENU')),'Tag','dummy');
%     obj2=findobj(allchild(findobj(allchild(0),'Tag','PROCESSINGSCRIPTSETTINGS')),'Tag','dummy');
%     if strcmp(handle.Parent.Tag,'PROCESSINGSCRIPTMENU')
%         uicontrol(obj1);
%     else
%         uicontrol(obj2)
%     end

    
    global myScriptData myProcessingData;
    tag = get(handle,'tag'); 
    
    checkNewInput(handle, tag);

    if isfield(myScriptData.TYPE,tag)
        objtype = myScriptData.TYPE.(tag);
    else
        objtype = 'string';
    end
    switch objtype
        case {'file','string'}
            myScriptData.(tag)=get(handle,'string');
        case {'double','vector','integer'}
            myScriptData.(tag)=mystr2num(get(handle,'string'));
        case 'bool'
            myScriptData.(tag)=get(handle,'value');
        case 'select'
            myScriptData.(tag)=get(handle,'value');
        case 'selectR'
            value=get(handle,'value');
            myScriptData.(tag)=value;           
            if length(myScriptData.RUNGROUPNAMES) < value  %if NEW RUNGROUP is selected, make all group cells longer
                fn=fieldnames(myScriptData.TYPE);
                for p=1:length(fn)
                    if strncmp(myScriptData.TYPE.(fn{p}),'group',5)
                        myScriptData.(fn{p}){end+1}={};
                    end
                    if strncmp(myScriptData.TYPE.(fn{p}),'rungroup',8)  %if NEW RUNGROUP is selected, make all rungroup cells one entry longer
                        myScriptData.(fn{p}){end+1} = myScriptData.DEFAULT.(fn{p});
                    end                     
                end
                myScriptData.GROUPSELECT=0;
             end          
        case 'listbox'
            myScriptData.ACQFILES = myScriptData.ACQFILENUMBER(get(handle,'value'));
        case {'listboxedit'}
            myScriptData.(tag)=mystr2num(get(handle,'string'));
        case {'groupfile','groupstring','groupdouble','groupvector','groupbool'}      %if any of the groupstuff is changed
            group = myScriptData.GROUPSELECT;      %integer, which group is selected in dropdown
            if (group > 0)
                if isfield(myScriptData,tag)  %todor And if {runroupselect} exists
                    cellarray = myScriptData.(tag){myScriptData.RUNGROUPSELECT};     % cellarray is eg {{'-gr1', '-gr2'}, .. } 
                else
                    cellarray = {};
                end
                switch objtype(6:end)     %change individual entry of cellarray according to user input. no change here necessary
                    case {'file','string'}
                        cellarray{group} = get(handle,'string');
                    case {'double','vector'}
                        cellarray{group} = mystr2num(get(handle,'string'));
                    case {'bool'}
                        cellarray{group} = get(handle,'value');
                end
                myScriptData.(tag){myScriptData.RUNGROUPSELECT}=cellarray;
            end
        case {'rungroupstring', 'rungroupvector'}  
            rungroup=myScriptData.RUNGROUPSELECT;
            if rungroup > 0
                cellarray = myScriptData.(tag);     % cellarray is eg {{'-gr1', '-gr2'}, .. } 
                
                switch objtype(9:end)     %change individual entry of cellarray according to user input. 
                    case {'file','string'}
                        cellarray{rungroup} = get(handle,'string');
                    case {'double','vector'}
                        cellarray{rungroup} = mystr2num(get(handle,'string'));
                    case {'bool'}
                        cellarray{rungroup} = get(handle,'value');
                end
                myScriptData.(tag)=cellarray;
            end
            myUpdateACQFiles;
                
    end
    
    if strcmp(tag,'RUNGROUPFILES')
        %make sure each file is only associated with one rungroup
        rungroup=myScriptData.RUNGROUPSELECT;
        for s=1:length(myScriptData.RUNGROUPFILES{rungroup})
            rgFileID=myScriptData.RUNGROUPFILES{rungroup}(s);
            for t=1:length(myScriptData.RUNGROUPFILES)
                if t== rungroup, continue, end
                myScriptData.RUNGROUPFILES{t}=myScriptData.RUNGROUPFILES{t}(myScriptData.RUNGROUPFILES{t}~=rgFileID);
            end
        end
        myUpdateACQFiles(handle);
    end
    
    
    if nargin == 2
        if strcmp(mode,'input')   %if call was by input bar
            getAC2Labels;   % upate msd.ACQLABEL
            GetACQFiles;    %update all the file related cellarrays, load files into TS cellarray
        end
    end
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
    
    if strcmp(tag,'ACQDIR') || strcmp(tag,'SCRIPTDATA')
        myUpdateACQFiles(handle);
    end
        
end



function loadSettings(handle)
% callback function to the 'load settings from file' button
% - asks user for a myScriptData.mat file
% - calls dealWithNewScriptData, which does all the needed stuff
    
    global myScriptData;
    [filename,pathname] = uigetfile('*.mat','Choose myScriptData file');
    filename = fullfile(pathname,filename);
    dealWithNewMyScriptData(filename);

end 


function saveSettings(~)
%callback function for Save Settings Button
% save myScriptData as a matfile in the filename/path specified in
% myScriptData.SCRIPTFILE
    global myScriptData;
    filename = myScriptData.SCRIPTFILE;
    save(filename,'myScriptData','-mat');
end



function removeGroup(handle)
%callback function to 'Remove this Group' button

    global myScriptData;
    group = myScriptData.GROUPSELECT;
    if group > 0
       fn = fieldnames(myScriptData.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               myScriptData.(fn{p}){myScriptData.RUNGROUPSELECT}(group)=[];
           end
       end
       myScriptData.GROUPSELECT =length(myScriptData.GROUPNAME{myScriptData.RUNGROUPSELECT});
   end
   myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function removeRunGroup(handle)
%callback to 'remove this rungroup'
    global myScriptData;
    rungroup = myScriptData.RUNGROUPSELECT;
    if rungroup > 0
       fn = fieldnames(myScriptData.TYPE);
       for p=1:length(fn)
           if strncmp(fn{p},'RUNGROUP',8) && ~strcmp('RUNGROUPSELECT',fn{p})
               myScriptData.(fn{p})(rungroup)=[];
           end
           if strncmp(fn{p},'GROUP',5) && ~strcmp('GROUPSELECT',fn{p})
               myScriptData.(fn{p})(rungroup)=[];
           end
       end
       myScriptData.RUNGROUPSELECT=length(myScriptData.RUNGROUPNAMES);
       
       rungroupselect=myScriptData.RUNGROUPSELECT;
       if rungroupselect > 0
            myScriptData.GROUPSELECT = length(myScriptData.GROUPNAME{rungroupselect});
       else
           myScriptData.GROUPSELECT = 0;
       end
 
   end
   myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
end


function selectAllACQ(~)
%callback function to "select all" button at file listbox
    global myScriptData;
    myScriptData.ACQFILES = myScriptData.ACQFILENUMBER;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function selectNoneACQ(~)
%callback to 'clear selection' button
    global myScriptData;
    myScriptData.ACQFILES = [];
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function ACQselectLabel(~)
%callback to 'select label containing..' 
    
    global myScriptData;
    pat = myScriptData.ACQPATTERN;
    sel = [];
    for p=1:length(myScriptData.ACQINFO),
        if ~isempty(strfind(myScriptData.ACQINFO{p},pat)), sel = [sel myScriptData.ACQFILENUMBER(p)]; end
    end
    myScriptData.ACQFILES = sel;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
end

function openSettings(~)
%callback to 'Settings Windwow'
handle=SettingsDisplay;
myUpdateFigure(handle)


end

function runScript(handle)
%callback to 'apply' button, this starts the whole processing process!

%this function
%   - saves all settings in msd.SCRIPTFILE, just in case programm crashes
%   - checks if all settings are correkt (in particular, if groups have
%     been selected
%   - loads myProcessingData
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
    global myScriptData
    saveSettings();
    
    loadMyProcessingData;  
    saveSettings
    h = [];   %for waitbar
%     olddir =pwd;      %why?     seems not important TODO
%     cd(myScriptData.PWD); 
    PreLoopScript;
    saveSettings(handle);

    for s=1:length(myScriptData.RUNGROUPNAMES)
        if isempty(myScriptData.GROUPNAME{s})
            errordlg('you need to define groups for each defined rungroup in order to  process the data.');
            error('There is at least one rungroup with no groups defined.')
        end
    end

    %%%% MAIN LOOP %%%
    acqfiles = unique(myScriptData.ACQFILES);
    h  = waitbar(0,'SCRIPT PROGRESS','Tag','waitbar'); drawnow;

    p = 1;
    while (p <= length(acqfiles))

        myScriptData.ACQNUM = acqfiles(p);
        
        %%%% find the current rungroup of processed file
        myScriptData.CURRENTRUNGROUP=[];
        for s=1:length(myScriptData.RUNGROUPNAMES)
            if ismember(acqfiles(p), myScriptData.RUNGROUPFILES{s})
                myScriptData.CURRENTRUNGROUP=s;
                break
            end
        end
        if isempty(myScriptData.CURRENTRUNGROUP)
            msg=sprintf('No Rungroup specified for %s. You need to specify a Rungroup for each file that you want to process.',myScriptData.ACQFILENAME{acqfiles(p)});
            errordlg(msg);
            error('No Rungroup specified for all files')
        end
            

        ProcessACQFile(myScriptData.ACQFILENAME{acqfiles(p)},myScriptData.ACQDIR);
        
        switch myScriptData.NAVIGATION
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
    myUpdateGroups;
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU')); 
end

function KeyPress(handle)
    global myScriptData;

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


function PreLoopScript
    %this function is called right before main loop starts. Its jobs are: 
%       - checks if mapfile etc exist
%       - generates a CALIBRATION file, if none is supplied but
%       Do_Calibration is on
%       - set up SCRIPT.GBADLEADS,  SCRIPT.MAXLEAD and mpd.LIBADLEADS
%       mpd.LI, ALIGNSTART, ALIGNSIZE
    

    global myScriptData myProcessingData   
    myScriptData.ALIGNSTART = 'detect';
    myScriptData.ALIGNSIZE = 'detect';
    
    
    %%%% -create filenames, which holds all the filename-strings of only the files selected by user.  
    % -create index, which holds all the indexes of filenames, that contain '-acq' or '.ac2'
    filenames = myScriptData.ACQFILENAME(myScriptData.ACQFILES);    % only take the files selected by the user
    index = [];
    for r=1:length(filenames)
        if ~isempty(strfind(filenames{r},'.acq')) || ~isempty(strfind(filenames{r}, '.ac2')), index = [index r]; end
    end   
    
    
    %%%% check if input directory is provided and valid
    if ~exist(myScriptData.MATODIR,'dir')
        errordlg('Provided output directory does not exist.')
        error('Invalid output directory')
    end
    
    
    
    if ~isempty(index)
        %%%%%%  generate a calibration file if neccessary %%%%%%%%%%%%%%%
        if myScriptData.DO_CALIBRATE == 1  % if 'calibrate Signall' button is on
            %%% if no calibration file and no CALIBRATIONACQ is given: exit
            %%% and make error message
            if isempty(myScriptData.CALIBRATIONACQ) && isempty(myScriptData.CALIBRATIONFILE)
                errordlg('Specify the filenumbers of the calibration measurements or a calibration file');
                error('No ac2cal files or .cal8 file specified.'); 
            end   
		    
            %%%% create a calfile if DO_CALIBRATE is on, but no calfile is
            %%%% given
		    if isempty(myScriptData.CALIBRATIONFILE) && myScriptData.DO_CALIBRATE
                    % generate a cell array of the .ac2 files used for
                    % calibration
                    acqcalfiles=myScriptData.ACQFILENAME(myScriptData.CALIBRATIONACQ);
				    if ~iscell(acqcalfiles), acqcalfiles = {acqcalfiles}; end 
                    
                    %find the mappingfile used for the acqcalfiles.
                    mappingfile=[];
                    for s=1:length(myScriptData.RUNGROUPNAMES)
                        if ismember(myScriptData.CALIBRATIONACQ,myScriptData.RUNGROUPFILES{s})
                            mappingfile=myScriptData.RUNGROUPMAPPINGFILE{s};
                            break
                        end
                    end
                    if isempty(mappingfile)
                        errordlg('matmap can only create a .cal8 file, if all files used for calibration belong to the same rungroup. However, this does not seem to be the case.');
                        error('error creating the .cal8 file. Couldn''t figure out which mapping file to use..')
                    end
                    
                    
				    for p=1:length(acqcalfiles)
                        acqcalfiles{p} = fullfile(myScriptData.ACQDIR,acqcalfiles{p});
                    end
                    
				    pointer = get(gcf,'pointer'); set(gcf,'pointer','watch');
                    calfile='calibration.cal8';
				    sigCalibrate8(acqcalfiles{:},mappingfile,calfile,'displaybar');
				    set(gcf,'pointer',pointer);
                    
                    myScriptData.CALIBRATIONFILE = fullfile(pwd,calfile);
		    end 
        end
    end    
    
    %%%% RENDER A GLOBAL LIST OF ALL THE BADLEADS,  set msd.GBADLEADS%%%%
   
   myScriptData.GBADLEADS={};
   for s=1:length(myScriptData.RUNGROUPNAMES)
       badleads=[];
       for p=1:length(myScriptData.GROUPBADLEADS{s})           
            reference=myScriptData.GROUPLEADS{s}{p}(1)-1;    
            addBadleads=  myScriptData.GROUPBADLEADS{s}{p} + reference;
            
            % check if user input for badleads is correct
            diff=myScriptData.GROUPLEADS{s}{p}(end)-myScriptData.GROUPLEADS{s}{p}(1);
            if any(myScriptData.GROUPBADLEADS{s}{p} < 1) || any(myScriptData.GROUPBADLEADS{s}{p} > diff+1)
                msg=sprintf('Bad leads for the group %s in the rungroup %s are invalid. Bad leads must be between 1 and ( 1 + maxGrouplead - minGrouplead).',myScriptData.GROUPNAME{s}{p}, myScriptData.RUNGROUPNAMES{s});
                errordlg(msg);
                error('specified bad leads are invalid')
            end
            

            
            % read in badleadsfile, if there is one
            if ~isempty(myScriptData.GROUPBADLEADSFILE{s}{p}) %TODO, do I want to badleadsfile of this grouplisttype?
                bfile = load(myScriptData.GROUPBADLEADSFILE{s}{p},'-ASCII');
                badleads = union(bfile(:)',badleads);
            end        
       end
        
        
        myScriptData.GBADLEADS{s} = badleads;
   end

    
    
    %%%% FIND MAXIMUM LEAD for each rg
    myScriptData.MAXLEAD={};  %set to empty first, just in case
    for s=1:length(myScriptData.RUNGROUPNAMES)  
        maxlead = 1;
        for p=1:length(myScriptData.GROUPLEADS{s})
            maxlead = max([maxlead myScriptData.GROUPLEADS{s}{p}]);  %TODO this can be done a lot easier..
        end
        myScriptData.MAXLEAD{s} = maxlead;
    end
    
    
    
    if myScriptData.DO_INTERPOLATE == 1
        
        if myScriptData.DO_SPLIT == 0
            errordlg('Need to split the signals before interpolation');
            error('ERROR');
        end
        for s=1:length(myScriptData.RUNGROUPNAMES)  %a edit: for each rg..
            for q=1:length(myScriptData.GROUPNAME{s})
                myProcessingData.LIBADLEADS{s}{q} = [];   % TRIGGER INITIATION
                myProcessingData.LI{s}{q} = [];
            end
        end
    end
end






function ProcessACQFile(inputfilename,inputfiledir)

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

    


    olddir = pwd;
    global myScriptData TS myProcessingData;

%%%%% create cellaray files={full acqfilename, mappingfile, calibration file}, if the latter two are needet & exist    
    filename = fullfile(inputfiledir,inputfilename);
    files{1} = filename;
    isMatFile=0;
    if contains(inputfilename,'.mat'), isMatFile=1; end
    
    
    % load & check mappinfile
    mappingfile = myScriptData.RUNGROUPMAPPINGFILE{myScriptData.CURRENTRUNGROUP};
    if isempty(mappingfile)
        myScriptData.RUNGROUPMAPPINGFILE{myScriptData.CURRENTRUNGROUP} = '';
    elseif ~exist(mappingfile,'file')
        msg=sprintf('The provided .mapping file for the Rungroup %s does not exist.',myScriptData.RUNGROUPNAMES{myScriptData.CURRENTRUNGROUP});
        errordlg(msg);
        error('problem with mappinfile.')
    else
        files{end+1}=mappingfile;
    end    

    if myScriptData.DO_CALIBRATE == 1 && ~isMatFile     % mat.-files are already calibrated
        if ~isempty(myScriptData.CALIBRATIONFILE)
            if exist(myScriptData.CALIBRATIONFILE,'file')
                files{end+1} = myScriptData.CALIBRATIONFILE;
            end
        end
    end
    

%%%%%%% read in the files in TS.  index is index with TS{index}=current ts
%%%%%%% structure
    if isMatFile
        index=ioReadMAT(files{:});
    else
        index = ioReadTS(files{:});
    end
    
    
%%%%% make ts.filename only the filename without the path

[~,filename,ext]=fileparts(TS{index}.filename);
TS{index}.filename=[filename ext];
    
    
    
    
    
%%%%%% check if dimensions of potvals are correct, issure error msg if not
    if size(TS{index}.potvals,1) < myScriptData.MAXLEAD{myScriptData.CURRENTRUNGROUP}
        errordlg('Maximum lead in settings is greater than number of leads in file');
        cd(olddir);
        error('ERROR');
    end
    

%%%% ImportUserSettings (put Data from myProcessingData in TS{currentTS} %%%%%%%%%%    
    fieldstoload = {'SELFRAMES','AVERAGEMETHOD','AVERAGESTART','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES'};
    if myScriptData.DO_ADDBADLEADS, fieldtoload{end+1} = 'LEADINFO'; end   % DO_ADDBA.. doesnt exist.. remove? TO DO
      
    ImportUserSettings(inputfilename,index,fieldstoload);
    
    
%%%%  store the GBADLEADS also in the ts structure (in ts.leadinfo)%%%% 
    badleads=myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP};
    TS{index}.leadinfo(badleads) = 1;
        
%%%%% do the temporal filter of current file %%%%%%%%%%%%%%%%
    if myScriptData.DO_FILTER      % if 'apply temporal filter' is selected
        if 0 %isfield(myScriptData,'FILTER')     % this doesnt work atm, cause buttons for Filtersettings etc have been removed
            myScriptData.FILTERSETTINGS = [];
            for p=1:length(myScriptData.FILTER)
                if strcmp(myScriptData.FILTER(p).label,myScriptData.FILTERNAME)
                    myScriptData.FILTERSETTINGS = myScriptData.FILTER(p);
                end
            end
        else
            myScriptData.FILTERSETTINGS.B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
            myScriptData.FILTERSETTINGS.A = 1;
        end
        temporalFilter(index);    % no add audit? shouldnt it be recordet somewhere that this was filtered??? TODO
    end
        

%%%%%  call SliceDisplay (if UserInterface is selected) %%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this block does the following:
% - call SliceDisplay
% - some Navigation stuff
% -  does some upgrades to bad leads 
% - calls sigSlice, which in this case:  updates TS{currentIndex} bei
% keeping only the timeframe-window specified in ts.selframes
    
    if myScriptData.DO_SLICE == 1   % DO_SLICE is 1 by default and is never changed, so always 1 -> obsolete?! DOTO  
        if myScriptData.DO_SLICE_USER == 1  %if 'user interaction' button is pressed
            handle = mySliceDisplay(index); % this only changes selframes I think it also uses ts.averageframes (and all from export userlist bellow?)
         
            waitfor(handle);
 
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','back'}, cd(olddir); tsClear(index); return; 
            end

            if myScriptData.KEEPBADLEADS == 1
                badleads = tsIsBad(index);
                for p=1:length(myScriptData.GROUPBADLEADS{myScriptData.CURRENTRUNGROUP}) 
                    [~,localindex] = intersect(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p},badleads);
                    myScriptData.GROUPBADLEADS{myScriptData.CURRENTRUNGROUP}{p} = localindex;
                end
            end

            
            
            
            % SO STORE ALL THE SETTINGS/CHANGES WE MADE
            
            ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO'});
        end
        
        % CONTINUE AND DO THE SLICING/AVERAGING OPERATION
        sigSlice(index);   % keeps only the selected timeframes in the potvals, using ts.selframes as start and endpoint
    end
    
%%%%%% if 'blank bad leads' button is selected,   set all values of the bad leads to 0   
    if myScriptData.DO_BLANKBADLEADS == 1
        badleads = tsIsBad(index);
        TS{index}.potvals(badleads,:) = 0;
        tsSetBlank(index,badleads);
        tsAddAudit(index,'|Blanked out bad leads');
    end
 
    
 %%%%%% import more Usersettings from myProcessingData into TS{index} %%%%
    fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
    ImportUserSettings(inputfilename,index,fieldstoload);
    
%%%%%%%%%% start baseline stuff %%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if myScriptData.DO_BASELINE_USER, myScriptData.DO_BASELINE = 1; end
    if (myScriptData.DO_BASELINE == 1)
    %%%% shift ficucials to the new local frame %%%%%%%%%%%%
    % fids are always in local frame, but because user selected new local
    % frame (the selframe), the local frame changed!
    
        if ~isfield(TS{index},'selframes')
            msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a myProcessingData file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame.',TS{index}.filename);
            errordlg(msg)
            TS{index}=[];
            error('ERROR')
        end
        if ~isfield(TS{index},'startframe'), TS{index}.startframe = 1; end
        newstartframe = TS{index}.selframes(1);  
        oldstartframe = TS{index}.startframe(1);          
        fidsShiftFids(index,oldstartframe-newstartframe);    
        TS{index}.startframe = newstartframe;  % TODO shouldnt this be directly after the slicing? fits better inhaltlich
        
 
    %%%%  get baseline (the intervall ) from TS (so default or from ImportSettings. If values are weird, set to [1, numframes]
    % and set that as new fiducial
        baseline = fidsFindFids(index,'baseline');
        framelength = size(TS{index}.potvals,2);
        baselinewidth = myScriptData.BASELINEWIDTH;       % also upgrade baselinewidth
        TS{index}.baselinewidth = baselinewidth;
        if length(baseline) < 2
            fidsRemoveFiducial(index,'baseline');
            fidsAddFiducial(index,1,'baseline');
            fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
        end
    %%%% if 'Pre-RMS Baseline correction' button is pressed, do baseline
    %%%% corection of current index (before user selects anything..
        if myScriptData.DO_BASELINE_RMS == 1
            baselinewidth = myScriptData.BASELINEWIDTH;
            sigBaseLine(index,[],baselinewidth);
        end
    
    %%%%   open Fidsdisplay in mode 2, (baseline mode)
        if myScriptData.DO_BASELINE_USER == 1
            handle = myFidsDisplay(index,2);    % this changes fids, but nothing else
            waitfor(handle);
            
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
            end     
        end
    %%%% and save user selections in myProcessingScript    
        ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGECHANNEL','AVERAGERMSTYPE','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});

        
%     %%%% Do_DeltaFOVERF, if that option is selected  (get rid of??)
%         if myScriptData.DO_DELTAFOVERF == 1 
%             fidsFindFids(index,20)
%             fidsFindFids(index,21)
%             if isempty(fidsFindFids(index,20))||isempty(fidsFindFids(index,21))  %this is always the case?! since 20 and 21 dont exist in fids fkt
%                 han = errordlg('No interval specified for DetlaF over F correction, skipping correction');
%                 waitfor(han);
%             else            
%                 sigDeltaFoverF(index);
%             end
%         end          
        
        
    %%%% now do the final baseline correction
        if myScriptData.DO_BASELINE == 1
            baselinewidth = myScriptData.BASELINEWIDTH;
            if length(fidsFindFids(index,'baseline')) < 2 
                han = errordlg('At least two baseline points need to be specified, skipping baseline correction');
                waitfor(han);
            else
                sigBaseLine(index,[],baselinewidth);
            end
        end    
        
  
    end
    
    
    
    
    %%% Do_LAPLACIAN_INTERPOLATE %%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if myScriptData.DO_LAPLACIAN_INTERPOLATE == 1
%         
%          %%% find the groups to be processed. splitgroup=[1 3] if there are
%          %%% 3 groups but the 2 shouldnt be processed
%         splitgroup = [];
%         for p=1:length(myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP})
%             if myScriptData.GROUPDONOTPROCESS{myScriptData.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
%         end
%         
%         
%         
%         for q=1:length(splitgroup)   %for each group to be processed
%             
%             %%% continue, if group has no bad leads
%             if isempty(myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                 continue;
%             end
%             
%             
%             %%% initialice LIBADLEADS with [], if not initialized yet
%             if ~isfield(myProcessingData,'LIBADLEADS')
%                 myProcessingData.LIBADLEADS{myScriptData.CURRENTRUNGROUP}{q} = [];
%             end
%             
%             
%             %%% if GBADLEADS(groupIndex) without LIBADLEADS(groupIndex) is
%             %%% not empty
%             if ~isempty(setdiff(myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)},myProcessingData.LIBADLEADS{myScriptData.CURRENTRUNGROUP}{q}))
%                 myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)} = [];
%                 
%                 
%                 %%% if no GROUPGEOM-file is given, continue
%                 %%% file= { GEOM-File,  GroupChannel-File} 
%                 files = {};
%                 files{1} = myScriptData.GROUPGEOM{myScriptData.CURRENTRUNGROUP}{splitgroup(q)};
%                 if isempty(files{1})
%                     continue;
%                 end
%                 if ~isempty(myScriptData.GROUPCHANNELS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                     files{2} = myScriptData.GROUPCHANNELS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)};
%                 end
%                 
%                 
%                 
%                 
%                 myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)} = sparse(triLaplacianInterpolation(files{:},myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)},length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})));
%             end
%             
%             
%             %%% continue, if triLaplacian interpolation didnt return
%             %%% anything
%             if isempty(myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                 continue;
%             end
%             
%             %%% potvals(groupleads{p})=potvals(groupleads{p})*LI{p}..
%             leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)};
%             TS{index}.potvals(leads,:) = myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)}*TS{index}.potvals(leads,:);
%             
%             
%             %%% mark interpolated leads as interpolated
%             tsSetInterp(index,leads(myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)}));
%           
%         end
%         tsAddAudit(index,'|Interpolated bad leads (Laplacian interpolation)');
%     end
    
    
    %%%%%%%% now detect the rest of fiducials, if 'detect fids' was selected   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if myScriptData.DO_DETECT_USER, myScriptData.DO_DETECT=1; end
    if myScriptData.DO_DETECT == 1
        fieldstoload = {'FIDS','FIDSET','STARTFRAME'};
        ImportUserSettings(inputfilename,index,fieldstoload);
        
        
        %%% fids shift, same as in baseline stuff, to get to local frame?!
        if ~isfield(TS{index},'selframes')
            msg=sprintf('Couldn''t find any selected start/end time frames for %s. Either provide one by using a myProcessingData file where this information has been saved previously or select ''User Interaction'' at the Slice/Average'' section to manually select a start/end time frame.',TS{index}.filename);
            errordlg(msg)
            TS{index}=[];
            error('ERROR')
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
        baselinewidth = myScriptData.BASELINEWIDTH;
        if length(baseline) < 2
            fidsRemoveFiducial(index,'baseline');
            fidsAddFiducial(index,1,'baseline');
            fidsAddFiducial(index,framelength-baselinewidth+1,'baseline');
        end
        
        
        %%%%%% open FidsDisplay again, this time to select fiducials
        
        if myScriptData.DO_DETECT_USER == 1
            handle = myFidsDisplay(index);    
            
            waitfor(handle);
            switch myScriptData.NAVIGATION
                case {'prev','next','stop','redo','back'}, cd(olddir); tsClear(index); return; 
            end     
        end    
        % save the user selections (stored in ts) in myProcessingData
        ExportUserSettings(inputfilename,index,{'SELFRAMES','AVERAGEMETHOD','AVERAGERMSTYPE','AVERAGECHANNEL','AVERAGESTART','AVERAGEEND','AVERAGEFRAMES','TEMPLATEFRAMES','LEADINFO','FIDS','FIDSET','STARTFRAME'});
    end
    
        
    %%%% this blog does the splitting. In detail it
    % - creates numgroups new ts structures (one for each group) using
    % tsSplitTS
    % - it sets ts.'tsdfcfilename' to myScriptData.GROUPTSDFC(splitgroup)
    % - it sets ts.filename to  exact the same..  'including some tsdf
    % stuff
    % - original ts (the one thats splittet) is cleared
    % - index is now index array of the splittet sub ts!!

    %%%% split TS{index} into numGroups smaller ts
    splitgroup = [];
    for p=1:length(myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP})
        if myScriptData.GROUPDONOTPROCESS{myScriptData.CURRENTRUNGROUP}{p} == 0, splitgroup = [splitgroup p]; end
    end
    % splitgroup is now eg [1 3] if there are 3 groups but the 2 should
    % not be processed
    channels=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}(splitgroup);
    indices = mytsSplitTS(index, channels);    
    tsDeal(indices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup))); 
    tsClear(index);        
    index = indices;


    
    
%     %%%% do trilaplacian interpolation for each ts 
%     if myScriptData.DO_INTERPOLATE == 1     % if second 'Interpolate' button is on
%         if myScriptData.DO_SPLIT == 0
%             error('Need to split the signal before interpolating');
%         end
%         for q=1:length(index)    %remember, index is now array
%             
%             if isempty(myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                 continue;
%             end
%                 
%             if ~isempty(setdiff(myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)},myProcessingData.LIBADLEADS{myScriptData.CURRENTRUNGROUP}{q}))
%                 myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)} = [];
%                 
%                 if myScriptData.GROUPDONOTPROCESS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)} == 1
%                     continue;
%                 end
%                 
%                 files = {};
%                 files{1} = myScriptData.GROUPGEOM{myScriptData.CURRENTRUNGROUP}{splitgroup(q)};
%                 if isempty(files{1})
%                     continue;
%                 end
%                 if ~isempty(myScriptData.GROUPCHANNELS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                     files{2} = myScriptData.GROUPCHANNELS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)};
%                 end
% 
%                 myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)} = sparse(triLaplacianInterpolation(files{:},SCRIPT.GBADLEADS{splitgroup(q)},length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})));
%             end
%             
%             if isempty(myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)})
%                 continue;
%             end
%             
%             TS{index(q)}.potvals = myProcessingData.LI{myScriptData.CURRENTRUNGROUP}{splitgroup(q)}*TS{index(q)}.potvals;
%             tsSetInterp(index(q),myScriptData.GBADLEADS{myScriptData.CURRENTRUNGROUP}{splitgroup(q)});
%             tsAddAudit(index(q),'|Interpolated bad leads (Laplacian interpolation)');
%             
%         end
%     end
    

    %%%% save the new ts structures using ioWriteTS
    olddir = cd(myScriptData.MATODIR);
    tsDeal(index,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup)));
    ioWriteTS(index,'noprompt','oworiginal');
    cd(olddir);

    
    %%%% do integral maps and save them  
    if myScriptData.DO_INTEGRALMAPS == 1
        if myScriptData.DO_DETECT == 0
            msg=sprintf('Need fiducials (at least QRS wave or T wave) to do integral maps for %s.', inputfilename);
            errordlg(msg)
            error('Need fiducials to do integral maps');
        end
        mapindices = fidsIntAll(index);
        if length(splitgroup)~=length(mapindices)
            msg=sprintf('Fiducials (QRS wave or T wave) necessary to do integral maps. However, for %s there are no fiducials for all groups.',inputfilename);
            errordlg(msg)
            error('No fiducials for integralmaps.')
        end
        
        olddir = cd(myScriptData.MATODIR); 
        fnames=ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-itg');

        tsDeal(mapindices,'filename',fnames); 
        tsSet(mapindices,'newfileext','');
        ioWriteTS(mapindices,'noprompt','oworiginal');
        cd(olddir);
    
        tsClear(mapindices);
    end
    
    
 %%%%% Do activation maps   
    
   if myScriptData.DO_ACTIVATIONMAPS == 1
        if myScriptData.DO_DETECT == 0 % 'Detect fiducials must be selected'
            error('Need fiducials to do activation maps');
        end
        
        %%%% make new ts at TS(mapindices). That new ts is like the old
        %%%% one, but has ts.potvals=[act rec act-rec]
        mapindices = sigActRecMap(index);   
        
        
        %%%%  save the 'new act/rec' ts as eg 'Run0009-gr1-ari.mat
        % AND clearTS{mapindex}!
        olddir = cd(myScriptData.MATODIR);
        tsDeal(mapindices,'filename',ioUpdateFilename('.mat',inputfilename,myScriptData.GROUPEXTENSION{myScriptData.CURRENTRUNGROUP}(splitgroup),'-ari')); 
        tsSet(mapindices,'newfileext','');
        ioWriteTS(mapindices,'noprompt','oworiginal');
        cd(olddir);
        tsClear(mapindices);
        
%         %%%%%%  all this just changes TS{index}, but those ts are cleared
%         %%%%%%  without any saving.. totally useless??
%         
%         s = tsNew(length(index));    
%         for j=1:length(index)
%             
%             
%             %%%% make acttime=[act1; act2; act2] .. all the local act
%             %%%% timeframes,   
%             acttime = floor(fidsFindLocalFids(index(j),'act'));
%             acttime = round(median([ones(size(acttime)) acttime  (TS{index(j)}.numframes-1)*ones(size(acttime))],2));
%  
%             %%%% why is this commented out?
%             for p=1:TS{index(j)}.numleads
% %                keyboard
%                 if ~isempty(acttime)
%                     %dvdt(p) = (TS{index(j)}.potvals(p,acttime(p)+1) - TS{index(j)}.potvals(p,acttime(p)))/TS{index(j)}.samplefrequency;    
%                 else
%                     %dvdt(p) = 0;
%                 end
%             end
%            % TS{index(j)}.dvdt = dvdt;
%            
%            
%             TS{s(j)} = TS{index(j)};
%             %TS{s(j)}.potvals = dvdt;
%             TS{s(j)}.numframes = 1;
%             TS{s(j)}.pacing = [];
%             TS{s(j)}.fids = [];
%             TS{s(j)}.fidset = {};
%             TS{s(j)}.audit = '| Dv/Dt at activation';           
%         end
%         tsClear(s);  %% why clear everything --> makes above pointless?? TODO
   end
   
   
   
   
   
   %%%%% save everything and clear TS
    saveMyProcessingData;
    saveSettings();
    tsClear(index);
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


function tf = isCorrectFile(pathstring,toBeFile,flag)
% this function checks if the file given by pathstring is the file it is
% supposed to be (specified by toBeFile)
% input:
%   - pathstring:  a string containing the full path to the file to be
%   checked
%   - toBeFile: either 'myScriptData' or 'myProcessingData
% output:  true or false. If false, this function opens an error-dialog
% with descriptive message

% how it works/what it does:
% - it checks if the given file is a struct
%-  if yes, it checks if that struct has all the fields it is supposed to
%   have

    nec_fields = { 'PWD','','file',...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'CALIBRATIONACQUSED','','vector',...
                    'SCRIPTFILE','myScriptData.mat','file',...
                    'ACQLABEL','','string',...
                    'ACQLISTBOX','','listbox',...
                    'ACQFILES',[],'listboxedit',...
                    'ACQPATTERN','','string',...
                    'ACQFILENUMBER',[],'vector',...
                    'ACQINFO',{},'string',...
                    'ACQFILENAME',{},'string',...
                    'ACQNUM',0,'integer',...
                    'DATAFILE','myProcessingData.mat','file',...
                    'TSDFDIR','autoprocessing','file',...
                    'ACQDIR','','file',...
                    'ACQCONTAIN','','string',...
                    'ACQCONTAINNOT','','string',...
                    'ACQEXT','.acq,.ac2','string',...   % was tag for fileextension. I dont use it.. TODO
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
                    'DO_DETECT',1,'bool',...
                    'DO_DETECT_USER',1,'bool',...
                    'DO_DETECT_LOADTSDFC',1,'bool',...
                    'DO_DETECT_AUTO',1,'bool',...
                    'DO_DETECT_PACING',1,'bool',...
                    'DO_LAPLACIAN_INTERPOLATE',1,'bool',...
                    'DO_INTERPOLATE',0,'bool',...
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
                    'ALIGNSTART','detect','integer',...
                    'ALIGNSIZE','detect','integer',...
                    'ALIGNMETHOD',1,'integer',...
                    'ALIGNSTARTENABLE',1,'integer',...
                    'ALIGNSIZEENABLE',1,'integer',...
                    'ALIGNRMSTYPE',1,'integer',...
                    'ALIGNTHRESHOLD',0.9,'double',...
                    'AVERAGEMETHOD',1,'integer',...
                    'AVERAGERMSTYPE',1,'integer',...
                    'AVERAGECHANNEL',1,'integer',...
                    'AVERAGEMAXN',5,'integer',...
                    'AVERAGEMAXRE',0.1,'double',...
                    'KEEPBADLEADS',1,'integer',...
                    'FIDSLOOPFIDS',1,'integer',...
                    'FIDSAUTOACT',1,'integer',...
                    'FIDSAUTOREC',1,'integer',...
                    'FIDSAUTOPEAK',1,'integer',...
                    'FIDSACTREV',0,'integer',...
                    'FIDSRECREV',0,'integer',...
                    'TSDFODIR','tsdf','string',...
                    'TSDFODIRON',1,'bool',...
                    'MATODIR','mat','string',...
                    'ACTWIN',7,'integer',...
                    'ACTDEG',3,'integer',...
                    'ACTNEG',1,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'RECNEG',0,'integer',...
                    'ALEADNUM',1,'integer',...
                    'ADOFFSET',0.2,'double',...
                    'ADISPLAYTYPE',1,'integer',...
                    'ADISPLAYOFFSET',1,'integer',...
                    'ADISPLAYGRID',1,'integer',...
                    'ADISPLAYGROUP',1,'vector',...
                    'OPTICALLABEL','','string',...
                    'FILTERFILE','','string',...
                    'FILTERNAME','NONE','string',...
                    'FILTERNAMES',{'NONE'},'string',...
                    'FILTER',[],'string',...
                    'INPUTTSDFC','','string'
            };
        

metastruct=load(pathstring);

if nargin==3 && strcmp(flag,'supressMessages')
    msg=0;
else msg=1;
end


if isfield(metastruct,'myScriptData'); loadedStruct=metastruct.('myScriptData');
elseif isfield(metastruct,'myProcessingData'); loadedStruct=metastruct.('myProcessingData'); end

if ~isstruct(loadedStruct)
    if msg; errordlg('The chosen file doesn''t contain a struct called myScriptData or myProcessingData.'); end
    tf=0;
    return
end

switch toBeFile
    case 'myScriptData'
        for p=1:3:length(nec_fields)
            if ~isfield(loadedStruct,nec_fields{p})
                errormsg = sprintf('The choosen file doesn''t seem to be a myScriptData file. \n It doesn''t have the %s field.', nec_fields{p});
                if msg; errordlg(errormsg); end
                tf=0;
                return
            end
        end
    case 'myProcessingData'
        for p={'FILENAME', 'SELFRAMES'}
            p=p{1};
            if ~isfield(loadedStruct,p)
                errormsg = sprintf('The choosen file doesn''t seem to be a myProcessingData file. \n It doesn''t have the %s field', p);
                if msg; errordlg(errormsg); end
                tf=0;
                return
            end
        end        
end
tf=1;
end

function dealWithNewMyScriptData(newFileString)
%whenever path to myScriptData is changed to newFileString, this function
% - checks if the path to new file & the file itself is correct
% - converts old myScriptData files to the new rungroup format
% - updates .SCRIPTDATA etc
% - updates figure


    global myScriptData myProcessingData
    oldMyProcessingDataPath=myScriptData.DATAFILE;
    [path, filename, ext]=fileparts(newFileString);
    if isempty(newFileString)
        errordlg('The myScriptData field mustn''t be empty.')
        myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
        error('ERROR')                
    elseif ~exist(path,'dir') && ~isempty(path)           
        errordlg('specified path doesn''t exist')
        myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
        error('ERROR')
    elseif ~strcmp('.mat',ext)
        errordlg('Specified path must end with ''.mat''')
        myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
        error('ERROR')
    elseif exist(newFileString,'file')
        if isCorrectFile(newFileString,'myScriptData')
            load(newFileString)
            old2newMyScriptData
            myScriptData.SCRIPTFILE=newFileString; 
        else
            myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
            error('ERROR')
        end
    else
        save(newFileString,'myScriptData')
    end
    
    %%%% check the myProcessingData specified in the new myScriptData
    if exist(myScriptData.DATAFILE,'file') && isCorrectFile(newFileString,'myProcessingScript','supressMessages') 
        load(myScriptData.DATAFILE)    
    else
        errordlg('This myScriptData contained the path to a non existend or wrong myProcessingData. Therefore the origial myProcessingData is kept. The new MyScriptData is still loaded.')
        myScriptData.DATAFILE=oldMyProcessingDataPath;
    end
    
    
    
    
    
    
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
    myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTMENU'));
    myUpdateACQFiles;
    myUpdateGroups; 
end

function   checkNewInput(handle, tag)
    global myScriptData myProcessingData
    switch tag
        case 'SCRIPTFILE'
            pathstring=get(handle,'string');
            dealWithNewMyScriptData(pathstring);
         case 'DATAFILE'
            %if scriptfiel edit text is changed, check if new string is
            %valid. if yes, check if it exists and load it, else, save
            %myScriptdata with new specified string as filename
            pathstring=get(handle,'string');
            [path filename ext]=fileparts(pathstring);
            if isempty(pathstring)
                errordlg('This field mustn''t be empty.')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')             
            elseif ~exist(path,'dir') && ~isempty(path)           
                errordlg('specified path doesn''t exist')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')
            elseif ~strcmp('.mat',ext)
                errordlg('specified path must end with ''.mat''')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')
            else
                if exist(pathstring,'file')
                    if isCorrectFile(pathstring,'myProcessingData')
                        load(pathstring)
                    else
                        myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                        error('ERROR')
                    end
                else
                    save(pathstring,'myProcessingData')
                end
            end
        case {'ACQDIR', 'MATODIR'}
            pathstring=get(handle,'string');
            if ~exist(pathstring,'dir')
                errordlg('Specified path doesn''t exist.')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')
            end
        case {'CALIBRATIONFILE', 'RUNGROUPMAPPINGFILE'}
            pathstring=get(handle,'string');
            if ~exist(pathstring,'file') && ~isempty(pathstring)
                errordlg('Specified file doesn''t exist.')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')
            end
        case 'GROUPNAME'
            newGroupName=get(handle,'string');
            existingGroups=myScriptData.GROUPNAME{myScriptData.RUNGROUPSELECT};
            
            existingGroups(myScriptData.GROUPSELECT)=[];
            if ~isempty(find(ismember(existingGroups,newGroupName), 1))
                errordlg('A group with the same groupname already exists.')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR')
            end
            if isempty(newGroupName)
                errordlg('Group name mustn''t be empty.')
                myUpdateFigure(findobj(allchild(0),'tag','PROCESSINGSCRIPTSETTINGS'));
                error('ERROR') 
            end
    end  
end

function old2newMyScriptData()
%convert old myScriptData without rungroups to the new format

    global myScriptData
    defaultsettings=getDefaultSettings;
    
    
    
   
    
    %%%%% make sure myScriptData only has the fields specified in default
    %%%%% settings and no unnecessary fields
    mappingfile='';
    if isfield(myScriptData,'MAPPINGFILE'), mappingfile=myScriptData.MAPPINGFILE; end  %remember the mappingfile, before that information is deleted
    oldfields=fieldnames(myScriptData);
    fields2beRemoved=setdiff(oldfields,defaultsettings(1:3:end));
    myScriptData=rmfield(myScriptData,fields2beRemoved);
    
    
    %%%% now set .DEFAULT and TYPE and add missing fields that are
    %%%% unrelated to (run)groups
    myScriptData.DEFAULT=struct();
    myScriptData.TYPE=struct();
    for p=1:3:length(defaultsettings)
        myScriptData.DEFAULT.(defaultsettings{p})=defaultsettings{p+1};
        myScriptData.TYPE.(defaultsettings{p})=defaultsettings{p+2};
        if ~isfield(myScriptData,defaultsettings{p}) && ~(strncmp(defaultsettings{p+2},'group',5) || strncmp(defaultsettings{p+2},'rungroup',8))
            myScriptData.(defaultsettings{p})=defaultsettings{p+1};
        end
    end
    
    
    %%%% fix some problems with old myScriptData
    if ~isempty(myScriptData.GROUPNAME)
        if ~iscell(myScriptData.GROUPNAME{1})  % if it is an old myScriptData
            len=length(myScriptData.GROUPNAME);
            for p=1:3:length(defaultsettings)
                if strncmp(myScriptData.TYPE.(defaultsettings{p}),'group',5) && (length(myScriptData.(defaultsettings{p})) <len)
                    myScriptData.defaultsettings{p}(1:len)=defaultsettings{p+1};
                end
            end
        end
    end
                    
                
    
    
    
    %%%% convert 'GROUP..' fields into new format
    fn=fieldnames(myScriptData.TYPE);
    rungroupAdded=0;
    for p=1:length(fn)
        if strncmp(myScriptData.TYPE.(fn{p}),'group',5)            
            if ~isempty(myScriptData.(fn{p}))  
                if ~iscell(myScriptData.(fn{p}){1})
                    myScriptData.(fn{p})={myScriptData.(fn{p})};
                    if ~rungroupAdded, rungroupAdded=1; end
                end
            end
        end   
    end


    %%%% create the 'RUNGROUP..'  fields, if there aren't there yet.
    for p=1:3:length(defaultsettings)
        if strncmp(defaultsettings{p+2},'rungroup',8)
            if ~isfield(myScriptData, defaultsettings{p})
                if rungroupAdded
                    myScriptData.(defaultsettings{p})={defaultsettings{p+1}};
                else
                    myScriptData.(defaultsettings{p})={};
                end
            end   
        end
    end
    
    if ~isempty(mappingfile) %if myScriptData.MAPPINFILE existed, make that mappinfile the mappinfile for all rungroups
            myScriptData.RUNGROUPMAPPINGFILE=cell(1,length(myScriptData.RUNGROUPNAMES));
            [myScriptData.RUNGROUPMAPPINGFILE{:}]=deal(mappingfile);
            
            myScriptData.RUNGROUPCALIBRATIONMAPPINGUSED=cell(1,length(myScriptData.RUNGROUPNAMES));
            [myScriptData.RUNGROUPCALIBRATIONMAPPINGUSED{:}]=deal('');
    end
    
    
    
    %%%% if there are no rungroups in old myScriptData, set all selected acq
    %%%% files as default for a newly created rungroup.
    if rungroupAdded
        myScriptData.RUNGROUPFILES={myScriptData.ACQFILES};
    end
    

    
    
    myScriptData.RUNGROUPSELECT=length(myScriptData.RUNGROUPNAMES);
    if myScriptData.RUNGROUPSELECT > 0
        myScriptData.GROUPSELECT=length(myScriptData.GROUPNAME{myScriptData.RUNGROUPSELECT});
    else
        myScriptData.GROUPSELECT=0;
    end
    
end


function defaultsettings=getDefaultSettings
    defaultsettings = { 'PWD','','file',...
                    'FILES2SPLIT',[],'vector',...
                    'SPLITFILECONTAIN','','string',...
                    'SPLITDIR','','string',...
                    'SPLITINTERVAL','', 'string',...
                    'CALIBRATE_SPLIT',1,'integer',...
                    'PACINGLEAD',[],'double', ...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'CALIBRATIONACQUSED','','vector',...
                    'SCRIPTFILE','myScriptData.mat','file',...
                    'ACQLABEL','','string',...
                    'ACQLISTBOX','','listbox',...
                    'ACQFILES',[],'listboxedit',...
                    'ACQPATTERN','','string',...
                    'ACQFILENUMBER',[],'vector',...
                    'ACQINFO',{},'string',...
                    'ACQFILENAME',{},'string',...
                    'ACQNUM',0,'integer',...
                    'DATAFILE','myProcessingData.mat','file',...
                    'TSDFDIR','autoprocessing','file',...
                    'ACQDIR','','file',...
                    'ACQCONTAIN','','string',...
                    'ACQCONTAINNOT','','string',...
                    'ACQEXT','.acq,.ac2','string',...   
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
                    'DO_DETECT',1,'bool',...
                    'DO_DETECT_USER',1,'bool',...
                    'DO_DETECT_LOADTSDFC',1,'bool',...
                    'DO_DETECT_AUTO',1,'bool',...
                    'DO_DETECT_PACING',1,'bool',...
                    'DO_LAPLACIAN_INTERPOLATE',1,'bool',...
                    'DO_INTERPOLATE',0,'bool',...
                    'DO_INTEGRALMAPS',1,'bool',...
                    'DO_ACTIVATIONMAPS',1,'bool',...
                    'DO_FILTER',0,'bool',...
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
                    'ALIGNSTART','detect','integer',...
                    'ALIGNSIZE','detect','integer',...
                    'ALIGNMETHOD',1,'integer',...
                    'ALIGNSTARTENABLE',1,'integer',...
                    'ALIGNSIZEENABLE',1,'integer',...
                    'ALIGNRMSTYPE',1,'integer',...
                    'ALIGNTHRESHOLD',0.9,'double',...
                    'AVERAGEMETHOD',1,'integer',...
                    'AVERAGERMSTYPE',1,'integer',...
                    'AVERAGECHANNEL',1,'integer',...
                    'AVERAGEMAXN',5,'integer',...
                    'AVERAGEMAXRE',0.1,'double',...
                    'KEEPBADLEADS',1,'integer',...
                    'FIDSLOOPFIDS',1,'integer',...
                    'LOOP_ORDER',1,'vector',...
                    'FIDSAUTOACT',1,'integer',...
                    'FIDSAUTOREC',1,'integer',...
                    'FIDSAUTOPEAK',1,'integer',...
                    'FIDSACTREV',0,'integer',...
                    'FIDSRECREV',0,'integer',...
                    'TSDFODIR','tsdf','string',...
                    'TSDFODIRON',1,'bool',...
                    'MATODIR','','string',...
                    'ACTWIN',7,'integer',...
                    'ACTDEG',3,'integer',...
                    'ACTNEG',1,'integer',...
                    'RECWIN',7,'integer',...
                    'RECDEG',3,'integer',...
                    'RECNEG',0,'integer',...
                    'ALEADNUM',1,'integer',...
                    'ADOFFSET',0.2,'double',...
                    'ADISPLAYTYPE',1,'integer',...
                    'ADISPLAYOFFSET',1,'integer',...
                    'ADISPLAYGRID',1,'integer',...
                    'ADISPLAYGROUP',1,'vector',...
                    'OPTICALLABEL','','string',...
                    'FILTERFILE','','string',...
                    'FILTERNAME','NONE','string',...
                    'FILTERNAMES',{'NONE'},'string',...
                    'FILTER',[],'string',...
                    'INPUTTSDFC','','string',...
                    'RUNGROUPSELECT',0,'selectR',... 
                    'RUNGROUPNAMES','RUNGROUP', 'rungroupstring',...
                    'RUNGROUPFILES',[],'rungroupvector'... 
                    'RUNGROUPMAPPINGFILE','','rungroupstring',...
                    'RUNGROUPCALIBRATIONMAPPINGUSED','','rungroupstring',...
                    'RUNGROUPFILECONTAIN', '', 'rungroupstring'    %for the SelectRungroupfiles 'contains' button
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
