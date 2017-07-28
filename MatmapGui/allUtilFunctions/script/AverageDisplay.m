function handle = AverageDisplay(varargin)

% FUNCTION AverageDisplay()
%
% DESCRIPTION
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

    if nargin > 1,
        feval(varargin{1},varargin{2:end});
    else
        if nargin == 1,
            handle = Init(varargin{1});
        else
            handle = Init;
        end
    end
return

function handle = Init(tsindex)

    if nargin == 1,
        global SCRIPT;
        SCRIPT.CURRENTTS = tsindex;
    end

    handle = winAverageDisplay;
    InitDisplayButtons(handle);
    InitAverageButtons(handle);
    InitMouseFunctions(handle);
    
    SetupNavigationBar(handle);
    SetupDisplay(handle);
    UpdateDisplay(handle);
    
    return

function Navigation(handle,mode)

    global SCRIPT;
    
    switch mode
    case {'apply'}
        global SCRIPT TS;
        tsindex = SCRIPT.CURRENTTS;
        SCRIPT.NAVIGATION = 'apply';
        set(handle,'DeleteFcn','');
        delete(handle);
    otherwise
        error('unknown navigation command');
    end

    return

function SetupNavigationBar(handle)

    return    
    
    
function InitMouseFunctions(handle)

    global SLICEDISPLAY;

    if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = [0 1]; end
    if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = [0 1]; end
    if ~isfield(SLICEDISPLAY,'XLIM'), SLICEDISPLAY.XLIM = [0 1]; end
    if ~isfield(SLICEDISPLAY,'YLIM'), SLICEDISPLAY.YLIM = [0 1]; end
    if isempty(SLICEDISPLAY.YWIN), SLICEDISPLAY.YWIN = [0 1]; end
    
    
    SLICEDISPLAY.ZOOM = 0;
    
    SLICEDISPLAY.ZOOMBOX =[];
    SLICEDISPLAY.P1 = [];
    SLICEDISPLAY.P2 = [];
    set(handle,'WindowButtonDownFcn','AverageDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','AverageDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','AverageDisplay(''ButtonUp'',gcbf)','KeyPressFcn','AverageDisplay(''KeyPress'',gcbf)','interruptible','off');
    return
           
    
function InitDisplayButtons(handle),

    global SCRIPT SLICEDISPLAY;
    
    button = findobj(allchild(handle),'tag','ADISPLAYTYPE');
    set(button,'string',{'global RMS','group RMS', 'single channel'},'value',SCRIPT.ADISPLAYTYPE);
    
    button = findobj(allchild(handle),'tag','ADISPLAYOFFSET');
    set(button,'string',{'Offset ON','Offset OFF','Offset CUSTOM'},'value',SCRIPT.ADISPLAYOFFSET);
    
    button = findobj(allchild(handle),'tag','ADISPLAYGRID');
    set(button,'string',{'No grid','Coarse grid','Fine grid'},'value',SCRIPT.ADISPLAYGRID);

    button = findobj(allchild(handle),'tag','ALEADNUM');
    set(button,'string',num2str(SCRIPT.ALEADNUM));

    button = findobj(allchild(handle),'tag','ADOFFSET');
    set(button,'string',num2str(SCRIPT.ADOFFSET));

    button = findobj(allchild(handle),'tag','ADISPLAYGROUP');
    group = SCRIPT.GROUPNAME;
    if (isempty(SCRIPT.ADISPLAYGROUP))|(SCRIPT.ADISPLAYGROUP == 0),
        SCRIPT.ADISPLAYGROUP = 1;
    end
    SCRIPT.ADISPLAYGROUP = intersect(SCRIPT.ADISPLAYGROUP,[1:length(group)]);
    set(button,'string',group,'max',1,'value',SCRIPT.ADISPLAYGROUP);

    if ~isfield(AVERAGEDISPLAY,'XWIN'), AVERAGEDISPLAY.XWIN = []; end
    if ~isfield(AVERAGEDISPLAY,'YWIN'), AVERAGEDISPLAY.YWIN = []; end
    
    return
    
