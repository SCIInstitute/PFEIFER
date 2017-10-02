function handle = SliceDisplay(varargin)

% FUNCTION SliceDisplay()
%
% DEscription
% This is an internal function, that maintains the slicing/averaging selection
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
% SLICEDISPLAY. Do not alter any of these globals directly from the
% commandline

    if nargin > 1
        feval(varargin{1},varargin{2:end});
    else
        if nargin == 1
            handle = Init(varargin{1});
        else
            handle = Init;
        end
    end


function Navigation(handle,mode)
    %callback to all navigation buttons (including apply)
    global ScriptData
    
    switch mode
    case {'prev','next','stop'}
        ScriptData.NAVIGATION = mode;
        handle.DeleteFcn = '';
        delete(handle);
    case {'apply'}
        global TS;
        tsindex = ScriptData.CURRENTTS;
        if ~isfield(TS{tsindex},'selframes')
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        elseif isempty(TS{tsindex}.selframes)
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        else
            ScriptData.NAVIGATION = 'apply';
            handle.DeleteFcn = '';
            delete(handle);
        end
    otherwise
        error('unknown navigation command');
    end

    return

function SetupNavigationBar(handle)
    % sets up Filename, Filelabel etc in the top bar (right to navigation
    % bar)
    global ScriptData TS;
    tsindex = ScriptData.CURRENTTS;
    
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
    t.String=sprintf('ACQNUM: %d',ScriptData.ACQNUM);
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

    
function handle = Init(tsindex)

if nargin == 1
    global ScriptData;
    ScriptData.CURRENTTS = tsindex;
end

clear global SLICEDISPLAY;  % just in case.. 

handle = winSliceDisplay;
InitDisplayButtons(handle);
InitMouseFunctions(handle);

SetupNavigationBar(handle);
SetupDisplay(handle);
UpdateDisplay(handle);

    
function InitMouseFunctions(handle)

global SLICEDISPLAY;

if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = [0 1]; end
if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = [0 1]; end
if ~isfield(SLICEDISPLAY,'XLIM'), SLICEDISPLAY.XLIM = [0 1]; end
if ~isfield(SLICEDISPLAY,'YLIM'), SLICEDISPLAY.YLIM = [0 1]; end
if isempty(SLICEDISPLAY.YWIN), SLICEDISPLAY.YWIN = [0 1]; end


SLICEDISPLAY.ZOOM = 0;
events.box = [];
events.selected = 0;
events.axes = [];
events.timepos = [];
events.ylim = [0 1];
events.on = 1;
SLICEDISPLAY.EVENTS{1} = events;

SLICEDISPLAY.ZOOMBOX =[];
SLICEDISPLAY.P1 = [];
SLICEDISPLAY.P2 = [];
set(handle,'WindowButtonDownFcn','sliceDisplay(''ButtonDown'',gcbf)',...
           'WindowButtonMotionFcn','sliceDisplay(''ButtonMotion'',gcbf)',...
           'WindowButtonUpFcn','sliceDisplay(''ButtonUp'',gcbf)',...
           'KeyPressFcn','sliceDisplay(''KeyPress'',gcbf)',...
           'interruptible','off');

           


        
function InitDisplayButtons(handle)

global ScriptData SLICEDISPLAY;

button = findobj(allchild(handle),'tag','DISPLAYTYPE');
set(button,'string',{'Global RMS','Group RMS','Individual'},'value',ScriptData.DISPLAYTYPE);

button = findobj(allchild(handle),'tag','DISPLAYOFFSET');
set(button,'string',{'Offset ON','Offset OFF'},'value',ScriptData.DISPLAYOFFSET);

button = findobj(allchild(handle),'tag','DISPLAYLABEL');
set(button,'string',{'Label ON','Label OFF'},'value',ScriptData.DISPLAYLABEL);

button = findobj(allchild(handle),'tag','DISPLAYGRID');
set(button,'string',{'No Grid','Coarse Grid','Fine Grid'},'value',ScriptData.DISPLAYGRID);

