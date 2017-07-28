function varargout = DispSignal(varargin)

    if nargin == 0,
        Init;
    end

    if ischar(varargin{1}),
        feval(varargin{:});
    end
    
    if (isstruct(varargin{1}))|(isnumeric(varargin{1})),
        Init(varargin{:});
    end
    return

function handle = Init(varargin)

    handle = winDispSignal;
    tsdata = varargin{1};
    if nargin > 1, windata = varargin{2:end}; else windata = {}; end
    
    InitMD(handle,windata{:});
    UpdateTSMD(handle,tsdata);
    
    
    
function InitMD(handle,varargin)

    % SETUP THE MATRIX DISPLAY AXES

    defaultoptions = {  'mode','rms','modeoptions',{'rms','grouprms','all'}, ...
                        'scale','local','scaleoptions',{'local','global'}, ...
                        'axis','off','axisoptions',{'on','off'}, ...
                        'timewin','auto','chanwin','auto','maxchan',10 ...
                        'rowmode','offset','offset',0.5
                      };                
    
    md = [];
    ts = [];
    sg = [];
    md.axes = findobj(allchild(handle,'tag','MATRIXDISPLAY'));
    md.xslider = findobj(allchild(handle,'tag','MDXSLIDER'));
    md.yslider = findobj(allchild(handle,'tag','MDYSLIDER'));
    cbstring = sprintf('%s(''UpdateMDSlider'',gcbf)',mfilename);
    set(md.xslider,'callback',cbstring);
    set(md.yslider,'callback',cbstring);
    
    for p=1:2:length(defaultoptions), md = setfield(md,defaultoptions{p},defaultoptions{p+1}); end
    if nargin > 2, for p=2:2:nargin, md = setfield(md,varargin{p},varargin{p+1}); end, end
    
    setappdata(handle,'md',md);
    setappdata(handle,'ts',ts);
    setappdata(handle,'sg',sg);
    
    UpdateMDWindow(handle,'load');
    
    return
    
function UpdateMDWindow(handle,option)

    % SETUP THE MD STRUCTURE FROM A PREVIOUS WINDOW
    
    persistent MD;
    copyfields = {'mode','scale','axis','timewin','chanwin'};
    
    md = getappdata(handle,'md');
    switch option,
        case 'load',
            for p=1:length(copyfields),
                if isfield(MD,copyfields{p}),
                    md = setfield(md,copyfields{p},getfield(MD,copyfields{p}));
                end
            end
        case 'save',
            for p=1:length(copyfields),
                if isfield(md,copyfields{p}),
                    MD = setfield(MD,copyfields{p},getfield(md,copyfields{p}));
                end
            end
    end
    
    setappdata(handle,'md',md);
    return
    
function UploadTSMD(handle,data)

    md = getappdata(handle,'md');
    
    ts.potvals = [];
    ts.leadinfo = [];
    ts.group = {};
    ts.groupname = {};
    
    if isnumeric(data),
        global TS;
        TSindex = data(1);
        if length(TS) < TSindex,
            error('Invalid TSindex number');
        end
        ts.potvals = TS{TSindex}.data;
        if isfield(TS{TSindex},'group'),
            ts.group = TS{TSindex}.group;
        end
        if isfield(TS{TSindex},'groupname'),
            ts.groupname = TS{TSindex}.groupname;
        end
        if isfield(TS{TSindex},'leadinfo'),
            ts.leadinfo = TS{TSindex}.leadinfo;
        end
        
    elseif isstruct(data),
        if isfield(data,'potvals'),
            ts.potvals = data.potvals;
        else
            error('Time series needs to contain a field field potvals');
        end
        if isfield(data,'group'),
            ts.group = data.group;
        end
        if isfield(data,'groupname'),
            ts.groupname = data.groupname;
        end
        if isfield(data,'leadinfo'),
            ts.leadinfo = data.leadinfo;
        end
    else
        error('Timeseries needs to be a struct or an index into the TS array');
    end
    
    if ~isempty(ts.group) & isempty(ts.groupname),
        for p=1:length(ts.group), ts.groupname{p} = sprintf('Group %d',p); end
    end
    
    if length(ts.group) ~= length(ts.groupname),
        error('Group and groupname need to have the same number of entries');
    end
    
    md.modeoptions = {'rms','grouprms','all'};
    md.modeoptions((end+1):(end+length(ts.groupname))) = ts.groupname;
    
    setappdata(handle,'ts',ts);
    setappdata(handle,'md',md);
    UpdateSignalMD(handle);
    
    return
    
