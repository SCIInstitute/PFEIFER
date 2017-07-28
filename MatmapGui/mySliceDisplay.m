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
    global myScriptData
    
    switch mode
    case {'prev','next','stop'}
        myScriptData.NAVIGATION = mode;
        set(handle,'DeleteFcn','');
        delete(handle);
    case {'apply'}
        global TS;
        tsindex = myScriptData.CURRENTTS;
        if ~isfield(TS{tsindex},'selframes')
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        elseif isempty(TS{tsindex}.selframes)
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        else
    %        if DetectAlignment(handle) == 0, return; end        I turned
    %        this of
            myScriptData.NAVIGATION = 'apply';
            set(handle,'DeleteFcn','');
            delete(handle);
        end
    otherwise
        error('unknown navigation command');
    end

    return

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
    
% function success = DetectAlignment(handle)
%     % what is this?
%     global myScriptData SLICEDISPLAY TS;
%     
%     if ischar(myScriptData.ALIGNSTART),
%         switch myScriptData.ALIGNMETHOD
%             case 1,
%                 % DO NOTHING
%             case 2,
%                 selframes = TS{myScriptData.CURRENTTS}.selframes;
%                 if isfield(TS{myScriptData.CURRENTTS},'pacing'),
%                     pacing = TS{myScriptData.CURRENTTS}.pacing;
%                     [dummy,index] = min(abs(pacing-selframes(1)));
%                     myScriptData.ALIGNSTART = -pacing(index(1)) + selframes(1);
%                 end
%             case 3,
%                 DetectAlignmentRMS;
%                 selframes = TS{myScriptData.CURRENTTS}.selframes;
%                 pacing = SLICEDISPLAY.RMSPEAKS;
%                 if ~isempty(pacing)
%                     [dummy,index] = min(abs(pacing-selframes(1)));
%                     myScriptData.ALIGNSTART = -pacing(index(1)) + selframes(1);
%                 end
%             case 4,
%                 success = 1;
%                 if ~isfield(TS{myScriptData.CURRENTTS},'templateframe'), success = 0;
%                 elseif isempty(TS{myScriptData.CURRENTTS}.templateframe), success = 0; end
%                 if success == 0,
%                     errordlg('You need to specify a template for alignment','AUTOMATIC ALIGNMENT');
%                    return;    
%                 end
%                 DetectAlignmentRMStemplate(2);
%                 selframes = TS{myScriptData.CURRENTTS}.selframes;
%                 pacing = SLICEDISPLAY.RMSPEAKS;
%                 if ~isempty(pacing),
%                     [dummy,index] = min(abs(pacing-selframes(1)));
%                     myScriptData.ALIGNSTART = -pacing(index(1)) + selframes(1);
%                end
%         end
%     end
% 
%     if ischar(myScriptData.ALIGNSIZE),
%         switch myScriptData.ALIGNMETHOD
%             case 1,
%                 % DO NOTHING
%             otherwise
%                 selframes = TS{myScriptData.CURRENTTS}.selframes;
%                 myScriptData.ALIGNSIZE = selframes(2)-selframes(1);
%         end
%     end
% 
%     success = 1;
%     
%     return
    
    
function handle = Init(tsindex)

    if nargin == 1
        global myScriptData;
        myScriptData.CURRENTTS = tsindex;
    end
    
    clear global SLICEDISPLAY;  % just in case.. 

    handle = winMySliceDisplay;
    InitDisplayButtons(handle);
%    InitAlignButtons(handle);
%    InitAverageButtons(handle);
    InitMouseFunctions(handle);
    
    SetupNavigationBar(handle);
    SetupDisplay(handle);
    UpdateDisplay(handle);

    
    return
    
function InitMouseFunctions(handle)

    global SLICEDISPLAY;

    if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = [0 1]; end
    if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = [0 1]; end
    if ~isfield(SLICEDISPLAY,'XLIM'), SLICEDISPLAY.XLIM = [0 1]; end
    if ~isfield(SLICEDISPLAY,'YLIM'), SLICEDISPLAY.YLIM = [0 1]; end
    if isempty(SLICEDISPLAY.YWIN), SLICEDISPLAY.YWIN = [0 1]; end
    
    
    SLICEDISPLAY.ZOOM = 0;
    SLICEDISPLAY.SELEVENTS = 1;
    
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
    set(handle,'WindowButtonDownFcn','mySliceDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','mySliceDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','mySliceDisplay(''ButtonUp'',gcbf)',...
               'KeyPressFcn','mySliceDisplay(''KeyPress'',gcbf)',...
               'interruptible','off');
    return
           


        
