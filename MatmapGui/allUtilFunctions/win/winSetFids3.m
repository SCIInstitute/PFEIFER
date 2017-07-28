function handle = winSetFids3(varargin)
% FUNCTION handle = winSetFids3(TSindex)
%
% DESCRIPTION
% The function pops up a window, makes an rms of the signal and lets you change the fiducial values
% using the mouse. 
%
% INPUT
% TSindex      The index of the Timeseries on the TS heap
%
% OUTPUT
% -
%
% SEE ALSO -

    if ischar(varargin{1}),
        feval(varargin{:});
    elseif isnumeric(varargin{1}),  
        handle = Init(varargin{1}); 
    end
        
return


function NextTS(handle)

    global TS
    window = get(handle,'UserData');

    TSindex = window.TSindex;
    TSindex = min([TSindex+1 length(TS)]);
    while (isempty(TS{TSindex}))&(TSindex ~= length(TS)),      
        TSindex = min([TSindex+1 length(TS)]); 
    end
    
    number = 2;
    window.events.newtypecolor = window.fidcolors{number+1};
    window.events.newtypenumber = number;
    set(window.fidtypebutton,'value',number+1);
    
    set(handle,'UserData',window);
    
    if ~isempty(TSindex),
        SetTimeSeries(handle,TSindex);
    end
return

function PrevTS(handle)

    global TS
    window = get(handle,'UserData');

    TSindex = window.TSindex;
    TSindex = max([TSindex-1 1]);
    while (isempty(TS{TSindex}))&(TSindex ~= 1),      
        TSindex = max([TSindex-1 1]); 
    end
    
    number = 2;
    window.events.newtypecolor = window.fidcolors{number+1};
    window.events.newtypenumber = number;
    set(window.fidtypebutton,'value',number+1);
    
    set(handle,'UserData',window);
    
    if ~isempty(TSindex),
        SetTimeSeries(handle,TSindex);
    end

return


function SetTimeSeries(handle,TSindex)
    
    global TS
    window = get(handle,'UserData');

    if isfield(TS{TSindex},'rmsindex'),
        if isnumeric(TS{TSindex}.rmsindex),
            ind = TS{TSindex}.rmsindex;
            ind = ind(find(TS{TSindex}.leadinfo(ind) == 0));
            window.rms = sqrt(mean((TS{TSindex}.potvals(ind,:)).^2));
        end
        if iscell(TS{TSindex}.rmsindex),
            ind = TS{TSindex}.rmsindex{1};
            ind = ind(find(TS{TSindex}.leadinfo(ind) == 0));
            window.rms = sqrt(mean((TS{TSindex}.potvals(ind,:)).^2));
            for p = 2:length(TS{TSindex}.rmsindex),
                ind2 = TS{TSindex}.rmsindex{p};
                ind2 = ind2(find(TS{TSindex}.leadinfo(ind2) == 0));
                window.rms2{p-1} = sqrt(mean((TS{TSindex}.potvals(ind2,:)).^2));
                window.rms2{p-1} = (max(window.rms)/max(window.rms2{p-1}))*window.rms2{p-1};
            end
        end
    else
       ind = find(TS{TSindex}.leadinfo == 0);
       window.rms = sqrt(mean((TS{TSindex}.potvals(ind,:)).^2));
    end    
   
    window.time = [0:(size(TS{TSindex}.potvals,2)-1)];
    window.ylim = [min(window.rms) max(window.rms)];
    window.xlim = [min(window.time) max(window.time)];

    window.TSindex = TSindex;
    window.events.Lines = [];
    window.events.Patches = [];
    window.events.Selected = 0;
    window.events.Color = {};
    window.events.Axes = window.axes;
    window.events.Index = [];
    window.events.Events = [];
    window.events.TSindex = TSindex;
    window.yrange = [min(window.rms) max(window.rms)];
    window.events.newfidset = 0;
    
    if isfield(TS{TSindex},'pacingchannel'),
        window.pacing = TS{TSindex}.potvals(TS{TSindex}.pacingchannel,:);
        window.pacing = (max(window.rms)/max(window.pacing))*window.pacing;
    end
  
    global TS;
    if ~isfield(TS{TSindex},'fids'),
        TS{TSindex}.fids = [];
    end  
    
    if ~isfield(TS{TSindex},'fidset'),
        TS{TSindex}.fidset = {};
    end
    
    if isfield(TS{TSindex},'baselinewidth'),
        window.events.bl = [0 TS{TSindex}.baselinewidth-1];
    else
        window.events.bl = [0 0];
    end
    
    k = 1;
    for p = 1:length(TS{TSindex}.fids),
        if length(TS{TSindex}.fids(p).value)  == 1,
            window.events.Events(k) = TS{TSindex}.fids(p).value; 
            window.events.Fidnum(k) = p;
            window.events.Color{k} = window.fidcolors{TS{TSindex}.fids(p).type+1};
            window.events.Type(k) = TS{TSindex}.fids(p).type;
            k = k + 1;
        end
    end
    
    set(handle,'UserData',window); % Set these things in the userdata
    set(handle,'name',sprintf('winSetFids3:%s',TS{TSindex}.filename));
    Update(handle);