button = findobj(allchild(handle),'tag','DISPLAYSCALING');
set(button,'string',{'Local','Global','Group'},'value',ScriptData.DISPLAYSCALING);

button = findobj(allchild(handle),'tag','DISPLAYGROUP');
group = ScriptData.GROUPNAME{ScriptData.CURRENTRUNGROUP};
ScriptData.DISPLAYGROUP = 1:length(group);
set(button,'string',group,'max',length(group),'value',ScriptData.DISPLAYGROUP);

if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = []; end
if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = []; end


%%%% set up the listeners for the sliders
sliderx=findobj(allchild(handle),'tag','SLIDERX');
slidery=findobj(allchild(handle),'tag','SLIDERY');

addlistener(sliderx,'ContinuousValueChange',@UpdateSlider);
addlistener(slidery,'ContinuousValueChange',@UpdateSlider);

function DisplayButton(handle)
%callback to all the display buttons

global ScriptData;

tag = handle.Tag;
switch tag
    case {'DISPLAYTYPE','DISPLAYOFFSET','DISPLAYSCALING','DISPLAYGROUP'}  % in case display needs to be reinitialised
        ScriptData.(tag) = handle.Value;
        parent = handle.Parent;
        SetupDisplay(parent);
        UpdateDisplay(parent);       
    case {'DISPLAYLABEL','DISPLAYGRID'}
        ScriptData.(tag) = handle.Value;  % display needs only updating. no recomputing of signal
        parent = handle.Parent;
        UpdateDisplay(parent); 
end



function SetupDisplay(handle)

pointer = handle.Pointer;
handle.Pointer = 'watch';
global TS ScriptData SLICEDISPLAY;

tsindex = ScriptData.CURRENTTS;

numframes = size(TS{tsindex}.potvals,2);
SLICEDISPLAY.TIME = [1:numframes]/ScriptData.SAMPLEFREQ;
SLICEDISPLAY.XLIM = [1 numframes]/ScriptData.SAMPLEFREQ;

if isempty(SLICEDISPLAY.XWIN)

    SLICEDISPLAY.XWIN = [median([0 SLICEDISPLAY.XLIM]) median([3000/ScriptData.SAMPLEFREQ SLICEDISPLAY.XLIM])];
else
    SLICEDISPLAY.XWIN = [median([SLICEDISPLAY.XWIN(1) SLICEDISPLAY.XLIM]) median([SLICEDISPLAY.XWIN(2) SLICEDISPLAY.XLIM])];
end


SLICEDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
SLICEDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
SLICEDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');


groups = ScriptData.DISPLAYGROUP;
numgroups = length(groups);

SLICEDISPLAY.NAME ={};
SLICEDISPLAY.GROUPNAME = {};
SLICEDISPLAY.GROUP = [];