function InitDisplayButtons(handle)

    global myScriptData SLICEDISPLAY;

    button = findobj(allchild(handle),'tag','DISPLAYTYPE');
    set(button,'string',{'Global RMS','Group RMS','Individual'},'value',myScriptData.DISPLAYTYPE);
    
    button = findobj(allchild(handle),'tag','DISPLAYOFFSET');
    set(button,'string',{'Offset ON','Offset OFF'},'value',myScriptData.DISPLAYOFFSET);
    
    button = findobj(allchild(handle),'tag','DISPLAYLABEL');
    set(button,'string',{'Label ON','Label OFF'},'value',myScriptData.DISPLAYLABEL);
    
    button = findobj(allchild(handle),'tag','DISPLAYPACING');
    set(button,'string',{'Pacing ON','Pacing OFF'},'value',myScriptData.DISPLAYPACING);
    
    button = findobj(allchild(handle),'tag','DISPLAYGRID');
    set(button,'string',{'No grid','Coarse grid','Fine grid'},'value',myScriptData.DISPLAYGRID);
    
    button = findobj(allchild(handle),'tag','DISPLAYSCALING');
    set(button,'string',{'Local','Global','Group'},'value',myScriptData.DISPLAYSCALING);

    button = findobj(allchild(handle),'tag','DISPLAYGROUP');
    group = myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP};
    myScriptData.DISPLAYGROUP = 1:length(group);
    set(button,'string',group,'max',length(group),'value',myScriptData.DISPLAYGROUP);

    button = findobj(allchild(handle),'tag','KEEPBADLEADS');
    set(button,'value',myScriptData.KEEPBADLEADS);

    if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = []; end
    if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = []; end
    
    
    %%%% set up the listeners for the sliders
    sliderx=findobj(allchild(handle),'tag','SLIDERX');
    slidery=findobj(allchild(handle),'tag','SLIDERY');

    addlistener(sliderx,'ContinuousValueChange',@UpdateSlider);
    addlistener(slidery,'ContinuousValueChange',@UpdateSlider);
    
    return
    