return


function handle = Init(TSindex)      
    
    global TS;        
        
    % Initiate window

    windowname = 'Set Fiducials';    
    position = [0.100 0.100 0.600 0.500]; 
    handle = guiFigure(windowname,position,windowname);

    [X,Y] = guiMakeGrid(handle,[],6);

    % Create the buttons and stuff

    window.zoombutton = guiCreateButton(handle,'Zoom OFF','winSetFids3(''ZoomOnOff'',gcf)',[X(1) Y(end-2) X(2) Y(end-1)]);
   % window.savebutton = guiCreateButton(handle,'Save','winSetFids(''Save'',gcf)',[X(6) Y(end-2) X(7) Y(end-1)]);
   % window.saveallbutton = guiCreateButton(handle,'Save All','winSetFids(''SaveAll'',gcf)',[X(6) Y(end-1) X(7) Y(end)]);
    windw.apply = guiCreateButton(handle,'Apply','winSetFids3(''Apply'',gcf)',[X(6) Y(end-2) X(7) Y(end-1)]); 
          
    window.fidtypes = {'pon','poff','qrson','qrspeak','qrsend','ton','tpeak','toff','actplus','actmin','act','recplus','recmin','rec','ref','jpt','baseline'};
    window.fidcolors = {[1 0 0],[0.7 0 0],[0 1 0],[0.5 1 0.5],[0 0.7 0],[0 0 1],[0.5 0.5 1],[0 0 0.7],[0.6 0.6 0.6],[0.5 0.5 0.5],[1 1 0],[0.6 0.6 0.6],[0.5 0.5 0.5],[0 1 1],[0 0 0],[0.3 0.7 0.3],[1 0 1]};
    window.fidcolors{31} = [0.6 0 0.8];
    window.fidtypebutton = guiCreatePopupMenu(handle,window.fidtypes,'winSetFids3(''SetFidType'',gcf)',[X(2) Y(end-2) X(3) Y(end-1)],3);
    
   % window.nextTS = guiCreateButton(handle,'Next TS','winSetFids(''NextTS'',gcf)',[X(2) Y(end-1) X(3) Y(end)]);
   % window.prevTS = guiCreateButton(handle,'Prev TS','winSetFids(''PrevTS'',gcf)',[X(1) Y(end-1) X(2) Y(end)]);
     
    window.rms = [0]; 
    window.time = [0]; 
    window.ylim = [0 1];
    window.xlim = [0 1];
    window.yrange = [0 1];
    
    window.axes = axes('units','pixels','position',guiTranslatePosition([X(1) Y(1) X(end) Y(end-3)],1),'xlim',window.xlim,'ylim',window.ylim);
    window.TSindex = TSindex;
    window.zoom = 0;
    window.zoomp1 = [];
    window.zoomp2 = [];
    window.zoombox = [];
    
    window.events.bl = [0 0];
    window.events.Lines = [];
    window.events.Patches = [];
    window.events.Selected = 0;
    window.events.Color = {};
    window.events.Axes = window.axes;
    window.events.Index = [];
    window.events.Events = [];
    window.events.Type = [];
    window.events.TSindex = TSindex;
    
    window.events.newtypecolor = window.fidcolors{3};
    window.events.newtypenumber = 2;
    
    set(handle,'UserData',window); % Set these things in the userdata
    % so when the window is destroyed so is its data

    set(handle,'KeyPressFcn','winSetFids3(''KeyPressed'',gcf);', ...
	   	'WindowButtonUpFcn','winSetFids3(''ButtonUp'',gcf);', ...
   		'WindowButtonDownFcn','winSetFids3(''ButtonDown'',gcf);', ...
                'WindowButtonMotionFcn','winSetFids3(''ButtonMotion'',gcf);');

    SetTimeSeries(handle,TSindex);

