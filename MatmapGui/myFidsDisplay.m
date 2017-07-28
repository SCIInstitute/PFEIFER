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

    if nargin > 0
        
        if ischar(varargin{1})   
            feval(varargin{1},varargin{2:end});    % if input is char, then evaluate char (used for ButtonUp user interface callback fkts)
        else
            if nargin > 1
                handle = Init(varargin{1},varargin{2});
            else
                handle = Init(varargin{1});
            end
        end
    else    
        handle = Init;    
    end
    
end


function Navigation(handle,mode)
    %callback function to Navigation bar. E.G. the "next" button has
    %callback function:   FidsDisplay('Navigation',gcbf,'next')
    %also callback to "apply" button!!
    
    global myScriptData;
    
    switch mode
    case {'prev','next','stop','redo','back'}
        myScriptData.NAVIGATION = mode;
        set(handle,'DeleteFcn','');  % normally, DeleteFcn is: FidsDisplay('Navigation',gcbf,'stop')  (why?!)
        delete(handle);
    case {'apply'}
  
        EventsToFids;
        myScriptData.NAVIGATION = 'apply';
        set(handle,'DeleteFcn','');
        delete(handle);
        
    otherwise
        error('unknown navigation command');
    end

end

function SetupNavigationBar(handle)
    % sets up Filename, Filelabel etc in the top bar (right to navigation
    % bar)
    global myScriptData TS;
    tsindex = myScriptData.CURRENTTS;
    
    t = findobj(allchild(handle),'tag','NAVFILENAME');
    t.String=['FILENAME: ' TS{tsindex}.filename];
    t.Units='character';
    needed_length=t.Extent(3);
    t.Position(3)=needed_length+0.001;
    t.Units='normalize';
    
   
    t = findobj(allchild(handle),'tag','NAVLABEL');
    t.String=['FILELABEL: ' TS{tsindex}.label];
    t.Units='character';
    needed_length=t.Extent(3);
    t.Position(3)=needed_length+0.001;
    t.Units='normalize';
    
    t = findobj(allchild(handle),'tag','NAVACQNUM');
    t.String=sprintf('ACQNUM: %d',myScriptData.ACQNUM);
    t.Units='character';
    needed_length=t.Extent(3);
    t.Position(3)=needed_length+0.001;
    t.Units='normalize';
    
    t = findobj(allchild(handle),'tag','NAVTIME');
    t.Units='character';
    needed_length=t.Extent(3);
    t.Position(3)=needed_length+0.001;
    t.Units='normalize';
    if isfield(TS{tsindex},'time')
        t.String=['TIME: ' TS{tsindex}.time];
        t.Units='character';
        needed_length=t.Extent(3);
        t.Position(3)=needed_length+0.001;
        t.Units='normalize';
    end
end

    
function handle = Init(tsindex,mode)
    %initialisation function, essentially the first function that is run,
    %It also opens the gui figure
    global myScriptData;
    
    clear global FIDSDISPLAY;    %just in case
    
    if nargin > 0
        myScriptData.CURRENTTS = tsindex;
    end
    if nargin < 2
        mode = 1;
    end

    handle = winMyFidsDisplay;
    InitFiducials(handle,mode);
    InitDisplayButtons(handle);  
    InitMouseFunctions(handle);   %sets callback functions for user interface (eg 'ButtonUpFcn'
    SetupNavigationBar(handle);
    SetupDisplay(handle);
    UpdateDisplay(handle);
    
    if mode==2
        setInvisible(handle)
    end
    
    
    
    
    
end

function SetFids(handle)
    
    %callback function to the three buttons ('Global Fids', Group
    % Fids') in the "Fiducials" Window (middle left up)
    
    % makes sure that only one of the three buttons ('Global Fids', Group
    % Fids', 'Local Fids' is selected at the same time. All three buttons
    % have same callback function (this one), but different tags..
    
    % then it udates Axes accordingly (by calling DisplayFiducials)

    global FIDSDISPLAY;

    window = get(handle,'parent');
    tag = get(handle,'tag');
    switch tag
        case 'FIDSGLOBAL'
            FIDSDISPLAY.SELFIDS = 1;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',1);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',0);
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',0);
        case 'FIDSGROUP'
            FIDSDISPLAY.SELFIDS = 2;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',0);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',1);
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',0);            
        case 'FIDSLOCAL'
            FIDSDISPLAY.SELFIDS = 3;
            set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',0);
            set(findobj(allchild(window),'tag','FIDSGROUP'),'value',0); 
            set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',1);
    end
    DisplayFiducials;
    
end
 
function SelFidsType(handle)    
    %callback function of middle right, the list box
    
    %sets NEWFIDSTYPE to number of selected fid-type (eg T-Wave) in listbox
     
    global FIDSDISPLAY;
    FIDSDISPLAY.NEWFIDSTYPE = FIDSDISPLAY.EVENTS{1}.num(get(handle,'value'));
end
    
function InitFiducials(handle,mode)
    % sets up .EVENTS 
    % calls FidsToEvents
    

    global FIDSDISPLAY myScriptData TS;

    FIDSDISPLAY.MODE = 1;
    if nargin == 2
        FIDSDISPLAY.MODE = mode;
    end    
    
     if FIDSDISPLAY.MODE == 1
        myScriptData.DISPLAYTYPEF = myScriptData.DISPLAYTYPEF1;
    else
        myScriptData.DISPLAYTYPEF = myScriptData.DISPLAYTYPEF2;
     end    
    
     
    % for all fiducial types
    events.dt = myScriptData.BASELINEWIDTH/myScriptData.SAMPLEFREQ;
    events.value = [];
    events.type = [];
    events.handle = [];
    events.axes = findobj(allchild(handle),'tag','AXES');
    events.colorlist = {[1 0.7 0.7],[0.7 1 0.7],[0.7 0.7 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[1 0 1],[1 1 0],[0 1 1],  [1 0.5 0],[1 0.5 0]};
    events.colorlistgray = {[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],   [0.8 0.8 0.8],[0.8 0.8 0.8]};
    events.typelist = [2 2 2 1 1 3 1 1 1 1 2];
    events.linestyle = {'-','-','-','-.','-.','-','-','-','-','-','-'};
    events.linewidth = {1,1,1,2,2,1,2,2,2,2,2,1};
    events.num = [1 2 3 4 5 7 8 9 10 11];
    

    FIDSDISPLAY.SELFIDS = 1;
    if isempty(myScriptData.LOOP_ORDER), myScriptData.LOOP_ORDER=1; end %should be unnecesarry, but weird stuff happened..
    if FIDSDISPLAY.MODE == 1
        FIDSDISPLAY.NEWFIDSTYPE = myScriptData.LOOP_ORDER(1);
    else
        FIDSDISPLAY.NEWFIDSTYPE = 6;           
    end

    FIDSDISPLAY.fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Activation','Recovery','Reference','X-Peak','X-Wave'};     
    if FIDSDISPLAY.MODE == 2
        FIDSDISPLAY.fidslist = {'Baseline'};
        events.num = 6;
    end
    FIDSDISPLAY.NUMTYPES = length(FIDSDISPLAY.fidslist);
    button = findobj(allchild(handle),'tag','FIDSTYPE');
    set(button,'value',find(events.num == FIDSDISPLAY.NEWFIDSTYPE),'string',FIDSDISPLAY.fidslist);
    
    FIDSDISPLAY.SELFIDS = 1;
    set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
    set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
    set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
    
    
    events.sel = 0;
    events.sel2 = 0;
    events.sel3 = 0;
     
    events.maxn = 1;
    events.class = 1; FIDSDISPLAY.EVENTS{1} = events;  % GLOBAL EVENTS
    events.maxn = length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP});
    events.class = 2; FIDSDISPLAY.EVENTS{2} = events;  % GROUP EVENTS
    events.maxn = size(TS{myScriptData.CURRENTTS}.potvals,1);
    events.class = 3; FIDSDISPLAY.EVENTS{3} = events;  % LOCAL EVENTS

    FidsToEvents;
    
end