function DisplayButton(handle)
    %callback to all the display buttons

    global myScriptData;
    
    tag = get(handle,'tag');
    switch tag
        case {'DISPLAYTYPE','DISPLAYOFFSET','DISPLAYSCALING','DISPLAYPACING','DISPLAYGROUP'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
            parent = get(handle,'parent');
            SetupDisplay(parent);
            UpdateDisplay(parent);       
        case {'DISPLAYLABEL','DISPLAYGRID'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
            parent = get(handle,'parent');
            UpdateDisplay(parent); 
    end

    return
    
function InitAlignButtons(handle)

    global myScriptData SLICEDISPLAY;

    button = findobj(allchild(handle),'tag','ALIGNSTART');
    if isnumeric(myScriptData.ALIGNSTART), set(button,'string',num2str(myScriptData.ALIGNSTART)); else set(button,'string','detect'); end
    
    button = findobj(allchild(handle),'tag','ALIGNSIZE');
    if isnumeric(myScriptData.ALIGNSIZE), set(button,'string',num2str(myScriptData.ALIGNSIZE)); else set(button,'string','detect'); end
    
    button = findobj(allchild(handle),'tag','ALIGNMETHOD');
    set(button,'string',{'No alignment','Alignment on pacing lead','Alignment on RMS peak','Alignment on RMS correlation'},'value',myScriptData.ALIGNMETHOD);
   
    button = findobj(allchild(handle),'tag','ALIGNSIZEENABLE');
    set(button,'value',myScriptData.ALIGNSIZEENABLE); 
   
    button = findobj(allchild(handle),'tag','ALIGNSTARTENABLE');
    set(button,'value',myScriptData.ALIGNSTARTENABLE);
    
    button = findobj(allchild(handle),'tag','ALIGNRMSTYPE');
    types = myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}; types{end+1} = 'GLOBAL';
    set(button,'value',myScriptData.ALIGNRMSTYPE,'string',types);
    
    button = findobj(allchild(handle),'tag','ALIGNTHRESHOLD');
    set(button,'string',num2str(myScriptData.ALIGNTHRESHOLD));
    
    SLICEDISPLAY.RMS = [];
    SLICEDISPLAY.THRESHOLD = 0;
    SLICEDISPLAY.RMSTYPE = 0;
    SLICEDISPLAY.RMSMAX = 0;
    SLICEDISPLAY.RMSPEAKS = [];
    if ~isfield(SLICEDISPLAY,'TEMPLATE')
        SLICEDISPLAY.TEMPLATE = [];
    end
    return
    
function InitAverageButtons(handle)

    global myScriptData TS;

    button = findobj(allchild(handle),'tag','AVERAGEMAXN');
    set(button,'string',num2str(myScriptData.AVERAGEMAXN)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMAXRE');
    set(button,'string',num2str(myScriptData.AVERAGEMAXRE)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMETHOD');
    set(button,'string',{'No averaging','Averaging using matched filter RMS','Averaging using matched filter AVERAGE'},'value',myScriptData.AVERAGEMETHOD);
    
    button = findobj(allchild(handle),'tag','AVERAGERMSTYPE');
    types{1} = 'GLOBAL';
    types{2} = 'CHANNEL';
    types(3:(length(myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP})+2)) = myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP};
    set(button,'value',myScriptData.AVERAGERMSTYPE,'string',types);
    
    button = findobj(allchild(handle),'tag','AVERAGECHANNEL');
    set(button,'string',mynum2str(myScriptData.AVERAGECHANNEL));
    
    TS{myScriptData.CURRENTTS}.averagemethod = myScriptData.AVERAGEMETHOD;
    
    return    
    
    
function AverageButton(handle)

    global myScriptData TS;
    
    tag = get(handle,'tag');
    switch tag
        case {'AVERAGEMAXN','AVERAGEMAXRE'}
            value = str2num(get(handle,'string'));
            myScriptData = setfield(myScriptData,tag,value);
        case {'AVERAGERMSTYPE'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
        case {'AVERAGEMETHOD'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
            TS{myScriptData.CURRENTTS}.averagemethod = myScriptData.AVERAGEMETHOD;
            UpdateDisplay(get(handle,'parent'));
        case {'AVERAGECHANNEL'}
            myScriptData = setfield(myScriptData,tag,mystr2num(get(handle,'string')));
            TS{myScriptData.CURRENTTS}.averagechannel = myScriptData.AVERAGECHANNEL;
    end
    return

 
function vec = mystr2num(str)
    
    vec = eval(['[' str ']']);
    return
   

function str = mynum2str(vec)

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
     return    
    
function AlignButton(handle)

    global myScriptData;
    
    tag = get(handle,'tag');
    switch tag
        case {'ALIGNSTART','ALIGNSIZE'}
            value = get(handle,'string');
            if strcmp(value,'detect') ~= 1, value = str2num(value); end
            myScriptData = setfield(myScriptData,tag,value);
        case {'ALIGNMETHOD','ALIGNSTARTENABLE','ALIGNSIZEENABLE','ALIGNRMSTYPE'}
            myScriptData = setfield(myScriptData,tag,get(handle,'value'));
        case {'ALIGNTHRESHOLD'}
            value = str2num(get(handle,'string'));
            myScriptData = setfield(myScriptData,tag,value);
    end
    return
    
function AlignButtonDetect(handle)
    
    global myScriptData;
    tag = get(handle,'tag');
    handle = get(handle,'parent');
    switch tag
        case 'ALIGNSTARTDETECT'
            myScriptData.ALIGNSTART = 'detect';
            set(findobj(allchild(handle),'tag','ALIGNSTART'),'string','detect');
        case 'ALIGNSIZEDETECT',
            myScriptData.ALIGNSTART = 'detect';
            set(findobj(allchild(handle),'tag','ALIGNSIZE'),'string','detect');    
    end
    return
    
function DetectAverage(handle)

    global TS myScriptData SLICEDISPLAY;
    
    if myScriptData.AVERAGEMETHOD < 2, return; end
    
    if ~isfield(TS{myScriptData.CURRENTTS},'averageframes')
        errordlg('Select an averaging template first','DETECT AVERAGING'); return;
    end
    if isempty(TS{myScriptData.CURRENTTS}.averageframes)
        errordlg('Select an averaging template first','DETECT AVERAGING'); return;
    end
    
    frame = TS{myScriptData.CURRENTTS}.averageframes;
    rmstype = myScriptData.AVERAGERMSTYPE;
    
    if (rmstype > 2) && ( rmstype <= length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})),
        ch = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{rmstype-2};
    elseif rmstype == 1
        ch = []; for p = 1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}), ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; end
    elseif rmstype == 2
        ch = myScriptData.AVERAGECHANNEL;
    end
    
    if myScriptData.AVERAGEMETHOD == 2
        rms = sqrt(mean(TS{myScriptData.CURRENTTS}.potvals(ch,:).^2,1));
        template = rms(frame(end):-1:frame(1));
    else
        rms = mean(TS{myScriptData.CURRENTTS}.potvals(ch,:),1);
        template = rms(frame(end):-1:frame(1));
    end
    
    template = template-mean(template);
    e = ones(1,length(template));
    rmsbar = filter(e,1,rms)/length(template);
    rms = (filter(e,1,rms.^2) - 2*filter(template,1,rms) + sum(template.^2) -  (rmsbar.^2)*length(template))/sum(template.^2);
    
    m = [];
    for p = 1:floor(length(rms)/myScriptData.SAMPLEFREQ)
        m = [m max(rms([1:myScriptData.SAMPLEFREQ]+(p-1)*myScriptData.SAMPLEFREQ))];
    end
    if isempty(m), m = max(rms); end
    rmsmax = median(m);
        
    apeaks = DPeaks(-rms,(-(myScriptData.AVERAGEMAXRE).^2)*rmsmax);
    if isempty(apeaks), return; end
    
    vpeaks = rms(apeaks);
    [vpeaks,I] = sort(vpeaks);
    apeaks = apeaks(I);

    if ~isfield(TS{myScriptData.CURRENTTS},'selframes')
        selframes = frame;
    elseif isempty(TS{myScriptData.CURRENTTS}.selframes)
        selframes = frame;
    else
        selframes = TS{myScriptData.CURRENTTS}.selframes;
    end

    
    reltimeframe = selframes-apeaks(1);
    index = find(((apeaks+reltimeframe(1)) >= 1)&((apeaks+reltimeframe(2))<=length(rms))&(vpeaks < myScriptData.AVERAGEMAXRE));
    apeaks = apeaks(index); vpeaks = vpeaks(index);
    if length(apeaks) > myScriptData.AVERAGEMAXN, apeaks = apeaks(1:myScriptData.AVERAGEMAXN); end

    if vpeaks > 3
        vdif =  max(vpeaks(2:3)-vpeaks(1));
        index = find(vpeaks-vpeaks(1) < 2*vdif);
        apeaks = apeaks(index); vpeaks = vpeaks(index);
    end
    
    astart = apeaks+reltimeframe(1);
    aend   = apeaks+reltimeframe(2);
    
    TS{myScriptData.CURRENTTS}.averagestart = astart;
    TS{myScriptData.CURRENTTS}.averageend = aend;
    TS{myScriptData.CURRENTTS}.averagemethod = myScriptData.AVERAGEMETHOD;
    TS{myScriptData.CURRENTTS}.averagechannel = myScriptData.AVERAGECHANNEL;

    SetupDisplay(handle);
    UpdateDisplay(handle);
    
    return
    