switch ScriptData.DISPLAYTYPE
    case 1
        ch  = []; 
        for p=groups
            leads = ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{p};
            index = find(TS{tsindex}.leadinfo(leads)==0);
            ch = [ch leads(index)]; 
        end 
        SLICEDISPLAY.SIGNAL = sqrt(mean(TS{tsindex}.potvals(ch,:).^2));
        % MAKE IT AC COUPLED
        SLICEDISPLAY.SIGNAL = SLICEDISPLAY.SIGNAL-min(SLICEDISPLAY.SIGNAL);
        SLICEDISPLAY.LEADINFO = 0;
        SLICEDISPLAY.GROUP = 1;
        SLICEDISPLAY.LEAD = 0;
        SLICEDISPLAY.NAME = {'Global RMS'};
        SLICEDISPLAY.GROUPNAME = {'Global RMS'};
    case 2
        SLICEDISPLAY.SIGNAL = zeros(numgroups,numframes);
        for p=1:numgroups 
            leads = ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{groups(p)};
            index = find(TS{tsindex}.leadinfo(leads)==0);
            SLICEDISPLAY.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
            SLICEDISPLAY.SIGNAL(p,:) = SLICEDISPLAY.SIGNAL(p,:)-min(SLICEDISPLAY.SIGNAL(p,:));
            SLICEDISPLAY.NAME{p} = [ScriptData.GROUPNAME{ScriptData.CURRENTRUNGROUP}{groups(p)} ' RMS']; 
        end
        SLICEDISPLAY.GROUPNAME = SLICEDISPLAY.NAME;
        SLICEDISPLAY.GROUP = 1:numgroups;
        SLICEDISPLAY.LEAD = 0*SLICEDISPLAY.GROUP;
        SLICEDISPLAY.LEADINFO = zeros(numgroups,1);
    case 3
        SLICEDISPLAY.GROUP =[];
        SLICEDISPLAY.NAME = {};
        SLICEDISPLAY.LEAD = [];
        ch  = []; 
        for p=groups
            ch = [ch ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{p}]; 
            SLICEDISPLAY.GROUP = [SLICEDISPLAY.GROUP p*ones(1,length(ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{p}))]; 
            SLICEDISPLAY.LEAD = [SLICEDISPLAY.LEAD ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{p}];
            for q=1:length(ScriptData.GROUPLEADS{ScriptData.CURRENTRUNGROUP}{p}), SLICEDISPLAY.NAME{end+1} = sprintf('%s # %d',ScriptData.GROUPNAME{ScriptData.CURRENTRUNGROUP}{p},q); end 
        end
        for p=1:length(groups)
            SLICEDISPLAY.GROUPNAME{p} = [ScriptData.GROUPNAME{ScriptData.CURRENTRUNGROUP}{groups(p)}]; 
        end 
        SLICEDISPLAY.SIGNAL = TS{tsindex}.potvals(ch,:);
        SLICEDISPLAY.LEADINFO = TS{tsindex}.leadinfo(ch);
end

switch ScriptData.DISPLAYSCALING
    case 1
        k = max(abs(SLICEDISPLAY.SIGNAL),[],2);
        [m,~] = size(SLICEDISPLAY.SIGNAL);
        k(k==0) = 1;
        s = sparse(1:m,1:m,1./k,m,m);
        SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
    case 2
        k = max(abs(SLICEDISPLAY.SIGNAL(:)));
        [m,~] = size(SLICEDISPLAY.SIGNAL);
        if k > 0
            s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
            SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
        end
    case 3
        [m,~] = size(SLICEDISPLAY.SIGNAL);
        k = ones(m,1);
        for p=groups
            ind = find(SLICEDISPLAY.GROUP == p);
            k(ind) = max(max(abs(SLICEDISPLAY.SIGNAL(ind,:)),[],2));
        end
        s = sparse(1:m,1:m,1./k,m,m);
        SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
end

if ScriptData.DISPLAYTYPE == 3
    SLICEDISPLAY.SIGNAL = 0.5*SLICEDISPLAY.SIGNAL+0.5;
end

numsignal = size(SLICEDISPLAY.SIGNAL,1);
switch ScriptData.DISPLAYOFFSET
    case 1
        for p=1:numsignal
            SLICEDISPLAY.SIGNAL(p,:) = SLICEDISPLAY.SIGNAL(p,:)+(numsignal-p);
        end
        ylim = SLICEDISPLAY.YLIM;
        SLICEDISPLAY.YLIM = [0 numsignal];
        if ~isempty(setdiff(ylim,SLICEDISPLAY.YLIM))
            SLICEDISPLAY.YWIN = [max([0 numsignal-6]) numsignal];
        end
    case 2
        ylim = SLICEDISPLAY.YLIM;
        SLICEDISPLAY.YLIM = [0 1];
        if ~isempty(setdiff(ylim,SLICEDISPLAY.YLIM))
            SLICEDISPLAY.YWIN = [0 1];
        end
end

SLICEDISPLAY.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};

handle.Pointer = pointer;

    
function scrollFcn(handle, eventData)
    %callback for scrolling
    diff=(-1)*eventData.VerticalScrollCount*0.05;
    
    xslider=findobj(allchild(handle),'tag','SLIDERY');
    value=xslider.Value;
    
    value=value+diff;
    
    if value > 1, value=1; end
    if value < 0, value=0; end
    
    xslider.Value = value;
    
    UpdateSlider(xslider)
    

    
