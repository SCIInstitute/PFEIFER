function plotAutoProcFids(varargin)
%this function opens the 4th window and deals with everything related to it

if nargin > 1 % if callback of winAutoProcessing is to be executed
    feval(varargin{1},varargin{2:end});  % execute callback
else
    setUpAllForTesting
    Init; % else initialize and open winAutoProcessing.fig
end
function setUpAllForTesting()
%this is only for testing, remove at the end
%%%%  all input parameters
clear global 
global AUTOPROCESSING TS;


Run=80;  % which Run to load

% set up 2 dummy groups
leadsGr1=1:247;
leadsGr2=248:547;

% badleads
badleads=[140,150, 157, 213:232, 293:301]+247;     % the global indices of leads that are bad accourding to wilson

leadsOfAllGroups=setdiff([leadsGr1, leadsGr2],badleads);  %signal (where the beat is found) will constitute of those.  got rid of badleads



% set leadsToAutoprocess, the leads to find fiducials for and plot.  As far as autoprocessing is concerned, only these leads will be shown/fiducialised/are of concern.
nToBeFiducialised=10;    % chose nToBeFiducialised  evenly spread out leads out of leadsOfAllGroups
idxs=round(linspace(1,length(leadsOfAllGroups),nToBeFiducialised));
AUTOPROCESSING.leadsToAutoprocess=leadsOfAllGroups(idxs);    % TO DO: make sure bad leads are filtered out..



%%%% no more parameters from here on %%%%%%%%%%%%%%%%

data=fullfile('C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\Testing\17-6-30 latestExp\Data\Preprocessed',sprintf('Run%04d.mat',Run));
withfids=fullfile('C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\Testing\17-6-30 latestExp\Data\Processed',sprintf('Run%04d-ns.mat',Run));
mapping='C:\alle Meine Workspaces von allen zusammen\Matlab workspaces\AllMatmapStuff\Testing\17-6-30 latestExp\Data\Matmap\newmapping.mapping';
index = ioReadMAT(data, mapping);
sts=TS{index};
load(withfids)
ets=ts;

% give ts the badleads
leadinfo=zeros(sts.numleads,1);
leadinfo(badleads)=1;
sts.leadinfo=leadinfo;


signal = preprocessPotvals(sts.potvals(leadsOfAllGroups,:));   % make signal out of leadsOfAllGroups

sts.potvals=temporalFilter(sts.potvals);         % but keep all leads in potvals



AUTOPROCESSING.bsk=ets.selframes(1);    % "beat start kernel"
AUTOPROCESSING.bek=ets.selframes(2);  %beat end kernel

AUTOPROCESSING.oriFids=ets.fids;


%%%% find allFis
AUTOPROCESSING.allFids=findAllFids(sts.potvals(AUTOPROCESSING.leadsToAutoprocess,:),signal);



AUTOPROCESSING.ZOOMBOX=[];

% set up globals, myScriptData
clear global TS
global TS
TS{1}=sts;
global myScriptData
myScriptData=struct();
myScriptData.CURRENTTS=1;
myScriptData.DISPLAYGROUPA=[1 2];  %what groups to display
myScriptData.DISPLAYTYPEA=1; % show global RMS
myScriptData.DISPLAYSCALINGA=1; % what scaling?
myScriptData.GROUPNAME={{'group1', 'group2'}};
myScriptData.CURRENTRUNGROUP=1;
myScriptData.GROUPDONOTPROCESS={{0,0}};
myScriptData.GROUPLEADS={{leadsGr1,leadsGr2}};
myScriptData.GROUPEXTENSION={{'-gr1','-gr2'}};
myScriptData.SAMPLEFREQ=1000;
myScriptData.DISPLAYGRIDA=0;
myScriptData.DISPLAYOFFSETA = 1;
myScriptData.DISPLAYLABELA = 1;
myScriptData.BASELINEWIDTH = 5;




%%%%%%% actuall stuff starts here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Init

fig=winAutoProcessing;
InitFiducials(fig)
InitDisplayButtons(fig)
SetupDisplay(fig);
UpdateDisplay;