function ResetAverage(handle)

    global TS SLICEDISPLAY myScriptData;
    
    if isfield(TS{myScriptData.CURRENTTS},'averagestart')
        TS{myScriptData.CURRENTTS} = rmfield(TS{myScriptData.CURRENTTS},{'averagestart','averageend'});
    end
    UpdateDisplay(handle);
    
    return
    
function SetupDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    global TS myScriptData SLICEDISPLAY;
    
    tsindex = myScriptData.CURRENTTS;
    
    numframes = size(TS{tsindex}.potvals,2);
    SLICEDISPLAY.TIME = [1:numframes]/myScriptData.SAMPLEFREQ;
    SLICEDISPLAY.XLIM = [1 numframes]/myScriptData.SAMPLEFREQ;
    
    if isempty(SLICEDISPLAY.XWIN)
        
        SLICEDISPLAY.XWIN = [median([0 SLICEDISPLAY.XLIM]) median([3000/myScriptData.SAMPLEFREQ SLICEDISPLAY.XLIM])];
    else
        SLICEDISPLAY.XWIN = [median([SLICEDISPLAY.XWIN(1) SLICEDISPLAY.XLIM]) median([SLICEDISPLAY.XWIN(2) SLICEDISPLAY.XLIM])];
    end
    
    
    SLICEDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
    SLICEDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
    SLICEDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');
    
    SLICEDISPLAY.PACING = [];
    if isfield(TS{tsindex},'pacing')
        SLICEDISPLAY.PACING = TS{tsindex}.pacing;
    else
        SLICEDISPLAY.PACING = []; 
    end
    
    
    groups = myScriptData.DISPLAYGROUP;
    numgroups = length(groups);
    
    SLICEDISPLAY.NAME ={};
    SLICEDISPLAY.GROUPNAME = {};
    SLICEDISPLAY.GROUP = [];
    
    switch myScriptData.DISPLAYTYPE
        case 1
            ch  = []; 
            for p=groups
                leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p};
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
                leads = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{groups(p)};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                SLICEDISPLAY.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
                SLICEDISPLAY.SIGNAL(p,:) = SLICEDISPLAY.SIGNAL(p,:)-min(SLICEDISPLAY.SIGNAL(p,:));
                SLICEDISPLAY.NAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)} ' RMS']; 
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
                ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; 
                SLICEDISPLAY.GROUP = [SLICEDISPLAY.GROUP p*ones(1,length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}))]; 
                SLICEDISPLAY.LEAD = [SLICEDISPLAY.LEAD myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}];
                for q=1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}), SLICEDISPLAY.NAME{end+1} = sprintf('%s # %d',myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{p},q); end 
            end
            for p=1:length(groups)
                SLICEDISPLAY.GROUPNAME{p} = [myScriptData.GROUPNAME{myScriptData.CURRENTRUNGROUP}{groups(p)}]; 
            end 
            SLICEDISPLAY.SIGNAL = TS{tsindex}.potvals(ch,:);
            SLICEDISPLAY.LEADINFO = TS{tsindex}.leadinfo(ch);
    end
        
    switch myScriptData.DISPLAYSCALING
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
    
    if myScriptData.DISPLAYTYPE == 3
        SLICEDISPLAY.SIGNAL = 0.5*SLICEDISPLAY.SIGNAL+0.5;
    end
    
    numsignal = size(SLICEDISPLAY.SIGNAL,1);
    switch myScriptData.DISPLAYOFFSET
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
    
    SLICEDISPLAY.ASIGNAL = [];
    SLICEDISPLAY.ATIME = {};
    numframes = size(SLICEDISPLAY.SIGNAL,2);
    
    if isfield(TS{myScriptData.CURRENTTS},'averagestart')
        if myScriptData.AVERAGEMETHOD > 1
            as = TS{myScriptData.CURRENTTS}.averagestart/myScriptData.SAMPLEFREQ; ae = TS{myScriptData.CURRENTTS}.averageend/myScriptData.SAMPLEFREQ;
            startframe = max([floor(myScriptData.SAMPLEFREQ*as(1)) 1]);
            endframe = min([ceil(myScriptData.SAMPLEFREQ*ae(1)) numframes]);
            lenframe = min([(endframe-startframe)+1 numframes]);
            SLICEDISPLAY.ASIGNAL = zeros(size(SLICEDISPLAY.SIGNAL,1),lenframe);
            
            n = 0;
            for p=1:length(as)
                startframe = max([floor(myScriptData.SAMPLEFREQ*as(p)) 1]);
                endframe = min([ceil(myScriptData.SAMPLEFREQ*ae(p)) numframes]);
                if (endframe > numframes), continue; end
                SLICEDISPLAY.ATIME{p} = as(p)+(1/myScriptData.SAMPLEFREQ)*[0:(lenframe-1)];
                SLICEDISPLAY.ASIGNAL = SLICEDISPLAY.ASIGNAL+SLICEDISPLAY.SIGNAL(:,startframe+[0:(lenframe-1)]);
                n = n+1;
            end
            SLICEDISPLAY.ASIGNAL = SLICEDISPLAY.ASIGNAL*(1/n);
        end
    end
    
    SLICEDISPLAY.COLORLIST = {[1 0 0],[0 0.7 0],[0 0 1],[0.5 0 0],[0 0.3 0],[0 0 0.5],[1 0.3 0.3],[0.3 0.7 0.3],[0.3 0.3 1],[0.75 0 0],[0 0.45 0],[0 0 0.75]};
   
    
    % PREPROCESS THE ALIGMENT RMS SIGNALS
    % IF A WINDOW IS SELECTED THIS WILL SPEED UP
    % THE ALIGNMENT AS NO RMS HAS TO BE COMPUTED
    if (isnumeric(myScriptData.ALIGNSTART) && (myScriptData.ALIGNSTARTENABLE == 1))
        if myScriptData.ALIGNMETHOD  > 1
            switch myScriptData.ALIGNMETHOD
                case 3
                    DetectAlignmentRMS;
                case 4
                    DetectAlignmentRMStemplate(1);
            end
        end
    end
    
    set(handle,'pointer',pointer);
    return
    
