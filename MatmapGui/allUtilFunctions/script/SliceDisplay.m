function handle = SliceDisplay(varargin)

% FUNCTION SliceDisplay()
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


function Navigation(handle,mode)

    global SCRIPT;
    
    switch mode
    case {'prev','next','stop'},
        SCRIPT.NAVIGATION = mode;
        set(handle,'DeleteFcn','');
        delete(handle);
    case {'apply'}
        global SCRIPT TS;
        tsindex = SCRIPT.CURRENTTS;
        if ~isfield(TS{tsindex},'selframes'),
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        elseif isempty(TS{tsindex}.selframes),
            errordlg('No selection has been made; use the mouse to select a piece of signal');
        else
            if DetectAlignment(handle) == 0, return; end
            SCRIPT.NAVIGATION = 'apply';
            set(handle,'DeleteFcn','');
            delete(handle);
        end
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
    
function success = DetectAlignment(handle)

    global SCRIPT SLICEDISPLAY TS;
    
    if ischar(SCRIPT.ALIGNSTART),
        switch SCRIPT.ALIGNMETHOD
            case 1,
                % DO NOTHING
            case 2,
                selframes = TS{SCRIPT.CURRENTTS}.selframes;
                if isfield(TS{SCRIPT.CURRENTTS},'pacing'),
                    pacing = TS{SCRIPT.CURRENTTS}.pacing;
                    [dummy,index] = min(abs(pacing-selframes(1)));
                    SCRIPT.ALIGNSTART = -pacing(index(1)) + selframes(1);
                end
            case 3,
                DetectAlignmentRMS;
                selframes = TS{SCRIPT.CURRENTTS}.selframes;
                pacing = SLICEDISPLAY.RMSPEAKS;
                if ~isempty(pacing)
                    [dummy,index] = min(abs(pacing-selframes(1)));
                    SCRIPT.ALIGNSTART = -pacing(index(1)) + selframes(1);
                end
            case 4,
                success = 1;
                if ~isfield(TS{SCRIPT.CURRENTTS},'templateframe'), success = 0;
                elseif isempty(TS{SCRIPT.CURRENTTS}.templateframe), success = 0; end
                if success == 0,
                    errordlg('You need to specify a template for alignment','AUTOMATIC ALIGNMENT');
                   return;    
                end
                DetectAlignmentRMStemplate(2);
                selframes = TS{SCRIPT.CURRENTTS}.selframes;
                pacing = SLICEDISPLAY.RMSPEAKS;
                if ~isempty(pacing),
                    [dummy,index] = min(abs(pacing-selframes(1)));
                    SCRIPT.ALIGNSTART = -pacing(index(1)) + selframes(1);
               end
        end
    end

    if ischar(SCRIPT.ALIGNSIZE),
        switch SCRIPT.ALIGNMETHOD
            case 1,
                % DO NOTHING
            otherwise
                selframes = TS{SCRIPT.CURRENTTS}.selframes;
                SCRIPT.ALIGNSIZE = selframes(2)-selframes(1);
        end
    end

    success = 1;
    
    return
    
function handle = Init(tsindex)

    if nargin == 1,
        global SCRIPT;
        SCRIPT.CURRENTTS = tsindex;
    end

    handle = winSliceDisplay;
    InitDisplayButtons(handle);
    InitAlignButtons(handle);
    InitAverageButtons(handle);
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
    set(handle,'WindowButtonDownFcn','SliceDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','SliceDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','SliceDisplay(''ButtonUp'',gcbf)','KeyPressFcn','SliceDisplay(''KeyPress'',gcbf)','interruptible','off');
    return
           
    
function InitDisplayButtons(handle),

    global SCRIPT SLICEDISPLAY;

    button = findobj(allchild(handle),'tag','DISPLAYTYPE');
    set(button,'string',{'Global RMS','Group RMS','Individual'},'value',SCRIPT.DISPLAYTYPE);
    
    button = findobj(allchild(handle),'tag','DISPLAYOFFSET');
    set(button,'string',{'Offset ON','Offset OFF'},'value',SCRIPT.DISPLAYOFFSET);
    
    button = findobj(allchild(handle),'tag','DISPLAYLABEL');
    set(button,'string',{'Label ON','Label OFF'},'value',SCRIPT.DISPLAYLABEL);
    
    button = findobj(allchild(handle),'tag','DISPLAYPACING');
    set(button,'string',{'Pacing ON','Pacing OFF'},'value',SCRIPT.DISPLAYPACING);
    
    button = findobj(allchild(handle),'tag','DISPLAYGRID');
    set(button,'string',{'No grid','Coarse grid','Fine grid'},'value',SCRIPT.DISPLAYGRID);
    
    button = findobj(allchild(handle),'tag','DISPLAYSCALING');
    set(button,'string',{'Local','Global','Group'},'value',SCRIPT.DISPLAYSCALING);

    button = findobj(allchild(handle),'tag','DISPLAYGROUP');
    group = SCRIPT.GROUPNAME;
    if (isempty(SCRIPT.DISPLAYGROUP))|(SCRIPT.DISPLAYGROUP == 0),
        SCRIPT.DISPLAYGROUP = 1:length(group);
    end
    SCRIPT.DISPLAYGROUP = intersect(SCRIPT.DISPLAYGROUP,[1:length(group)]);
    set(button,'string',group,'max',length(group),'value',SCRIPT.DISPLAYGROUP);

    button = findobj(allchild(handle),'tag','KEEPBADLEADS');
    set(button,'value',SCRIPT.KEEPBADLEADS);

    if ~isfield(SLICEDISPLAY,'XWIN'), SLICEDISPLAY.XWIN = []; end
    if ~isfield(SLICEDISPLAY,'YWIN'), SLICEDISPLAY.YWIN = []; end
    
    return
    