%%%%%%% functions %%%%%%%%%%%%%%%%%%%%%%

function InitDisplayButtons(fig)
% initialize everything in figure exept the plotting stuff.. 
%%%% set up the listeners for the sliders
sliderx=findobj(allchild(fig),'tag','SLIDERX');
slidery=findobj(allchild(fig),'tag','SLIDERY');

addlistener(sliderx,'ContinuousValueChange',@UpdateSlider);
addlistener(slidery,'ContinuousValueChange',@UpdateSlider);

function SetupDisplay(fig)
%      no plotting, but everything else with axes, particualrely:
%         - sets up some start values for xlim, ylim, sets up axes and slider handles
%         - makes the FD.SIGNAL values,   (RMS and scaling of potvals)
pointer=fig.Pointer;
fig.Pointer='watch';

global TS myScriptData AUTOPROCESSING;

tsindex = myScriptData.CURRENTTS;
numframes = size(TS{tsindex}.potvals,2);
AUTOPROCESSING.TIME = [1:numframes]*(1/myScriptData.SAMPLEFREQ);
AUTOPROCESSING.XLIM = [1 numframes]*(1/myScriptData.SAMPLEFREQ);
AUTOPROCESSING.XWIN = [median([0 AUTOPROCESSING.XLIM]) median([3000/myScriptData.SAMPLEFREQ AUTOPROCESSING.XLIM])];


AUTOPROCESSING.AXES = findobj(allchild(fig),'tag','AXES');
AUTOPROCESSING.XSLIDER = findobj(allchild(fig),'tag','SLIDERX');
AUTOPROCESSING.YSLIDER = findobj(allchild(fig),'tag','SLIDERY');



groups = myScriptData.DISPLAYGROUPA;
numgroups = length(groups);

AUTOPROCESSING.NAME ={};
AUTOPROCESSING.GROUPNAME = {};
AUTOPROCESSING.GROUP = [];
AUTOPROCESSING.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};

% set up signals for global RMS, GROUP RMS or individual RMS
switch myScriptData.DISPLAYTYPEA
    case 1   % show global RMS
        ch  = []; 
        for p=groups 
            leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p};
            index = TS{tsindex}.leadinfo(leads)==0;  % index of only the 'good' leads, filter out badleads
            ch = [ch leads(index)];   % ch is leads only of the leads of the groubs selected, not of all leads
        end
        
        AUTOPROCESSING.SIGNAL = sqrt(mean(TS{tsindex}.potvals(ch,:).^2));
        AUTOPROCESSING.SIGNAL = AUTOPROCESSING.SIGNAL-min(AUTOPROCESSING.SIGNAL);
        AUTOPROCESSING.LEADINFO = 0;
        AUTOPROCESSING.GROUP = 1;
        AUTOPROCESSING.LEAD = 0;
        AUTOPROCESSING.LEADGROUP = 0;
        AUTOPROCESSING.NAME = {'Global RMS'};
        AUTOPROCESSING.GROUPNAME = {'Global RMS'};

        
        set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on'); 
        set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','off');
        if AUTOPROCESSING.SELFIDS > 1
            AUTOPROCESSING.SELFIDS = 1;
            set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'value',1);
            set(findobj(allchild(fig),'tag','FIDSLOCAL'),'value',0);
        end

    case 2
        AUTOPROCESSING.SIGNAL = zeros(numgroups,numframes);
        for p=1:numgroups
            leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{groups(p)};
            index = TS{tsindex}.leadinfo(leads)==0;
            AUTOPROCESSING.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
            AUTOPROCESSING.SIGNAL(p,:) = AUTOPROCESSING.SIGNAL(p,:)-min(AUTOPROCESSING.SIGNAL(p,:));
            AUTOPROCESSING.NAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)} ' RMS']; 
        end
        AUTOPROCESSING.GROUPNAME = AUTOPROCESSING.NAME;
        AUTOPROCESSING.GROUP = 1:numgroups;
        AUTOPROCESSING.LEAD = 0*AUTOPROCESSING.GROUP;
        AUTOPROCESSING.LEADGROUP = groups;
        AUTOPROCESSING.LEADINFO = zeros(numgroups,1);

        set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on');
        set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','off');
        if AUTOPROCESSING.SELFIDS > 2
            AUTOPROCESSING.SELFIDS = 1;
            set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'value',1);
            set(findobj(allchild(fig),'tag','FIDSLOCAL'),'value',0);
        end

    case 3   % indiv fids
        
        
        %%%% only for autoprocessing, make copy of GROUPLEADS, where the groupleads, that are not in leadsToAutoprocess, are filtered out. Only work with the copies here       
        GROUPLEADS=myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP};   %the copy
        for group=groups
            GROUPLEADS{group}=intersect(AUTOPROCESSING.leadsToAutoprocess, GROUPLEADS{group});
        end
        
        
        
        AUTOPROCESSING.GROUP =[];
        AUTOPROCESSING.NAME = {};
        AUTOPROCESSING.LEAD = [];
        AUTOPROCESSING.LEADGROUP = [];
        ch  = []; 
        for p=groups
            ch = [ch GROUPLEADS{p}]; 
            AUTOPROCESSING.GROUP = [AUTOPROCESSING.GROUP p*ones(1,length(GROUPLEADS{p}))];
            AUTOPROCESSING.LEADGROUP = [AUTOPROCESSING.GROUP GROUPLEADS{p}];
            AUTOPROCESSING.LEAD = [AUTOPROCESSING.LEAD GROUPLEADS{p}];
            for q=1:length(GROUPLEADS{p})
                AUTOPROCESSING.NAME{end+1} = sprintf('# %d',GROUPLEADS{p}(q)); 
            end 
        end
        for p=1:length(groups)
            AUTOPROCESSING.GROUPNAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)}]; 
        end
        AUTOPROCESSING.SIGNAL = TS{tsindex}.potvals(ch,:);
        AUTOPROCESSING.LEADINFO = TS{tsindex}.leadinfo(ch);

        set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'enable','on');
        set(findobj(allchild(fig),'tag','FIDSGROUP'),'enable','on');
        set(findobj(allchild(fig),'tag','FIDSLOCAL'),'enable','on');