function scrollFcn(handle, eventData)
    %callback for scrolling
    diff=(-1)*eventData.VerticalScrollCount*0.05;
    
    xslider=findobj(allchild(handle),'tag','SLIDERY');
    value=get(xslider,'value');
    
    value=value+diff;
    
    if value > 1, value=1; end
    if value < 0, value=0; end
    
    set(xslider,'value',value)
    
    UpdateSlider(xslider)
    

    
function UpdateSlider(handle,~)
    %callback to slider
    global SLICEDISPLAY;

    tag = get(handle,'tag');
    value = get(handle,'value');
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
    
    parent = get(handle,'parent');
    UpdateDisplay(parent);
    return;
    
    
function UpdateDisplay(handle)

    global SLICEDISPLAY myScriptData TS;
    
    ax=findobj(allchild(handle),'tag','AXES');
    
    
    axes(ax);    
    cla(ax);   

    hold(ax,'on');
    
    ywin = SLICEDISPLAY.YWIN;
    xwin = SLICEDISPLAY.XWIN;
    xlim = SLICEDISPLAY.XLIM;
    ylim = SLICEDISPLAY.YLIM;
    
    
    
    numframes = size(SLICEDISPLAY.SIGNAL,2);
    startframe = max([floor(myScriptData.SAMPLEFREQ*xwin(1)) 1]);
    endframe = min([ceil(myScriptData.SAMPLEFREQ*xwin(2)) numframes]);

    
    numchannels = size(SLICEDISPLAY.SIGNAL,1);
    if myScriptData.DISPLAYOFFSET == 1
        chend = numchannels - max([floor(ywin(1)) 0]);
        chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
    else
        chstart = 1;
        chend = numchannels;
    end

    
    % DRAW THE GRID
    
    if myScriptData.DISPLAYGRID > 1
        if myScriptData.DISPLAYGRID > 2
            clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
            X = [clines; clines]; Y = ywin'*ones(1,length(clines));
            line(X,Y,'color',[0.9 0.9 0.9],'hittest','off');
        end
        clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(X,Y,'color',[0.5 0.5 0.5],'hittest','off');
    end

    if isfield(TS{myScriptData.CURRENTTS},'averagestart')
        if myScriptData.AVERAGEMETHOD > 1
            as = TS{myScriptData.CURRENTTS}.averagestart/myScriptData.SAMPLEFREQ; ae = TS{myScriptData.CURRENTTS}.averageend/myScriptData.SAMPLEFREQ;
            for p=1:length(as), patch('XData',[as(p) as(p) ae(p) ae(p) as(p)],'YData',[ywin(1) ywin(2) ywin(2) ywin(1) ywin(1)],'facecolor',[1 0.6 0.6]); end
            for p=1:length(as), patch('XData',[as(p) as(p) ae(p) ae(p) as(p)],'YData',[ywin(1) ywin(2) ywin(2) ywin(1) ywin(1)],'facecolor','none','edgecolor',[0 0 0],'linewidth',2); end

            for p=chstart:chend
                k = startframe:endframe;
                color = [0 0 0];
               
                for r=1:length(SLICEDISPLAY.ATIME)
                    if (SLICEDISPLAY.ATIME{r}(end) >= xwin(1)) && (SLICEDISPLAY.ATIME{r}(1) <= xwin(2)),
                        plot(ax,SLICEDISPLAY.ATIME{r},SLICEDISPLAY.ASIGNAL(p,:),'color',color,'hittest','off','linewidth',1);
                    end
                end
            end
        end
    end
            
    
    if myScriptData.DISPLAYPACING == 1
        if  ~isempty(SLICEDISPLAY.PACING)
            plines = SLICEDISPLAY.PACING/myScriptData.SAMPLEFREQ;
            plines = plines((plines >xwin(1)) & (plines < xwin(2)));
            X = [plines; plines]; Y = ywin'*ones(1,length(plines));
            line(X,Y,'color',[0.55 0 0.65],'hittest','off','linewidth',2);    
        end
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
        if (myScriptData.DISPLAYOFFSET == 1) && (myScriptData.DISPLAYLABEL == 1)&&(chend-chstart < 30) && (SLICEDISPLAY.YWIN(2) >= numchannels-p+1)
            text(ax,SLICEDISPLAY.XWIN(1),numchannels-p+1,SLICEDISPLAY.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
        end
    end
   
    if (myScriptData.DISPLAYOFFSET == 2) && (myScriptData.DISPLAYLABEL ==1)
        for q=1:length(SLICEDISPLAY.GROUPNAME)
            color = SLICEDISPLAY.COLORLIST{q};
            text(ax,SLICEDISPLAY.XWIN(1),SLICEDISPLAY.YWIN(2)-(q*0.05*(SLICEDISPLAY.YWIN(2)-SLICEDISPLAY.YWIN(1))),SLICEDISPLAY.GROUPNAME{q},'color',color,'VerticalAlignment','top','hittest','off'); 
        end    
    end
    
    
    set(SLICEDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);
    
    xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xlen < (1/myScriptData.SAMPLEFREQ), xslider = 0.999; else xslider = xwin(1)/xlen; end
    xredlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xredlen ~= 0, xfill = (xwin(2)-xwin(1))/xredlen; else xfill = myScriptData.SAMPLEFREQ; end
    xinc = median([0.01 xfill 0.999]);
    xfill = median([0.01 xfill myScriptData.SAMPLEFREQ]);
    xslider = median([1/myScriptData.SAMPLEFREQ xslider 0.999]);
    set(SLICEDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

    ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if ylen < (1/myScriptData.SAMPLEFREQ), yslider = 0.999; else yslider = ywin(1)/ylen; end
    yredlen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if yredlen ~= 0, yfill = (ywin(2)-ywin(1))/yredlen; else yfill =myScriptData.SAMPLEFREQ; end
    yinc = median([0.0002 yfill 0.999]);
    yfill = median([0.0002 yfill myScriptData.SAMPLEFREQ]);
    yslider = median([(1/myScriptData.SAMPLEFREQ) yslider 0.999]);
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
    
    if isfield(TS{myScriptData.CURRENTTS},'selframes')
        events = SLICEDISPLAY.EVENTS{1}; events = AddEvent(events,(TS{myScriptData.CURRENTTS}.selframes/myScriptData.SAMPLEFREQ)); events.selected = 0; SLICEDISPLAY.EVENTS{1} = events;
    end   
    
    if isfield(TS{myScriptData.CURRENTTS},'templateframes')
        events = SLICEDISPLAY.EVENTS{2}; events = AddEvent(events,(TS{myScriptData.CURRENTTS}.templateframes/myScriptData.SAMPLEFREQ)); events.selected = 0; SLICEDISPLAY.EVENTS{1} = events;    
    end   
    
    if isfield(TS{myScriptData.CURRENTTS},'averageframes')
        events = SLICEDISPLAY.EVENTS{3}; events = AddEvent(events,(TS{myScriptData.CURRENTTS}.averageframes/myScriptData.SAMPLEFREQ)); events.selected = 0; SLICEDISPLAY.EVENTS{3} = events;    
    end  
    
    return
   
function Zoom(handle,mode)
    global SLICEDISPLAY;

    if nargin == 2, handle = findobj(allchild(handle),'tag','DISPLAYZOOM'); end
    
    value = get(handle,'value');
    if nargin == 2, value = xor(value,1); end
    
    parent = get(handle,'parent');
    switch value
        case 0
            set(parent,'WindowButtonDownFcn','mySliceDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','mySliceDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','mySliceDisplay(''ButtonUp'',gcbf)',...
               'pointer','arrow');
            set(handle,'string','(Z)oom OFF','value',value);
            SLICEDISPLAY.ZOOM = 0;
        case 1
            set(parent,'WindowButtonDownFcn','mySliceDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','mySliceDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','mySliceDisplay(''ZoomUp'',gcbf)',...
               'pointer','crosshair');
            set(handle,'string','(Z)oom ON','value',value);
            SLICEDISPLAY.ZOOM = 1;
    end
    return
    
    
function ZoomDown(handle)
    
    global SLICEDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    if ~strcmp(seltype,'alt')
        pos = get(SLICEDISPLAY.AXES,'CurrentPoint');
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
	    point = get(SLICEDISPLAY.AXES,'CurrentPoint');
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
        point = get(SLICEDISPLAY.AXES,'CurrentPoint');
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
    
    global SLICEDISPLAY myScriptData TS;
    
    if (myScriptData.DISPLAYTYPE == 3)&&(myScriptData.DISPLAYOFFSET==1)
        m = size(SLICEDISPLAY.SIGNAL,1);
        n = median([1 ceil(m-lead) m]);
        state = SLICEDISPLAY.LEADINFO(n);
        state = bitset(state,1,xor(bitget(state,1),1));
        SLICEDISPLAY.LEADINFO(n) = state;
        TS{myScriptData.CURRENTTS}.leadinfo(SLICEDISPLAY.LEAD(n)) = state;
        UpdateDisplay(handle);
    end
    
    return
    
function  DeactivateAverage(handle,t)

    global SLICEDISPLAY myScriptData TS;

    if isfield(TS{myScriptData.CURRENTTS},'averagestart')
        as = TS{myScriptData.CURRENTTS}.averagestart/myScriptData.SAMPLEFREQ;  
        ae = TS{myScriptData.CURRENTTS}.averageend/myScriptData.SAMPLEFREQ;  
        
        keep = [];
        for p=1:length(as)
            if (t >= as(p))&&(t <= ae(p))
            else
                keep = [keep p];
            end
        end
        TS{myScriptData.CURRENTTS}.averagestart = TS{myScriptData.CURRENTTS}.averagestart(keep);
        TS{myScriptData.CURRENTTS}.averageend = TS{myScriptData.CURRENTTS}.averageend(keep);
        SetupDisplay(handle);
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
    
    seltype = get(gcbf,'SelectionType');
    
    point = get(SLICEDISPLAY.AXES,'CurrentPoint');
    t = point(1,1); y = point(1,2);
    
    if strcmp(seltype,'extend')
 %       SetBadLead(handle,y);
         DeactivateAverage(handle,t);
        return
    end
    
    
    
    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS}; 
    
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
    SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
    return   

    
function ButtonMotion(handle)
        
    global SLICEDISPLAY;

    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};  
	if events.selected > 0
        point = get(SLICEDISPLAY.AXES,'CurrentPoint');
        t = median([SLICEDISPLAY.XLIM point(1,1)]);
        SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = SetClosestEvent(events,t);
    end
    return
    