function UpdateSlider(handle,~)
    %callback to slider
    global SLICEDISPLAY;

    tag = handle.Tag;
    value = handle.Value;
    switch tag
        case 'SLIDERX'
            xwin = SLICEDISPLAY.XWIN;
            xlim = SLICEDISPLAY.XLIM;
            winlen = xwin(2)-xwin(1);
            limlen = xlim(2)-xlim(1);
            xwin(1) = median([xlim value*(limlen-winlen)+xlim(1)]);
            xwin(2) = median([xlim xwin(1)+winlen]);
            SLICEDISPLAY.XWIN = xwin;
       case 'SLIDERY'
            ywin = SLICEDISPLAY.YWIN;
            ylim = SLICEDISPLAY.YLIM;
            winlen = ywin(2)-ywin(1);
            limlen = ylim(2)-ylim(1);
            ywin(1) = median([ylim value*(limlen-winlen)+ylim(1)]);
            ywin(2) = median([ylim ywin(1)+winlen]);
            SLICEDISPLAY.YWIN = ywin;     
    end
    
    parent = handle.Parent;
    UpdateDisplay(parent);
    return;
    
    
function UpdateDisplay(handle)

global SLICEDISPLAY ScriptData TS;

ax=findobj(allchild(handle),'tag','AXES');


axes(ax);    
cla(ax);   

hold(ax,'on');

ywin = SLICEDISPLAY.YWIN;
xwin = SLICEDISPLAY.XWIN;
xlim = SLICEDISPLAY.XLIM;
ylim = SLICEDISPLAY.YLIM;



numframes = size(SLICEDISPLAY.SIGNAL,2);
startframe = max([floor(ScriptData.SAMPLEFREQ*xwin(1)) 1]);
endframe = min([ceil(ScriptData.SAMPLEFREQ*xwin(2)) numframes]);


numchannels = size(SLICEDISPLAY.SIGNAL,1);
if ScriptData.DISPLAYOFFSET == 1
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
else
    chstart = 1;
    chend = numchannels;
end


% DRAW THE GRID

if ScriptData.DISPLAYGRID > 1
    if ScriptData.DISPLAYGRID > 2
        clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(X,Y,'color',[0.9 0.9 0.9],'hittest','off');
    end
    clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
    X = [clines; clines]; Y = ywin'*ones(1,length(clines));
    line(X,Y,'color',[0.5 0.5 0.5],'hittest','off');
end