return

function Apply(handle)

    delete(handle);
    
    return

function ZoomOnOff(handle)

    window = get(handle,'UserData');

    window.zoom = xor(window.zoom,1);
    if window.zoom == 1,
        set(window.zoombutton,'string','Zoom ON');
    else    
        set(window.zoombutton,'string','Zoom OFF');
    end
    set(handle,'UserData',window);
    
return

function Save(handle)

    global TS
    window = get(handle,'UserData');
    TSindex = window.TSindex;
    if ~isfield(TS{TSindex},'tsdfcfilename'),
        errordlf('No TSDFC-filename specified','Error message');
    else
        options.tsdfconly = 1;
        ioWriteTS(TSindex,options);
    end        
        
return

        
function SetFidType(handle)        

    window = get(handle,'UserData');
    number = get(window.fidtypebutton,'value')-1;
    window.events.newtypecolor = window.fidcolors{number+1};
    window.events.newtypenumber = number;
    set(handle,'UserData',window);
    
return        
        
function Update(handle)
    
    window = get(handle,'UserData');
    axes(window.axes);
    if isfield(window,'pacing'), 
        plot(window.pacing,'color',[0.5 0.5 0.5]);
        hold on;
    end
    if isfield(window,'rms2'),
        colors = {[1 0.5 0.5],[1 0.75 0.75],[0.5 1 0.5],[0.75 1 0.75]};
        for p =1:length(window.rms2),
            plot(window.rms2{p},'color',colors{p});
            hold on;
        end
    end
    plot(window.time,window.rms);
    set(window.axes,'xlim',window.xlim,'ylim',window.ylim);
    window.events.Lines = [];
    window.events.Index = find((window.events.Events < window.xlim(2))&(window.events.Events > window.xlim(1)));
    
    
    for p = 1:length(window.events.Index),
        Pos = window.events.Events(window.events.Index(p));
        window.events.Lines(p) = line('parent',window.axes,'XData',[Pos Pos],'YData',window.ylim,'EraseMode','xor','Color',window.events.Color{window.events.Index(p)});
        window.events.Patches(p) = 0;     
        
        if window.events.Type(p) == 16,
            bl = window.events.bl;
            window.events.Patches(p) = patch('parent',window.axes,'XData',...
                [Pos+bl(1) Pos+bl(1) Pos+bl(2) Pos+bl(2)],...
                'YData',[window.ylim window.ylim([2 1])],'EraseMode','xor','FaceColor','r');
        end
    end
    
    set(handle,'UserData',window);
   
return
    
function events = AutoJump(events,window)

    if events.newtypenumber < 7,
         number = events.newtypenumber+1;
         events.newtypecolor = window.fidcolors{number+1};
         events.newtypenumber = number;
         set(window.fidtypebutton,'value',number+1);
    end     

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  TimeInstant Fcns               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  FindClosestEvent               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Events = FindClosestEvent(Events,T)
    
   if ~isempty(Events.Index),
        TT = abs(Events.Events(Events.Index)-T);
        Events.Selected = find(TT == min(TT));
        Events.Selected = Events.Selected(1);
    else
  	Events.Selected = 0;
    end
return