function ButtonUp(handle)
   % - events=EVENT{SD.SELEVENTS}
   % - if events.selected > 0:
   %        - get currentpoint -> setClosestEvent(events,t), set events.selected = 0
   %        - AlignEvents???
   %        - set ts.selframes (or templateframes r averageframes,
   %        depending on SD.SELEVENTS)
   % -drawnow
   
    
    
    
    global SLICEDISPLAY TS myScriptData;

    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};  
    if events.selected > 0
 	    point = get(SLICEDISPLAY.AXES,'CurrentPoint');
	    t = median([SLICEDISPLAY.XLIM point(1,1)]);
        events = SetClosestEvent(events,t); 
        events.selected = 0;
 %       events = AlignEvents(events);
        
        SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
        switch  SLICEDISPLAY.SELEVENTS
            case 1
                TS{myScriptData.CURRENTTS}.selframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ)); 
            case 2
                TS{myScriptData.CURRENTTS}.templateframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ));
            case 3
                TS{myScriptData.CURRENTTS}.averageframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ));
        end
    end
    
    drawnow;
    return

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

function events = AlignEvents(events)
% unimportant?! since I dont Align?
    global SLICEDISPLAY myScriptData;
    if SLICEDISPLAY.SELEVENTS > 1, return; end
    
    events.timepos = sort(events.timepos);
    
    if (isnumeric(myScriptData.ALIGNSTART) && (myScriptData.ALIGNSTARTENABLE == 1))
    
        if myScriptData.ALIGNMETHOD  > 1
            switch myScriptData.ALIGNMETHOD
                case 2
                    pacing = (SLICEDISPLAY.PACING/myScriptData.SAMPLEFREQ);
                case 3
                    DetectAlignmentRMS;
                    pacing = (SLICEDISPLAY.RMSPEAKS/myScriptData.SAMPLEFREQ);
                case 4
                    DetectAlignmentRMStemplate(1);
                    pacing = (SLICEDISPLAY.RMSPEAKS/myScriptData.SAMPLEFREQ);
            end
            start = events.timepos(1)-(myScriptData.ALIGNSTART/myScriptData.SAMPLEFREQ);
            pacing = pacing(pacing-(myScriptData.ALIGNSTART/myScriptData.SAMPLEFREQ) >= SLICEDISPLAY.XLIM(1));
            [~,index] = min(abs(pacing-start));
            start = pacing(index(1))+(myScriptData.ALIGNSTART/myScriptData.SAMPLEFREQ);
            events.timepos(1) = median([start SLICEDISPLAY.XLIM]);
        end
    end
    
    if (isnumeric(myScriptData.ALIGNSIZE) && (myScriptData.ALIGNSIZEENABLE == 1))
    
        switch myScriptData.ALIGNMETHOD
            case 1
                % DO NOTHING
            otherwise
                events.timepos(2) = median([(events.timepos(1)+(myScriptData.ALIGNSIZE/myScriptData.SAMPLEFREQ)) SLICEDISPLAY.XLIM]);                
        end
    end
    
    p = events.timepos;
    set(events.box,'XData',[p(1) p(1) p(2) p(2)]);
 %   drawnow;
    return
    
    