function FidsButton(handle)
    %callback to middle-down left  and complete down.  

    global myScriptData
    
    tag = get(handle,'tag');
    switch tag
        case {'FIDSLOOPFIDS','FIDSAUTOREC','FIDSAUTOACT'}
            myScriptData= setfield(myScriptData,tag,get(handle,'value'));
        case {'ACTNEG','RECNEG'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value')-1);
            parent = get(handle,'parent');
            UpdateDisplay(parent);        
            
        case {'ACTWIN','ACTDEG','RECWIN','RECDEG'}
            myScriptData = setfield(myScriptData,tag,str2num(get(handle,'string')));
            parent = get(handle,'parent');
            UpdateDisplay(parent);             
            
    end
end

function DisplayFiducials
    % this functions plotts the lines/patches when u select the fiducials
    % (the line u can move around with your mouse)
    
    global FIDSDISPLAY myScriptData;
    
    % GLOBAL EVENTS
    events = FIDSDISPLAY.EVENTS{1};
     if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end   %delete any existing lines
    events.handle = [];
    ywin = FIDSDISPLAY.YWIN;
    if FIDSDISPLAY.SELFIDS == 1, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    for p=1:size(events.value,2)   %   for p=[1: anzahl zu plottender linien]
        switch events.typelist(events.type(p))
            case 1 % normal fiducial
                v = events.value(1,p,1);
                events.handle(1,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ywin,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            case {2,3} % interval fiducial/ fixed intereval fiducial
                v = events.value(1,p,1);
                v2 = events.value(1,p,2);
                events.handle(1,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ywin ywin([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
        end
    end
    FIDSDISPLAY.EVENTS{1} = events;           

    if myScriptData.DISPLAYTYPEF == 1, return; end
    
    % GROUP FIDUCIALS
    
    events = FIDSDISPLAY.EVENTS{2};
    if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    if FIDSDISPLAY.SELFIDS == 2, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    numchannels = size(FIDSDISPLAY.SIGNAL,1);
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
 
    index = chstart:chend;
    
    for q=1:max(FIDSDISPLAY.LEADGROUP)
        nindex = index(FIDSDISPLAY.LEADGROUP(index)==q);
        if isempty(nindex), continue; end
        ydata = numchannels-[min(nindex)-1 max(nindex)];
        
        
        for p=1:size(events.value,2)
            switch events.typelist(events.type(p))
                case 1 % normal fiducial
                    v = events.value(q,p,1);
                    events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                case {2,3} % interval fiducial/ fixed intereval fiducial
                    v = events.value(q,p,1);
                    v2 = events.value(q,p,2);
                    events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
            end
        end
    end
    FIDSDISPLAY.EVENTS{2} = events;   
    
    if myScriptData.DISPLAYTYPEF == 2, return; end
    
    % LOCAL FIDUCIALS
    
    events = FIDSDISPLAY.EVENTS{3};
    
    %%%% delete all current handles and set events.handles=[]
     if ~isempty(events.handle)
         index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0));
         delete(events.handle(index))
     end
    events.handle = [];
    
    
    if FIDSDISPLAY.SELFIDS == 3, colorlist = events.colorlist; else colorlist = events.colorlistgray; end
    
    
    %%%% index is eg [3 4 5 8 9 10], if those are the leads currently
    %%%% displayed (this changes with yslider!, note 5 8 !

    index = FIDSDISPLAY.LEAD(chstart:chend);
    for q=index     % for each of the 5-7 channels, that one can see in axes
        for idx=find(q==FIDSDISPLAY.LEAD)
            ydata = numchannels-[idx-1 idx];   % y-value, from where to where each local fid is plottet, eg [15, 16]  
            for p=1:size(events.value,2)   % for each fid of that channel
                switch events.typelist(events.type(p))
                    case 1 % normal fiducial
                        v = events.value(q,p,1);
                       events.handle(q,p) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',colorlist{events.type(p)},'hittest','off','linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                    case {2,3} % interval fiducial/ fixed intereval fiducial
                        v = events.value(q,p,1);
                        v2 = events.value(q,p,2);
                        events.handle(q,p) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',colorlist{events.type(p)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(p)},'linestyle',events.linestyle{events.type(p)});
                end
            end
        end
    end
    FIDSDISPLAY.EVENTS{3} = events;   
    
end
    
function InitMouseFunctions(handle)
  % defines callbacks for UserInput

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
set(handle,'WindowButtonDownFcn','myFidsDisplay(''ButtonDown'',gcbf)',...
           'WindowButtonMotionFcn','myFidsDisplay(''ButtonMotion'',gcbf)',...
           'WindowButtonUpFcn','myFidsDisplay(''ButtonUp'',gcbf)',...
           'KeyPressFcn','myFidsDisplay(''KeyPress'',gcbf)',...
           'Interruptible','off');   
end
  
function setInvisible(handle)
% set the uicontrolls that are not needed, if only baseline values are to
% be selected (if mode==2)

Tags2beSetInvisible={'FIDSCLEAR','FIDSLOOPFIDS', 'SELECT_LOOP','FIDSAUTOACT','FIDSDETECTACT',...
    'FIDSAUTOREC', 'FIDSDETECTREC', 'text26','text29','text27','ACTWIN','RECWIN','text28','ACTDEG',...
    'RECDEG','ACTNEG','RECNEG'};

for p=1:length(Tags2beSetInvisible)
    obj=findobj(allchild(handle),'Tag',Tags2beSetInvisible{p});
   
    obj.Visible='Off';
    if isfield(obj,'Enable')
        obj.Enable='off';
    end
end

end
  
function InitDisplayButtons(handle)
    %A.  Initialices the display with values from myScriptData

    global myScriptData FIDSDISPLAY;

    button = findobj(allchild(handle),'tag','DISPLAYTYPEF');
    set(button,'string',{'Global RMS','Group RMS','Individual'},'value',myScriptData.DISPLAYTYPEF);
    
    button = findobj(allchild(handle),'tag','DISPLAYOFFSET');
    set(button,'string',{'Offset ON','Offset OFF'},'value',myScriptData.DISPLAYOFFSET);
    
    button = findobj(allchild(handle),'tag','DISPLAYLABELF');
    set(button,'string',{'Label ON','Label OFF'},'value',myScriptData.DISPLAYLABELF);
    
    button = findobj(allchild(handle),'tag','DISPLAYPACINGF');
    set(button,'string',{'Pacing ON','Pacing OFF'},'value',myScriptData.DISPLAYPACINGF);
    
    button = findobj(allchild(handle),'tag','DISPLAYGRIDF');
    set(button,'string',{'No grid','Coarse grid','Fine grid'},'value',myScriptData.DISPLAYGRIDF);
    
    button = findobj(allchild(handle),'tag','DISPLAYSCALINGF');
    set(button,'string',{'Local','Global'},'value',myScriptData.DISPLAYSCALINGF);

    button = findobj(allchild(handle),'tag','ACTWIN');
    set(button,'string',num2str(myScriptData.ACTWIN));
   
    button = findobj(allchild(handle),'tag','ACTDEG');
    set(button,'string',num2str(myScriptData.ACTDEG));

    button = findobj(allchild(handle),'tag','RECWIN');
    set(button,'string',num2str(myScriptData.RECWIN));
   
    button = findobj(allchild(handle),'tag','RECDEG');
    set(button,'string',num2str(myScriptData.RECDEG));    
    
    button = findobj(allchild(handle),'tag','ACTNEG');
    set(button,'value',myScriptData.ACTNEG+1); 
    
    button = findobj(allchild(handle),'tag','RECNEG');
    set(button,'value',myScriptData.RECNEG+1);    
    
    button = findobj(allchild(handle),'tag','DISPLAYGROUPF');
    group = myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP};

    %%%% check if myScriptData.DISPLAYGROUPF has valid values
    myScriptData.DISPLAYGROUPF = 1:length(group);
    set(button,'string',group,'max',length(group),'value',myScriptData.DISPLAYGROUPF);

    if ~isfield(FIDSDISPLAY,'XWIN'), FIDSDISPLAY.XWIN = []; end
    if ~isfield(FIDSDISPLAY,'YWIN'), FIDSDISPLAY.YWIN = []; end
    
        %%%% set up the listeners for the sliders
    sliderx=findobj(allchild(handle),'tag','SLIDERX');
    slidery=findobj(allchild(handle),'tag','SLIDERY');

    addlistener(sliderx,'ContinuousValueChange',@UpdateSlider);
    addlistener(slidery,'ContinuousValueChange',@UpdateSlider);
    
end
    
function selectLoopOrder(~)
    selectLoop
end
    
function DisplayButton(handle)
    % callback to  links oben, to all 5 "mini dropdown-menues")
    global myScriptData;
    
    tag = get(handle,'tag');
    switch tag
        case {'DISPLAYTYPEF','DISPLAYOFFSET','DISPLAYSCALINGF','DISPLAYPACINGF','DISPLAYGROUPF'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
            parent = get(handle,'parent');
            SetupDisplay(parent);
            UpdateDisplay(parent);       
 
        case {'DISPLAYLABELF','DISPLAYGRIDF'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
            parent = get(handle,'parent');
            UpdateDisplay(parent); 
      
    end
end
 
function SetupDisplay(handle)
%      no plotting, but everything else with axes, particualrely:
%         - sets up some start values for xlim, ylim, sets up axes and slider handles
%         - makes the FD.SIGNAL values,   (RMS and scaling of potvals)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    global TS myScriptData FIDSDISPLAY;
    
    tsindex = myScriptData.CURRENTTS;
    
    numframes = size(TS{tsindex}.potvals,2);
    FIDSDISPLAY.TIME = [1:numframes]*(1/myScriptData.SAMPLEFREQ);
    FIDSDISPLAY.XLIM = [1 numframes]*(1/myScriptData.SAMPLEFREQ);

%    if isempty(FIDSDISPLAY.XWIN);
        FIDSDISPLAY.XWIN = [median([0 FIDSDISPLAY.XLIM]) median([3000/myScriptData.SAMPLEFREQ FIDSDISPLAY.XLIM])];
        %    else
        %FIDSDISPLAY.XWIN = [median([FIDSDISPLAY.XWIN(1) FIDSDISPLAY.XLIM]) median([FIDSDISPLAY.XWIN(2) FIDSDISPLAY.XLIM])];
        %end
    
    FIDSDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
    FIDSDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
    FIDSDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');
    
    if isfield(TS{tsindex},'pacing')
        FIDSDISPLAY.PACING = TS{tsindex}.pacing;
    else
        FIDSDISPLAY.PACING = []; 
    end
    
    
    groups = myScriptData.DISPLAYGROUPF;
    numgroups = length(groups);
    
    FIDSDISPLAY.NAME ={};
    FIDSDISPLAY.GROUPNAME = {};
    FIDSDISPLAY.GROUP = [];
    FIDSDISPLAY.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};
    
    if FIDSDISPLAY.MODE == 1
        myScriptData.DISPLAYTYPEF1 = myScriptData.DISPLAYTYPEF;
    else
        myScriptData.DISPLAYTYPEF2 = myScriptData.DISPLAYTYPEF;
    end    
    
    switch myScriptData.DISPLAYTYPEF
        case 1   % show global RMS
            ch  = []; 
            for p=groups 
                leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p};
                index = TS{tsindex}.leadinfo(leads)==0;  % index of only the 'good' leads, filter out badleads
                ch = [ch leads(index)];   % ch is leads only of the leads of the groubs selected, not of all leads
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
            if FIDSDISPLAY.SELFIDS > 1
                FIDSDISPLAY.SELFIDS = 1;
                set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
                set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
                set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
            end
            
        case 2
            FIDSDISPLAY.SIGNAL = zeros(numgroups,numframes);
            for p=1:numgroups
                leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{groups(p)};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                FIDSDISPLAY.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
                FIDSDISPLAY.SIGNAL(p,:) = FIDSDISPLAY.SIGNAL(p,:)-min(FIDSDISPLAY.SIGNAL(p,:));
                FIDSDISPLAY.NAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)} ' RMS']; 
            end
            FIDSDISPLAY.GROUPNAME = FIDSDISPLAY.NAME;
            FIDSDISPLAY.GROUP = 1:numgroups;
            FIDSDISPLAY.LEAD = 0*FIDSDISPLAY.GROUP;
            FIDSDISPLAY.LEADGROUP = groups;
            FIDSDISPLAY.LEADINFO = zeros(numgroups,1);
            set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSGROUP'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSLOCAL'),'enable','off');
            if FIDSDISPLAY.SELFIDS > 2
                FIDSDISPLAY.SELFIDS = 1;
                set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'value',1);
                set(findobj(allchild(handle),'tag','FIDSGROUP'),'value',0);
                set(findobj(allchild(handle),'tag','FIDSLOCAL'),'value',0);
            end
            
        case 3
            FIDSDISPLAY.GROUP =[];
            FIDSDISPLAY.NAME = {};
            FIDSDISPLAY.LEAD = [];
            FIDSDISPLAY.LEADGROUP = [];
            ch  = []; 
            for p=groups
                ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; 
                FIDSDISPLAY.GROUP = [FIDSDISPLAY.GROUP p*ones(1,length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}))];
                FIDSDISPLAY.LEADGROUP = [FIDSDISPLAY.GROUP myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}];
                FIDSDISPLAY.LEAD = [FIDSDISPLAY.LEAD myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}];
                for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}), FIDSDISPLAY.NAME{end+1} = sprintf('%s # %d',myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{p},q); end 
            end
            for p=1:length(groups)
                FIDSDISPLAY.GROUPNAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)}]; 
            end 
            FIDSDISPLAY.SIGNAL = TS{tsindex}.potvals(ch,:);
            FIDSDISPLAY.LEADINFO = TS{tsindex}.leadinfo(ch);
            set(findobj(allchild(handle),'tag','FIDSGLOBAL'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSGROUP'),'enable','on');
            set(findobj(allchild(handle),'tag','FIDSLOCAL'),'enable','on');
    end
        
    switch myScriptData.DISPLAYSCALINGF
        case 1
            k = max(abs(FIDSDISPLAY.SIGNAL),[],2);
            [m,~] = size(FIDSDISPLAY.SIGNAL);
            k(k==0) = 1;
            s = sparse(1:m,1:m,1./k,m,m);
            FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
        case 2
            k = max(abs(FIDSDISPLAY.SIGNAL(:)));
            [m,~] = size(FIDSDISPLAY.SIGNAL);
            if k > 0
                s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
                FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
            end
        case 3
            [m,~] = size(FIDSDISPLAY.SIGNAL);
            k = ones(m,1);
            for p=groups
                ind = find(FIDSDISPLAY.GROUP == p);
                k(ind) = max(max(abs(FIDSDISPLAY.SIGNAL(ind,:)),[],2));
            end
            s = sparse(1:m,1:m,1./k,m,m);
            FIDSDISPLAY.SIGNAL = s*FIDSDISPLAY.SIGNAL;
    end
    
    if myScriptData.DISPLAYTYPEF == 3
        FIDSDISPLAY.SIGNAL = 0.5*FIDSDISPLAY.SIGNAL+0.5;
    end
    
    numsignal = size(FIDSDISPLAY.SIGNAL,1);
    for p=1:numsignal
        FIDSDISPLAY.SIGNAL(p,:) = FIDSDISPLAY.SIGNAL(p,:)+(numsignal-p);
    end
    
    
    FIDSDISPLAY.YLIM = [0 numsignal];
    FIDSDISPLAY.YWIN = [max([0 numsignal-6]) numsignal];
    
    set(handle,'pointer',pointer);
    
end

function UpdateSlider(handle,~)

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
end
    
    
function UpdateDisplay(handle)
    %plots the FD.SIGNAL,  makes the plot..  also calls  DisplayFiducials

    global FIDSDISPLAY myScriptData ;
    ax=FIDSDISPLAY.AXES;
    axes(ax);
    cla(ax);
    hold(ax,'on');
    ywin = FIDSDISPLAY.YWIN;
    xwin = FIDSDISPLAY.XWIN;
    xlim = FIDSDISPLAY.XLIM;
    ylim = FIDSDISPLAY.YLIM;
    
    numframes = size(FIDSDISPLAY.SIGNAL,2);
    startframe = max([floor(myScriptData.SAMPLEFREQ*xwin(1)) 1]);
    endframe = min([ceil(myScriptData.SAMPLEFREQ*xwin(2)) numframes]);

    % DRAW THE GRID
    
    if myScriptData.DISPLAYGRIDF > 1
        if myScriptData.DISPLAYGRIDF > 2
            clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
            X = [clines; clines]; Y = ywin'*ones(1,length(clines));
            line(ax,X,Y,'color',[0.9 0.9 0.9],'hittest','off');
        end
        clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(ax,X,Y,'color',[0.5 0.5 0.5],'hittest','off');
    end

    if myScriptData.DISPLAYPACINGF == 1
        if  ~isempty(FIDSDISPLAY.PACING)
            plines = FIDSDISPLAY.PACING/myScriptData.SAMPLEFREQ;
            plines = plines((plines >xwin(1)) & (plines < xwin(2)));
            X = [plines; plines]; Y = ywin'*ones(1,length(plines));
            line(ax,X,Y,'color',[0.55 0 0.65],'hittest','off','linewidth',2);    
        end
    end
    
    numchannels = size(FIDSDISPLAY.SIGNAL,1);
    if myScriptData.DISPLAYOFFSET == 1
        chend = numchannels - max([floor(ywin(1)) 0]);
        chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
    else
        chstart = 1;
        chend = numchannels;
    end
    
    for p=chstart:chend
        k = startframe:endframe;
        color = FIDSDISPLAY.COLORLIST{FIDSDISPLAY.GROUP(p)};
        if FIDSDISPLAY.LEADINFO(p) > 0
            color = [0 0 0];
            if FIDSDISPLAY.LEADINFO(p) > 3
                color = [0.35 0.35 0.35];
            end
        end
        
        plot(ax,FIDSDISPLAY.TIME(k),FIDSDISPLAY.SIGNAL(p,k),'color',color,'hittest','off');
        if (myScriptData.DISPLAYLABELF == 1)&&(chend-chstart < 30) && (FIDSDISPLAY.YWIN(2) >= numchannels-p+1),
            text(ax,FIDSDISPLAY.XWIN(1),numchannels-p+1,FIDSDISPLAY.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
        end
    end
    
    set(FIDSDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);
    
    xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xlen < (1/myScriptData.SAMPLEFREQ), xslider = 0.99999; else xslider = (xwin(1)-xlim(1))/xlen; end
    if xlen >= (1/myScriptData.SAMPLEFREQ), xfill = (xwin(2)-xwin(1))/xlen; else xfill = myScriptData.SAMPLEFREQ; end
    xinc = median([(1/myScriptData.SAMPLEFREQ) xfill/2 0.99999]);
    xfill = median([(1/myScriptData.SAMPLEFREQ) xfill myScriptData.SAMPLEFREQ]);
    xslider = median([0 xslider 0.99999]);
    set(FIDSDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

    ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if ylen < (1/myScriptData.SAMPLEFREQ), yslider = 0.99999; else yslider = ywin(1)/ylen; end
    if ylen >= (1/myScriptData.SAMPLEFREQ), yfill = (ywin(2)-ywin(1))/ylen; else yfill =myScriptData.SAMPLEFREQ; end
    yinc = median([(1/myScriptData.SAMPLEFREQ) yfill/2 0.99999]);
    yfill = median([(1/myScriptData.SAMPLEFREQ) yfill myScriptData.SAMPLEFREQ]);
    yslider = median([0 yslider 0.99999]);
    set(FIDSDISPLAY.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);
    
    FIDSDISPLAY.EVENTS{1}.handle = [];
    FIDSDISPLAY.EVENTS{2}.handle = [];
    FIDSDISPLAY.EVENTS{3}.handle = [];
    
    DisplayFiducials;
    
end


    
    
   
function Zoom(handle)

    global FIDSDISPLAY;

    value = get(handle,'value');
    parent = get(handle,'parent');
    switch value
        case 0
            set(parent,'WindowButtonDownFcn','myFidsDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','myFidsDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','myFidsDisplay(''ButtonUp'',gcbf)',...
               'pointer','arrow');
            set(handle,'string','Zoom OFF');
            FIDSDISPLAY.ZOOM = 0;
        case 1
            set(parent,'WindowButtonDownFcn','myFidsDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','myFidsDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','myFidsDisplay(''ZoomUp'',gcbf)',...
               'pointer','crosshair');
            set(handle,'string','Zoom ON');
            FIDSDISPLAY.ZOOM = 1;
    end
end
    
    
function ZoomDown(handle)

    global FIDSDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    if ~strcmp(seltype,'alt')
        pos = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P1 = pos(1,1:2); P2 = P1;
        FIDSDISPLAY.P1 = P1;
        FIDSDISPLAY.P2 = P2;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    FIDSDISPLAY.ZOOMBOX = line('parent',FIDSDISPLAY.AXES,'XData',X,'YData',Y,'Color','k','HitTest','Off');
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
end
    
function ZoomMotion(handle)
    global FIDSDISPLAY;
    if ishandle(FIDSDISPLAY.ZOOMBOX)
	    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([FIDSDISPLAY.XLIM point(1,1)]); P2(2) = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.P2 = P2;
        P1 = FIDSDISPLAY.P1;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    set(FIDSDISPLAY.ZOOMBOX,'XData',X,'YData',Y);
        drawnow;
    end
end
    
function ZoomUp(handle)
   
    global FIDSDISPLAY;
    if ishandle(FIDSDISPLAY.ZOOMBOX)
        point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([FIDSDISPLAY.XLIM point(1,1)]); P2(2) = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.P2 = P2; P1 = FIDSDISPLAY.P1;
        if (P1(1) ~= P2(1)) && (P1(2) ~= P2(2))
            FIDSDISPLAY.XWIN = sort([P1(1) P2(1)]);
            FIDSDISPLAY.YWIN = sort([P1(2) P2(2)]);
        end
        delete(FIDSDISPLAY.ZOOMBOX);
   	    UpdateDisplay(handle);
    end
end   

    
    
function ButtonDown(handle)
   	%callback for mouse click   
   % - checks if mouseclick is in winy/winx
   % - checks if no right click:
   %        - if yes: events=FindClosestEvents(events,t)
   %           - if event.sel(1)>1 (if erste oder zweite linie gewählt):
   %               - SetClosestEvent
   %        - else: AddEvent
   % - if right click: events=AddEvent(events,t)
   % - update the .EVENTS
    global FIDSDISPLAY;
    
    seltype = get(gcbf,'SelectionType');   % double click, right click etc
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS}; %local, group, or global fids
    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
    t = point(1,1); y = point(1,2);
    
    xwin = FIDSDISPLAY.XWIN;
    ywin = FIDSDISPLAY.YWIN;
    if (t>xwin(1))&&(t<xwin(2))&&(y>ywin(1))&&(y<ywin(2))     % if mouseclick within axes
        if ~strcmp(seltype,'alt')                         % if  no a "right click"
      		events = FindClosestEvent(events,t,y);       % update sel, sel1, sel2
            if events.sel(1) > 0
                events = SetClosestEvent(events,t,y);    % 
    	    else
                events = AddEvent(events,t,y);        % this gets apparently never called..
	        end
        else
         	events = AddEvent(events,t,y);
        end
    end
    FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
end   

    
function ButtonMotion(handle)
    % as long as something is selected (sel>0), continuously setClosestEvent.    
    global FIDSDISPLAY;
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};  
	if events.sel(1) > 0
        point = get(FIDSDISPLAY.AXES,'CurrentPoint');
        t = median([FIDSDISPLAY.XLIM point(1,1)]);
        y = median([FIDSDISPLAY.YLIM point(1,2)]);
        FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = SetClosestEvent(events,t,y);
    end
end
    
function ButtonUp(handle)
   % - get the current event
   % - if some event is selected (sel>0): SetClosestEvent
   % - set sel=sel2=sel3=0
   % - do some Activation/Recovery stuff (TODO: remove this?)
   % - Set the 'Choose Fiducials' listbox to NEWFIDSTYPE (necessary if
   % looping is activated)
    global FIDSDISPLAY  myScriptData;
    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};  
    if events.sel(1) > 0
 	    point = get(FIDSDISPLAY.AXES,'CurrentPoint');
	    t = median([FIDSDISPLAY.XLIM point(1,1)]);
        y = median([FIDSDISPLAY.YLIM point(1,2)]);
        events = SetClosestEvent(events,t,y); 
        sel = events.sel;
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
        FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;

        if (events.type(sel) == 2) && (myScriptData.FIDSAUTOACT == 1), DetectActivation(handle); end
        if (events.type(sel) == 3) && (myScriptData.FIDSAUTOREC == 1), DetectRecovery(handle); end
    end
    
    set(findobj(allchild(handle),'tag','FIDSTYPE'),'value',find(events.num == FIDSDISPLAY.NEWFIDSTYPE)); %in case fiducial was looped
    
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FindClosestEvent               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        

 function events = FindClosestEvent(events,t,y)
    % returns events untouched, exept that sel1, sel2 sel3 are changed:
    % sel=1 => erster balken am nächsten zu input t,  sel=2  =>2. balken am nächstn  
    % sel2=1  => erste Strich von balken am nächsten,  sel2=2  => zweiter strich näher
    % alle sel sind 0, falls isempty(value)
    %sel3 ist bei global gleich 1, ansonsten ist sel3 glaub lead..
    global FIDSDISPLAY;
 
    if isempty(events.value)                                       %sels are all 0 if first time
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
        return
    end
    
    value=events.value;
    if FIDSDISPLAY.MODE==1
        bl_indices=find(events.type==6);
        value(:,bl_indices,:)=100000;  % give baseline values arbitrary nubers, so they are not selected
    end
            
    switch events.class
        case 1
            tt = abs(permute(value(1,:,:),[3 2 1])-t);   % tt=[ AbstZu1StrOf1Line, AbstZu1StrOf2Line; AbstZu2StrOf1Line, AbstZu2StrOf2Line], abstand von mouseclick (2x2x1) matrix)
            [events.sel2,events.sel] = find(tt == min(tt(:)));   
            events.sel = events.sel(1);         % sel=1 => erster balken am nächsten,  sel=2  =>2. balken am nächstn                 
            events.sel2 = events.sel2(1);       % sel2=1  => erste Strich von balken am nächsten,  sel2=2  => zweiter strich näher
            events.sel3 = 1;

        case 2
            numchannels = size(FIDSDISPLAY.SIGNAL,1);
            ch = median([ 1 numchannels-floor(y)  numchannels]);
            group = FIDSDISPLAY.GROUP(ch);
            tt = abs(permute(value(group,:,:),[3 2 1])-t);
            [events.sel2,events.sel] = find(tt == min(tt(:)));
            events.sel = events.sel(1);
            events.sel2 = events.sel2(1);
            events.sel3 = group;
        case 3
             numchannels = size(FIDSDISPLAY.SIGNAL,1);
            ch = median([ 1 numchannels-floor(y)  numchannels]);
            lead = FIDSDISPLAY.LEAD(ch);
            tt = abs(permute(value(lead,:,:),[3 2 1])-t);
            [events.sel2,events.sel] = find(tt == min(tt(:)));
            events.sel = events.sel(1);
            events.sel2 = events.sel2(1);
            events.sel3 = lead;
    end
    if FIDSDISPLAY.MODE==1
        if find(events.sel==bl_indices)
            events.sel=0;
            events.sel2=0;
            events.sel3=0;
        end
    end
    
    events.latestEvent=[events.sel, events.sel2, events.sel3];  % needed in keypress fcn
    
 end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SetClosestEvent                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = SetClosestEvent(events,t,~)
    % - sets/redraws the patch identified by sel,sel1,sel3 (which are set by FindClosestEvent)
    %   at the new value t 
    % - updates the events. values corresponding to that patch
    % if sel==0 it returns imediatly
    
    
    s = events.sel;
    s2 = events.sel2;
    s3 = events.sel3;

    if s(1) == 0, return; end
    
    switch events.typelist(events.type(s))
               case 1
                    for w=s3
                        if (events.handle(w,s) > 0)&&(ishandle(events.handle(w,s))), set(events.handle(w,s),'XData',[t t]); end
                        events.value(w,s,[1 2]) = [t t];
                    end
                    %drawnow;
                case 2
                    for w=s3
                        events.value(w,s,s2) = t;
                        t1 = events.value(w,s,1);
                        t2 = events.value(w,s,2);
                        if (events.handle(w,s) > 0)&&(ishandle(events.handle(w,s))), set(events.handle(w,s),'XData',[t1 t1 t2 t2]); end
                    end
                    %drawnow;  
                case 3
                    for w=s3
                        dt = diff(events.value(w,s,[s2 (3-s2)]));
                        events.value(w,s,s2) = t; events.value(w,s,(3-s2)) = t+dt;
                        t1 = events.value(w,s,1);
                        t2 = events.value(w,s,2);
                        if (events.handle(w,s) > 0)&&(ishandle(events.handle(w,s))),  set(events.handle(w,s),'XData',[t1 t1 t2 t2]); end
                    end
                    %drawnow;  
    end