function T = AdjustEvent(Events,handle,T)

    global TS;
    fidtype = TS{Events.TSindex}.fids(Events.Fidnum(Events.Selected)).type;
    
    if (fidtype == 3) | (fidtype == 6),
        window = get(handle,'UserData');
        range = round(T+1) + [-10:10];
        [dummy,r] = max(window.rms(range));
        T = range(r) - 1;
    end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  SetClosestEvent                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Events = SetClosestEvent(Events,T)

    Events.Events(Events.Index(Events.Selected)) = T;
    set(Events.Lines(Events.Selected),'XData',[T T]);
    if Events.Type(Events.Index(Events.Selected)) == 16,
        bl = Events.bl;
        if ishandle(Events.Patches(Events.Selected)),
            set(Events.Patches(Events.Selected),'XData',[T+bl(1) T+bl(1) T+bl(2) T+bl(2)]);  
        end
    end
    drawnow;
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddEvent                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Events = AddEvent(Events,T)

    NewIndex = length(Events.Lines) + 1;
    NewEvent = length(Events.Events) + 1;

    Events.Selected = NewIndex;
    Events.Index(NewIndex) = NewEvent;
    Events.Events(NewEvent) = T;   
    Events.Color{NewEvent} = Events.newtypecolor;
    Events.Type(NewEvent) = Events.newtypenumber;
    global TS
    TS{Events.TSindex}.fids(end+1).value = T;
    TS{Events.TSindex}.fids(end).type = Events.newtypenumber;
    if Events.newfidset == 0,
        TS{Events.TSindex}.fidset{end+1}.label = 'MATLAB generated fiducials';
        TS{Events.TSindex}.fidset{end+1}.audit = '';
        Events.newfidset = length(TS{Events.TSindex}.fidset);
    end
    TS{Events.TSindex}.fids(end).fidset = Events.newfidset;
    Events.Fidnum(NewEvent) = length(TS{Events.TSindex}.fids);

    Axes = Events.Axes; YRange = get(Axes,'YLim');
    
    Events.Lines(NewIndex) = line('parent',Axes,'XData',[T T],'YData',YRange,'EraseMode','xor','Color',Events.Color{NewIndex},'HitTest','Off');
    Events.Patches(NewIndex) = 0;
    
    if Events.Type(NewIndex) == 16,
        bl = Events.bl;
        Events.Patches(NewIndex) = patch('parent',Axes,'XData',[T+bl(1) T+bl(1) T+bl(2) T+bl(2)],...
                'YData',[YRange YRange([2 1])],'EraseMode','xor','FaceColor','r');
    end
    drawnow;
    
return   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  DeleteEvent                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Events = DeleteEvent(Events)

    if Events.Selected == 0,
        return
    end    

    DelEvent = Events.Index(Events.Selected);
    delete(Events.Lines(Events.Selected));
    if Events.Type(DelEvent) == 16,
        if ishandle(Events.Patches(Events.Selected)),
            delete(Events.Patches(Events.Selected));
        end
    end
        
    Events.Lines(Events.Selected) = 0;
   
    H = ones(size(Events.Index)); H(Events.Selected) = 0; H = find(H);
    Events.Index = Events.Index(H);
    Events.Lines = Events.Lines(H);
    Events.Patches = Events.Patches(H);
      
    H = ones(size(Events.Events)); H(DelEvent) = 0; H = find(H);
    T = zeros(size(Events.Events)); T(H) = 1:size(H,2);
    Events.Index = T(Events.Index);
    Events.Events = Events.Events(H);
    Events.Type = Events.Type(H);
    Events.Color = Events.Color(H);
    
    global TS
    TS{Events.TSindex}.fids(Events.Fidnum(Events.Selected)) = [];
    I = find(Events.Fidnum > Events.Selected);
    Events.Fidnum(I) = Events.Fidnum(I) -1;
    Events.Fidnum = Events.Fidnum(H);

    Events.Selected = 0;
    drawnow;