end

% modify signal accourding to chosen Displayscaling
switch myScriptData.DISPLAYSCALINGA
    case 1
        k = max(abs(AUTOPROCESSING.SIGNAL),[],2);
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        k(k==0) = 1;
        s = sparse(1:m,1:m,1./k,m,m);
        AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
    case 2
        k = max(abs(AUTOPROCESSING.SIGNAL(:)));
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        if k > 0
            s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
            AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
        end
    case 3
        [m,~] = size(AUTOPROCESSING.SIGNAL);
        k = ones(m,1);
        for p=groups
            ind = find(AUTOPROCESSING.GROUP == p);
            k(ind) = max(max(abs(AUTOPROCESSING.SIGNAL(ind,:)),[],2));
        end
        s = sparse(1:m,1:m,1./k,m,m);
        AUTOPROCESSING.SIGNAL = s*AUTOPROCESSING.SIGNAL;
end

% if individuals are displayed, give signals an offset, so they dont touch
% in plot
if myScriptData.DISPLAYTYPEA == 3
    AUTOPROCESSING.SIGNAL = 0.5*AUTOPROCESSING.SIGNAL+0.5;
end

numsignal = size(AUTOPROCESSING.SIGNAL,1);
for p=1:numsignal   % stack signals "on top of each other" for plotting..
    AUTOPROCESSING.SIGNAL(p,:) = AUTOPROCESSING.SIGNAL(p,:)+(numsignal-p);
end
AUTOPROCESSING.YLIM = [0 numsignal];
AUTOPROCESSING.YWIN = [max([0 numsignal-6]) numsignal]; %dipsplay maximal 6 singnals simulatniouslyy

fig.Pointer=pointer;

function UpdateDisplay
%plots the FD.SIGNAL,  makes the plot..  also calls  DisplayFiducials
global myScriptData AUTOPROCESSING;
ax=AUTOPROCESSING.AXES;
axes(ax);
cla(ax);
hold(ax,'on');
ywin = AUTOPROCESSING.YWIN;
xwin = AUTOPROCESSING.XWIN;
xlim = AUTOPROCESSING.XLIM;
ylim = AUTOPROCESSING.YLIM;