end
 
 function events = DPeaks(signal,threshold,detectionwidth)

    if nargin == 2
        detectionwidth = 0;
    end
    
    nsamples = size(signal,2);
   
    if detectionwidth > 0
   
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

    for i = 1:size(intervalstart,2)
        S = signal(intervalstart(i):intervalend(i));
        [~,ind] = max(S);
        events(i) = ind(max([1 round(length(ind)/2)])) + intervalstart(i) - 1;
    end
    
 end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddEvent                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = AddEvent(events,t,~)
% adds a new event to the events..
% - gets the newtype (the unique number indicating the type of fiducial to be added)
% - sets a new entry in events.value with values of addet event
% - appends newtype to the event.type list
% - sets sel, sel1, sel2, so that they represent the new addet event
% - draw the new event
% - if LoopFiducials is activated, set newtype to next type
  
  global FIDSDISPLAY myScriptData;
  newtype = FIDSDISPLAY.NEWFIDSTYPE;  % newtype is 1,2, ..9, 10. z.b. 1 for 'P-wave'

  switch(events.typelist(newtype))   % what type of patch is to be drawn?
      case 1
          events.value(1:events.maxn,end+1,:) = t*ones(events.maxn,1,2);   % set t as new value
          events.type(end+1) = newtype;                                    % add newtype as new entry to events.type
          events.handle(1:events.maxn,end+1) = zeros(events.maxn,1);
          events.sel = length(events.type);                              % set the sel values to current added line
          events.sel2 = 1;
          events.sel3 = 1:events.maxn;
      case 2
          events.value(1:events.maxn,end+1,:) = t*ones(events.maxn,1,2);  
          events.type(end+1) = newtype;
          events.handle(1:events.maxn,end+1) = zeros(events.maxn,1);       % handles initialisieren
          events.sel = length(events.type);
          events.sel2 = 2;
          events.sel3 = 1:events.maxn;
      case 3
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
  switch events.class
      case 1
            switch events.typelist(events.type(s))
                case 1 % just a line (for eg QRS-Peaks)
                    v = events.value(1,s,1);
                    events.handle(1,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ywin,'Color',events.colorlist{events.type(s)},'hittest','off','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                case {2,3} % interval fiducial/ fixed intereval fiducial
                    v = events.value(1,s,1);
                    v2 = events.value(1,s,2); %TODO: shouldnt v2=v1+baseline for case 3? when addet first time
                    events.handle(1,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ywin ywin([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
            end
        case 2
          numchannels = size(FIDSDISPLAY.SIGNAL,1);
          chend = numchannels - max([floor(ywin(1)) 0]);
          chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
          index = chstart:chend;
          ch = [];
          
          for q=1:max(FIDSDISPLAY.LEADGROUP)
              nindex = index(FIDSDISPLAY.LEADGROUP(index)==q);
              if isempty(nindex), continue; end
              ydata = numchannels-[min(nindex)-1 max(nindex)];
              switch events.typelist(events.type(s))
                  case 1 % normal fiducial
                      v = events.value(q,s,1);
                      events.handle(q,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',events.colorlist{events.type(s)},'hittest','off','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                  case {2,3} % interval fiducial/ fixed intereval fiducial
                      v = events.value(q,s,1);
                      v2 = events.value(q,s,2);
                      events.handle(q,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
              end
              ch = [ch q];
          end
          
      case 3
           numchannels = size(FIDSDISPLAY.SIGNAL,1);
           chend = numchannels - max([floor(ywin(1)) 0]);
           chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
           index = FIDSDISPLAY.LEAD(chstart:chend);
           ch = [];
           
           for q=index
               ydata = numchannels-[q-1 q];
               switch events.typelist(events.type(s))
                  case 1 % normal fiducial
                      v = events.value(q,s,1);
                      events.handle(q,s) = line('parent',events.axes,'Xdata',[v v],'Ydata',ydata,'Color',events.colorlist{events.type(s)},'hittest','off','linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
                  case {2,3} % interval fiducial/ fixed intereval fiducial
                      v = events.value(q,s,1);
                      v2 = events.value(q,s,2);
                      events.handle(q,s) = patch('parent',events.axes,'Xdata',[v v v2 v2],'Ydata',[ydata ydata([2 1])],'FaceColor',events.colorlist{events.type(s)},'hittest','off','FaceAlpha', 0.4,'linewidth',events.linewidth{events.type(s)},'linestyle',events.linestyle{events.type(s)});
              end
              ch =[ch q];
          end
  end
  % drawnow;
  
  if myScriptData.FIDSLOOPFIDS ==  1 && FIDSDISPLAY.MODE == 1
      loop_order=myScriptData.LOOP_ORDER;
      if isempty(loop_order)
          loop_order=1;
      end
      num=FIDSDISPLAY.EVENTS{1}.num;
      idx=find(num(loop_order)==FIDSDISPLAY.NEWFIDSTYPE);
 
      if isempty(idx)
          return
      elseif idx==length(loop_order)
        FIDSDISPLAY.NEWFIDSTYPE = num(loop_order(1));
      else
        FIDSDISPLAY.NEWFIDSTYPE = num(loop_order(idx+1));
      end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DeleteEvent                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = DeleteEvent(events)
    % not the callback! this deletes the handle of the currently selected
    % event (and corresponding event.value)
    if events.sel == 0
        return
    else
        s = events.sel;
        events.value(:,s,:) = [];
        events.type(s) = [];
        index = events.handle(:,s) > 0;
        delete(events.handle(index,s));
        events.handle(:,s) = [];
        events.sel = 0;
        events.sel2 = 0;
        events.sel3 = 0;
    end
            
   % drawnow;
end

function KeyPress(handle)
%callback for KeyPress
    global myScriptData FIDSDISPLAY;

    key = real(get(handle,'CurrentCharacter'));
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    
    switch key(1)
        case {8, 127}  % delete and backspace keys
            %delete current event
	        
            obj = findobj(allchild(handle),'tag','DISPLAYZOOM');
            value = get(obj,'value');
            if value == 0 
                point = get(FIDSDISPLAY.AXES,'CurrentPoint');
                xwin = FIDSDISPLAY.XWIN;
                ywin = FIDSDISPLAY.YWIN;
                t = point(1,1); y = point(1,2);
                if (t>xwin(1))&&(t<xwin(2))&&(y>ywin(1))&&(y<ywin(2))
                    events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};
                    events = FindClosestEvent(events,t,y);
                    events = DeleteEvent(events);   
                    FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
                end    
            end	
        case {28,29}  %left and right arrow
            events = FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS};
            if isfield(events,'latestEvent')  %if event was selected
                % get the current position and change it accordingly
                t=events.value(events.latestEvent(3),events.latestEvent(1),events.latestEvent(2));    
                if key(1)==28
                    t=t-(0.5/myScriptData.SAMPLEFREQ);
                else
                    t=t+(0.5/myScriptData.SAMPLEFREQ);
                end
                t = median([FIDSDISPLAY.XLIM t]);
                
                events.sel=events.latestEvent(1);
                events.sel2=events.latestEvent(2);
                events.sel3=events.latestEvent(3);
                
                events = SetClosestEvent(events,t); 
                sel=events.sel;
                events.sel=0;
                events.sel2=0;
                events.sel3=0;
                FIDSDISPLAY.EVENTS{FIDSDISPLAY.SELFIDS} = events;
                
                if (events.type(sel) == 2) && (myScriptData.FIDSAUTOACT == 1), DetectActivation(handle); end
                if (events.type(sel) == 3) && (myScriptData.FIDSAUTOREC == 1), DetectRecovery(handle); end

            end
            drawnow;
        case 32    % spacebar
            Navigation(gcbf,'apply');
        case {81,113}    % q/QW
            Navigation(gcbf,'prev');
        case {87,119}    % w
            Navigation(gcbf,'stop');
        case {69,101}    % e
            Navigation(gcbf,'next');
        case {49,50,51,52,53,54,55,56,57}  % numbers 1 to 9
            FIDSDISPLAY.MODE
            if FIDSDISPLAY.MODE==1
                obj=findobj(allchild(handle),'Tag','FIDSTYPE');
                obj.Value=key(1)-48;
                SelFidsType(obj)
            end
    end

end


function DetectRecovery(handle)
%callback for DetectRecovery


%%%% some initialisation, setting the mouse pointer..
global TS myScriptData FIDSDISPLAY; 
pointer = get(handle,'pointer');
set(handle,'pointer','watch');    
tsindex = myScriptData.CURRENTTS;
numchannels = size(TS{tsindex}.potvals,1);



%%%% create [numchannel x 1] arrays qstart and qend is beginning/end of T-wave, 
%%%% initialise rec=zeroes(numchan,1)
qstart = zeros(numchannels,1);
qend = zeros(numchannels,1);
rec = ones(FIDSDISPLAY.EVENTS{3}.maxn,1)*(1/myScriptData.SAMPLEFREQ);  
ind = find(FIDSDISPLAY.EVENTS{1}.type == 3);
if ~isempty(ind)
    qstart = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),1)*ones(numchannels,1);
    qend   = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),2)*ones(numchannels,1);
end

numgroups = length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP});
ind = find(FIDSDISPLAY.EVENTS{2}.type == 3);  % find the T-wave events
if ~isempty(ind)
    for p=1:numgroups
        qstart(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}) = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),1);
        qend(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p})   = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),2);
    end