function DetectAlignmentRMS

    global SLICEDISPLAY myScriptData TS;
    
    if (SLICEDISPLAY.RMSTYPE ~= myScriptData.ALIGNRMSTYPE)||(isempty(SLICEDISPLAY.RMS))
        SLICEDISPLAY.THRESHOLD = 0;
        rmstype = myScriptData.ALIGNRMSTYPE;
        if rmstype > length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
            ch = []; for p = 1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}), ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; end
        else
            ch = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{rmstype};
        end
    
        SLICEDISPLAY.RMS= sqrt(mean(TS{myScriptData.CURRENTTS}.potvals(ch,:).^2));
        SLICEDISPLAY.RMSTYPE = rmstype;
        
        m = [];
        for p = 1:floor(length(SLICEDISPLAY.RMS)/myScriptData.SAMPLEFREQ)
            m = [m max(SLICEDISPLAY.RMS([1:myScriptData.SAMPLEFREQ]+(p-1)*myScriptData.SAMPLEFREQ))];
        end
        if isempty(m), m = max(SLICEDISPLAY.RMS); end
        
        SLICEDISPLAY.RMSMAX = median(m);
    end
    
    if (SLICEDISPLAY.THRESHOLD ~= myScriptData.ALIGNTHRESHOLD)
        SLICEDISPLAY.THRESHOLD = myScriptData.ALIGNTHRESHOLD;
        SLICEDISPLAY.RMSPEAKS = DPeaks(SLICEDISPLAY.RMS,SLICEDISPLAY.THRESHOLD*SLICEDISPLAY.RMSMAX);
    end
    return
    