return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Mousecallbackfunctions         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonDown(handle)

    window = get(handle,'UserData');
    seltype = get(handle,'SelectionType');

    if window.zoom == 1,
        if ~strcmp(seltype,'alt'),
            % zoom in
            p = get(window.axes,'CurrentPoint');
            window.xlim = get(window.axes,'XLim');
            window.ylim = get(window.axes,'YLim');
            window.zoomp1 = [p(1,1) ; p(1,2)];
            window.zoomp2 = [p(1,1) ; p(1,2)];
            p1 = window.zoomp1; p2 = window.zoomp2;
            xdata = [ p1(1) p2(1) p2(1) p1(1) p1(1) ];
            ydata = [ p1(2) p1(2) p2(2) p2(2) p1(2) ];
            window.zoombox = line('parent',window.axes,'XData',xdata,'YData',ydata,'Erasemode','xor','Color','k','HitTest','Off');
            drawnow;
            set(handle,'UserData',window);
        else
            % zoom out;
            window.xlim = get(window.axes,'XLim');
            window.ylim = get(window.axes,'YLim');
      
            xsize = max([2*(window.xlim(2)-window.xlim(1)), 1]);
            window.xlim = [ window.xlim(1)-xsize/4 window.xlim(2)+xsize/4];
            window.xlim(1) = median([window.time(1) window.xlim(1) window.time(end)]);
            window.xlim(2) = median([window.time(1) window.xlim(2) window.time(end)]);
            
            ysize = max([2*(window.ylim(2)-window.ylim(1)), 1]);
            window.ylim = [ window.ylim(1)-ysize/4 window.ylim(2)+ysize/4];
            window.ylim(1) = median([window.yrange(1) window.ylim(1) window.yrange(end)]);
            window.ylim(2) = median([window.yrange(1) window.ylim(2) window.yrange(end)]);

            set(handle,'UserData',window);
            Update(handle);
        end
    else
   	% Do the event handling
   	point = get(window.axes,'CurrentPoint');
        T = point(1,1); Y = point(1,2);
   	
        if (T>window.xlim(1))&(T<window.xlim(2))&(Y>window.ylim(1))&(Y<window.ylim(2)),
            Events = window.events;
            if ~strcmp(seltype,'alt'),
   		        Events = FindClosestEvent(Events,T);
                if Events.Selected > 0, 
                    Events = SetClosestEvent(Events,T);
      		    else
                    Events = AddEvent(Events,T);
                    Events = AutoJump(Events,window);
	      	    end
            else
         	    Events = AddEvent(Events,T);
                Events = AutoJump(Events,window);
            end
            window.events = Events;
	end
  	set(handle,'UserData',window);
   end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonUp(handle)

    window = get(handle,'UserData');

    if window.zoom == 1,
        if ishandle(window.zoombox),
      
            point = get(window.axes,'CurrentPoint');
            T = median([window.xlim(1),point(1,1),window.xlim(2)]);
            Y = median([window.ylim(1),point(1,2),window.ylim(2)]);
            window.zoomp2 = [T Y];
      
            if (window.zoomp1(1) ~= window.zoomp2(1))&(window.zoomp1(2) ~= window.zoomp2(2)),
                window.xlim = sort([window.zoomp1(1) window.zoomp2(1)]);
                window.ylim = sort([window.zoomp1(2) window.zoomp2(2)]);
            end
            delete(window.zoombox);
            window.zoombox =[];
            set(handle,'UserData',window);      
            Update(handle);
        end
    else
        Events = window.events;  
   	    if Events.Selected > 0,
            point = get(window.axes,'CurrentPoint');
            T = median([window.xlim(1),point(1,1),window.xlim(2)]);
            T = AdjustEvent(Events,handle,T);
            Events = SetClosestEvent(Events,T);   	
            global TS
            TS{Events.TSindex}.fids(Events.Fidnum(Events.Selected)).value = T;
   	    end
   	    Events.Selected = 0;
   	    window.events = Events;  
   	    set(handle,'UserData',window);
    end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function ButtonMotion(handle)
    
    window = get(handle,'UserData');

    if window.zoom == 1,
        if ishandle(window.zoombox),
	    point = get(window.axes,'CurrentPoint');
            T = median([window.xlim(1),point(1,1),window.xlim(2)]);
            Y = median([window.ylim(1),point(1,2),window.ylim(2)]);
            window.zoomp2 = [T Y];
            P1 = window.zoomp1; P2 = window.zoomp2;
            XData = [ P1(1) P2(1) P2(1) P1(1) P1(1) ];
            YData = [ P1(2) P1(2) P2(2) P2(2) P1(2) ];
            set(window.zoombox,'XData',XData,'YData',YData);
            drawnow;
        end
    else
	% handle time instant lines   
        Events = window.events;  
	if Events.Selected > 0,
            point = get(window.axes,'CurrentPoint');
            T = median([window.xlim(1),point(1,1),window.xlim(2)]);
            Events = SetClosestEvent(Events,T);
            window.events = Events;  
        end
    end
    set(handle,'UserData',window);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function KeyPressed(handle)

    window = get(handle,'UserData');
    key = real(get(handle,'CurrentCharacter'));

    if isempty(key), return; end
    if ~isnumeric(key), return; end;

    switch key
    case {8, 127}  % delete and backspace keys
	if window.zoom == 0,   
            point = get(window.axes,'CurrentPoint');
            T = point(1,1); Y = point(1,2);
            if (T>window.xlim(1))&(T<window.xlim(2))&(Y>window.ylim(1))&(Y<window.ylim(2)),
                Events = window.events;
                Events = FindClosestEvent(Events,T);
                Events = DeleteEvent(Events);   
                window.events = Events;
                set(handle,'UserData',window);
            end    
        end	
    case {13, 3},   % enter and return keys
   
        % case 28
        % PrevTS(handle);
        % case 29
        % NextTS(handle);
        % case 122
   
        ZoomOnOff(handle);
    otherwise
%      fprintf(1,'%d',key)
    end

return

        
        
        