function DisplayButton(handle)

    global SCRIPT;
    
    tag = get(handle,'tag');
    switch tag
        case {'ADISPLAYTYPE','ADISPLAYOFFSET','ADISPLAYGROUP'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            SetupDisplay(parent);
            UpdateDisplay(parent);       
        case {'ADISPLAYGRID'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            UpdateDisplay(parent); 
        case {'ALEADNUM'}
            SCRIPT = setfield(SCRIPT,tag,str2num(get(handle,'string')));
        case {'ADOFFSET'}
            SCRIPT = setfield(SCRIPT,tag,str2num(get(handle,'string')));
            SetupDisplay(parent);
            UpdateDisplay(parent);
    end

    return
    
    
    
function SetupDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    global TS SCRIPT AVERAGEDISPLAY;
    
    tsindex = SCRIPT.CURRENTTS;
    
    numframes = size(TS{tsindex}.potvals,2);
    AVERAGEDISPLAY.TIME = [1:numframes]*0.001;
    AVERAGEDISPLAY.XLIM = [1 numframes]*0.001;

    if isempty(AVERAGEDISPLAY.XWIN);
        AVERAGEDISPLAY.XWIN = [median([0 AVERAGEDISPLAY.XLIM]) median([1 AVERAGEDISPLAY.XLIM])];
    else
        AVERAGEDISPLAY.XWIN = [median([AVERAGEDISPLAY.XWIN(1) AVERAGEDISPLAY.XLIM]) median([AVERAGEDISPLAY.XWIN(2) AVERAGEDISPLAY.XLIM])];
    end
    
    AVERAGEDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
    AVERAGEDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
    AVERAGEDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');
    
    groups = SCRIPT.DISPLAYGROUP;
    numgroups = length(groups);
    
    AVERAGEDISPLAY.NAME ={};
    AVERAGEDISPLAY.GROUPNAME = {};
    AVERAGEDISPLAY.GROUP = [];
    
    switch SCRIPT.ADISPLAYTYPE,
        case 1,
            ch  = []; 
            groups = 1:length(SCRIPT.GROUPNAME);
            for p=groups, 
                leads = SCRIPT.GROUPLEADS{p};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                ch = [ch leads(index)]; 
            end 
            AVERAGEDISPLAY.SIGNAL = sqrt(mean(TS{tsindex}.potvals(ch,:).^2));
            AVERAGEDISPLAY.LEADINFO = 0;
            AVERAGEDISPLAY.GROUP = 1;
            AVERAGEDISPLAY.LEAD = 0;
            AVERAGEDISPLAY.NAME = {'Global RMS'};
            AVERAGEDISPLAY.GROUPNAME = {'Global RMS'};
        case 2,
            AVERAGEDISPLAY.SIGNAL = zeros(1,numframes);
            group = SCRIPT.ADISPLAYGROUP;
            leads = SCRIPT.GROUPLEADS{groups};
            index = find(TS{tsindex}.leadinfo(leads)==0);
            AVERAGEDISPLAY.SIGNAL = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
            AVERAGEDISPLAY.NAME = [SCRIPT.GROUPNAME{groups} ' RMS']; 
            AVERAGEDISPLAY.GROUPNAME = AVERAGEDISPLAY.NAME;
            AVERAGEDISPLAY.LEAD = 0;
            AVERAGEDISPLAY.LEADINFO = 0;
        case 3,
            lead = SCRIPT.ALEADNUM;
            AVERAGEDISPLAY.SIGNAL = TS{tsindex}.potvals(lead,:)
            AVERAGEDISPLAY.NAME = ['channel ' sprintf('%d',lead)]; 
            AVERAGEDISPLAY.GROUPNAME = AVERAGEDISPLAY.NAME;
            AVERAGEDISPLAY.LEAD = 0;
            AVERAGEDISPLAY.LEADINFO = TS{tsindex}.leadinfo(lead);           
    end
 
    k = max(abs(AVERAGEDISPLAY.SIGNAL),[],2);
    [m,n] = size(AVERAGEDISPLAY.SIGNAL);
    k(find(k==0)) = 1;
    s = sparse(1:m,1:m,1./k,m,m);
    AVERAGEDISPLAY.SIGNAL = s*AVERAGEDISPLAY.SIGNAL;    
    
    if SCRIPT.ADISPLAYTYPE == 3,
        AVERAGEDISPLAY.SIGNAL = 0.5*AVERAGEDISPLAY.SIGNAL+0.5;
    end
    
    AVERAGEDISPLAY.NUMAVERAGES = 0;
    AVERAGEDISPLAY.AVERAGE = [];
    AVERAGEDISPLAY.LINE = [];
    
    if isfield(TS{tsindex},'averagestart'),
        if length(TS{index}.averagestart) > 0,
            
            AVERAGEDISPLAY.NUMAVERAGES = length(TS{tsindex}.averagestart);
            numsignal = AVERAGEDISPLAY.NUMAVERAGES;
            lengthsignal = TS{tsindex}.averageend(1) - TS{tsindex}.averagestart(1);
    
            AVERAGEDISPLAY.AVERAGE = zeros(numsignal,lengthsignal+1);

            for p=1:length(TS{tsindex}.averagestart),
                AVERAGEDISPLAY.AVERAGE(p,:) = AVERAGE.SIGNAL(TS{tsindex}.averagestart:TS{tsindex}.averageend);
            end

        end
    end
    
    AVERAGEDISPLAY.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};
 
    switch SCRIPT.ADISPLAYOFFSET,
        case 1,
            doffset = 1;
        case 2,
            doffset = 0;
        case 3,
            doffset = SCRIPT.ADOFFSET;
    end
    AVERAGEDISPLAY.DOFFSET = doffset;
    
    numsignal = size(AVERAGEDISPLAY.AVERAGE,1);
    ylim = [0 (doffset*numsignal)+1];
    AVERAGEDISPLAY.YLIM = ylim;
    
    set(handle,'pointer',pointer);
    
    return

function UpdateSlider(handle)

    global AVERAGEDISPLAY;

    tag = get(handle,'tag');
    value = get(handle,'value');
    switch tag
        case 'SLIDERX'
            xwin = AVERAGEDISPLAY.XWIN;
            xlim = AVERAGEDISPLAY.XLIM;
            winlen = xwin(2)-xwin(1);
            limlen = xlim(2)-xlim(1);
            xwin(1) = median([xlim value*(limlen-winlen)+xlim(1)]);
            xwin(2) = median([xlim xwin(1)+winlen]);
            AVERAGEDISPLAY.XWIN = xwin;
       case 'SLIDERY'
            ywin = AVERAGEDISPLAY.YWIN;
            ylim = AVERAGEDISPLAY.YLIM;
            winlen = ywin(2)-ywin(1);
            limlen = ylim(2)-ylim(1);
            ywin(1) = median([ylim value*(limlen-winlen)+ylim(1)]);
            ywin(2) = median([ylim ywin(1)+winlen]);
            AVERAGEDISPLAY.YWIN = ywin;     
    end
    
    parent = get(handle,'parent');
    UpdateDisplay(parent);
    return;
    
function UpdateDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');

    global AVERAGEDISPLAY SCRIPT TS;
    
    axes(AVERAGEDISPLAY.AXES);
    cla;
    hold on;
    ywin = AVERAGEDISPLAY.YWIN;
    xwin = AVERAGEDISPLAY.XWIN;
    xlim = AVERAGEDISPLAY.XLIM;
    ylim = AVERAGEDISPLAY.YLIM;
    
    numframes = size(AVERAGEDISPLAY.AVERAGE,2);
    startframe = max([floor(1000*xwin(1)) 1]);
    endframe = min([ceil(1000*xwin(2)) numframes]);

    % DRAW THE GRID
    
    if SCRIPT.ADISPLAYGRID > 1,
        if SCRIPT.ADISPLAYGRID > 2,
            clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
            X = [clines; clines]; Y = ywin'*ones(1,length(clines));
            line(X,Y,'color',[0.9 0.9 0.9],'hittest','off');
        end
        clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(X,Y,'color',[0.5 0.5 0.5],'hittest','off');
    end
    
    doffset = AVERAGEDISPLAY.DOFFSET;
    
    numchannels = size(AVERAGEDISPLAY.AVERAGE,1);
    chend = numchannels - max([floor(doffset*ywin(1)-1) 0]);
    chstart = numchannels - min([ceil(doffset*ywin(2)+1) numchannels])+1;
    
    for p=chstart:chend,
        k = startframe:endframe;
        color = AVERAGEDISPLAY.COLORLIST{AVERAGEDISPLAY.GROUP(p)};
        if AVERAGEDISPLAY.LEADINFO(p) > 0,
            color = [0 0 0];
            if AVERAGEDISPLAY.LEADINFO(p) > 3,
                color = [0.35 0.35 0.35];
            end
        end
        
        plot(AVERAGEDISPLAY.TIME(k),AVERAGEDISPLAY.AVERAGE(p,k)+doffset*(p-1),'color',color,'hittest','off');
    end
   
    set(AVERAGEDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);
    
    xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xlen < 0.001, xslider = 0.999; else xslider = xwin(1)/xlen; end
    xredlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xredlen ~= 0, xfill = (xwin(2)-xwin(1))/xredlen; else xfill = 1000; end
    xinc = median([0.01 xfill 0.999]);
    xfill = median([0.01 xfill 1000]);
    xslider = median([0.001 xslider 0.999]);
    set(AVERAGEDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

    ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if ylen < 0.001, yslider = 0.999; else yslider = ywin(1)/ylen; end
    yredlen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if yredlen ~= 0, yfill = (ywin(2)-ywin(1))/yredlen; else yfill =1000; end
    yinc = median([0.01 yfill 0.999]);
    yfill = median([0.01 yfill 1000]);
    yslider = median([0.001 yslider 0.999]);
    set(AVERAGEDISPLAY.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);

    set(handle,'pointer',pointer);
    
    return
   

function Zoom(handle,mode)

    global AVERAGEDISPLAY;

    if nargin == 2, handle = findobj(allchild(handle),'tag','DISPLAYZOOM'); end
    
    value = get(handle,'value');
    if nargin == 2, value = xor(value,1); end
    
    parent = get(handle,'parent');
    switch value
        case 0,
            set(parent,'WindowButtonDownFcn','AverageDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','AverageDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','AverageDisplay(''ButtonUp'',gcbf)','pointer','arrow');
            set(handle,'string','(Z)oom OFF','value',value);
            AVERAGEDISPLAY.ZOOM = 0;
        case 1,
            set(parent,'WindowButtonDownFcn','AverageDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','AverageDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','AverageDisplay(''ZoomUp'',gcbf)','pointer','crosshair');
            set(handle,'string','(Z)oom ON','value',value);
            AVERAGEDISPLAY.ZOOM = 1;
    end
    return
    
    
function ZoomDown(handle)

    global AVERAGEDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    if ~strcmp(seltype,'alt'),
        pos = get(AVERAGEDISPLAY.AXES,'CurrentPoint');
        P1 = pos(1,1:2); P2 = P1;
        AVERAGEDISPLAY.P1 = P1;
        AVERAGEDISPLAY.P2 = P2;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    AVERAGEDISPLAY.ZOOMBOX = line('parent',AVERAGEDISPLAY.AXES,'XData',X,'YData',Y,'Erasemode','xor','Color','k','HitTest','Off');
   	    drawnow;
    else
        xlim = AVERAGEDISPLAY.XLIM; ylim = AVERAGEDISPLAY.YLIM;
        xwin = AVERAGEDISPLAY.XWIN; ywin = AVERAGEDISPLAY.YWIN;
        xsize = max([2*(xwin(2)-xwin(1)) 1]);
        AVERAGEDISPLAY.XWIN = [ median([xlim xwin(1)-xsize/4]) median([xlim xwin(2)+xsize/4])];
        ysize = max([2*(ywin(2)-ywin(1)) 1]);
        AVERAGEDISPLAY.YWIN = [ median([ylim ywin(1)-ysize/4]) median([ylim ywin(2)+ysize/4])];
        UpdateDisplay(handle);
    end
    return
    
function ZoomMotion(handle)
  
    global AVERAGEDISPLAY;
    if ishandle(AVERAGEDISPLAY.ZOOMBOX),
	    point = get(AVERAGEDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([AVERAGEDISPLAY.XLIM point(1,1)]); P2(2) = median([AVERAGEDISPLAY.YLIM point(1,2)]);
        AVERAGEDISPLAY.P2 = P2;
        P1 = AVERAGEDISPLAY.P1;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    set(AVERAGEDISPLAY.ZOOMBOX,'XData',X,'YData',Y);
        drawnow;
    end
    return
    
function ZoomUp(handle)
   
    global AVERAGEDISPLAY;
    if ishandle(AVERAGEDISPLAY.ZOOMBOX),
        point = get(AVERAGEDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([AVERAGEDISPLAY.XLIM point(1,1)]); P2(2) = median([AVERAGEDISPLAY.YLIM point(1,2)]);
        AVERAGEDISPLAY.P2 = P2; P1 = AVERAGEDISPLAY.P1;
        if (P1(1) ~= P2(1))&(P1(2) ~= P2(2)),
            AVERAGEDISPLAY.XWIN = sort([P1(1) P2(1)]);
            AVERAGEDISPLAY.YWIN = sort([P1(2) P2(2)]);
        end
        delete(AVERAGEDISPLAY.ZOOMBOX);
   	    UpdateDisplay(handle);
    end
    return       
    
    
    
    
    
    
function InitAverageButtons(handle),

    global SCRIPT AVERAGEDISPLAY TS;

    button = findobj(allchild(handle),'tag','AVERAGEMAXN');
    set(button,'string',num2str(SCRIPT.AVERAGEMAXN)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMAXRE');
    set(button,'string',num2str(SCRIPT.AVERAGEMAXRE)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMETHOD');
    set(button,'string',{'No averaging','Averaging using matched filter'},'value',SCRIPT.AVERAGEMETHOD);
    
    button = findobj(allchild(handle),'tag','AVERAGERMSTYPE');
    types = SCRIPT.GROUPNAME; types{end+1} = 'GLOBAL';
    set(button,'value',SCRIPT.AVERAGERMSTYPE,'string',types);
    
    TS{SCRIPT.CURRENTTS}.averagemethod = SCRIPT.AVERAGEMETHOD;
    
    return    
    
    
function AverageButton(handle)

    global SCRIPT TS;
    
    tag = get(handle,'tag');
    switch tag
        case {'AVERAGEMAXN','AVERAGEMAXRE'}
            value = str2num(get(handle,'string'));
            SCRIPT = setfield(SCRIPT,tag,value);
        case {'AVERAGERMSTYPE'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
        case {'AVERAGEMETHOD'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            TS{SCRIPT.CURRENTTS}.averagemethod = SCRIPT.AVERAGEMETHOD;
            UpdateDisplay(handle);
    end
    return
    
function ButtonDown(handle)
   	
    global AVERAGEDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    
    point = get(AVERAGEDISPLAY.AXES,'CurrentPoint');
    t = point(1,1); y = point(1,2);
    
    return   

    
function ButtonMotion(handle)
        
    global AVERAGEDISPLAY;
    return
    
function ButtonUp(handle)
   
    global AVERAGEDISPLAY TS SCRIPT;
   
    drawnow;
    return

function KeyPress(handle)

    global SCRIPT AVERAGEDISPLAY TS;

    key = real(get(handle,'CurrentCharacter'));
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    switch key(1),
        case {8, 127}  % delete and backspace keys
	         
        case 93,
            ywin = AVERAGEDISPLAY.YWIN; ylim = AVERAGEDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin-ysize; 
            AVERAGEDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);
        case 91,
            ywin = AVERAGEDISPLAY.YWIN; ylim = AVERAGEDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin+ysize; 
            AVERAGEDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);   
        case 44,
            xwin = AVERAGEDISPLAY.XWIN; xlim = AVERAGEDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin-xsize; 
            AVERAGEDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);
        case 46,
            xwin = AVERAGEDISPLAY.XWIN; xlim = AVERAGEDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin+xsize; 
            AVERAGEDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);  
        case {122}    
            Zoom(handle,1);

    end

    return