numframes = size(AUTOPROCESSING.SIGNAL,2);
startframe = max([floor(myScriptData.SAMPLEFREQ*xwin(1)) 1]);
endframe = min([ceil(myScriptData.SAMPLEFREQ*xwin(2)) numframes]);

% DRAW THE GRID
if myScriptData.DISPLAYGRIDA > 1
    if myScriptData.DISPLAYGRIDA > 2
        clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(ax,X,Y,'color',[0.9 0.9 0.9],'hittest','off');
    end
    clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
    X = [clines; clines]; Y = ywin'*ones(1,length(clines));
    line(ax,X,Y,'color',[0.5 0.5 0.5],'hittest','off');
end



numchannels = size(AUTOPROCESSING.SIGNAL,1);
if myScriptData.DISPLAYOFFSETA == 1
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
else
    chstart = 1;
    chend = numchannels;
end

%%%% choose colors and plot
for p=chstart:chend
    k = startframe:endframe;
    color = AUTOPROCESSING.COLORLIST{AUTOPROCESSING.GROUP(p)};
    if AUTOPROCESSING.LEADINFO(p) > 0
        color = [0 0 0];
        if AUTOPROCESSING.LEADINFO(p) > 3
            color = [0.35 0.35 0.35];
        end
    end
    plot(ax,AUTOPROCESSING.TIME(k),AUTOPROCESSING.SIGNAL(p,k),'color',color,'hittest','off');
    if (myScriptData.DISPLAYLABELA == 1)&&(chend-chstart < 30) && (AUTOPROCESSING.YWIN(2) >= numchannels-p+1)
        text(ax,AUTOPROCESSING.XWIN(1),numchannels-p+1,AUTOPROCESSING.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
    end
end
set(AUTOPROCESSING.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);

%%%% do some slider stuff
xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
if xlen < (1/myScriptData.SAMPLEFREQ), xslider = 0.99999; else xslider = (xwin(1)-xlim(1))/xlen; end
if xlen >= (1/myScriptData.SAMPLEFREQ), xfill = (xwin(2)-xwin(1))/xlen; else xfill = myScriptData.SAMPLEFREQ; end
xinc = median([(1/myScriptData.SAMPLEFREQ) xfill/2 0.99999]);
xfill = median([(1/myScriptData.SAMPLEFREQ) xfill myScriptData.SAMPLEFREQ]);
xslider = median([0 xslider 0.99999]);
set(AUTOPROCESSING.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
if ylen < (1/myScriptData.SAMPLEFREQ), yslider = 0.99999; else yslider = ywin(1)/ylen; end
if ylen >= (1/myScriptData.SAMPLEFREQ), yfill = (ywin(2)-ywin(1))/ylen; else yfill =myScriptData.SAMPLEFREQ; end
yinc = median([(1/myScriptData.SAMPLEFREQ) yfill/2 0.99999]);
yfill = median([(1/myScriptData.SAMPLEFREQ) yfill myScriptData.SAMPLEFREQ]);
yslider = median([0 yslider 0.99999]);
set(AUTOPROCESSING.YSLIDER,'value',yslider,'sliderstep',[yinc yfill]);

%%%% set all handle lists empty (no lines/patches displaying the fids yet)
for beatNumber=1:length(AUTOPROCESSING.allFids)
    AUTOPROCESSING.EVENTS{beatNumber}{1}.handle = [];
    AUTOPROCESSING.EVENTS{beatNumber}{2}.handle = [];
    AUTOPROCESSING.EVENTS{beatNumber}{3}.handle = [];
end

DisplayFiducials;

function DisplayFiducials
% this functions plotts the lines/patches when u select the fiducials
% (the line u can move around with your mouse)

global myScriptData AUTOPROCESSING;

for beatNumber=1:length(AUTOPROCESSING.EVENTS)   %for each beat
    % GLOBAL EVENTS
    events = AUTOPROCESSING.EVENTS{beatNumber}{1};
     if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end   %delete any existing lines
    events.handle = [];
    ywin = AUTOPROCESSING.YWIN;
    if AUTOPROCESSING.SELFIDS == 1, colorlist = events.colorlist; else colorlist = events.colorlistgray; end

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
    AUTOPROCESSING.EVENTS{beatNumber}{1} = events;           

    if myScriptData.DISPLAYTYPEA == 1, continue; end

    % GROUP FIDUCIALS

    events = AUTOPROCESSING.EVENTS{beatNumber}{2};
    if ~isempty(events.handle), index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0)); delete(events.handle(index)); end
    events.handle = [];
    if AUTOPROCESSING.SELFIDS == 2, colorlist = events.colorlist; else colorlist = events.colorlistgray; end

    numchannels = size(AUTOPROCESSING.SIGNAL,1);
    chend = numchannels - max([floor(ywin(1)) 0]);
    chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;

    index = chstart:chend;

    for q=1:max(AUTOPROCESSING.LEADGROUP)
        nindex = index(AUTOPROCESSING.LEADGROUP(index)==q);
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
    AUTOPROCESSING.EVENTS{beatNumber}{2} = events;   

    if myScriptData.DISPLAYTYPEA == 2, continue; end

    % LOCAL FIDUCIALS

    events = AUTOPROCESSING.EVENTS{beatNumber}{3};

    %%%% delete all current handles and set events.handles=[]
     if ~isempty(events.handle)
         index = find(ishandle(events.handle(:)) & (events.handle(:) ~= 0));
         delete(events.handle(index))
     end
    events.handle = [];


    if AUTOPROCESSING.SELFIDS == 3, colorlist = events.colorlist; else colorlist = events.colorlistgray; end


    %%%% index is eg [3 4 5 8 9 10], if those are the leads (in global frame) currently
    %%%% displayed (this changes with yslider!, note 5 8 !

    index = AUTOPROCESSING.LEAD(chstart:chend);
    for q=index     % for each of the 5-7 channels, that one can see in axes
        for idx=find(q==AUTOPROCESSING.LEAD)
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
    AUTOPROCESSING.EVENTS{beatNumber}{3} = events;
end
    

function potvals=temporalFilter(potvals)
% TODO, this should not be needed here
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

function signal = preprocessPotvals(potvals)
% do temporal filter and RMS, to get a signal to work with

%%%% temporal filter
A = 1;
B = [0.03266412226059 0.06320942361376 0.09378788647083 0.10617422096837 0.09378788647083 0.06320942361376 0.03266412226059];
D = potvals';
D = filter(B,A,D);
D(1:(max(length(A),length(B))-1),:) = ones(max(length(A),length(B))-1,1)*D(max(length(A),length(B)),:);
potvals = D';

%%%% do RMS
signal=rms(potvals,1);
signal=signal-min(signal);


%%% scaling
k = max(abs(signal),[],2);
[m,~] = size(signal);
k(k==0) = 1;
s = sparse(1:m,1:m,1./k,m,m);
signal = full(s*signal);

%%%%%%% callback functions %%%%%%%%%%%%%%%%%%%%%

function Navigation(handle,mode)
%callback to all navigation buttons (including apply)
global myScriptData

switch mode
case {'prev','next','stop'}
    myScriptData.NAVIGATION = mode;
    set(handle,'DeleteFcn','');
    delete(handle);
case {'apply'}
    %TODO.. what to do when applied is pressed...
    myScriptData.NAVIGATION = 'apply';
    set(handle,'DeleteFcn','');
    delete(handle);
otherwise
    error('unknown navigation command');
end

function scrollFcn(handle, eventData)
%callback for scrolling
diff=(-1)*eventData.VerticalScrollCount*0.05;

yslider=findobj(allchild(handle),'tag','SLIDERY');
value=yslider.Value;

value=value+diff;

if value > 1, value=1; end
if value < 0, value=0; end

yslider.Value=value;

UpdateSlider(yslider)



function Zoom(handle)
global AUTOPROCESSING;
value = get(handle,'value');
parent = get(handle,'parent');
switch value
    case 0
        set(parent,'WindowButtonDownFcn','plotAutoProcFids(''ButtonDown'',gcbf)',...
           'WindowButtonMotionFcn','plotAutoProcFids(''ButtonMotion'',gcbf)',...
           'WindowButtonUpFcn','plotAutoProcFids(''ButtonUp'',gcbf)',...
           'pointer','arrow');
        set(handle,'string','Zoom OFF');
        AUTOPROCESSING.ZOOM = 0;
    case 1
        set(parent,'WindowButtonDownFcn','plotAutoProcFids(''ZoomDown'',gcbf)',...
           'WindowButtonMotionFcn','plotAutoProcFids(''ZoomMotion'',gcbf)',...
           'WindowButtonUpFcn','plotAutoProcFids(''ZoomUp'',gcbf)',...
           'pointer','crosshair');
        set(handle,'string','Zoom ON');
        AUTOPROCESSING.ZOOM = 1;
end


function ZoomDown(handle)

global AUTOPROCESSING    
seltype = get(gcbf,'SelectionType');
if ~strcmp(seltype,'alt')
    pos = get(AUTOPROCESSING.AXES,'CurrentPoint');
    P1 = pos(1,1:2); P2 = P1;
    AUTOPROCESSING.P1 = P1;
    AUTOPROCESSING.P2 = P2;
    X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
    AUTOPROCESSING.ZOOMBOX = line('parent',AUTOPROCESSING.AXES,'XData',X,'YData',Y,'Color','k','HitTest','Off');
    drawnow;
else
    xlim = AUTOPROCESSING.XLIM; ylim = AUTOPROCESSING.YLIM;
    xwin = AUTOPROCESSING.XWIN; ywin = AUTOPROCESSING.YWIN;
    xsize = max([2*(xwin(2)-xwin(1)) 1]);
    AUTOPROCESSING.XWIN = [ median([xlim xwin(1)-xsize/4]) median([xlim xwin(2)+xsize/4])];
    ysize = max([2*(ywin(2)-ywin(1)) 1]);
    AUTOPROCESSING.YWIN = [ median([ylim ywin(1)-ysize/4]) median([ylim ywin(2)+ysize/4])];
    UpdateDisplay;
end

    
function ZoomMotion(handle)
global AUTOPROCESSING    
if ishandle(AUTOPROCESSING.ZOOMBOX)
    point = get(AUTOPROCESSING.AXES,'CurrentPoint');
    P2(1) = median([AUTOPROCESSING.XLIM point(1,1)]); P2(2) = median([AUTOPROCESSING.YLIM point(1,2)]);
    AUTOPROCESSING.P2 = P2;
    P1 = AUTOPROCESSING.P1;
    X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
    set(AUTOPROCESSING.ZOOMBOX,'XData',X,'YData',Y);
    drawnow;
end

    
function ZoomUp(handle)  
global AUTOPROCESSING;    
if ishandle(AUTOPROCESSING.ZOOMBOX)
    point = get(AUTOPROCESSING.AXES,'CurrentPoint');
    P2(1) = median([AUTOPROCESSING.XLIM point(1,1)]); P2(2) = median([AUTOPROCESSING.YLIM point(1,2)]);
    AUTOPROCESSING.P2 = P2; P1 = AUTOPROCESSING.P1;
    if (P1(1) ~= P2(1)) && (P1(2) ~= P2(2))
        AUTOPROCESSING.XWIN = sort([P1(1) P2(1)]);
        AUTOPROCESSING.YWIN = sort([P1(2) P2(2)]);
    end
    delete(AUTOPROCESSING.ZOOMBOX);
    UpdateDisplay;
end


function ButtonDown(handle)
%TODO
function ButtonMotion(handle)
%TODO
function ButtonUp(handle)
%TODO

function UpdateSlider(handle,~)
%callback to slider
global AUTOPROCESSING
tag = get(handle,'tag');
value = get(handle,'value');
switch tag
    case 'SLIDERX'
        xwin = AUTOPROCESSING.XWIN;
        xlim = AUTOPROCESSING.XLIM;
        winlen = xwin(2)-xwin(1);
        limlen = xlim(2)-xlim(1);
        xwin(1) = median([xlim value*(limlen-winlen)+xlim(1)]);
        xwin(2) = median([xlim xwin(1)+winlen]);
        AUTOPROCESSING.XWIN = xwin;
   case 'SLIDERY'
        ywin = AUTOPROCESSING.YWIN;
        ylim = AUTOPROCESSING.YLIM;
        winlen = ywin(2)-ywin(1);
        limlen = ylim(2)-ylim(1);
        ywin(1) = median([ylim value*(limlen-winlen)+ylim(1)]);
        ywin(2) = median([ylim ywin(1)+winlen]);
        AUTOPROCESSING.YWIN = ywin;     
end

UpdateDisplay;

function DisplayButton(cbobj)
%callback function to all the buttons
global myScriptData
myScriptData.(cbobj.Tag)=cbobj.Value;

switch cbobj.Tag
    case {'DISPLAYTYPEA','DISPLAYOFFSETA','DISPLAYSCALINGA','DISPLAYGROUPA'}
        SetupDisplay(cbobj.Parent)
        UpdateDisplay
    otherwise
        UpdateDisplay
end


function SetFids(handle)
%callback function to the two buttons ('Global Fids', 'local Fids')

global AUTOPROCESSING;
window = get(handle,'parent');
tag = get(handle,'tag');
switch tag
    case 'FIDSGLOBAL'
        AUTOPROCESSING.SELFIDS = 1;
        set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',1);
        set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',0);          
    case 'FIDSLOCAL'
        AUTOPROCESSING.SELFIDS = 3;
        set(findobj(allchild(window),'tag','FIDSGLOBAL'),'value',0);
        set(findobj(allchild(window),'tag','FIDSLOCAL'),'value',1);
end
DisplayFiducials;
    

%%%%%%% util functions %%%%%%%%%%%%%%%%%%%%%%%
%TODO I think I dont need this
function fids=removeUnnecFids(fids,wantedFids)
toBeRemoved=[];
for p=1:length(fids)
    if ~ismember(fids(p).type, wantedFids)
        toBeRemoved=[toBeRemoved p];
    end
end
fids(toBeRemoved)=[];


function InitFiducials(fig)
% sets up .EVENTS
% sets up DefaultEvent
% calls FidsToEvents


global myScriptData TS AUTOPROCESSING;


% for all fiducial types
events.dt = myScriptData.BASELINEWIDTH/myScriptData.SAMPLEFREQ;
events.value = [];
events.type = [];
events.handle = [];
events.axes = findobj(allchild(fig),'tag','AXES');
events.colorlist = {[1 0.7 0.7],[0.7 1 0.7],[0.7 0.7 1],[0.5 0 0],[0 0.5 0],[0 0 0.5],[1 0 1],[1 1 0],[0 1 1],  [1 0.5 0],[1 0.5 0]};
events.colorlistgray = {[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],[0.8 0.8 0.8],   [0.8 0.8 0.8],[0.8 0.8 0.8]};
events.typelist = [2 2 2 1 1 3 1 1 1 1 2];
events.linestyle = {'-','-','-','-.','-.','-','-','-','-','-','-'};
events.linewidth = {1,1,1,2,2,1,2,2,2,2,2,1};
events.num = [1 2 3 4 5 7 8 9 10 11];

AUTOPROCESSING.fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Activation','Recovery','Reference','X-Peak','X-Wave'};     

AUTOPROCESSING.NUMTYPES = length(AUTOPROCESSING.fidslist);
AUTOPROCESSING.SELFIDS = 1;
set(findobj(allchild(fig),'tag','FIDSGLOBAL'),'value',1);
set(findobj(allchild(fig),'tag','FIDSLOCAL'),'value',0);


events.sel = 0;
events.sel2 = 0;
events.sel3 = 0;

events.maxn = 1;
events.class = 1; AUTOPROCESSING.DEFAULT_EVENTS{1} = events;  % GLOBAL EVENTS
events.maxn = length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP});
events.class = 2; AUTOPROCESSING.DEFAULT_EVENTS{2} = events;  % GROUP EVENTS
events.maxn = size(TS{myScriptData.CURRENTTS}.potvals,1);
events.class = 3; AUTOPROCESSING.DEFAULT_EVENTS{3} = events;  % LOCAL EVENTS

