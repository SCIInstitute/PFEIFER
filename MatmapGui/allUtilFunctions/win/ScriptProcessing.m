function ScriptProcessing(varargin)

    if nargin > 1,
        feval(varargin{1},varargin{2:end});
    else
        if nargin == 1,
            Init(varargin{1});
        else
            Init;
        end
    end
return

function Init(filename)

    global SCRIPT;
    InitScript;

    if nargin == 0,
        filename = SCRIPT.SCRIPTFILE;
    end
    
    if exist(filename,'file'),
        load(filename,'-mat');
    
        if exist('script','var'),
            fn = fieldnames(script)
            for p = 1:length(fn),
                SCRIPT = setfield(SCRIPT,fn{p},getfield(script,fn{p}));
            end
        end
    end

    winScriptProcessingSettings
    
    return
    
    
function InitScript

%%% DEFAULT SETUP %%%%

defaultsettings = { 'MAPPINGFILE','','file', ...
                    'PACINGLEAD',[],'double', ...
                    'CALIBRATIONFILE','','file', ...
                    'CALIBRATIONACQ','','vector', ...
                    'SCRIPTFILE','processingscript.mat','file',...
                    'ACQLABEL','','string',...
                    'DATAFILE','processingdata.mat','file',...
                    'TSDFDIR','autoprocessing','file',...
                    'GROUPNAME',{},'groupstring',...
                    'GROUPLEADS',{},'groupvector',...
                    'GROUPEXTENSON',{},'groupstring',...
                    'GROUPTSDFC',{},'groupfile',...
                    'GROUPGEOM',{},'groupfile',...
                    'GROUPCHANNELS',{},'groupfile',...
                    'GROUPBADLEADSFILE',{},'groupfile',...
                    'GROUPBADLEADS',{},'groupvector',...
                    'GROUPSELECT',0,'select' };
    global SCRIPT;

    SCRIPT = [];
    SCRIPT.DEFAULT = defaultsettings;
    SCRIPT.TYPE = [];

    for p=1:3:length(defaultsettings),
        SCRIPT = setfield(SCRIPT,defaultsettings{p},defaultsettings{p+1});
        SCRIPT.TYPE = setfield(SCRIPT.TYPE,defaultsettings{p},defaultsettings{p+2});
    end

return

function


function ScriptSettings(handle)

    global SCRIPT;
    
    if isempty(SCRIPT),
        InitScript;    
    end
    
    type = get(handle,'type');
    
    switch type,
        case 'figure',
            fn = fieldnames(SCRIPT);
            for p=length(fn),
                obj = findobj(allchild(handle),'tag',fn{p});
                if ~isempty(obj),
                    objtype = getfield(SCRIPT.TYPE,fn{p});
                    switch objtype,
                        case {'file','string'},
                            set(obj,'string',getfield(SCRIPT,fn{p}));
                        case {'double','vector'},
                            set(obj,'string',num2str(getfield(SCRIPT,fn{p})));
                        case {'bool','select'},
                            set(obj,'value',getfield(SCRIPT,fn{p}));
                            selectnames = SCRIPT.GROUPNAME;
                            selectnames{end} = 'NEW GROUP';
                            set(obj,'string',selectnames);
                        case {'groupfile','groupstring','groupdouble','groupvector','groupbool'},
                            group = SCRIPT.GROUPSELECT;
                            if (group > 0),
                                set(obj,'enable','on');
                                cellarray = getfield(SCRIPT,fn{p});
                                if length(cellarray) <= group, 
                                    switch objtype(6:end),
                                        case {'file','string'},
                                            set(obj,'string',cellarray{group});
                                        case {'double','vector'},
                                            set(obj,'string',num2str(cellarray{group}));
                                        case {'bool'},
                                            set(obj,'value',cellarray{group});
                                    end
                                else
                                    set(obj,'string','','value',0);
                                end
                            else
                                set(obj,'enable','off');
                            end
                    end
                end
            end
        case 'uicontrol',
            tag = get(handle,'tag');
            if isfield(SCRIPT.TYPE,tag),
                objtype = getfield(SCRIPT.TYPE,tag);
            else
                objtype = 'string';
            end
            switch objtype
                case {'file','string'},
                    SCRIPT = setfield(SCRIPT,tag,get(handle,'string'));
                    if strcmp(tag,'GROUPNAME') == 1,
                        parent = get(handle,'parent');
                        ScriptSettings(parent); 
                    end
                case {'double','vector'},
                    SCRIPT = setfield(SCRIPT,tag,str2num(get(handle,'string')));
                case 'bool'
                    SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
                case 'select'
                    SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
                    parent = get(handle,'parent');
                    ScriptSettings(parent);
                case {'groupfile','groupstring','groupdouble','groupvector','groupbool'},
                    group = SCRIPT.GROUPSELECT;
                    if (group > 0),
                        if isfield(SCTRIPT,tag),
                            cellarray = getfield(SCRIPT,tag);
                        else
                            cellarray = {};
                        end
                        switch objtype(6:end)
                            case {'file','string'}
                                cellarray{group} = get(obj,'string');
                            case {'double','vector'}
                                cellarray{group} = str2num(get(obj,'string'));
                            case {'bool'}
                                cellarray{group} = get(obj,'value');
                        end
                        SCRIPT = setfield(SCRIPT,tag,cellarray);
                    end
            end
    end
            
    return
    