function UpdateSignalMD(handle)

    sg = [];
    md = getappdata(handle,'md');
    ts = getappdata(handle,'ts');
    
    switch md.mode,
    case 'rms',
        sg.signal = sqrt(sum(ts.potvals.^2));
        sg.name = {'rms'};
    case 'grouprms',
        for p=1:length(ts.group), 
            sg.signal(p,:) = sqrt(sum(ts.potval(ts.group{p},:).^2)); 
            sg.name{p} = ['rms_' ts.groupname{p}];    
        end
    case 'all',
        sg.signal = ts.potvals;
        for p=1:size(sg.signal,1), sg.name{p} = sprintf('channel_%d',p); end
    case ts.groupname,
        q = strmatch(md.mode,ts.groupname);
        sg.signal = ts.potvals(ts.group{q},:);
        for p=1:size(sg.signal,1), sg.name{p} = sprintf('%s_%d',ts.groupname{q},p); end
    otherwise
        error('unknown mode option');
    end
    
    sg.time = 0.001*[1:size(sg.signal,2)];
    sg.timelim = sg.time([1 end]);
    sg.sigchan = size(sg.signal,1);
    
    switch md.scale,
    case 'local',
        sigmax = max(sg.signal,[],2);
        sigmin = min(sg.signal,[],2);     
        scale = 1./(sigmax-sigmin);
        S = spdiags(scale',0,sg.sigchan,sg.sigchan);
        sg.signal = S*sg.signal;    
    case 'global'
        sigmax = max(sg.signal,[],2);
        sigmin = min(sg.signal,[],2);
        h = max(sigmax-sigmin);
        scale = (1/h)*ones(1,sg.sigchan);
        S = spdiags(scale',0,sg.sigchan,sg.sigchan);
        sg.signal = S*sg.signal;     
    otherwise
        error('unknown scaling options');
    end
        
    switch md.rowmode,
    case 'offset',
        baseline = [0.5:md.offset:sg.sigchan*md.offset]'; 
        sg.signal = sg.signal + repmat(baseline(1:e(nd-1)),1,size(sg.signal,2));
    case 'nooffset',
        % do nothing
    otherwise
        error('unknown row offset mode');
    end
    sg.sigmax = max(sg.signal,[],2);
    sg.sigmin = min(sg.signal,[],2);
    sg.sigmean = mean(sg.signal,2);
    sg.chanlim = [min(sg.sigmin) max(sg.sigmax)];
 
    setappdata(handle,'sg',sg);
    
    return
    
function UpdateMD(handle) 

    md = getappdata(handle,'md');
    sg = getappdata(handle,'sg');
    
    % FILTER WINDOW SETTINGS
    if ischar(md.timewin), md.timewin = sg.timelim; end
    if ischar(md.chanwin), md.chanwin = [0 md.maxchan]; end
    md.timewin(1) = median([md.timewin(1) sg.timelim]);
    md.timewin(2) = median([md.timewin(2) sg.timelim]);
    md.chanwin(1) = median([md.chanwin(1) sg.chanlim]);
    md.chanwin(2) = median([md.chanwin(2) sg.chanlim]);
    
    startframe = median([floor(md.timewin(1)*1000) 1 size(sg.signal,2)]);
    endframe = median([ceil(md.timewin(2)*1000) 1 size(sg.signal,2)]);
    channels = find((sg.min < md.chanwin(2)) &(sg.max > md.chanwin(1)));
    
    axes(md.axis);
    cla;
    for p=channels,
        plot(sg.time(startframe:endframe),sg.signal(p,startframe:endframe));
    end
    
        


    return
    
function SetMatrixDisplay(handle,varargin)

    return
    

    
 