end    

ind = find(FIDSDISPLAY.EVENTS{3}.type == 3);
if ~isempty(ind)
    qstart = FIDSDISPLAY.EVENTS{3}.value(:,ind(1),1);
    qend = FIDSDISPLAY.EVENTS{3}.value(:,ind(1),2);
end

qs = min([qstart qend],[],2);
qe = max([qstart qend],[],2);

win = myScriptData.RECWIN;
deg = myScriptData.RECDEG;
neg = myScriptData.RECNEG;

for p=1:numgroups
    for q=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}
        if qs(q) > 0  %if T-wave is set..
            rec(q) = ARdetect(TS{tsindex}.potvals(q,round(myScriptData.SAMPLEFREQ*qs(q)):round(myScriptData.SAMPLEFREQ*qe(q))),win,deg,neg)/myScriptData.SAMPLEFREQ + qs(q);
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

end
    

function DetectActivation(handle)
   % callback to 'Detect Activation'. Is also called when autodetect is
   % on..
   
   
   %%%% load globals and set mouse arrow to waiting
    global TS myScriptData FIDSDISPLAY;
    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    
    
    %%%% get current tsIndex,  set qstart=qend=zeros(numchannel,1),
    %%%% act=(1/myScriptData.SAMPLEFREQ)*ones(numleads,1)
    tsindex = myScriptData.CURRENTTS;
    numchannels = size(TS{tsindex}.potvals,1);
    qstart = zeros(numchannels,1);
    qend = zeros(numchannels,1);
    act = ones(FIDSDISPLAY.EVENTS{3}.maxn,1)*(1/myScriptData.SAMPLEFREQ);
    
    
    %%%% qstart/end=QRS-Komplex-start/end-timeframe as saved in
    %%%% events.value. Check for global, group, local..
    ind = find(FIDSDISPLAY.EVENTS{1}.type == 2);
    if ~isempty(ind)
        qstart = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),1)*ones(numchannels,1);
        qend   = FIDSDISPLAY.EVENTS{1}.value(1,ind(1),2)*ones(numchannels,1);
    end   
    numgroups = length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP});
    ind = find(FIDSDISPLAY.EVENTS{2}.type == 2);
    if ~isempty(ind)
        for p=1:numgroups
            qstart(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}) = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),1);
            qend(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p})   = FIDSDISPLAY.EVENTS{2}.value(p,ind(1),2);
        end
    end
    
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 2);
    if ~isempty(ind)
        qstart = FIDSDISPLAY.EVENTS{3}.value(:,ind(1),1);
        qend = FIDSDISPLAY.EVENTS{3}.value(:,ind(1),2);
    end
    
    
    
    %%% qs and qe are qstart/qend, but 'sorted', thus qs(i)<qe(i) for all i
    qs = min([qstart qend],[],2);
    qe = max([qstart qend],[],2);
    

    
    %%%% init win/deg/neg
    win = myScriptData.ACTWIN;
    deg = myScriptData.ACTDEG;
    neg = myScriptData.ACTNEG;

    %%%% find act for all leads within QRS using ARdetect() 
    for p=1:numgroups
        for q=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}
         %for each lead in each group = for all leads..  
            if qe(q) > qs(q)      % if not qe=qs=0 (as initialised -> if QRS was previously selected)
                if isfield(TS{tsindex},'noisedrange')
                    % anton: act(q)=ARdetec(potval(p, qs:qe), win,
                    % deg,neg,noisedrange(q))  /myScriptData.SAMPLEFREQ + qs
                    
                    [act(q)] = (ARdetect(TS{tsindex}.potvals(q,round(myScriptData.SAMPLEFREQ*qs(q)):round(myScriptData.SAMPLEFREQ*qe(q))),win,deg,neg,TS{tsindex}.noisedrange(q))-1)/myScriptData.SAMPLEFREQ + qs(q);
                    %[act(q),dvdt] = (ARdetect(TS{tsindex}.potvals(q,round(myScriptData.SAMPLEFREQ*qs(q)):round(myScriptData.SAMPLEFREQ*qe(q))),win,deg,neg,TS{tsindex}.noisedrange(q))-1)/myScriptData.SAMPLEFREQ + qs(q);
                    %TS{tsindex}.dvdt(q) = dvdt;
                else
                    [act(q)] = (ARdetect(TS{tsindex}.potvals(q,round(myScriptData.SAMPLEFREQ*qs(q)):round(myScriptData.SAMPLEFREQ*qe(q))),win,deg,neg)-1)/myScriptData.SAMPLEFREQ + qs(q);
                    %[act(q),dvdt] = (ARdetect(TS{tsindex}.potvals(q,round(myScriptData.SAMPLEFREQ*qs(q)):round(myScriptData.SAMPLEFREQ*qe(q))),win,deg,neg)-1)/myScriptData.SAMPLEFREQ + qs(q);
                    %TS{tsindex}.dvdt(q) = dvdt;
                end
            end
        end
    end
    
    %%%% put the act in event{3}.values  and  DisplayFiducials
    ind = find(FIDSDISPLAY.EVENTS{3}.type == 7);
    if isempty(ind), ind = length(FIDSDISPLAY.EVENTS{3}.type)+1;end    
    FIDSDISPLAY.EVENTS{3}.value(:,ind,1) = act;
    FIDSDISPLAY.EVENTS{3}.value(:,ind,2) = act;
    FIDSDISPLAY.EVENTS{3}.type(ind) = 7;
    DisplayFiducials;
    
    set(handle,'pointer',pointer);
    
