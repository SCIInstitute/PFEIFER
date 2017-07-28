function handle = FidsDisplay(varargin)

% FUNCTION FidsDisplay()
%
% DESCRIPTION
% This is an internal function, that maintains the fiducial selection
% window. This function is called from ProcessingScript and should not be
% used without the GUI of the ProcessingScript.
%
% INPUT
% none - part of the GUI system
%
% OUTPUT
% none - part of the GUI system
%
% NOTE
% All communication in this unit works via the globals SCRIPT SCRIPTDATA
% FIDSDISPLAY. Do not alter any of these globals directly from the
% commandline

    if nargin > 0,
        
        if ischar(varargin{1}),
            feval(varargin{1},varargin{2:end});
        else
            if nargin > 1,
                handle = Init(varargin{1},varargin{2});
            else
                handle = Init(varargin{1});
            end
        end
    else    
        handle = Init;    
    end
    
return


function Navigation(handle,mode)

    global SCRIPT;
    
    switch mode
    case {'prev','next','stop','redo','back'},
        SCRIPT.NAVIGATION = mode;
        set(handle,'DeleteFcn','');
        delete(handle);
    case {'apply'}
  
        EventsToFids;
        SCRIPT.NAVIGATION = 'apply';
        set(handle,'DeleteFcn','');
        delete(handle);
        
    otherwise
        error('unknown navigation command');
    end

    return

function SetupNavigationBar(handle)

    global SCRIPT TS;
    tsindex = SCRIPT.CURRENTTS;
    
    t = findobj(allchild(handle),'tag','NAVFILENAME');
    set(t,'string',['FILENAME: ' TS{tsindex}.filename]);
    t = findobj(allchild(handle),'tag','NAVLABEL');
    set(t,'string',['FILELABEL: ' TS{tsindex}.label]);
    t = findobj(allchild(handle),'tag','NAVACQNUM');
    set(t,'string',sprintf('ACQNUM: %d',SCRIPT.ACQNUM));
    t = findobj(allchild(handle),'tag','NAVTIME');
    if isfield(TS{tsindex},'time'),
        set(t,'string',['TIME: ' TS{tsindex}.time]);
    end
    return

    
function handle = Init(tsindex,mode)

    global SCRIPT;

    if nargin > 0,
        SCRIPT.CURRENTTS = tsindex;
    end
    if nargin < 2,
        mode = 1;
    end

    handle = winFidsDisplay;
    InitFiducials(handle,mode);
    InitDisplayButtons(handle);
    InitMouseFunctions(handle);
    
    SetupNavigationBar(handle);
    SetupDisplay(handle);
    UpdateDisplay(handle);
    
    return

function SetFids(handle)

    global FIDSDISPLAY;

    window = get(handle,'parent');
    tag = get(handle,'tag');
    switch tag,
        case 'FIDSGLOBAL',
            FIDSDISPLAY.SELFIDS = 1;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',1);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',0);
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',0);
        case 'FIDSGROUP',
            FIDSDISPLAY.SELFIDS = 2;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',0);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',1);
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',0);            
        case 'FIDSLOCAL',
            FIDSDISPLAY.SELFIDS = 3;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',0);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',0); 
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',1);
    end
    DisplayFiducials;
    
    return
 
function SelFidsType(handle)    
     
    global FIDSDISPLAY;
    FIDSDISPLAY.NEWFIDSTYPE = FIDSDISPLAY.EVENTS{1}.num(get(handle,'value'));
    return
    