FidsToEvents;


function FidsToEvents
%puts ts.fids of a certain beat to .EVENTS{beatNumber}

global TS myScriptData AUTOPROCESSING;

samplefreq = myScriptData.SAMPLEFREQ;
isamplefreq = 1/samplefreq;

for beatNumber=1:length(AUTOPROCESSING.allFids)  %for each beat
    AUTOPROCESSING.EVENTS{beatNumber}=AUTOPROCESSING.DEFAULT_EVENTS;
    fids=AUTOPROCESSING.allFids{beatNumber};
    
    %%%% find the start_value and the end_value of a wave
    %this takes advantage of the fact, that end of wave imediatly follows beginning of waves in fids
    
    fidsIndex=1;
    while fidsIndex <=length(fids)
         switch fids(fidsIndex).type
            case 0
                mtype = 1;    
                start_value = fids(fidsIndex).value*isamplefreq;
                end_value= fids(fidsIndex+1).value*isamplefreq;
                fidsIndex=fidsIndex+1; % if its a wave, skip next entry (the end of wave)
            case 2
                mtype = 2;
                start_value = fids(fidsIndex).value*isamplefreq;
                end_value= fids(fidsIndex+1).value*isamplefreq;
                fidsIndex=fidsIndex+1;
            case 5
                mtype = 3;
                start_value = fids(fidsIndex).value*isamplefreq;
                end_value= fids(fidsIndex+1).value*isamplefreq;
                fidsIndex=fidsIndex+1;      
            case 3
                mtype = 4; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            case 6
                mtype = 5; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            case 16
                mtype = 6; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value+myScriptData.BASELINEWIDTH/samplefreq;
            case 10
                mtype = 7; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            case 13
                mtype = 8; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            case 14
                mtype = 9; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            case 26     % X-Wave
                mtype = 11;
                start_value = fids(fidsIndex).value*isamplefreq;
                end_value= fids(fidsIndex+1).value*isamplefreq;
                fidsIndex=fidsIndex+1;
            case 25   %X-Peak
                mtype = 10; start_value = fids(fidsIndex).value*isamplefreq; end_value = start_value;
            otherwise
                continue;
         end
        fidsIndex=fidsIndex+1;
        
        %start_value is now first value(s) of wave, end_value is last value(s) of wave. if the fiducial is a peak, they are both the same.
      	%mtype correstponds to: fidslist = {'P-wave','QRS-complex','T-wave','QRS-peak','T-peak','Baseline','Activation','Recovery','Reference','Fbase'};
        % eg. mtype=3 means it's a T-wave, because fidslist{3}='T-Wave'
        
        %%%% now check if it is global or local fid and put the values of start_value/end_value in events.value
        numLeadsToAutoprocess = length(AUTOPROCESSING.leadsToAutoprocess);
        if (length(start_value) == numLeadsToAutoprocess)&&(length(end_value) == numLeadsToAutoprocess) % if individual value for each lead
            AUTOPROCESSING.EVENTS{beatNumber}{3}.value(AUTOPROCESSING.leadsToAutoprocess,end+1,1) = start_value;
            AUTOPROCESSING.EVENTS{beatNumber}{3}.value(AUTOPROCESSING.leadsToAutoprocess,end,2) = end_value;
            AUTOPROCESSING.EVENTS{beatNumber}{3}.type(end+1) = mtype;
        elseif (length(start_value) ==1)&&(length(end_value) == 1) % if global fiducials
            AUTOPROCESSING.EVENTS{beatNumber}{1}.value(:,end+1,1) = start_value;
            AUTOPROCESSING.EVENTS{beatNumber}{1}.value(:,end,2) = end_value;
            AUTOPROCESSING.EVENTS{beatNumber}{1}.type(end+1) = mtype; 
        end
    end
end
   
    