end
    

function scrollFcn(handle, eventData)
    diff=(-1)*eventData.VerticalScrollCount*0.05;
    
    xslider=findobj(allchild(handle),'tag','SLIDERY');
    value=get(xslider,'value');
    
    value=value+diff;
    
    if value > 1, value=1; end
    if value < 0, value=0; end
    
    set(xslider,'value',value)
    
    UpdateSlider(xslider)
end
 
 %function [x,dvdt] = ARdetect(sig,win,deg,pol,ndrange)
  function [x] = ARdetect(sig,win,deg,pol,ndrange)
   if nargin == 4
        ndrange = 0;
   end
 
   %%%% if sigdrange to small compared to noisedrange (ndrange), return
   %%%% x=len(sig)
   sigdrange = max(sig)-min(sig);  
   if (sigdrange <= 1.75*ndrange)
        x = length(sig);
        return;
   end
   
   %make sure win is uneven
   if mod(win,2) == 0, win = win + 1; end
   
   %%%% return x=1, if len(sig)<win
   if length(sig) < win, x=1; return; end
 
    % Detection of the minimum derivative
    % Use a window of 5 frames and fit a 2nd order polynomial
    
    
    
    cen = ceil(win/2);
    X = zeros(win,(deg+1));
    L = [-(cen-1):(cen-1)]';
    for p=1:(deg+1)
        X(:,p) = L.^((deg+1)-p);
    end
    
    E = (X'*X)\X';

    sig = [sig sig(end)*ones(1,cen-1)];
    
    a = filter(E(deg,[win:-1:1]),1,sig);
    dy = a(cen:end);

    if pol == 1
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
    
  end
    
    
%  function x = polymin(sig)
% 
%     % Detection of the first derivative
%     % Use a window of 7 frames and fit a 3rd order polynomial
% 
%     deg = 3;
%     win = 7;
%     
%     if length(sig) < win, x=1; return; end
%     
%     % Detection of the minimum derivative
%     % Use a window of 5 frames and fit a 2nd order polynomial
%     
%     cen = ceil(win/2);
%     X = zeros(win,(deg+1));
%     L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
%     E = inv(X'*X)*X';
% 
%     sig = [sig sig(end)*ones(1,cen-1)];
%     
%     a = filter(E(deg,[win:-1:1]),1,sig);
%     dy = a(cen:end);
% 
%     [mv,mi] = min(dy(cen:end-cen));
%     mi = mi(1)+(cen-1);
%     
%     win2 = 5;
%     deg2 = 2;
%     
%     cen2 = ceil(win2/2);
%     L2 = [-(cen-1):(cen-1)]';
%     for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
%     c = inv(X2'*X2)*X2'*(dy(L2+mi)');
%     
%     if c(1) == 0, dx = 0; else dx = -c(2)/(2*c(1)); end
%        
%     x = mi+dx-1;
%    
%     return
    
    
%  function x = polymax(sig)
% 
%     % Detection of the first derivative
%     % Use a window of 7 frames and fit a 3rd order polynomial
%   
%     deg = 3;
%     win = 7;
%     
%     if length(sig) < win, x=1; return; end
% 
% 
%     % Detection of the minimum derivative
%     % Use a window of 5 frames and fit a 2nd order polynomial
%    
%     win2 = 5;
%     deg2 = 2;
%     
%     cen = ceil(win/2);
%     X = zeros(win,(deg+1));
%     L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
%     E = inv(X'*X)*X';
% 
%     sig = [sig sig(end)*ones(1,cen-1)];
%     
%     a = filter(E(deg,[win:-1:1]),1,sig);
%     dy = a(cen:end);
% 
%     [mv,mi] = max(dy(cen:end-cen));
%     mi = mi(1)+(cen-1);
%     
%     win2 = 5;
%     deg2 = 2;
%     
%     cen2 = ceil(win2/2);
%     L2 = [-(cen-1):(cen-1)]';
%     for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
%     c = inv(X2'*X2)*X2'*(dy(L2+mi)');
%     
%     if c(1) == 0, dx = 0; else dx = -c(2)/(2*c(1)); end
%     
%     x = mi+dx-1;    
    
    
function FidsToEvents
    %puts ts.fids  to .EVENTS

    global TS FIDSDISPLAY myScriptData;

    samplefreq = myScriptData.SAMPLEFREQ;
    isamplefreq = 1/samplefreq;
    
    if ~isfield(TS{myScriptData.CURRENTTS},'fids'), return; end
    fids = TS{myScriptData.CURRENTTS}.fids;
    if isempty(fids), return; end
    
    pval = []; qval = []; tval = []; Fval = [];
    pind = []; qind = []; tind = []; Find = [];
    xind=[]; xval=[];
    
    for q=1:length(fids)
        if fids(q).type == 1
            pind = [pind q]; pval = [pval mean(fids(q).value)*isamplefreq];    
        elseif fids(q).type == 4
            qind = [qind q]; qval = [qval mean(fids(q).value)*isamplefreq];
        elseif fids(q).type == 7
            tind = [tind q]; tval = [tval mean(fids(q).value)*isamplefreq];
        elseif fids(q).type == 21  %Delta F.. remove? TODO
            Find = [Find q]; Fval = [Fval mean(fids(q).value)*isamplefreq];
        elseif fids(q).type==27  % X-Wave
            xind = [xind q]; xval = [xval mean(fids(q).value)*isamplefreq];    
        end
    end
    
    numchannels = size(TS{myScriptData.CURRENTTS}.potvals,1);
            
    for p=1:length(fids)
        
        if FIDSDISPLAY.MODE == 2
            if (fids(p).type ~= 16)&&(fids(p).type ~= 20)&&(fids(p).type ~= 21)
                continue;
            end
        end
        
         switch fids(p).type
            case 0
                mtype = 1;
                val1 = fids(p).value*isamplefreq;
                if isempty(pind), continue; end
                ind2  = find(pval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(pval(ind2)==min(pval(ind2)));
                val2 = fids(pind(ind2(1))).value*isamplefreq;
            case 2
                mtype = 2;
                val1 = fids(p).value*isamplefreq;
                if isempty(qind), continue; end
                ind2  = find(qval > mean(val1)); 
                if isempty(ind2), continue; end
                ind2 = ind2(qval(ind2)==min(qval(ind2)));
                val2 = fids(qind(ind2(1))).value*isamplefreq;
            case 5
                mtype = 3;
                val1 = fids(p).value*isamplefreq;
                if isempty(tind), continue; end
                ind2  = find(tval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(tval(ind2)==min(tval(ind2)));
                val2 = fids(tind(ind2(1))).value*isamplefreq;
            case 20
                mtype = 10;
                val1 = fids(p).value*isamplefreq;
                if isempty(Find), continue; end
                ind2  = find(Fval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(Fval(ind2)==min(Fval(ind2)));
                val2 = fids(Find(ind2(1))).value*isamplefreq;            
            case 3
                mtype = 4; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 6
                mtype = 5; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 16
                mtype = 6; val1 = fids(p).value*isamplefreq; val2 = val1+myScriptData.BASELINEWIDTH/samplefreq;
            case 10
                mtype = 7; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 13
                mtype = 8; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 14
                mtype = 9; val1 = fids(p).value*isamplefreq; val2 = val1;
            case 26     % X-Wave
                mtype = 11;
                val1 = fids(p).value*isamplefreq;
                if isempty(xind), continue; end
                ind2  = find(xval > mean(val1));
                if isempty(ind2), continue; end
                ind2 = ind2(xval(ind2)==min(xval(ind2)));
                val2 = fids(xind(ind2(1))).value*isamplefreq;
            case 25   %X-Peak
                mtype = 10; val1 = fids(p).value*isamplefreq; val2 = val1;
            otherwise
                continue;
        end
        
        
        if (length(val1) == numchannels)&&(length(val2) == numchannels)
            
            isgroup = 1;
            for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
                channels = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q};
                if(nnz(val1(channels)-val1(channels(1)))>0), isgroup = 0; end
                if(nnz(val2(channels)-val2(channels(1)))>0), isgroup = 0; end
            end
   
            if isgroup == 1
                gval1 = []; gval2 =[];
                for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
                    channels = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q};
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
        elseif (length(val1) ==1)&&(length(val2) == 1)
            FIDSDISPLAY.EVENTS{1}.value(:,end+1,1) = val1;
            FIDSDISPLAY.EVENTS{1}.value(:,end,2) = val2;
            FIDSDISPLAY.EVENTS{1}.type(end+1) = mtype;  
        end
    end
    end
    
function EventsToFids

    global TS FIDSDISPLAY myScriptData;

    samplefreq = myScriptData.SAMPLEFREQ;
    isamplefreq = (1/samplefreq);
    fids = [];
    fidset = {};
    
    %%%% store the fids Data from global,local,group fids from event.value in val1,val2,mtype 
    val1 = {};
    val2 = {};
    mtype = {};  
    % first the global fids
    for p=1:length(FIDSDISPLAY.EVENTS{1}.type)
        val1{end+1} = FIDSDISPLAY.EVENTS{1}.value(1,p,1)*samplefreq;
        val2{end+1} = FIDSDISPLAY.EVENTS{1}.value(1,p,2)*samplefreq;
        mtype{end+1} = FIDSDISPLAY.EVENTS{1}.type(p);
    end
    
    % now the group fids
    numchannels = size(TS{myScriptData.CURRENTTS}.potvals,1);
    for p=1:length(FIDSDISPLAY.EVENTS{2}.type)
        v1 = ones(numchannels,1);
        v2 = ones(numchannels,1);
        for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
            v1(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q}) = FIDSDISPLAY.EVENTS{2}.value(q,p,1)*samplefreq;
            v2(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{q}) = FIDSDISPLAY.EVENTS{2}.value(q,p,2)*samplefreq;
        end
        val1{end+1} = v1;
        val2{end+1} = v2;
        mtype{end+1} = FIDSDISPLAY.EVENTS{2}.type(p);
    end
    
    
    % now the local fids
    for p=1:length(FIDSDISPLAY.EVENTS{3}.type)
        val1{end+1} = FIDSDISPLAY.EVENTS{3}.value(:,p,1)*samplefreq;
        val2{end+1} = FIDSDISPLAY.EVENTS{3}.value(:,p,2)*samplefreq;
        mtype{end+1} = FIDSDISPLAY.EVENTS{3}.type(p);
    end 
    
    % val1{1:NumGlFids}=firstValueOfGlobalFids,
    % val1{NumGlFids+1:NumGlFids+1+NumGroupFids}=1xNumleads vectors with
    % 1th val of group fids
    % val1{end-NumLocalFids:end}= values  of local fids
    % val2 analogous.    mtype same, but with fiducial event.type instead of values.
    
    
    
    %%%% remove baseline (16) and 20,21 from ts.fids
    if FIDSDISPLAY.MODE == 2
        fids = TS{myScriptData.CURRENTTS}.fids;
        rem = [];
        for p=1:length(fids)
            if (fids(p).type == 16)||(fids(p).type == 20)||(fids(p).type == 21)
                rem = [rem p];
            end
        end    
        fids(rem) = [];
    end  
    
    %%%% for each added fiducial (of all types): add it to fids
    for p=1:length(val1)
        v1 = min([val1{p} val2{p}],[],2);
        v2 = max([val1{p} val2{p}],[],2);
        
        % if Baseline or Delta F -> continue/ignore
        if FIDSDISPLAY.MODE == 2
            if (mtype{p} ~= 6) &&(mtype{p} ~= 10)
                continue; % do not add that fiducial    
            end
        end
        
        
        % add fids.type, fids.value, fids.fidset,  translate from
        % event.type to fids.type
        switch mtype{p}
            case 1
                fids(end+1).value = v1;
                fids(end).type = 0;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 1;
                fids(end).fidset = 0;
            case 2
                fids(end+1).value = v1;
                fids(end).type = 2;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 4;
                fids(end).fidset = 0;
            case 3
                fids(end+1).value = v1;
                fids(end).type = 5;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 7;
                fids(end).fidset = 0;
            case 4
                fids(end+1).value = v1;
                fids(end).type = 3;
                fids(end).fidset = 0;
            case 5
                fids(end+1).value = v1;
                fids(end).type = 6;
                fids(end).fidset = 0;
            case 6
                fids(end+1).value = v1;
                fids(end).type = 16;
                fids(end).fidset = 0;
            case 7
                fids(end+1).value = v1;
                fids(end).type = 10;
                fids(end).fidset = 0;
            case 8
                fids(end+1).value = v1;
                fids(end).type = 13;
                fids(end).fidset = 0;
            case 9
                fids(end+1).value = v1;
                fids(end).type = 14;
                fids(end).fidset = 0;
            case 10 % X-Peak
                fids(end+1).value = v1;
                fids(end).type = 25;
                fids(end).fidset = 0;
            case 11 % X-Wave
                fids(end+1).value = v1;
                fids(end).type = 26;
                fids(end).fidset = 0;
                fids(end+1).value = v2;
                fids(end).type = 27;
                fids(end).fidset = 0;
        end
    end
    
    TS{myScriptData.CURRENTTS}.fids = fids;
    TS{myScriptData.CURRENTTS}.fidset = fidset;
    
    end
    