function InitFiducials(handle,mode)

    global FIDSDISPLAY SCRIPT TS;

    FIDSDISPLAY.MODE = 1;
    if nargin == 2,
        FIDSDISPLAY.MODE = mode;
    end    
    
     if FIDSDISPLAY.MODE == 1,
        SCRIPT.DISPLAYTYPEF = SCRIPT.DISPLAYTYPEF1;
    else
        SCRIPT.DISPLAYTYPEF = SCRIPT.DISPLAYTYPEF2;
    end    
    
    % for all fiducial types
  
    events.dt = 5/1000;
    events.maxn = 1;
    events.value = [];
    events.type = [];
    events.handle = [];
    events.axes = findobj(allchild(handle),'tag','AXES');
    events.colorlist = {[1 0.7 0.7],[0.7 1 0.7],[0.7 0.7 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[1 0 1],[1 1 0],[0 1 1],[1 1 .8]};
    events.colorlistgray = {[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.5 0.5 0.5]};
    events.typelist = [2 2 2 1 1 3 1 1 1 2 ];
    events.linestyle = {'-','-','-','-.','-.','-','-','-','-','-'};
    events.linewidth = {1,1,1,2,2,1,2,2,2,2,1};
    events.next = [2 3 9 5 5 6 7 8 6 6];
    events.num = [1 2 3 4 5 6 7 8 9 10];
    

    FIDSDISPLAY.SELFIDS = 1;
    if FIDSDISPLAY.MODE == 1, 
        FIDSDISPLAY.NEWFIDSTYPE = 2;
    else
        if SCRIPT.DO_DELTAFOVERF == 1,
            FIDSDISPLAY.NEWFIDSTYPE = 10;
        else
            FIDSDISPLAY.NEWFIDSTYPE = 6;           
        end
    end
    fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Baseline','Activation','Recovery','Reference','Fbase'}; 
    events.num = [1:10];
    if FIDSDISPLAY.MODE == 2,
        fidslist = {'Baseline','Fbase'};
        events.num = [6 10];
    end
    FIDSDISPLAY.NUMTYPES = length(fidslist);
    button = findobj(allchild(handle),'tag','FIDSTYPE');
    set(button,'value',find(events.num == FIDSDISPLAY.NEWFIDSTYPE),'string',fidslist);
    
    FIDSDISPLAY.SELFIDS = 1;
    set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
    set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
    set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
    

    if FIDSDISPLAY.MODE == 2,
        events.num = [6 10];    
    end
    events.sel = 0;
    events.sel2 = 0;
    events.sel3 = 0;
     
    events.class = 1; FIDSDISPLAY.EVENTS{1} = events;  % GLOBAL EVENTS
    events.maxn = length(SCRIPT.GROUPLEADS);
    events.class = 2; FIDSDISPLAY.EVENTS{2} = events;  % GROUP EVENTS
    events.maxn = size(TS{SCRIPT.CURRENTTS}.potvals,1);
    events.class = 3; FIDSDISPLAY.EVENTS{3} = events;  % LOCAL EVENTS

    FidsToEvents;
    
    return

function FidsButton(handle)

    global SCRIPT
    
    tag = get(handle,'tag');
    switch tag,
        case {'FIDSLOOPFIDS','FIDSAUTOREC','FIDSAUTOACT'}
            SCRIPT= setfield(SCRIPT,tag,get(handle,'value'));
        case {'ACTNEG','RECNEG'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value')-1);
            parent = get(handle,'parent');
            UpdateDisplay(parent);        
            
        case {'ACTWIN','ACTDEG','RECWIN','RECDEG'}
            SCRIPT = setfield(SCRIPT,tag,str2num(get(handle,'string')));
            parent = get(handle,'parent');
            UpdateDisplay(parent);             
            
    end
    return
    
function DisplayFiducials

    global FIDSDISPLAY SCRIPT;
    
    % GLOBAL EVENTS
    events = FIDSDISPLAY.EVENTS{1};
     if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    ywin = FIDSDISPLAY.YWIN;
    if FIDSDISPLAY.SELFIDS == 1, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    for p=1:size(events.value,2),
        switch events.typelist(events.type(p)),
            case 1, % normal fiducial
                v = events.value(1,p,1);
                events.handle(1,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ywin,'Color',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            case {2,3}, % interval fiducial/ fixed intereval fiducial
                v = events.value(1,p,1);
                v2 = events.value(1,p,2);
                events.handle(1,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ywin ywin([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
        end
    end
    FIDSDISPLAY.EVENTS{1} = events;           

    if SCRIPT.DISPLAYTYPEF == 1, return; end
    
    % GROUP FIDUCIALS
    
    events = FIDSDISPLAY.EVENTS{2};
    if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    if FIDSDISPLAY.SELFIDS == 2, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    numchannels = size(FIDSDISPLAY.SIGNAL,1);
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
 
    index = chstart:chend;
    
    for q=1:max(FIDSDISPLAY.LEADGROUP),
        nindex = index(find(FIDSDISPLAY.LEADGROUP(index)==q));
        if isempty(nindex), continue; end
        ydata = numchannels-[min(nindex)-1 max(nindex)];
        
        
        for p=1:size(events.value,2),
            switch events.typelist(events.type(p)),
                case 1, % normal fiducial
                    v = events.value(q,p,1);
                    events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                case {2,3}, % interval fiducial/ fixed intereval fiducial
                    v = events.value(q,p,1);
                    v2 = events.value(q,p,2);
                    events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            end
        end
    end
    FIDSDISPLAY.EVENTS{2} = events;   
    
    if SCRIPT.DISPLAYTYPEF == 2, return; end
    
    % LOCAL FIDUCIALS
    
    events = FIDSDISPLAY.EVENTS{3};
     if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    if FIDSDISPLAY.SELFIDS == 3, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    index = FIDSDISPLAY.LEAD(chstart:chend);
    
    for q=index,
        ydata = numchannels-[q-1 q];
    
        for p=1:size(events.value,2),
            switch events.typelist(events.type(p)),
                case 1, % normal fiducial
                    v = events.value(q,p,1);
                    events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                case {2,3}, % interval fiducial/ fixed intereval fiducial
                    v = events.value(q,p,1);
                    v2 = events.value(q,p,2);
                    events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            end
        end
    end
    FIDSDISPLAY.EVENTS{3} = events;   
    
    return
    
  function InitMouseFunctions(handle)

    global FIDSDISPLAY;
   
    if ~isfield(FIDSDISPLAY,'XWIN'), FIDSDISPLAY.XWIN = [0 1]; end
    if ~isfield(FIDSDISPLAY,'YWIN'), FIDSDISPLAY.YWIN = [0 1]; end
    if ~isfield(FIDSDISPLAY,'XLIM'), FIDSDISPLAY.XLIM = [0 1]; end
    if ~isfield(FIDSDISPLAY,'YLIM'), FIDSDISPLAY.YLIM = [0 1]; end
    if isempty(FIDSDISPLAY.YWIN), FIDSDISPLAY.YWIN = [0 1]; end
    
    FIDSDISPLAY.ZOOM = 0;
    FIDSDISPLAY.SELEVENTS = 1;
    FIDSDISPLAY.ZOOMBOX =[];
    FIDSDISPLAY.P1 = [];
    FIDSDISPLAY.P2 = [];
    set(handle,'WindowButtonDownFcn','FidsDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','FidsDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','FidsDisplay(''ButtonUp'',gcbf)','KeyPressFcn','FidsDisplay(''KeyPress'',gcbf)','Interruptible','off');
    get(handle)       
    
    return
           
function InitDisplayButtons(handle),

    global SCRIPT FIDSDISPLAY;

    button = findobj(allchild(handle),'tag','DISPLAYTYPEF');
    set(button,'string',{'Global RMS','Group RMS','Individual'},'value',SCRIPT.DISPLAYTYPEF);
    
    button = findobj(allchild(handle),'tag','DISPLAYOFFSET');
    set(button,'string',{'Offset ON','Offset OFF'},'value',SCRIPT.DISPLAYOFFSET);
    
    button = findobj(allchild(handle),'tag','DISPLAYLABELF');
    set(button,'string',{'Label ON','Label OFF'},'value',SCRIPT.DISPLAYLABELF);
    
    button = findobj(allchild(handle),'tag','DISPLAYPACINGF');
    set(button,'string',{'Pacing ON','Pacing OFF'},'value',SCRIPT.DISPLAYPACINGF);
    
    button = findobj(allchild(handle),'tag','DISPLAYGRIDF');
    set(button,'string',{'No grid','Coarse grid','Fine grid'},'value',SCRIPT.DISPLAYGRIDF);
    
    button = findobj(allchild(handle),'tag','DISPLAYSCALINGF');
    set(button,'string',{'Local','Global'},'value',SCRIPT.DISPLAYSCALINGF);

    button = findobj(allchild(handle),'tag','ACTWIN');
    set(button,'string',num2str(SCRIPT.ACTWIN));
   
    button = findobj(allchild(handle),'tag','ACTDEG');
    set(button,'string',num2str(SCRIPT.ACTDEG));

    button = findobj(allchild(handle),'tag','RECWIN');
    set(button,'string',num2str(SCRIPT.RECWIN));
   
    button = findobj(allchild(handle),'tag','RECDEG');
    set(button,'string',num2str(SCRIPT.RECDEG));    
    
    button = findobj(allchild(handle),'tag','ACTNEG');
    set(button,'value',SCRIPT.ACTNEG+1); 
    
    button = findobj(allchild(handle),'tag','RECNEG');
    set(button,'value',SCRIPT.RECNEG+1);    
    
    button = findobj(allchild(handle),'tag','DISPLAYGROUPF');
    group = SCRIPT.GROUPNAME;
    if (isempty(SCRIPT.DISPLAYGROUPF))|(SCRIPT.DISPLAYGROUPF == 0),
        SCRIPT.DISPLAYGROUPF = 1:length(group);
    end
    SCRIPT.DISPLAYGROUPF = intersect(SCRIPT.DISPLAYGROUPF,[1:length(group)]);
    set(button,'string',group,'max',length(group),'value',SCRIPT.DISPLAYGROUPF);

    if ~isfield(FIDSDISPLAY,'XWIN'), FIDSDISPLAY.XWIN = []; end
    if ~isfield(FIDSDISPLAY,'YWIN'), FIDSDISPLAY.YWIN = []; end
    
    return
    
function DisplayButton(handle)

    global SCRIPT;
    
    tag = get(handle,'tag');
    switch tag
        case {'DISPLAYTYPEF','DISPLAYOFFSET','DISPLAYSCALINGF','DISPLAYPACINGF','DISPLAYGROUPF'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            SetupDisplay(parent);
            UpdateDisplay(parent);       
 
        case {'DISPLAYLABELF','DISPLAYGRIDF'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            UpdateDisplay(parent); 
      
    end
   return
 
function SetupDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    global TS SCRIPT FIDSDISPLAY;
    
    tsindex = SCRIPT.CURRENTTS;
    
    numframes = size(TS{tsindex}.potvals,2);
    FIDSDISPLAY.TIME = [1:numframes]*0.001;
    FIDSDISPLAY.XLIM = [1 numframes]*0.001;

%    if isempty(FIDSDISPLAY.XWIN);
        FIDSDISPLAY.XWIN = [median([0 FIDSDISPLAY.XLIM]) median([3 FIDSDISPLAY.XLIM])];
        %    else
        %FIDSDISPLAY.XWIN = [median([FIDSDISPLAY.XWIN(1) FIDSDISPLAY.XLIM]) median([FIDSDISPLAY.XWIN(2) FIDSDISPLAY.XLIM])];
        %end
    
    FIDSDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
    FIDSDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
    FIDSDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');
    
    SLICEDISPALY.PACING = [];
    if isfield(TS{tsindex},'pacing'),
        FIDSDISPLAY.PACING = TS{tsindex}.pacing;
    else
        FIDSDISPLAY.PACING = []; 
    end
    
    
    groups = SCRIPT.DISPLAYGROUPF;
    numgroups = length(groups);
    
    FIDSDISPLAY.NAME ={};
    FIDSDISPLAY.GROUPNAME = {};
    FIDSDISPLAY.GROUP = [];
    FIDSDISPLAY.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};
    
    if FIDSDISPLAY.MODE == 1,
        SCRIPT.DISPLAYTYPEF1 = SCRIPT.DISPLAYTYPEF;
    else
        SCRIPT.DISPLAYTYPEF2 = SCRIPT.DISPLAYTYPEF;
    end    
    
    switch SCRIPT.DISPLAYTYPEF,
        case 1,
            ch  = []; 
            for p=groups, 
                leads = SCRIPT.GROUPLEADS{p};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                ch = [ch leads(index)]; 
            end 
            FIDSDISPLAY.SIGNAL = sqrt(mean(TS{tsindex}.potvals(ch,:).^2));
            FIDSDISPLAY.SIGNAL = FIDSDISPLAY.SIGNAL-min(FIDSDISPLAY.SIGNAL);
            FIDSDISPLAY.LEADINFO = 0;
            FIDSDISPLAY.GROUP = 1;
            FIDSDISPLAY.LEAD = 0;
            FIDSDISPLAY.LEADGROUP = 0;
            FIDSDISPLAY.NAME = {'Global RMS'};
            FIDSDISPLAY.GROUPNAME = {'Global RMS'};
            set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSGROUP'),'enable','off');
            set(findobj(allchild(handle),'tag','FIDSLOCAL'),'enable','off');
            if FIDSDISPLAY.SELFIDS > 1, 
                FIDSDISPLAY.SELFIDS = 1;
                set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
                set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
                set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
            end
            
        case 2,
            FIDSDISPLAY.SIGNAL = zeros(numgroups,numframes);
            for p=1:numgroups, 
                leads = SCRIPT.GROUPLEADS{groups(p)};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                FIDSDISPLAY.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
                FIDSDISPLAY.SIGNAL(p,:) = FIDSDISPLAY.SIGNAL(p,:)-min(FIDSDISPLAY.SIGNAL(p,:));
                FIDSDISPLAY.NAME{p} = [SCRIPT.GROUPNAME{groups(p)} ' RMS']; 
            end
            FIDSDISPLAY.GROUPNAME = FIDSDISPLAY.NAME;
            FIDSDISPLAY.GROUP = 1:numgroups;
            FIDSDISPLAY.LEAD = 0*FIDSDISPLAY.GROUP;
            FIDSDISPLAY.LEADGROUP = groups;
            FIDSDISPLAY.LEADINFO = zeros(numgroups,1);
            set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSGROUP'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSLOCAL'),'enable','off');
            if FIDSDISPLAY.SELFIDS > 2, 
                FIDSDISPLAY.SELFIDS = 1;
                set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
                set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
                set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
            end
            
        case 3,
            FIDSDISPLAY.GROUP =[];
            FIDSDISPLAY.NAME = {};
            FIDSDISPLAY.LEAD = [];
            FIDSDISPLAY.LEADGROUP = [];
            ch  = []; 
            for p=groups, 
                ch = [ch SCRIPT.GROUPLEADS{p}]; 
                FIDSDISPLAY.GROUP = [FIDSDISPLAY.GROUP p*ones(1,length(SCRIPT.GROUPLEADS{p}))];
                FIDSDISPLAY.LEADGROUP = [FIDSDISPLAY.GROUP SCRIPT.GROUPLEADS{p}];
                FIDSDISPLAY.LEAD = [FIDSDISPLAY.LEAD SCRIPT.GROUPLEADS{p}];
                for q=1:length(SCRIPT.GROUPLEADS{p}), FIDSDISPLAY.NAME{end+1} = sprintf('%s # %d',SCRIPT.GROUPNAME{p},q); end 
            end
            for p=1:length(groups),
                FIDSDISPLAY.GROUPNAME{p} = [SCRIPT.GROUPNAME{groups(p)}]; 
            end 
            FIDSDISPLAY.SIGNAL = TS{tsindex}.potvals(ch,:);
            FIDSDISPLAY.LEADINFO = TS{tsindex}.leadinfo(ch);
            set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSGROUP'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSLOCAL'),'enable','on');
    end
        
    switch SCRIPT.DISPLAYSCALINGF,
        case 1,
            k = max(abs(FIDSDISPLAY.SIGNAL),[],2);
            [m,n] = size(FIDSDISPLAY.SIGNAL);
            k(find(k==0)) = 1;
            s = sparse(1:m,1:m,1./k,m,m);
            FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
        case 2,
            k = max(abs(FIDSDISPLAY.SIGNAL(:)));
            [m,n] = size(FIDSDISPLAY.SIGNAL);
            if k > 0,
                s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
                FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
            end
        case 3,
            [m,n] = size(FIDSDISPLAY.SIGNAL);
            k = ones(m,1);
            for p=groups,
                ind = find(FIDSDISPLAY.GROUP == p);
                k(ind) = max(max(abs(FIDSDISPLAY.SIGNAL(ind,:)),[],2));
            end
            s = sparse(1:m,1:m,1./k,m,m);
            FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
    end
    
    if SCRIPT.DISPLAYTYPEF == 3,
        FIDSDISPLAY.SIGNAL = 0.5*FIDSDISPLAY.SIGNAL+0.5;
    end
    
    numsignal = size(FIDSDISPLAY.SIGNAL,1);
    for p=1:numsignal,
        FIDSDISPLAY.SIGNAL(p,:) = FIDSDISPLAY.SIGNAL(p,:)+(numsignal-p);
    end
    
    
    FIDSDISPLAY.YLIM = [0 numsignal];
    FIDSDISPLAY.YWIN = [max([0 numsignal-6]) numsignal];
    
    set(handle,'pointer',pointer);
    
    return

function UpdateSlider(handle)

    global FIDSDISPLAY;

    tag = get(handle,'tag');
    value = get(handle,'value');
    switch tag
        case 'SLIDERX'
            xwin = FIDSDISPLAY.XWIN;
            xlim = FIDSDISPLAY.XLIM;
            winlen = xwin(2)-xwin(1);
            limlen = xlim(2)-xlim(1);
            xwin(1) = median([xlim value*(limlen-winlen)+xlim(1)]);
            xwin(2) = median([xlim xwin(1)+winlen]);
            FIDSDISPLAY.XWIN = xwin;
       case 'SLIDERY'
            ywin = FIDSDISPLAY.YWIN;
            ylim = FIDSDISPLAY.YLIM;
            winlen = ywin(2)-ywin(1);
            limlen = ylim(2)-ylim(1);
            ywin(1) = median([ylim value*(limlen-winlen)+ylim(1)]);
            ywin(2) = median([ylim ywin(1)+winlen]);
            FIDSDISPLAY.YWIN = ywin;     
    end
    
    parent = get(handle,'parent');
    UpdateDisplay(parent);
    return;
    
    
function UpdateDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');

    global FIDSDISPLAY SCRIPT TS;
    
    axes(FIDSDISPLAY.AXES);
    cla;
    hold on;
    ywin = FIDSDISPLAY.YWIN;
    xwin = FIDSDISPLAY.XWIN;
    xlim = FIDSDISPLAY.XLIM;
    ylim = FIDSDISPLAY.YLIM;
    
    numframes = size(FIDSDISPLAY.SIGNAL,2);
    startframe = max([floor(1000*xwin(1)) 1]);
    endframe = min([ceil(1000*xwin(2)) numframes]);

    % DRAW THE GRID
    
    if SCRIPT.DISPLAYGRIDF > 1,
        if SCRIPT.DISPLAYGRIDF > 2,
            clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
            X = [clines; clines]; Y = ywin'*ones(1,length(clines));
            line(X,Y,'color',[0.9 0.9 0.9],'hittest','off');
        end
        clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(X,Y,'color',[0.5 0.5 0.5],'hittest','off');
    end

    if SCRIPT.DISPLAYPACINGF == 1,
        if  length(FIDSDISPLAY.PACING) > 0,
            plines = FIDSDISPLAY.PACING/1000;
            plines = plines(find((plines >xwin(1)) & (plines < xwin(2))));
            X = [plines; plines]; Y = ywin'*ones(1,length(plines));
            line(X,Y,'color',[0.55 0 0.65],'hittest','off','linewidth',2);    
        end
    end
    
    numchannels = size(FIDSDISPLAY.SIGNAL,1);
    if SCRIPT.DISPLAYOFFSET == 1,
        chend = numchannels - max([floor(ywin(1)) 0]);
        chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
    else
        chstart = 1;
        chend = numchannels;
    end
    
    for p=chstart:chend,
        k = startframe:endframe;
        color = FIDSDISPLAY.COLORLIST{FIDSDISPLAY.GROUP(p)};
        if FIDSDISPLAY.LEADINFO(p) > 0,
            color = [0 0 0];
            if FIDSDISPLAY.LEADINFO(p) > 3,
                color = [0.35 0.35 0.35];
            end
        end
        
        plot(FIDSDISPLAY.TIME(k),FIDSDISPLAY.SIGNAL(p,k),'color',color,'hittest','off');
        if (SCRIPT.DISPLAYLABELF == 1)&(chend-chstart < 30) & (FIDSDISPLAY.YWIN(2) >= numchannels-p+1),
            text(FIDSDISPLAY.XWIN(1),numchannels-p+1,FIDSDISPLAY.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
        end
    end
    
    set(FIDSDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);
    
    xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xlen < 0.001, xslider = 0.99999; else xslider = (xwin(1)-xlim(1))/xlen; end
    if xlen >= 0.001, xfill = (xwin(2)-xwin(1))/xlen; else xfill = 1000; end
    xinc = median([0.001 xfill/2 0.99999]);
    xfill = median([0.001 xfill 1000]);
    xslider = median([0 xslider 0.99999]);
    set(FIDSDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

    ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if ylen < 0.001, yslider = 0.99999; else yslider = ywin(1)/ylen; end
    if ylen >= 0.001, yfill = (ywin(2)-ywin(1))/ylen; else yfill =1000; end
    yinc = median([0.001 yfill/2 0.99999]);
    yfill = median([0.001 yfill 1000]);
    yslider = median([0 yslider 0.99999]);
    set(FIDSDISPLAY.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);

    FIDSDISPLAY.EVENTS{1}.handle = [];
    FIDSDISPLAY.EVENTS{2}.handle = [];
    FIDSDISPLAY.EVENTS{3}.handle = [];
    
    DisplayFiducials;
    
    set(handle,'pointer',pointer);
    
    return


    
    
   
function Zoom(handle)

    global FIDSDISPLAY;

    value = get(handle,'value');
    parent = get(handle,'parent');
    switch value
        case 0,
            set(parent,'WindowButtonDownFcn','FidsDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','FidsDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','FidsDisplay(''ButtonUp'',gcbf)','pointer','arrow');
            set(handle,'string','Zoom OFF');
            FIDSDISPLAY.ZOOM = 0;
        case 1,
            set(parent,'WindowButtonDownFcn','FidsDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','FidsDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','FidsDisplay(''ZoomUp'',gcbf)','pointer','crosshair');
            set(handle,'string','Zoom ON');
            FIDSDISPLAY.ZOOM = 1;
    end
    return
    
    
function ZoomDown(handle)

    global FIDSDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    if ~strcmp(seltype,'alt'),
        pos = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P1 = pos(1,1:2); P2 = P1;
        FIDSDISPLAY.P1 = P1;
        FIDSDISPLAY.P2 = P2;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    FIDSDISPLAY.ZOOMBOX = line('parent',FIDSDISPLAY.AXES,'XData',X,'YData',Y,'Erasemode','xor','Color','k','HitTest','Off');
   	    drawnow;
    else
        xlim = FIDSDISPLAY.XLIM; ylim = FIDSDISPLAY.YLIM;
        xwin = FIDSDISPLAY.XWIN; ywin = FIDSDISPLAY.YWIN;
        xsize = max([2*(xwin(2)-xwin(1)) 1]);
        FIDSDISPLAY.XWIN = [ median([xlim xwin(1)-xsize/4]) median([xlim xwin(2)+xsize/4])];
        ysize = max([2*(ywin(2)-ywin(1)) 1]);
        FIDSDISPLAY.YWIN = [ median([ylim ywin(1)-ysize/4]) median([ylim ywin(2)+ysize/4])];
        UpdateDisplay(handle);
    end
    return
    
function ZoomMotion(handle)
  
    global FIDSDISPLAY;
    if ishandle(FIDSDISPLAY.ZOOMBOX),
	    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([FIDSDISPLAY.XLIM point(1,1)]); P2(2) = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.P2 = P2;
        P1 = FIDSDISPLAY.P1;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    set(FIDSDISPLAY.ZOOMBOX,'XData',X,'YData',Y);
        drawnow;
    end
    return
    
function ZoomUp(handle)
   
    global FIDSDISPLAY;
    if ishandle(FIDSDISPLAY.ZOOMBOX),
        point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([FIDSDISPLAY.XLIM point(1,1)]); P2(2) = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.P2 = P2; P1 = FIDSDISPLAY.P1;
        if (P1(1) ~= P2(1))&(P1(2) ~= P2(2)),
            FIDSDISPLAY.XWIN = sort([P1(1) P2(1)]);
            FIDSDISPLAY.YWIN = sort([P1(2) P2(2)]);
        end
        delete(FIDSDISPLAY.ZOOMBOX);
   	    UpdateDisplay(handle);
    end
    return   

    
    
function ButtonDown(handle)
   	
    global FIDSDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS}; 
    
    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
    t = point(1,1); y = point(1,2);
    
    xwin = FIDSDISPLAY.XWIN;
    ywin = FIDSDISPLAY.YWIN;
    if (t>xwin(1))&(t<xwin(2))&(y>ywin(1))&(y<ywin(2)),
        if ~strcmp(seltype,'alt'),
      		events = FindClosestEvent(events,t,y);
            if events.sel(1) > 0, 
                events = SetClosestEvent(events,t,y);
    	    else
                events = AddEvent(events,t,y);
	        end
        else
         	events = AddEvent(events,t,y);
        end
    end
    FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
    return   

    
function ButtonMotion(handle)
        
    global FIDSDISPLAY;
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};  
	if events.sel(1) > 0,
        point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        t = median([FIDSDISPLAY.XLIM point(1,1)]);
        y = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = SetClosestEvent(events,t,y);
    end
    return
    
function ButtonUp(handle)
   
    global FIDSDISPLAY TS SCRIPT;
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};  
    if events.sel(1) > 0,
 	    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
	    t = median([FIDSDISPLAY.XLIM point(1,1)]);
        y = median([FIDSDISPLAY.YLIM point(1,2)]);
        events = SetClosestEvent(events,t,y); 
        sel = events.sel;
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
        FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
        if (events.type(sel) == 2) & (SCRIPT.FIDSAUTOACT == 1), DetectActivation(handle); end
        if (events.type(sel) == 3) & (SCRIPT.FIDSAUTOREC == 1), DetectRecovery(handle); end
    end
    
    set(findobj(allchild(handle),'tag','FIDSTYPE'),'value',find(events.num == FIDSDISPLAY.NEWFIDSTYPE));
    
    return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FindClosestEvent               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function events = FindClosestEvent(events,t,y)
    
    global FIDSDISPLAY;
 
    if isempty(events.value), 
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
        return
    end
            
    switch events.class,
        case 1,
            tt = abs(permute(events.value(1,:,:),[3 2 1])-t);
            [events.sel2,events.sel] = find(tt == min(tt(:)));
            events.sel = events.sel(1);
            events.sel2 = events.sel2(1);
            events.sel3 = 1;
        case 2,
            numchannels = size(FIDSDISPLAY.SIGNAL,1);
            ch = median([ 1 numchannels-floor(y)  numchannels]);
            group = FIDSDISPLAY.GROUP(ch);
            tt = abs(permute(events.value(group,:,:),[3 2 1])-t);
            [events.sel2,events.sel] = find(tt == min(tt(:)));
            events.sel = events.sel(1);
            events.sel2 = events.sel2(1);
            events.sel3 = group;
        case 3,
             numchannels = size(FIDSDISPLAY.SIGNAL,1);
            ch = median([ 1 numchannels-floor(y)  numchannels]);
            lead = FIDSDISPLAY.LEAD(ch);
            tt = abs(permute(events.value(lead,:,:),[3 2 1])-t);
            [events.sel2,events.sel] = find(tt == min(tt(:)));
            events.sel = events.sel(1);
            events.sel2 = events.sel2(1);
            events.sel3 = lead;
    end

 return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SetClosestEvent                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = SetClosestEvent(events,t,y)

    s = events.sel;
    s2 = events.sel2;
    s3 = events.sel3;

    if s(1) == 0, return; end
    
    switch events.typelist(events.type(s)),
               case 1,
                    for w=s3,
                        if (events.handle(w,s) > 0)&(ishandle(events.handle(w,s))), set(events.handle(w,s),'XData',[t t]); end
                        events.value(w,s,[1 2]) = [t t];
                    end
                    %drawnow;
                case 2,
                    for w=s3,
                        events.value(w,s,s2) = t;
                        t1 = events.value(w,s,1);
                        t2 = events.value(w,s,2);
                        if (events.handle(w,s) > 0)&(ishandle(events.handle(w,s))), set(events.handle(w,s),'XData',[t1 t1 t2 t2]); end
                    end
                    %drawnow;  
                case 3,
                    for w=s3,
                        dt = diff(events.value(w,s,[s2 (3-s2)]));
                        events.value(w,s,s2) = t; events.value(w,s,(3-s2)) = t+dt;
                        t1 = events.value(w,s,1);
                        t2 = events.value(w,s,2);
                        if (events.handle(w,s) > 0)&(ishandle(events.handle(w,s))),  set(events.handle(w,s),'XData',[t1 t1 t2 t2]); end
                    end
                    %drawnow;  
    end

 return

  
 function events = DPeaks(signal,threshold,detectionwidth);

    if nargin == 2,
        detectionwidth = 0;
    end
    
    nsamples = size(signal,2);
   
    if detectionwidth > 0,
   
        L = (detectionwidth -1);
        N = 2*L+1;
        X = -L:L;
        C2 = sum(X.*X);
        C4 = sum(X.*X.*X.*X);

        % define matched filters
        MF1 = ones(1,N);  
        MF2 = X.*X;

        % Make a convolution with the matched filter

        Conv1 = conv(signal,MF1);
        Conv2 = conv(signal,MF2);
        Conv1 = Conv1((L+1):(L+nsamples));
        Conv2 = Conv2((L+1):(L+nsamples));

        signal = (Conv2 - ((C4/C2)*Conv1))*(C2/(C2*C2-N*C4));
    end

    % C is now a filtered signal containing the value when
    % a second order function is fitted on to the data in a region
    % between -L and L points from the centre. L is a kind of detection
    % width

    N = size(signal,2);
    index = find(signal >= threshold);
    I2 = zeros(1,N+2);
    I2(index+1) = ones(size(index,1));
    I2 = I2(2:N+2) - I2(1:N+1);

    % Detect the intervals in which a maximum has to detected

    intervalstart = find(I2 == 1);
    intervalend = find(I2 == -1);
    intervalend = intervalend -1;

    % detect maxima

    events = [];

    for i = 1:size(intervalstart,2),
        S = signal(intervalstart(i):intervalend(i));
        [dummy,ind] = max(S);
        events(i) = ind(max([1 round(length(ind)/2)])) + intervalstart(i) - 1;
    end
    
    return
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddEvent                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = AddEvent(events,t,y)

  global FIDSDISPLAY SCRIPT;
  newtype = FIDSDISPLAY.NEWFIDSTYPE;

  switch(events.typelist(newtype)),
      case 1,
          events.value(1:events.maxn,end+1,:) = t*ones(events.maxn,1,2);
          events.type(end+1) = newtype;
          events.handle(1:events.maxn,end+1) = zeros(events.maxn,1);
          events.sel = length(events.type);
          events.sel2 = 1;
          events.sel3 = 1:events.maxn;
      case 2,
          events.value(1:events.maxn,end+1,:) = t*ones(events.maxn,1,2);
          events.type(end+1) = newtype;
          events.handle(1:events.maxn,end+1) = zeros(events.maxn,1);
          events.sel = length(events.type);
          events.sel2 = 2;
          events.sel3 = 1:events.maxn;
      case 3,
          events.value(1:events.maxn,end+1,1) = t*ones(events.maxn,1,1);
          events.value(1:events.maxn,end,2) = (t+events.dt)*ones(events.maxn,1,1);
          events.type(end+1) = newtype;
          events.handle(1:events.maxn,end+1) = zeros(events.maxn,1);
          events.sel = length(events.type);
          events.sel2 = 1;
          events.sel3 = 1:events.maxn;
  end
  
  ywin = FIDSDISPLAY.YWIN;
  s = events.sel;
  switch events.class,
      case 1,
            switch events.typelist(events.type(s)),
                case 1, % normal fiducial
                    v = events.value(1,s,1);
                    events.handle(1,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ywin,'Color',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                case {2,3}, % interval fiducial/ fixed intereval fiducial
                    v = events.value(1,s,1);
                    v2 = events.value(1,s,2);
                    events.handle(1,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ywin ywin([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
            end
        case 2,
          numchannels = size(FIDSDISPLAY.SIGNAL,1);
          chend = numchannels - max([floor(ywin(1)) 0]);
          chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
          index = chstart:chend;
          ch = [];
          
          for q=1:max(FIDSDISPLAY.LEADGROUP),
              nindex = index(find(FIDSDISPLAY.LEADGROUP(index)==q));
              if isempty(nindex), continue; end
              ydata = numchannels-[min(nindex)-1 max(nindex)];
              switch events.typelist(events.type(s)),
                  case 1, % normal fiducial
                      v = events.value(q,s,1);
                      events.handle(q,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                  case {2,3}, % interval fiducial/ fixed intereval fiducial
                      v = events.value(q,s,1);
                      v2 = events.value(q,s,2);
                      events.handle(q,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
              end
              ch = [ch q];
          end
          
      case 3,
           numchannels = size(FIDSDISPLAY.SIGNAL,1);
           chend = numchannels - max([floor(ywin(1)) 0]);
           chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
           index = FIDSDISPLAY.LEAD(chstart:chend);
           ch = [];
           
           for q=index,
               ydata = numchannels-[q-1 q];
               switch events.typelist(events.type(s)),
                  case 1, % normal fiducial
                      v = events.value(q,s,1);
                      events.handle(q,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                  case {2,3}, % interval fiducial/ fixed intereval fiducial
                      v = events.value(q,s,1);
                      v2 = events.value(q,s,2);
                      events.handle(q,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','erasemode','xor','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
              end
              ch =[ch q];
          end
  end
  % drawnow;
  
  if SCRIPT.FIDSLOOPFIDS ==  1,
      FIDSDISPLAY.NEWFIDSTYPE = events.next(FIDSDISPLAY.NEWFIDSTYPE);
  end
return   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DeleteEvent                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = DeleteEvent(events)

    if events.sel == 0,
        return
    else
        s = events.sel;
        events.value(:,s,:) = [];
        events.type(s) = [];
        index = find(events.handle(:,s) > 0);
        delete(events.handle(index,s));
        events.handle(:,s) = [];
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
    end
            
   % drawnow;
return
    
function KeyPress(handle)

    global SCRIPT FIDSDISPLAY TS;

    key = real(get(handle,'CurrentCharacter'));
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    switch key(1),
        case {8, 127}  % delete and backspace keys
	        
            obj = findobj(allchild(handle),'tag','DISPLAYZOOM');
            value = get(obj,'value');
            if value == 0,   
                point = get(FIDSDISPLAY.AXES,'CurrentPoint');
                xwin = FIDSDISPLAY.XWIN;
                ywin = FIDSDISPLAY.YWIN;
                t = point(1,1); y = point(1,2);
                if (t>xwin(1))&(t<xwin(2))&(y>ywin(1))&(y<ywin(2)),
                    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};
                    events = FindClosestEvent(events,t,y);
                    events = DeleteEvent(events);   
                    FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
                    switch FIDSDISPLAY.SELEVENTS
                        case 1,
                            TS{SCRIPT.CURRENTTS}.timeframe = []; 
                        case 2,
                            TS{SCRIPT.CURRENTTS}.templateframe = [];
                        case 3,
                            TS{SCRIPT.CURRENTTS}.averageframe = [];
                    end
                end    
            end	
        case 93,
            ywin = FIDSDISPLAY.YWIN; ylim = FIDSDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin-ysize; 
            FIDSDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);
        case 91,
            ywin = FIDSDISPLAY.YWIN; ylim = FIDSDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin+ysize; 
            FIDSDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);   
        case 44,
            xwin = FIDSDISPLAY.XWIN; xlim = FIDSDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin-xsize; 
            FIDSDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);
        case 46,
            xwin = FIDSDISPLAY.XWIN; xlim = FIDSDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin+xsize; 
            FIDSDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);  
        case {116,50}
            FIDSDISPLAY.SELEVENTS = 2;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',2);
        case {115,119,49}
            FIDSDISPLAY.SELEVENTS = 1;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',1);
        case {97,51}
            FIDSDISPLAY.SELEVENTS = 3;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',3);
        otherwise
            fprintf(1,'%d',key);
    end

    return

function DetectRecovery(handle)

    global TS SCRIPT FIDSDISPLAY;
    
    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    
    tsindex = SCRIPT.CURRENTTS;
    numchannels = size(TS{tsindex}.potvals,1);
    qstart = zeros(numchannels,1);
    qend = zeros(numchannels,1);
    rec = ones(FIDSDISPLAY.EVENTS{3}.maxn,1)*(1/1000);
    
    ind = find(FIDSDISPLAY.EVENTS{1}.type == 3);
    if ~isempty(ind),
        qstart = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),1)*ones(numchannels,1);
        qend   = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),2)*ones(numchannels,1);
    end
    
    numgroups = length(SCRIPT.GROUPLEADS);
    ind = find(FIDSDISPLAY.EVENTS{2}.type == 3);
    if ~isempty(ind),
        for p=1:numgroups, 
            qstart(SCRIPT.GROUPLEADS{p}) = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),1);
            qend(SCRIPT.GROUPLEADS{p})   = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),2);
        end
    end    
    
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 3);
    if ~isempty(ind),
        qstart = FIDSDISPLAY.EVENTS{2}.value(:,ind(1),1);
        qend = FIDSDISPLAY.EVENTS{2}.value(:,ind(1),1);
    end
    
    qs = min([qstart qend],[],2);
    qe = max([qstart qend],[],2);
    
    win = SCRIPT.RECWIN;
    deg = SCRIPT.RECDEG;
    neg = SCRIPT.RECNEG;
    
    for p=1:numgroups,
        for q=SCRIPT.GROUPLEADS{p},
            if qs(q) > 0,
                rec(q) = ARdetect(TS{tsindex}.potvals(q,round(1000*qs(q)):round(1000*qe(q))),win,deg,neg)/1000 + qs(q);
            end
        end
    end
  
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 8);
    if isempty(ind), ind = length(FIDSDISPLAY.EVENTS{3}.type)+1;end

    FIDSDISPLAY.EVENTS{3}.value(:,ind,1) = rec;
    FIDSDISPLAY.EVENTS{3}.value(:,ind,2) = rec;
    FIDSDISPLAY.EVENTS{3}.type(ind) = 8;
    DisplayFiducials;
    
    set(handle,'pointer',pointer);
    
    return    
    