function DisplayButton(handle)

    global SCRIPT;
    
    tag = get(handle,'tag');
    switch tag
        case {'DISPLAYTYPE','DISPLAYOFFSET','DISPLAYSCALING','DISPLAYPACING','DISPLAYGROUP'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            SetupDisplay(parent);
            UpdateDisplay(parent);       
        case {'DISPLAYLABEL','DISPLAYGRID'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
            parent = get(handle,'parent');
            UpdateDisplay(parent); 
    end

    return
    
function InitAlignButtons(handle),

    global SCRIPT SLICEDISPLAY;

    button = findobj(allchild(handle),'tag','ALIGNSTART');
    if isnumeric(SCRIPT.ALIGNSTART), set(button,'string',num2str(SCRIPT.ALIGNSTART)); else set(button,'string','detect'); end
    
    button = findobj(allchild(handle),'tag','ALIGNSIZE');
    if isnumeric(SCRIPT.ALIGNSIZE), set(button,'string',num2str(SCRIPT.ALIGNSIZE)); else set(button,'string','detect'); end
    
    button = findobj(allchild(handle),'tag','ALIGNMETHOD');
    set(button,'string',{'No alignment','Alignment on pacing lead','Alignment on RMS peak','Alignment on RMS correlation'},'value',SCRIPT.ALIGNMETHOD);
   
    button = findobj(allchild(handle),'tag','ALIGNSIZEENABLE');
    set(button,'value',SCRIPT.ALIGNSIZEENABLE); 
   
    button = findobj(allchild(handle),'tag','ALIGNSTARTENABLE');
    set(button,'value',SCRIPT.ALIGNSTARTENABLE);
    
    button = findobj(allchild(handle),'tag','ALIGNRMSTYPE');
    types = SCRIPT.GROUPNAME; types{end+1} = 'GLOBAL';
    set(button,'value',SCRIPT.ALIGNRMSTYPE,'string',types);
    
    button = findobj(allchild(handle),'tag','ALIGNTHRESHOLD');
    set(button,'string',num2str(SCRIPT.ALIGNTHRESHOLD));
    
    SLICEDISPLAY.RMS = [];
    SLICEDISPLAY.THRESHOLD = 0;
    SLICEDISPLAY.RMSTYPE = 0;
    SLICEDISPLAY.RMSMAX = 0;
    SLICEDISPLAY.RMSPEAKS = [];
    if ~isfield(SLICEDISPLAY,'TEMPLATE'),
        SLICEDISPLAY.TEMPLATE = [];
    end
    return
    
function InitAverageButtons(handle),

    global SCRIPT SLICEDISPLAY TS;

    button = findobj(allchild(handle),'tag','AVERAGEMAXN');
    set(button,'string',num2str(SCRIPT.AVERAGEMAXN)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMAXRE');
    set(button,'string',num2str(SCRIPT.AVERAGEMAXRE)); 
    
    button = findobj(allchild(handle),'tag','AVERAGEMETHOD');
    set(button,'string',{'No averaging','Averaging using matched filter RMS','Averaging using matched filter AVERAGE'},'value',SCRIPT.AVERAGEMETHOD);
    
    button = findobj(allchild(handle),'tag','AVERAGERMSTYPE');
    types{1} = 'GLOBAL';
    types{2} = 'CHANNEL';
    types(3:(length(SCRIPT.GROUPNAME)+2)) = SCRIPT.GROUPNAME;
    set(button,'value',SCRIPT.AVERAGERMSTYPE,'string',types);
    
    button = findobj(allchild(handle),'tag','AVERAGECHANNEL');
    set(button,'string',mynum2str(SCRIPT.AVERAGECHANNEL));
    
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
            UpdateDisplay(get(handle,'parent'));
        case {'AVERAGECHANNEL'}
            SCRIPT = setfield(SCRIPT,tag,mystr2num(get(handle,'string')));
            TS{SCRIPT.CURRENTTS}.averagechannel = SCRIPT.AVERAGECHANNEL;
    end
    return

 
function vec = mystr2num(str)
    
    vec = eval(['[' str ']']);
    return
   

function str = mynum2str(vec)

    if length(vec) == 1,
        str = num2str(vec);
    else
        if nnz(vec-round(vec)) > 0,
            str = num2str(vec);
        else
            vec = sort(vec);
            str = '';
            ind = 1;
            len = length(vec);
            while (ind <= len),
                if (len-ind) > 0,
                     step = vec(ind+1)-vec(ind);
                     k = 1;
                     while (k+ind+1 <= len)
                         if vec(ind+k+1)-vec(ind+k) == step, 
                             k = k + 1;
                         else
                             break;
                         end
                     end
                     if k > 1,
                         if step == 1,
                            str = [str sprintf('%d:%d ',vec(ind),vec(ind+k))]; ind = ind + k+1;
                        else
                            str = [str sprintf('%d:%d:%d ',vec(ind),step,vec(ind+k))]; ind = ind + k+1;
                        end
                     else
                         str = [str sprintf('%d ',vec(ind))]; ind = ind + 1;
                     end
                 else
                     for p = ind:len,
                         str = [str sprintf('%d ',vec(p))]; ind = len + 1;
                     end
                 end
             end
         end
     end
     return    
    
function AlignButton(handle)

    global SCRIPT;
    
    tag = get(handle,'tag');
    switch tag
        case {'ALIGNSTART','ALIGNSIZE'}
            value = get(handle,'string');
            if strcmp(value,'detect') ~= 1, value = str2num(value); end
            SCRIPT = setfield(SCRIPT,tag,value);
        case {'ALIGNMETHOD','ALIGNSTARTENABLE','ALIGNSIZEENABLE','ALIGNRMSTYPE'}
            SCRIPT = setfield(SCRIPT,tag,get(handle,'value'));
        case {'ALIGNTHRESHOLD'}
            value = str2num(get(handle,'string'));
            SCRIPT = setfield(SCRIPT,tag,value);
    end
    return
    
function AlignButtonDetect(handle)
    
    global SCRIPT;
    tag = get(handle,'tag');
    handle = get(handle,'parent');
    switch tag
        case 'ALIGNSTARTDETECT',
            SCRIPT.ALIGNSTART = 'detect';
            set(findobj(allchild(handle),'tag','ALIGNSTART'),'string','detect');
        case 'ALIGNSIZEDETECT',
            SCRIPT.ALIGNSTART = 'detect';
            set(findobj(allchild(handle),'tag','ALIGNSIZE'),'string','detect');    
    end
    return
    
function DetectAverage(handle)

    global TS SCRIPT SLICEDISPLAY;
    
    if SCRIPT.AVERAGEMETHOD < 2, return; end
    
    if ~isfield(TS{SCRIPT.CURRENTTS},'averageframes'),
        errordlg('Select an averaging template first','DETECT AVERAGING'); return;
    end
    if isempty(TS{SCRIPT.CURRENTTS}.averageframes),
        errordlg('Select an averaging template first','DETECT AVERAGING'); return;
    end
    
    frame = TS{SCRIPT.CURRENTTS}.averageframes;
    rmstype = SCRIPT.AVERAGERMSTYPE;
    
    if (rmstype > 2) & ( rmstype <= length(SCRIPT.GROUPLEADS)),
        ch = SCRIPT.GROUPLEADS{rmstype-2};
    elseif rmstype == 1,
        ch = []; for p = 1:length(SCRIPT.GROUPLEADS), ch = [ch SCRIPT.GROUPLEADS{p}]; end
    elseif rmstype == 2,
        ch = SCRIPT.AVERAGECHANNEL;
    end
    
    if SCRIPT.AVERAGEMETHOD == 2,
        rms = sqrt(mean(TS{SCRIPT.CURRENTTS}.potvals(ch,:).^2,1));
        template = rms(frame(end):-1:frame(1));
    else
        rms = mean(TS{SCRIPT.CURRENTTS}.potvals(ch,:),1);
        template = rms(frame(end):-1:frame(1));
    end
    
    template = template-mean(template);
    e = ones(1,length(template));
    rmsbar = filter(e,1,rms)/length(template);
    rms = (filter(e,1,rms.^2) - 2*filter(template,1,rms) + sum(template.^2) -  (rmsbar.^2)*length(template))/sum(template.^2);
    
    m = [];
    for p = 1:floor(length(rms)/1000),
        m = [m max(rms([1:1000]+(p-1)*1000))];
    end
    if isempty(m), m = max(rms); end
    rmsmax = median(m);
        
    apeaks = DPeaks(-rms,(-(SCRIPT.AVERAGEMAXRE).^2)*rmsmax);
    if isempty(apeaks), return; end
    
    vpeaks = rms(apeaks);
    [vpeaks,I] = sort(vpeaks);
    apeaks = apeaks(I);

    if ~isfield(TS{SCRIPT.CURRENTTS},'selframes'),
        selframes = frame;
    elseif isempty(TS{SCRIPT.CURRENTTS}.selframes),
        selframes = frame;
    else
        selframes = TS{SCRIPT.CURRENTTS}.selframes;
    end

    
    reltimeframe = selframes-apeaks(1);
    index = find(((apeaks+reltimeframe(1)) >= 1)&((apeaks+reltimeframe(2))<=length(rms))&(vpeaks < SCRIPT.AVERAGEMAXRE));
    apeaks = apeaks(index); vpeaks = vpeaks(index);
    if length(apeaks) > SCRIPT.AVERAGEMAXN, apeaks = apeaks(1:SCRIPT.AVERAGEMAXN); end

    if vpeaks > 3, 
        vdif =  max(vpeaks(2:3)-vpeaks(1));
        index = find(vpeaks-vpeaks(1) < 2*vdif);
        apeaks = apeaks(index); vpeaks = vpeaks(index);
    end
    
    astart = apeaks+reltimeframe(1);
    aend   = apeaks+reltimeframe(2);
    
    TS{SCRIPT.CURRENTTS}.averagestart = astart;
    TS{SCRIPT.CURRENTTS}.averageend = aend;
    TS{SCRIPT.CURRENTTS}.averagemethod = SCRIPT.AVERAGEMETHOD;
    TS{SCRIPT.CURRENTTS}.averagechannel = SCRIPT.AVERAGECHANNEL;

    SetupDisplay(handle);
    UpdateDisplay(handle);
    
    return
    
function ResetAverage(handle)

    global TS SLICEDISPLAY SCRIPT;
    
    if isfield(TS{SCRIPT.CURRENTTS},'averagestart'),
        TS{SCRIPT.CURRENTTS} = rmfield(TS{SCRIPT.CURRENTTS},{'averagestart','averageend'});
    end
    UpdateDisplay(handle);
    
    return
    
function SetupDisplay(handle)

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');
    global TS SCRIPT SLICEDISPLAY;
    
    tsindex = SCRIPT.CURRENTTS;
    
    numframes = size(TS{tsindex}.potvals,2);
    SLICEDISPLAY.TIME = [1:numframes]*0.001;
    SLICEDISPLAY.XLIM = [1 numframes]*0.001;

    if isempty(SLICEDISPLAY.XWIN);
        SLICEDISPLAY.XWIN = [median([0 SLICEDISPLAY.XLIM]) median([3 SLICEDISPLAY.XLIM])];
    else
        SLICEDISPLAY.XWIN = [median([SLICEDISPLAY.XWIN(1) SLICEDISPLAY.XLIM]) median([SLICEDISPLAY.XWIN(2) SLICEDISPLAY.XLIM])];
    end
    
    SLICEDISPLAY.AXES = findobj(allchild(handle),'tag','AXES');
    SLICEDISPLAY.XSLIDER = findobj(allchild(handle),'tag','SLIDERX');
    SLICEDISPLAY.YSLIDER = findobj(allchild(handle),'tag','SLIDERY');
    
    SLICEDISPLAY.PACING = [];
    if isfield(TS{tsindex},'pacing'),
        SLICEDISPLAY.PACING = TS{tsindex}.pacing;
    else
        SLICEDISPLAY.PACING = []; 
    end
    
    
    groups = SCRIPT.DISPLAYGROUP;
    numgroups = length(groups);
    
    SLICEDISPLAY.NAME ={};
    SLICEDISPLAY.GROUPNAME = {};
    SLICEDISPLAY.GROUP = [];
    
    switch SCRIPT.DISPLAYTYPE,
        case 1,
            ch  = []; 
            for p=groups, 
                leads = SCRIPT.GROUPLEADS{p};
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
        case 2,
            SLICEDISPLAY.SIGNAL = zeros(numgroups,numframes);
            for p=1:numgroups, 
                leads = SCRIPT.GROUPLEADS{groups(p)};
                index = find(TS{tsindex}.leadinfo(leads)==0);
                SLICEDISPLAY.SIGNAL(p,:) = sqrt(mean(TS{tsindex}.potvals(leads(index),:).^2)); 
                SLICEDISPLAY.SIGNAL(p,:) = SLICEDISPLAY.SIGNAL(p,:)-min(SLICEDISPLAY.SIGNAL(p,:));
                SLICEDISPLAY.NAME{p} = [SCRIPT.GROUPNAME{groups(p)} ' RMS']; 
            end
            SLICEDISPLAY.GROUPNAME = SLICEDISPLAY.NAME;
            SLICEDISPLAY.GROUP = 1:numgroups;
            SLICEDISPLAY.LEAD = 0*SLICEDISPLAY.GROUP;
            SLICEDISPLAY.LEADINFO = zeros(numgroups,1);
        case 3,
            SLICEDISPLAY.GROUP =[];
            SLICEDISPLAY.NAME = {};
            SLICEDISPLAY.LEAD = [];
            ch  = []; 
            for p=groups, 
                ch = [ch SCRIPT.GROUPLEADS{p}]; 
                SLICEDISPLAY.GROUP = [SLICEDISPLAY.GROUP p*ones(1,length(SCRIPT.GROUPLEADS{p}))]; 
                SLICEDISPLAY.LEAD = [SLICEDISPLAY.LEAD SCRIPT.GROUPLEADS{p}];
                for q=1:length(SCRIPT.GROUPLEADS{p}), SLICEDISPLAY.NAME{end+1} = sprintf('%s # %d',SCRIPT.GROUPNAME{p},q); end 
            end
            for p=1:length(groups),
                SLICEDISPLAY.GROUPNAME{p} = [SCRIPT.GROUPNAME{groups(p)}]; 
            end 
            SLICEDISPLAY.SIGNAL = TS{tsindex}.potvals(ch,:);
            SLICEDISPLAY.LEADINFO = TS{tsindex}.leadinfo(ch);
    end
        
    switch SCRIPT.DISPLAYSCALING,
        case 1,
            k = max(abs(SLICEDISPLAY.SIGNAL),[],2);
            [m,n] = size(SLICEDISPLAY.SIGNAL);
            k(find(k==0)) = 1;
            s = sparse(1:m,1:m,1./k,m,m);
            SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
        case 2,
            k = max(abs(SLICEDISPLAY.SIGNAL(:)));
            [m,n] = size(SLICEDISPLAY.SIGNAL);
            if k > 0,
                s = sparse(1:m,1:m,1/k*ones(1,m),m,m);
                SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
            end
        case 3,
            [m,n] = size(SLICEDISPLAY.SIGNAL);
            k = ones(m,1);
            for p=groups,
                ind = find(SLICEDISPLAY.GROUP == p);
                k(ind) = max(max(abs(SLICEDISPLAY.SIGNAL(ind,:)),[],2));
            end
            s = sparse(1:m,1:m,1./k,m,m);
            SLICEDISPLAY.SIGNAL = s*SLICEDISPLAY.SIGNAL;
    end
    
    if SCRIPT.DISPLAYTYPE == 3,
        SLICEDISPLAY.SIGNAL = 0.5*SLICEDISPLAY.SIGNAL+0.5;
    end
    
    numsignal = size(SLICEDISPLAY.SIGNAL,1);
    switch SCRIPT.DISPLAYOFFSET,
        case 1,
            for p=1:numsignal,
                SLICEDISPLAY.SIGNAL(p,:) = SLICEDISPLAY.SIGNAL(p,:)+(numsignal-p);
            end
            ylim = SLICEDISPLAY.YLIM;
            SLICEDISPLAY.YLIM = [0 numsignal];
            if ~isempty(setdiff(ylim,SLICEDISPLAY.YLIM)),
                SLICEDISPLAY.YWIN = [max([0 numsignal-6]) numsignal];
            end
        case 2,
            ylim = SLICEDISPLAY.YLIM;
            SLICEDISPLAY.YLIM = [0 1];
            if ~isempty(setdiff(ylim,SLICEDISPLAY.YLIM)),
                SLICEDISPLAY.YWIN = [0 1];
            end
    end
    
    SLICEDISPLAY.ASIGNAL = [];
    SLICEDISPLAY.ATIME = {};
    numframes = size(SLICEDISPLAY.SIGNAL,2);
    
    if isfield(TS{SCRIPT.CURRENTTS},'averagestart'),
        if SCRIPT.AVERAGEMETHOD > 1,
            as = TS{SCRIPT.CURRENTTS}.averagestart/1000; ae = TS{SCRIPT.CURRENTTS}.averageend/1000;
            startframe = max([floor(1000*as(1)) 1]);
            endframe = min([ceil(1000*ae(1)) numframes]);
            lenframe = min([(endframe-startframe)+1 numframes]);
            SLICEDISPLAY.ASIGNAL = zeros(size(SLICEDISPLAY.SIGNAL,1),lenframe);
            
            n = 0;
            for p=1:length(as),
                startframe = max([floor(1000*as(p)) 1]);
                endframe = min([ceil(1000*ae(p)) numframes]);
                if (endframe > numframes), continue; end
                SLICEDISPLAY.ATIME{p} = as(p)+(1/1000)*[0:(lenframe-1)];
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
    if (isnumeric(SCRIPT.ALIGNSTART) & (SCRIPT.ALIGNSTARTENABLE == 1)),
        if SCRIPT.ALIGNMETHOD  > 1,
            switch SCRIPT.ALIGNMETHOD,
                case 3,
                    DetectAlignmentRMS;
                case 4,
                    DetectAlignmentRMStemplate(1);
            end
        end
    end
    
    set(handle,'pointer',pointer);
    
    return

function UpdateSlider(handle)

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

    pointer = get(handle,'pointer');
    set(handle,'pointer','watch');

    global SLICEDISPLAY SCRIPT TS;
    
    axes(SLICEDISPLAY.AXES);
    cla;
    hold on;
    ywin = SLICEDISPLAY.YWIN;
    xwin = SLICEDISPLAY.XWIN;
    xlim = SLICEDISPLAY.XLIM;
    ylim = SLICEDISPLAY.YLIM;
    
    numframes = size(SLICEDISPLAY.SIGNAL,2);
    startframe = max([floor(1000*xwin(1)) 1]);
    endframe = min([ceil(1000*xwin(2)) numframes]);

    
    numchannels = size(SLICEDISPLAY.SIGNAL,1);
    if SCRIPT.DISPLAYOFFSET == 1,
        chend = numchannels - max([floor(ywin(1)) 0]);
        chstart = numchannels - min([ceil(ywin(2)) numchannels])+1;
    else
        chstart = 1;
        chend = numchannels;
    end

    
    % DRAW THE GRID
    
    if SCRIPT.DISPLAYGRID > 1,
        if SCRIPT.DISPLAYGRID > 2,
            clines = 0.04*[floor(xwin(1)/0.04):ceil(xwin(2)/0.04)];
            X = [clines; clines]; Y = ywin'*ones(1,length(clines));
            line(X,Y,'color',[0.9 0.9 0.9],'hittest','off');
        end
        clines = 0.2*[floor(xwin(1)/0.2):ceil(xwin(2)/0.2)];
        X = [clines; clines]; Y = ywin'*ones(1,length(clines));
        line(X,Y,'color',[0.5 0.5 0.5],'hittest','off');
    end

    if isfield(TS{SCRIPT.CURRENTTS},'averagestart'),
        if SCRIPT.AVERAGEMETHOD > 1,
            as = TS{SCRIPT.CURRENTTS}.averagestart/1000; ae = TS{SCRIPT.CURRENTTS}.averageend/1000;
            for p=1:length(as), patch('XData',[as(p) as(p) ae(p) ae(p) as(p)],'YData',[ywin(1) ywin(2) ywin(2) ywin(1) ywin(1)],'facecolor',[1 0.6 0.6]); end
            for p=1:length(as), patch('XData',[as(p) as(p) ae(p) ae(p) as(p)],'YData',[ywin(1) ywin(2) ywin(2) ywin(1) ywin(1)],'facecolor','none','edgecolor',[0 0 0],'linewidth',2); end

            for p=chstart:chend,
                k = startframe:endframe;
                color = [0 0 0];
               
                for r=1:length(SLICEDISPLAY.ATIME),
                    if (SLICEDISPLAY.ATIME{r}(end) >= xwin(1)) & (SLICEDISPLAY.ATIME{r}(1) <= xwin(2)),
                        plot(SLICEDISPLAY.ATIME{r},SLICEDISPLAY.ASIGNAL(p,:),'color',color,'hittest','off','linewidth',1);
                    end
                end
            end
        end
    end
            
    
    if SCRIPT.DISPLAYPACING == 1,
        if  length(SLICEDISPLAY.PACING) > 0,
            plines = SLICEDISPLAY.PACING/1000;
            plines = plines(find((plines >xwin(1)) & (plines < xwin(2))));
            X = [plines; plines]; Y = ywin'*ones(1,length(plines));
            line(X,Y,'color',[0.55 0 0.65],'hittest','off','linewidth',2);    
        end
    end
    
    for p=chstart:chend,
        k = startframe:endframe;
        color = SLICEDISPLAY.COLORLIST{SLICEDISPLAY.GROUP(p)};
        if SLICEDISPLAY.LEADINFO(p) > 0,
            color = [0 0 0];
            if SLICEDISPLAY.LEADINFO(p) > 3,
                color = [0.35 0.35 0.35];
            end
        end
        
        plot(SLICEDISPLAY.TIME(k),SLICEDISPLAY.SIGNAL(p,k),'color',color,'hittest','off');
        if (SCRIPT.DISPLAYOFFSET == 1) & (SCRIPT.DISPLAYLABEL == 1)&(chend-chstart < 30) & (SLICEDISPLAY.YWIN(2) >= numchannels-p+1),
            text(SLICEDISPLAY.XWIN(1),numchannels-p+1,SLICEDISPLAY.NAME{p},'color',color,'VerticalAlignment','top','hittest','off'); 
        end
    end
   
    if (SCRIPT.DISPLAYOFFSET == 2) & (SCRIPT.DISPLAYLABEL ==1),
        for q=1:length(SLICEDISPLAY.GROUPNAME)
            color = SLICEDISPLAY.COLORLIST{q};
            text(SLICEDISPLAY.XWIN(1),SLICEDISPLAY.YWIN(2)-(q*0.05*(SLICEDISPLAY.YWIN(2)-SLICEDISPLAY.YWIN(1))),SLICEDISPLAY.GROUPNAME{q},'color',color,'VerticalAlignment','top','hittest','off'); 
        end    
    end
    
    
    set(SLICEDISPLAY.AXES,'YTick',[],'YLim',ywin,'XLim',xwin);
    
    xlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xlen < 0.001, xslider = 0.999; else xslider = xwin(1)/xlen; end
    xredlen = (xlim(2)-xlim(1)-xwin(2)+xwin(1));
    if xredlen ~= 0, xfill = (xwin(2)-xwin(1))/xredlen; else xfill = 1000; end
    xinc = median([0.01 xfill 0.999]);
    xfill = median([0.01 xfill 1000]);
    xslider = median([0.001 xslider 0.999]);
    set(SLICEDISPLAY.XSLIDER,'value',xslider,'sliderstep',[xinc xfill]);

    ylen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if ylen < 0.001, yslider = 0.999; else yslider = ywin(1)/ylen; end
    yredlen = (ylim(2)-ylim(1)-ywin(2)+ywin(1));
    if yredlen ~= 0, yfill = (ywin(2)-ywin(1))/yredlen; else yfill =1000; end
    yinc = median([0.0002 yfill 0.999]);
    yfill = median([0.0002 yfill 1000]);
    yslider = median([0.001 yslider 0.999]);
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
    
    if isfield(TS{SCRIPT.CURRENTTS},'selframes'),
        events = SLICEDISPLAY.EVENTS{1}; events = AddEvent(events,(TS{SCRIPT.CURRENTTS}.selframes/1000)); events.selected = 0; SLICEDISPLAY.EVENTS{1} = events;
    end   
    
    if isfield(TS{SCRIPT.CURRENTTS},'templateframes'),
        events = SLICEDISPLAY.EVENTS{2}; events = AddEvent(events,(TS{SCRIPT.CURRENTTS}.templateframes/1000)); events.selected = 0; SLICEDISPLAY.EVENTS{1} = events;    
    end   
    
    if isfield(TS{SCRIPT.CURRENTTS},'averageframes'),
        events = SLICEDISPLAY.EVENTS{3}; events = AddEvent(events,(TS{SCRIPT.CURRENTTS}.averageframes/1000)); events.selected = 0; SLICEDISPLAY.EVENTS{3} = events;    
    end  
 
    set(handle,'pointer',pointer);
    
    return
   
function Zoom(handle,mode)

    global SLICEDISPLAY;

    if nargin == 2, handle = findobj(allchild(handle),'tag','DISPLAYZOOM'); end
    
    value = get(handle,'value');
    if nargin == 2, value = xor(value,1); end
    
    parent = get(handle,'parent');
    switch value
        case 0,
            set(parent,'WindowButtonDownFcn','SliceDisplay(''ButtonDown'',gcbf)',...
               'WindowButtonMotionFcn','SliceDisplay(''ButtonMotion'',gcbf)',...
               'WindowButtonUpFcn','SliceDisplay(''ButtonUp'',gcbf)','pointer','arrow');
            set(handle,'string','(Z)oom OFF','value',value);
            SLICEDISPLAY.ZOOM = 0;
        case 1,
            set(parent,'WindowButtonDownFcn','SliceDisplay(''ZoomDown'',gcbf)',...
               'WindowButtonMotionFcn','SliceDisplay(''ZoomMotion'',gcbf)',...
               'WindowButtonUpFcn','SliceDisplay(''ZoomUp'',gcbf)','pointer','crosshair');
            set(handle,'string','(Z)oom ON','value',value);
            SLICEDISPLAY.ZOOM = 1;
    end
    return
    
    
function ZoomDown(handle)

    global SLICEDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    if ~strcmp(seltype,'alt'),
        pos = get(SLICEDISPLAY.AXES,'CurrentPoint');
        P1 = pos(1,1:2); P2 = P1;
        SLICEDISPLAY.P1 = P1;
        SLICEDISPLAY.P2 = P2;
        X = [ P1(1) P2(1) P2(1) P1(1) P1(1) ]; Y = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
   	    SLICEDISPLAY.ZOOMBOX = line('parent',SLICEDISPLAY.AXES,'XData',X,'YData',Y,'Erasemode','xor','Color','k','HitTest','Off');
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
    if ishandle(SLICEDISPLAY.ZOOMBOX),
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
    if ishandle(SLICEDISPLAY.ZOOMBOX),
        point = get(SLICEDISPLAY.AXES,'CurrentPoint');
        P2(1) = median([SLICEDISPLAY.XLIM point(1,1)]); P2(2) = median([SLICEDISPLAY.YLIM point(1,2)]);
        SLICEDISPLAY.P2 = P2; P1 = SLICEDISPLAY.P1;
        if (P1(1) ~= P2(1))&(P1(2) ~= P2(2)),
            SLICEDISPLAY.XWIN = sort([P1(1) P2(1)]);
            SLICEDISPLAY.YWIN = sort([P1(2) P2(2)]);
        end
        delete(SLICEDISPLAY.ZOOMBOX);
   	    UpdateDisplay(handle);
    end
    return   

function SetBadLead(handle,lead)
    
    global SLICEDISPLAY SCRIPT TS;
    
    if (SCRIPT.DISPLAYTYPE == 3)&(SCRIPT.DISPLAYOFFSET==1),
        m = size(SLICEDISPLAY.SIGNAL,1);
        n = median([1 ceil(m-lead) m]);
        state = SLICEDISPLAY.LEADINFO(n);
        state = bitset(state,1,xor(bitget(state,1),1));
        SLICEDISPLAY.LEADINFO(n) = state;
        TS{SCRIPT.CURRENTTS}.leadinfo(SLICEDISPLAY.LEAD(n)) = state;
        UpdateDisplay(handle);
    end
    
    return
    
function  DeactivateAverage(handle,t)

    global SLICEDISPLAY SCRIPT TS;

    if isfield(TS{SCRIPT.CURRENTTS},'averagestart'),
        as = TS{SCRIPT.CURRENTTS}.averagestart/1000;  
        ae = TS{SCRIPT.CURRENTTS}.averageend/1000;  
        
        keep = [];
        for p=1:length(as),
            if (t >= as(p))&(t <= ae(p)),
            else
                keep = [keep p];
            end
        end
        TS{SCRIPT.CURRENTTS}.averagestart = TS{SCRIPT.CURRENTTS}.averagestart(keep);
        TS{SCRIPT.CURRENTTS}.averageend = TS{SCRIPT.CURRENTTS}.averageend(keep);
        SetupDisplay(handle);
        UpdateDisplay(handle);
    end
    
    return    
    
function ButtonDown(handle)
   	
    global SLICEDISPLAY;
    
    seltype = get(gcbf,'SelectionType');
    
    point = get(SLICEDISPLAY.AXES,'CurrentPoint');
    t = point(1,1); y = point(1,2);
    
    if strcmp(seltype,'extend'),
 %       SetBadLead(handle,y);
         DeactivateAverage(handle,t);
        return
    end
    
    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS}; 
    
    xwin = SLICEDISPLAY.XWIN;
    ywin = SLICEDISPLAY.YWIN;
    if (t>xwin(1))&(t<xwin(2))&(y>ywin(1))&(y<ywin(2)),
        if ~strcmp(seltype,'alt'),
      		events = FindClosestEvent(events,t);
            if events.selected > 0, 
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
	if events.selected > 0,
        point = get(SLICEDISPLAY.AXES,'CurrentPoint');
        t = median([SLICEDISPLAY.XLIM point(1,1)]);
        SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = SetClosestEvent(events,t);
    end
    return
    
function ButtonUp(handle)
   
    global SLICEDISPLAY TS SCRIPT;

    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};  
    if events.selected > 0,
 	    point = get(SLICEDISPLAY.AXES,'CurrentPoint');
	    t = median([SLICEDISPLAY.XLIM point(1,1)]);
        events = SetClosestEvent(events,t); 
        events.selected = 0;
        events = AlignEvents(events);
        
        SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
        switch  SLICEDISPLAY.SELEVENTS,
            case 1,
                TS{SCRIPT.CURRENTTS}.selframes = sort(round(events.timepos*1000)); 
            case 2,
                TS{SCRIPT.CURRENTTS}.templateframes = sort(round(events.timepos*1000));
            case 3,
                TS{SCRIPT.CURRENTTS}.averageframes = sort(round(events.timepos*1000));
        end
    end
    
    drawnow;
    return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FindClosestEvent               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 function events = FindClosestEvent(events,t)
    
   if ~isempty(events.timepos),
        tt = abs(events.timepos-t);
        events.selected = find(tt == min(tt));
        events.selected = events.selected(1);
    else
  	events.selected = 0;
    end
 return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SetClosestEvent                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = SetClosestEvent(events,t)

    if events.selected==1,
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

    global SLICEDISPLAY SCRIPT;
    if SLICEDISPLAY.SELEVENTS > 1, return; end
    
    events.timepos = sort(events.timepos);
    
    if (isnumeric(SCRIPT.ALIGNSTART) & (SCRIPT.ALIGNSTARTENABLE == 1)),
    
        if SCRIPT.ALIGNMETHOD  > 1,
            switch SCRIPT.ALIGNMETHOD,
                case 2,
                    pacing = (SLICEDISPLAY.PACING/1000);
                case 3,
                    DetectAlignmentRMS;
                    pacing = (SLICEDISPLAY.RMSPEAKS/1000);
                case 4,
                    DetectAlignmentRMStemplate(1);
                    pacing = (SLICEDISPLAY.RMSPEAKS/1000);
            end
            start = events.timepos(1)-(SCRIPT.ALIGNSTART/1000);
            pacing = pacing(find(pacing-(SCRIPT.ALIGNSTART/1000) >= SLICEDISPLAY.XLIM(1)));
            [dummy,index] = min(abs(pacing-start));
            start = pacing(index(1))+(SCRIPT.ALIGNSTART/1000);
            events.timepos(1) = median([start SLICEDISPLAY.XLIM]);
        end
    end
    
    if (isnumeric(SCRIPT.ALIGNSIZE) & (SCRIPT.ALIGNSIZEENABLE == 1)),
    
        switch SCRIPT.ALIGNMETHOD,
            case 1,
                % DO NOTHING
            otherwise,
                events.timepos(2) = median([(events.timepos(1)+(SCRIPT.ALIGNSIZE/1000)) SLICEDISPLAY.XLIM]);                
        end
    end
    
    p = events.timepos;
    set(events.box,'XData',[p(1) p(1) p(2) p(2)]);
 %   drawnow;
    return
    
    
function DetectAlignmentRMS

    global SLICEDISPLAY SCRIPT TS;
    
    if (SLICEDISPLAY.RMSTYPE ~= SCRIPT.ALIGNRMSTYPE)|(isempty(SLICEDISPLAY.RMS)),
        SLICEDISPLAY.THRESHOLD = 0;
        rmstype = SCRIPT.ALIGNRMSTYPE;
        if rmstype > length(SCRIPT.GROUPLEADS),
            ch = []; for p = 1:length(SCRIPT.GROUPLEADS), ch = [ch SCRIPT.GROUPLEADS{p}]; end
        else
            ch = SCRIPT.GROUPLEADS{rmstype};
        end
    
        SLICEDISPLAY.RMS= sqrt(mean(TS{SCRIPT.CURRENTTS}.potvals(ch,:).^2));
        SLICEDISPLAY.RMSTYPE = rmstype;
        
        m = [];
        for p = 1:floor(length(SLICEDISPLAY.RMS)/1000),
            m = [m max(SLICEDISPLAY.RMS([1:1000]+(p-1)*1000))];
        end
        if isempty(m), m = max(SLICEDISPLAY.RMS); end
        
        SLICEDISPLAY.RMSMAX = median(m);
    end
    
    if (SLICEDISPLAY.THRESHOLD ~= SCRIPT.ALIGNTHRESHOLD),
        SLICEDISPLAY.THRESHOLD = SCRIPT.ALIGNTHRESHOLD;
        SLICEDISPLAY.RMSPEAKS = DPeaks(SLICEDISPLAY.RMS,SLICEDISPLAY.THRESHOLD*SLICEDISPLAY.RMSMAX);
    end
    return
    

function DetectAlignmentRMStemplate(mode)

    global SLICEDISPLAY SCRIPT TS;
    
    if (SLICEDISPLAY.RMSTYPE ~= SCRIPT.ALIGNRMSTYPE)|(mode == 2)|(isempty(SLICEDISPLAY.RMS)),
        SLICEDISPLAY.THRESHOLD = 0;
        rmstype = SCRIPT.ALIGNRMSTYPE;
        if rmstype > length(SCRIPT.GROUPLEADS),
            ch = []; for p = 1:length(SCRIPT.GROUPLEADS), ch = [ch SCRIPT.GROUPLEADS{p}]; end
        else
            ch = SCRIPT.GROUPLEADS{rmstype};
        end
    
        SLICEDISPLAY.RMS= sqrt(mean(TS{SCRIPT.CURRENTTS}.potvals(ch,:).^2));
        SLICEDISPLAY.RMSTYPE = rmstype;
        
        if mode == 2,
            template = TS{SCRIPT.CURRENTTS}.templateframe;
            SLICEDISPLAY.TEMPLATE = SLICEDISPLAY.RMS(template(end):-1:template(1));
        end
        SLICEDISPLAY.RMS = -filter(ones(1,length(SLICEDISPLAY.TEMPLATE)),1,SLICEDISPLAY.RMS.^2) + 2*filter(SLICEDISPLAY.TEMPLATE,1,SLICEDISPLAY.RMS) - sum(SLICEDISPLAY.TEMPLATE.^2);
        SLICEDISPLAY.RMS = SLICEDISPLAY.RMS - min(SLICEDISPLAY.RMS);
        m = [];
        for p = 1:floor(length(SLICEDISPLAY.RMS)/1000),
            m = [m max(SLICEDISPLAY.RMS([1:1000]+(p-1)*1000))];
        end
        if isempty(m), m = max(SLICEDISPLAY.RMS); end
        SLICEDISPLAY.RMSMAX = median(m);
    end
    
    if (SLICEDISPLAY.THRESHOLD ~= SCRIPT.ALIGNTHRESHOLD),
        SLICEDISPLAY.THRESHOLD = SCRIPT.ALIGNTHRESHOLD;
        SLICEDISPLAY.RMSPEAKS = DPeaks(SLICEDISPLAY.RMS,SLICEDISPLAY.THRESHOLD*SLICEDISPLAY.RMSMAX);
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

function events = AddEvent(events,t)

  if length(t) == 1, t =[t t]; end

  if isempty(events.timepos)  
    ypos = events.ylim;
    events.box = patch('parent',events.axes,'XData',[t(1) t(1) t(2) t(2)],'YData',[ypos(1) ypos(2) ypos(2) ypos(1)],'EraseMode','xor','FaceColor',events.color);
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

    if events.selected == 0,
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

    global SCRIPT;
    SCRIPT.KEEPBADLEADS = get(handle,'value');
    return
    
function KeyPress(handle)

    global SCRIPT SLICEDISPLAY TS;

    key = real(get(handle,'CurrentCharacter'));
    
    if isempty(key), return; end
    if ~isnumeric(key), return; end

    switch key(1),
        case {8, 127}  % delete and backspace keys
	        
            obj = findobj(allchild(handle),'tag','DISPLAYZOOM');
            value = get(obj,'value');
            if value == 0,   
                point = get(SLICEDISPLAY.AXES,'CurrentPoint');
                xwin = SLICEDISPLAY.XWIN;
                ywin = SLICEDISPLAY.YWIN;
                t = point(1,1); y = point(1,2);
                if (t>xwin(1))&(t<xwin(2))&(y>ywin(1))&(y<ywin(2)),
                    events = SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS};
                    events = FindClosestEvent(events,t);
                    events = DeleteEvent(events);   
                    SLICEDISPLAY.EVENTS{SLICEDISPLAY.SELEVENTS} = events;
                    switch SLICEDISPLAY.SELEVENTS
                        case 1,
                            TS{SCRIPT.CURRENTTS}.selframes = []; 
                        case 2,
                            TS{SCRIPT.CURRENTTS}.templateframes = [];
                        case 3,
                            TS{SCRIPT.CURRENTTS}.averageframes = [];
                    end
                end    
            end	
        case 93,
            ywin = SLICEDISPLAY.YWIN; ylim = SLICEDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin-ysize; 
            SLICEDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);
        case 91,
            ywin = SLICEDISPLAY.YWIN; ylim = SLICEDISPLAY.YLIM;
            ysize = ywin(2)-ywin(1); ywin = ywin+ysize; 
            SLICEDISPLAY.YWIN = [median([ylim(1) ywin(1) ylim(2)-ysize]) median([ylim(1)+ysize ywin(2) ylim(2)])];
            UpdateDisplay(handle);   
        case 44,
            xwin = SLICEDISPLAY.XWIN; xlim = SLICEDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin-xsize; 
            SLICEDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);
        case 46,
            xwin = SLICEDISPLAY.XWIN; xlim = SLICEDISPLAY.XLIM;
            xsize = xwin(2)-xwin(1); xwin = xwin+xsize; 
            SLICEDISPLAY.XWIN = [median([xlim(1) xwin(1) xlim(2)-xsize]) median([xlim(1)+xsize xwin(2) xlim(2)])];
            UpdateDisplay(handle);  
        case {116,50}
            SLICEDISPLAY.SELEVENTS = 2;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',2);
        case {115,119,49}
            SLICEDISPLAY.SELEVENTS = 1;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',1);
        case {97,51}
            SLICEDISPLAY.SELEVENTS = 3;
            set(findobj(allchild(handle),'tag','EVENTSELECT'),'value',3);
        case {100}
            DetectAverage(handle);
        case {114}
            ResetAverage(handle);
        case {122}    
            Zoom(handle,1);
        otherwise
            fprintf(1,'%d',key);
    end

    return