function DetectAlignmentRMStemplate(mode)

    global SLICEDISPLAY myScriptData TS;
    
    if (SLICEDISPLAY.RMSTYPE ~= myScriptData.ALIGNRMSTYPE)||(mode == 2)||(isempty(SLICEDISPLAY.RMS))
        SLICEDISPLAY.THRESHOLD = 0;
        rmstype = myScriptData.ALIGNRMSTYPE;
        if rmstype > length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP})
            ch = []; for p = 1:length(myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}), ch = [ch myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{p}]; end
        else
            ch = myScriptData.GROUPLEADS{myScriptData.CURRENTRUNGROUP}{rmstype};
        end
    
        SLICEDISPLAY.RMS= sqrt(mean(TS{myScriptData.CURRENTTS}.potvals(ch,:).^2));
        SLICEDISPLAY.RMSTYPE = rmstype;
        
        if mode == 2
            template = TS{myScriptData.CURRENTTS}.templateframe;
            SLICEDISPLAY.TEMPLATE = SLICEDISPLAY.RMS(template(end):-1:template(1));
        end
        SLICEDISPLAY.RMS = -filter(ones(1,length(SLICEDISPLAY.TEMPLATE)),1,SLICEDISPLAY.RMS.^2) + 2*filter(SLICEDISPLAY.TEMPLATE,1,SLICEDISPLAY.RMS) - sum(SLICEDISPLAY.TEMPLATE.^2);
        SLICEDISPLAY.RMS = SLICEDISPLAY.RMS - min(SLICEDISPLAY.RMS);
        m = [];
        for p = 1:floor(length(SLICEDISPLAY.RMS)/myScriptData.SAMPLEFREQ)
            m = [m max(SLICEDISPLAY.RMS([1:myScriptData.SAMPLEFREQ]+(p-1)*myScriptData.SAMPLEFREQ))];
        end
        if isempty(m), m = max(SLICEDISPLAY.RMS); end
        SLICEDISPLAY.RMSMAX = median(m);
    end
    
    if (SLICEDISPLAY.THRESHOLD ~= myScriptData.ALIGNTHRESHOLD)
        SLICEDISPLAY.THRESHOLD = myScriptData.ALIGNTHRESHOLD;
        SLICEDISPLAY.RMSPEAKS = DPeaks(SLICEDISPLAY.RMS,SLICEDISPLAY.THRESHOLD*SLICEDISPLAY.RMSMAX);
    end
    
    return
    
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
    
return   

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
   % drawnow;
return

function SetEvents(handle)

    global SLICEDISPLAY;
    SLICEDISPLAY.SELEVENTS = get(handle,'value');
    return

function KeepBadleads(handle)

    global myScriptData;
    myScriptData.KEEPBADLEADS = get(handle,'value');
    return
    
function KeyPress(handle)

    global myScriptData SLICEDISPLAY TS;

    key = real(handle.CurrentCharacter);
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    switch key(1) 
        case {8, 127}  % delete and backspace keys
	        % delete current selected frame
            obj = findobj(allchild(handle),'tag','DISPLAYZOOM');
            value = get(obj,'value');
            if value == 0
                point = get(SLICEDISPLAY.AXES,'CurrentPoint');
                xwin = SLICEDISPLAY.XWIN;
                ywin = SLICEDISPLAY.YWIN;
                t = point(1,1); y = point(1,2);
                if (t>xwin(1))&&(t<xwin(2))&&(y>ywin(1))&&(y<ywin(2))
                    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};
                    events = FindClosestEvent(events,t);
                    events = DeleteEvent(events);   
                    SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
                    switch SLICEDISPLAY.SELEVENTS
                        case 1
                            TS{myScriptData.CURRENTTS}.selframes = []; 
                        case 2
                            TS{myScriptData.CURRENTTS}.templateframes = [];
                        case 3
                            TS{myScriptData.CURRENTTS}.averageframes = [];
                    end
                end    
            end
        case {28,29}  %left and right arrow
                events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};  
                if isfield(events,'last_selected')  
                    events.selected=events.last_selected;
                    if events.last_selected==1
                        t=events.timepos(1);
                    elseif events.last_selected==2
                        t=events.timepos(2);
                    end
                    
                    if key(1)==28
                        t=t-(1/myScriptData.SAMPLEFREQ);
                    else
                        t=t+(1/myScriptData.SAMPLEFREQ);
                    end
                    t = median([SLICEDISPLAY.XLIM t]);
                
                    events = SetClosestEvent(events,t); 
                    events.selected=0;

                    SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
                    switch  SLICEDISPLAY.SELEVENTS
                        case 1
                            TS{myScriptData.CURRENTTS}.selframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ)); 
                        case 2
                            TS{myScriptData.CURRENTTS}.templateframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ));
                        case 3
                            TS{myScriptData.CURRENTTS}.averageframes = sort(round(events.timepos*myScriptData.SAMPLEFREQ));
                    end
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
    return
    