function DetectActivation(handle)

    global TS SCRIPT FIDSDISPLAY;
    
    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    
    tsindex = SCRIPT.CURRENTTS;
    numchannels = size(TS{tsindex}.potvals,1);
    qstart = zeros(numchannels,1);
    qend = zeros(numchannels,1);
    act = ones(FIDSDISPLAY.EVENTS{3}.maxn,1)*(1/1000);
    
    ind = find(FIDSDISPLAY.EVENTS{1}.type == 2);
    if ~isempty(ind),
        qstart = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),1)*ones(numchannels,1);
        qend   = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),2)*ones(numchannels,1);
    end
    
    numgroups = length(SCRIPT.GROUPLEADS);
    ind = find(FIDSDISPLAY.EVENTS{2}.type == 2);
    if ~isempty(ind),
        for p=1:numgroups, 
            qstart(SCRIPT.GROUPLEADS{p}) = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),1);
            qend(SCRIPT.GROUPLEADS{p})   = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),2);
        end
    end    
    
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 2);
    if ~isempty(ind),
        qstart = FIDSDISPLAY.EVENTS{2}.value(:,ind(1),1);
        qend = FIDSDISPLAY.EVENTS{2}.value(:,ind(1),1);
    end
    
    qs = min([qstart qend],[],2);
    qe = max([qstart qend],[],2);
    
    win = SCRIPT.ACTWIN;
    deg = SCRIPT.ACTDEG;
    neg = SCRIPT.ACTNEG;
    
    for p=1:numgroups,
        for q=SCRIPT.GROUPLEADS{p},
            if qe(q) > qs(q),
                if isfield(TS{tsindex},'noisedrange'),
                    [act(q)] = (ARdetect(TS{tsindex}.potvals(q,round(1000*qs(q)):round(1000*qe(q))),win,deg,neg,TS{tsindex}.noisedrange(q))-1)/1000 + qs(q);
                    %[act(q),dvdt] = (ARdetect(TS{tsindex}.potvals(q,round(1000*qs(q)):round(1000*qe(q))),win,deg,neg,TS{tsindex}.noisedrange(q))-1)/1000 + qs(q);
                    %TS{tsindex}.dvdt(q) = dvdt;
                else
                    [act(q)] = (ARdetect(TS{tsindex}.potvals(q,round(1000*qs(q)):round(1000*qe(q))),win,deg,neg)-1)/1000 + qs(q);
                    %[act(q),dvdt] = (ARdetect(TS{tsindex}.potvals(q,round(1000*qs(q)):round(1000*qe(q))),win,deg,neg)-1)/1000 + qs(q);
                    %TS{tsindex}.dvdt(q) = dvdt;
                end
            end
        end
    end
      
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 7);
    if isempty(ind), ind = length(FIDSDISPLAY.EVENTS{3}.type)+1;end
    
    FIDSDISPLAY.EVENTS{3}.value(:,ind,1) = act;
    FIDSDISPLAY.EVENTS{3}.value(:,ind,2) = act;
    FIDSDISPLAY.EVENTS{3}.type(ind) = 7;
    DisplayFiducials;
    
    set(handle,'pointer',pointer);
    
    return
 
 %function [x,dvdt] = ARdetect(sig,win,deg,pol,ndrange)
  function [x] = ARdetect(sig,win,deg,pol,ndrange)
 
   if nargin == 4,
        ndrange = 0;
   end
 
   sigdrange = max(sig)-min(sig);
   
   if (sigdrange <= 1.75*ndrange),
        x = length(sig);
        return;
   end
   
   if mod(win,2) == 0, win = win + 1; end
   if length(sig) < win, x=1; return; end
 
    % Detection of the minimum derivative
    % Use a window of 5 frames and fit a 2nd order polynomial
    
    cen = ceil(win/2);
    X = zeros(win,(deg+1));
    L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
    E = inv(X'*X)*X';

    sig = [sig sig(end)*ones(1,cen-1)];
    
    a = filter(E(deg,[win:-1:1]),1,sig);
    dy = a(cen:end);

    if pol == 1,
        [mv,mi] = min(dy(cen:end-cen));
    else
        [mv,mi] = max(dy(cen:end-cen));
    end
    mi = mi(1)+(cen-1);
    
    % preset values for peak detector
    
    win2 = 5;
    deg2 = 2;
    
    cen2 = ceil(win2/2);
    L2 = [-(cen2-1):(cen2-1)]';
    for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
    c = inv(X2'*X2)*X2'*(dy(L2+mi)');
    
    if abs(c(1)) < 100*eps, dx = 0; else dx = -c(2)/(2*c(1)); end
   
    dvdt = 2*c(1)*dx+c(2);
    
    dx = median([-0.5 dx 0.5]);
    
    x = mi+dx-1;
    
    return
    
    
 function x = polymin(sig)

    % Detection of the first derivative
    % Use a window of 7 frames and fit a 3rd order polynomial

    deg = 3;
    win = 7;
    
    if length(sig) < win, x=1; return; end
    
    % Detection of the minimum derivative
    % Use a window of 5 frames and fit a 2nd order polynomial
    
    cen = ceil(win/2);
    X = zeros(win,(deg+1));
    L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
    E = inv(X'*X)*X';

    sig = [sig sig(end)*ones(1,cen-1)];
    
    a = filter(E(deg,[win:-1:1]),1,sig);
    dy = a(cen:end);

    [mv,mi] = min(dy(cen:end-cen));
    mi = mi(1)+(cen-1);
    
    win2 = 5;
    deg2 = 2;
    
    cen2 = ceil(win2/2);
    L2 = [-(cen-1):(cen-1)]';
    for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
    c = inv(X2'*X2)*X2'*(dy(L2+mi)');
    
    if c(1) == 0, dx = 0; else dx = -c(2)/(2*c(1)); end
       
    x = mi+dx-1;
   
    return
    
    
 function x = polymax(sig)

    % Detection of the first derivative
    % Use a window of 7 frames and fit a 3rd order polynomial
  
    deg = 3;
    win = 7;
    
    if length(sig) < win, x=1; return; end


    % Detection of the minimum derivative
    % Use a window of 5 frames and fit a 2nd order polynomial
   
    win2 = 5;
    deg2 = 2;
    
    cen = ceil(win/2);
    X = zeros(win,(deg+1));
    L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
    E = inv(X'*X)*X';

    sig = [sig sig(end)*ones(1,cen-1)];
    
    a = filter(E(deg,[win:-1:1]),1,sig);
    dy = a(cen:end);

    [mv,mi] = max(dy(cen:end-cen));
    mi = mi(1)+(cen-1);
    
    win2 = 5;
    deg2 = 2;
    
    cen2 = ceil(win2/2);
    L2 = [-(cen-1):(cen-1)]';
    for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
    c = inv(X2'*X2)*X2'*(dy(L2+mi)');
    
    if c(1) == 0, dx = 0; else dx = -c(2)/(2*c(1)); end
    
    x = mi+dx-1;    
    
    
function FidsToEvents

    global TS FIDSDISPLAY SCRIPT;

    samplefreq = 1000;
    isamplefreq = 1/samplefreq;
    
    if ~isfield(TS{SCRIPT.CURRENTTS},'fids'), return; end
    fids = TS{SCRIPT.CURRENTTS}.fids;
    if isempty(fids), return; end
    
    pval = []; qval = []; tval = []; Fval = [];
    pind = []; qind = []; tind = []; Find = [];
    
    for q=1:length(fids),
        if fids(q).type == 1,
            pind = [pind q]; pval = [pval mean(fids(q).value)*isamplefreq];
        end
        if fids(q).type == 4,
            qind = [qind q]; qval = [qval mean(fids(q).value)*isamplefreq];
        end
        if fids(q).type == 7,
            tind = [tind q]; tval = [tval mean(fids(q).value)*isamplefreq];
        end
        if fids(q).type == 21,
            Find = [Find q]; Fval = [Fval mean(fids(q).value)*isamplefreq];
        end
    end
    
    numchannels = size(TS{SCRIPT.CURRENTTS}.potvals,1);
            
    for p=1:length(fids),
        
        if FIDSDISPLAY.MODE == 2,
            if (fids(p).type ~= 16)&(fids(p).type ~= 20)&(fids(p).type ~= 21)
                continue;
            end
        end
        
         switch fids(p).type,
            case 0,
                mtype = 1;
                val1 = fids(p).value*isamplefreq;
                if isempty(pind), continue; end
                ind2  = find(pval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(find(pval(ind2)==min(pval(ind2))));
                val2 = fids(pind(ind2(1))).value*isamplefreq;
            case 2,
                mtype = 2;
                val1 = fids(p).value*isamplefreq;
                if isempty(qind), continue; end
                ind2  = find(qval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(find(qval(ind2)==min(qval(ind2))));
                val2 = fids(qind(ind2(1))).value*isamplefreq;
            case 5,
                mtype = 3;
                val1 = fids(p).value*isamplefreq;
                if isempty(tind), continue; end
                ind2  = find(tval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(find(tval(ind2)==min(tval(ind2))));
                val2 = fids(tind(ind2(1))).value*isamplefreq;
            case 20,
                mtype = 10;
                val1 = fids(p).value*isamplefreq;
                if isempty(Find), continue; end
                ind2  = find(Fval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(find(Fval(ind2)==min(Fval(ind2))));
                val2 = fids(Find(ind2(1))).value*isamplefreq;            
            case 3,
                mtype = 4; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 6,
                mtype = 5; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 16,
                mtype = 6; val1 = fids(p).value*isamplefreq; val2 = val1+TS{SCRIPT.CURRENTTS}.baselinewidth/samplefreq;
            case 10,
                mtype = 7; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 13,
                mtype = 8; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 14,
                mtype = 9; val1 = fids(p).value*isamplefreq; val2 = val1; 
            otherwise
                continue;
        end
        
        
        if (length(val1) == numchannels)&(length(val2) == numchannels)
            
            isgroup = 1;
            for q=1:length(SCRIPT.GROUPLEADS),
                channels = SCRIPT.GROUPLEADS{q};
                if(nnz(val1(channels)-val1(channels(1)))>0), isgroup = 0; end
                if(nnz(val2(channels)-val2(channels(1)))>0), isgroup = 0; end
            end
   
            if isgroup == 1,
                gval1 = []; gval2 =[];
                for q=1:length(SCRIPT.GROUPLEADS),
                    channels = SCRIPT.GROUPLEADS{q};
                    gval1(q) = val1(channels(1));
                    gval2(q) = val2(channels(1));
                end
                FIDSDISPLAY.EVENTS{2}.value(:,end+1,1) = gval1;
                FIDSDISPLAY.EVENTS{2}.value(:,end,2) = gval2;
                FIDSDISPLAY.EVENTS{2}.type(end+1) = mtype;                
            else
                FIDSDISPLAY.EVENTS{3}.value(:,end+1,1) = val1;
                FIDSDISPLAY.EVENTS{3}.value(:,end,2) = val2;
                FIDSDISPLAY.EVENTS{3}.type(end+1) = mtype;
            end
        elseif (length(val1) ==1)&(length(val2) == 1),
            FIDSDISPLAY.EVENTS{1}.value(:,end+1,1) = val1;
            FIDSDISPLAY.EVENTS{1}.value(:,end,2) = val2;
            FIDSDISPLAY.EVENTS{1}.type(end+1) = mtype;  
        end
    end
    return
    
function EventsToFids

    global TS FIDSDISPLAY SCRIPT;

    samplefreq = 1000;
    isamplefreq = (1/samplefreq);
    fids = [];
    fidset = {};
    
    val1 = {};
    val2 = {};
    mtype = {};
    
    for p=1:length(FIDSDISPLAY.EVENTS{1}.type),
        val1{end+1} = FIDSDISPLAY.EVENTS{1}.value(1,p,1)*samplefreq;
        val2{end+1} = FIDSDISPLAY.EVENTS{1}.value(1,p,2)*samplefreq;
        mtype{end+1} = FIDSDISPLAY.EVENTS{1}.type(p);
    end
    
    numchannels = size(TS{SCRIPT.CURRENTTS}.potvals,1);
    for p=1:length(FIDSDISPLAY.EVENTS{2}.type),
        v1 = ones(numchannels,1);
        v2 = ones(numchannels,1);
        for q=1:length(SCRIPT.GROUPLEADS),
            v1(SCRIPT.GROUPLEADS{q}) = FIDSDISPLAY.EVENTS{2}.value(q,p,1)*samplefreq;
            v2(SCRIPT.GROUPLEADS{q}) = FIDSDISPLAY.EVENTS{2}.value(q,p,2)*samplefreq;
        end
        val1{end+1} = v1;
        val2{end+1} = v2;
        mtype{end+1} = FIDSDISPLAY.EVENTS{2}.type(p);
    end
    
    for p=1:length(FIDSDISPLAY.EVENTS{3}.type),
        val1{end+1} = FIDSDISPLAY.EVENTS{3}.value(:,p,1)*samplefreq;
        val2{end+1} = FIDSDISPLAY.EVENTS{3}.value(:,p,2)*samplefreq;
        mtype{end+1} = FIDSDISPLAY.EVENTS{3}.type(p);
    end 
    
    % FILTER OUT ALL THE FIDUCIALS WE ARE GOING TO REPLACE
    if FIDSDISPLAY.MODE == 2,
        fids = TS{SCRIPT.CURRENTTS}.fids;
        rem = [];
        for p=1:length(fids),
            if (fids(p).type == 16)|(fids(p).type == 20)|(fids(p).type == 21),
                rem = [rem p];
            end
        end    
        fids(rem) = [];
    end
    
    
    for p=1:length(val1),
        v1 = min([val1{p} val2{p}],[],2);
        v2 = max([val1{p} val2{p}],[],2);
    
        if FIDSDISPLAY.MODE == 2,
            if (mtype{p} ~= 6) &(mtype{p} ~= 10),
                continue; % do not add that fiducial    
            end
        end
        
        switch mtype{p},
            case 1,
                fids(end+1).value = v1;
                fids(end).type = 0;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 1;
                fids(end).fidset = 0;
            case 2,
                fids(end+1).value = v1;
                fids(end).type = 2;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 4;
                fids(end).fidset = 0;
            case 3,
                fids(end+1).value = v1;
                fids(end).type = 5;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 7;
                fids(end).fidset = 0;
            case 4,
                fids(end+1).value = v1;
                fids(end).type = 3;
                fids(end).fidset = 0;
            case 5,
                fids(end+1).value = v1;
                fids(end).type = 6;
                fids(end).fidset = 0;
            case 6,
                fids(end+1).value = v1;
                fids(end).type = 16;
                fids(end).fidset = 0;
            case 7,
                fids(end+1).value = v1;
                fids(end).type = 10;
                fids(end).fidset = 0;
            case 8,
                fids(end+1).value = v1;
                fids(end).type = 13;
                fids(end).fidset = 0;
            case 9,
                fids(end+1).value = v1;
                fids(end).type = 14;
                fids(end).fidset = 0;
            case 10,
                fids(end+1).value = v1;
                fids(end).type = 20;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 21;
                fids(end).fidset = 0;
        end
    end
    
    TS{SCRIPT.CURRENTTS}.fids = fids;
    TS{SCRIPT.CURRENTTS}.fidset = fidset;
    
    return
    