for p=chstart:chend
    k = startframe:endframe;
    color = SLICEDISPLAY.COLORLIST{SLICEDISPLAY.GROUP(p)};
    if SLICEDISPLAY.LEADINFO(p) > 0
        color = [0 0 0];
        if SLICEDISPLAY.LEADINFO(p) > 3
            color = [0.35 0.35 0.35];
        end
    end

    plot(ax,SLICEDISPLAY.TIME(k),SLICEDISPLAY.SIGNAL(p,k),'color',color,'hittest','off');
    if (ScriptData.DISPLAYOFFSET == 1) && (ScriptData.DISPLAYLABEL == 1)&&(chend-chstart < 30) && (SLICEDISPLAY.YWIN(2) >= numchannels-p+1)
        text(ax,SLICEDISPLAY.XWIN(1),numchannels-p+1,SLICEDISPLAY.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
    end
end

if (ScriptData.DISPLAYOFFSET == 2) && (ScriptData.DISPLAYLABEL ==1)
    for q=1:length(SLICEDISPLAY.GROUPNAME)
        color = SLICEDISPLAY.COLORLIST{q};
        text(ax,SLICEDISPLAY.XWIN(1),SLICEDISPLAY.YWIN(2)-(q*0.05*(SLICEDISPLAY.YWIN(2)-SLICEDISPLAY.YWIN(1))),SLICEDISPLAY.GROUPNAME{q},'color',color,'VerticalAlignment','top','hittest','off'); 
    end    
end


set(SLICEDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);

xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
if xlen < (1/ScriptData.SAMPLEFREQ), xslider = 0.999; else xslider = xwin(1)/xlen; end
xredlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
if xredlen ~= 0, xfill = (xwin(2)-xwin(1))/xredlen; else xfill = ScriptData.SAMPLEFREQ; end
xinc = median([0.01 xfill 0.999]);
xfill = median([0.01 xfill ScriptData.SAMPLEFREQ]);
xslider = median([1/ScriptData.SAMPLEFREQ xslider 0.999]);
set(SLICEDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
if ylen < (1/ScriptData.SAMPLEFREQ), yslider = 0.999; else yslider = ywin(1)/ylen; end
yredlen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
if yredlen ~= 0, yfill = (ywin(2)-ywin(1))/yredlen; else yfill =ScriptData.SAMPLEFREQ; end
yinc = median([0.0002 yfill 0.999]);
yfill = median([0.0002 yfill ScriptData.SAMPLEFREQ]);
yslider = median([(1/ScriptData.SAMPLEFREQ) yslider 0.999]);
set(SLICEDISPLAY.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);

events.box = [];
events.selected = 0;
events.axes = SLICEDISPLAY.AXES;
events.timepos = [];
events.ylim = SLICEDISPLAY.YWIN;
events.on = 1;

SLICEDISPLAY.EVENTS = {};
events.color = 'b'; SLICEDISPLAY.EVENTS{1} = events;
events.color = 'g'; SLICEDISPLAY.EVENTS{2} = events;
events.color = 'r'; SLICEDISPLAY.EVENTS{3} = events;

if isfield(TS{ScriptData.CURRENTTS},'selframes')
    events = SLICEDISPLAY.EVENTS{1}; events = AddEvent(events,(TS{ScriptData.CURRENTTS}.selframes/ScriptData.SAMPLEFREQ)); events.selected = 0; SLICEDISPLAY.EVENTS{1} = events;
end   

function Zoom(handle,mode)
    global SLICEDISPLAY;

    if nargin == 2, handle = findobj(allchild(handle),'tag','DISPLAYZOOM'); end
    
    value = handle.Parent;
    if nargin == 2, value = xor(value,1); end
    
    parent = handle.Parent;
    switch value
        case 0
            set(parent,'WindowButtonDownFcn','sliceDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','sliceDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','sliceDisplay(''ButtonUp'',gcbf)',...
               'pointer','arrow');
            set(handle,'string','(Z)oom OFF','value',value);
            SLICEDISPLAY.ZOOM = 0;
        case 1
            set(parent,'WindowButtonDownFcn','sliceDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','sliceDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','sliceDisplay(''ZoomUp'',gcbf)',...
               'pointer','crosshair');
            set(handle,'string','(Z)oom ON','value',value);
            SLICEDISPLAY.ZOOM = 1;
    end
    return
    
    
function ZoomDown(handle)
    
    global SLICEDISPLAY;
    
    seltype = handle.SelectionType;
    if ~strcmp(seltype,'alt')
        pos = SLICEDISPLAY.AXES.CurrentPoint;
        P1 = pos(1,1:2); P2 = P1;
        SLICEDISPLAY.P1 = P1;
        SLICEDISPLAY.P2 = P2;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    SLICEDISPLAY.ZOOMBOX = line('parent',SLICEDISPLAY.AXES,'XData',X,'YData',Y,'Color','k','HitTest','Off');
   	    drawnow;
    else
        xlim = SLICEDISPLAY.XLIM; ylim = SLICEDISPLAY.YLIM;
        xwin = SLICEDISPLAY.XWIN; ywin = SLICEDISPLAY.YWIN;
        xsize = max([2*(xwin(2)-xwin(1)) 1]);
        SLICEDISPLAY.XWIN = [ median([xlim xwin(1)-xsize/4]) median([xlim xwin(2)+xsize/4])];
        ysize = max([2*(ywin(2)-ywin(1)) 1]);
        SLICEDISPLAY.YWIN = [ median([ylim ywin(1)-ysize/4]) median([ylim ywin(2)+ysize/4])];
        UpdateDisplay(handle);
    end
    return
    
function ZoomMotion(handle)
  
    global SLICEDISPLAY;
    if ishandle(SLICEDISPLAY.ZOOMBOX)
	    point = SLICEDISPLAY.AXES.CurrentPoint;
        P2(1) = median([SLICEDISPLAY.XLIM point(1,1)]); P2(2) = median([SLICEDISPLAY.YLIM point(1,2)]);
        SLICEDISPLAY.P2 = P2;
        P1 = SLICEDISPLAY.P1;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    set(SLICEDISPLAY.ZOOMBOX,'XData',X,'YData',Y);
        drawnow;
    end
    return
    
function ZoomUp(handle)
   
    global SLICEDISPLAY;
    if ishandle(SLICEDISPLAY.ZOOMBOX)
        point = SLICEDISPLAY.AXES.CurrentPoint;
        P2(1) = median([SLICEDISPLAY.XLIM point(1,1)]); P2(2) = median([SLICEDISPLAY.YLIM point(1,2)]);
        SLICEDISPLAY.P2 = P2; P1 = SLICEDISPLAY.P1;
        if (P1(1) ~= P2(1))&&(P1(2) ~= P2(2))
            SLICEDISPLAY.XWIN = sort([P1(1) P2(1)]);
            SLICEDISPLAY.YWIN = sort([P1(2) P2(2)]);
        end
        delete(SLICEDISPLAY.ZOOMBOX);
   	    UpdateDisplay(handle);
    end
    return   

function SetBadLead(handle,lead)
    
    global SLICEDISPLAY ScriptData TS;
    
    if (ScriptData.DISPLAYTYPE == 3)&&(ScriptData.DISPLAYOFFSET==1)
        m = size(SLICEDISPLAY.SIGNAL,1);
        n = median([1 ceil(m-lead) m]);
        state = SLICEDISPLAY.LEADINFO(n);
        state = bitset(state,1,xor(bitget(state,1),1));
        SLICEDISPLAY.LEADINFO(n) = state;
        TS{ScriptData.CURRENTTS}.leadinfo(SLICEDISPLAY.LEAD(n)) = state;
        UpdateDisplay(handle);
    end
    
    return

function ButtonDown(handle)   
%callback for mouse click 
% - checks if right mouse click type (right click etc) is selected
% - checks if mouseclick is in winy/winx
%        - if yes: events=FindClosestEvents
%           - if event.sel(1)>1 (if erste oder zweite linie gewählt):
%               -yes: SetClosestEvent
%               - else: AddEvent
% - update the .EVENTS

global SLICEDISPLAY;

seltype = handle.SelectionType;

point = SLICEDISPLAY.AXES.CurrentPoint;
t = point(1,1); y = point(1,2);

events = SLICEDISPLAY.EVENTS{1}; 

xwin = SLICEDISPLAY.XWIN;
ywin = SLICEDISPLAY.YWIN;
if (t>xwin(1))&&(t<xwin(2))&&(y>ywin(1))&&(y<ywin(2))
    if ~strcmp(seltype,'alt')
        events = FindClosestEvent(events,t);
        if events.selected > 0
            events = SetClosestEvent(events,t);
        else
            events = AddEvent(events,t);
        end
    else
        events = AddEvent(events,t);
    end
end
SLICEDISPLAY.EVENTS{1} = events;


function ButtonMotion(handle)
        
global SLICEDISPLAY;

events = SLICEDISPLAY.EVENTS{1};  
if events.selected > 0
    point = SLICEDISPLAY.AXES.CurrentPoint;
    t = median([SLICEDISPLAY.XLIM point(1,1)]);
    SLICEDISPLAY.EVENTS{1} = SetClosestEvent(events,t);
end

    
function ButtonUp(handle)
% - events=EVENT{SD.SELEVENTS}
% - if events.selected > 0:
%        - get currentpoint -> setClosestEvent(events,t), set events.selected = 0

%        - set ts.selframes 
% -drawnow




global SLICEDISPLAY TS ScriptData;

events = SLICEDISPLAY.EVENTS{1};  
if events.selected > 0
    point = SLICEDISPLAY.AXES.CurrentPoint;
    t = median([SLICEDISPLAY.XLIM point(1,1)]);
    events = SetClosestEvent(events,t); 
    events.selected = 0;

    SLICEDISPLAY.EVENTS{1} = events;
    TS{ScriptData.CURRENTTS}.selframes = sort(round(events.timepos*ScriptData.SAMPLEFREQ)); 
end

drawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FindClosestEvent               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function events = FindClosestEvent(events,t)
    
   if ~isempty(events.timepos)
        tt = abs(events.timepos-t);
        events.selected = find(tt == min(tt));
        events.selected = events.selected(1);
        events.last_selected=events.selected;
    else
  	events.selected = 0;
    end
 return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SetClosestEvent                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = SetClosestEvent(events,t)

    if events.selected==1
      pos = events.timepos;
      set(events.box,'XData',[t t pos(2) pos(2)]);
      events.timepos(1) = t;
 %     drawnow;
    end
    if events.selected==2
      pos = events.timepos;
      set(events.box,'XData',[pos(1) pos(1) t t]);
      events.timepos(2) = t;
 %     drawnow;
    end
    
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddEvent                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = AddEvent(events,t)

if length(t) == 1, t =[t t]; end

if isempty(events.timepos)  
ypos = events.ylim;
events.box = patch('parent',events.axes,'XData',[t(1) t(1) t(2) t(2)],'YData',[ypos(1) ypos(2) ypos(2) ypos(1)],'FaceAlpha', 0.4,'FaceColor',events.color);
events.timepos = t; 
% drawnow;
else
set(events.box,'XData',[t(1) t(1) t(2) t(2)]);
events.timepos = t;
% drawnow;
end
events.selected=2;
    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DeleteEvent                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = DeleteEvent(events)

if events.selected == 0
  return
else
 events.timepos=[];
 delete(events.box);
 events.box=[];
 events.selected=0;
end    

function KeyPress(handle)

global ScriptData SLICEDISPLAY TS;

key = real(handle.CurrentCharacter);

if isempty(key), return; end
if ~isnumeric(key), return; end

switch key(1) 
    case {8, 127}  % delete and backspace keys
        % delete current selected frame
        obj = findobj(allchild(handle),'tag','DISPLAYZOOM');
        value = obj.Value;
        if value == 0
            point = SLICEDISPLAY.AXES.CurrentPoint;
            xwin = SLICEDISPLAY.XWIN;
            ywin = SLICEDISPLAY.YWIN;
            t = point(1,1); y = point(1,2);
            if (t>xwin(1))&&(t<xwin(2))&&(y>ywin(1))&&(y<ywin(2))
                events = SLICEDISPLAY.EVENTS{1};
                events = FindClosestEvent(events,t);
                events = DeleteEvent(events);   
                SLICEDISPLAY.EVENTS{1} = events;
                TS{ScriptData.CURRENTTS}.selframes = []; 
            end    
        end
    case {28,29}  %left and right arrow
            events = SLICEDISPLAY.EVENTS{1};  
            if isfield(events,'last_selected')  
                events.selected=events.last_selected;
                if events.last_selected==1
                    t=events.timepos(1);
                elseif events.last_selected==2
                    t=events.timepos(2);
                end

                if key(1)==28
                    t=t-(1/ScriptData.SAMPLEFREQ);
                else
                    t=t+(1/ScriptData.SAMPLEFREQ);
                end
                t = median([SLICEDISPLAY.XLIM t]);

                events = SetClosestEvent(events,t); 
                events.selected=0;

                SLICEDISPLAY.EVENTS{1} = events;
                TS{ScriptData.CURRENTTS}.selframes = sort(round(events.timepos*ScriptData.SAMPLEFREQ)); 
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
end

    

