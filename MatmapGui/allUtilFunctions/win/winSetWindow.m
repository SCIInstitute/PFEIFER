function handle = winSetWindow(varargin)
% FUNCTION handle = winSetWindow(TSindex)
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

    if isfield(TS{TSindex},'pacingchannel'),
        window.pacing = TS{TSindex}.potvals(TS{TSindex}.pacingchannel,:);
        window.pacing = (max(window.rms)/max(window.pacing))*window.pacing;
    end
    
    window.TSindex = TSindex;
    window.events.box = [];
    window.events.selected = 0;
    window.events.axes = window.axes;
    window.events.timepos = [];
    window.events.ylim = window.ylim;
    window.yrange = [min(window.rms) max(window.rms)];

    
    if isfield(TS{TSindex},'timeframe'),
        window.events.timepos = TS{TSindex}.timeframe;
        pos = window.events.timepos;
        ypos = window.ylim;
        window.events.box = patch('parent',window.axes,'XData',[pos(1) ...
	       pos(1) pos(2) pos(2)],'YData',[ypos(1) ypos(2) ypos(2) ypos(1)],'EraseMode','xor','FaceColor','b');
    end   
    
    set(handle,'UserData',window); % Set these things in the userdata
    set(handle,'name',sprintf('winSetWindow:%s',TS{TSindex}.filename));
    Update(handle);

return

function Abort(handle)
    global SCRIPT
    SCRIPT.ABORT = 1;
    
    delete(handle);
    return

function handle = Init(TSindex)      
    
    global TS;        
        
    % Initiate window

    windowname = 'Set Fiducials';    
    position = [0.100 0.100 0.600 0.500]; 
    handle = guiFigure(windowname,position,windowname);

    [X,Y] = guiMakeGrid(handle,[],6);

    % Create the buttons and stuff

    window.zoombutton = guiCreateButton(handle,'Zoom OFF','winSetWindow(''ZoomOnOff'',gcf)',[X(1) Y(end-2) X(2) Y(end-1)]);
    window.applybutton = guiCreateButton(handle,'Apply','winSetWindow(''Apply'',gcf)',[X(6) Y(end-2) X(7) Y(end-1)]);
    window.skipbutton = guiCreateButton(handle,'Skip','winSetWindow(''Skip'',gcf)',[X(5) Y(end-2) X(6) Y(end-1)]);
    window.fullzoomout = guiCreateButton(handle,'Zoom out','winSetWindow(''FullZoomOut'',gcf)',[X(2) Y(end-2) X(3) Y(end-1)]);
    window.abort = guiCreateButton(handle,'ABORT','winSetWindow(''Abort'',gcf)',[X(4) Y(end-2) X(5) Y(end-1)]);
    
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
    
    window.events.box = [];
    window.events.selected = 0;
    window.events.axes = window.axes;
    window.events.ylim = window.ylim;
    window.events.timepos = [];
    
    set(handle,'UserData',window); % Set these things in the userdata
    % so when the window is destroyed so is its data

    set(handle,'KeyPressFcn','winSetWindow(''KeyPressed'',gcf);', ...
	   	'WindowButtonUpFcn','winSetWindow(''ButtonUp'',gcf);', ...
   		'WindowButtonDownFcn','winSetWindow(''ButtonDown'',gcf);', ...
                'WindowButtonMotionFcn','winSetWindow(''ButtonMotion'',gcf);');

    SetTimeSeries(handle,TSindex);

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

function Apply(handle)

    global TS;
    window = get(handle,'UserData');
    TSindex = window.TSindex;
    frames = sort(round(window.events.timepos));
    TS{TSindex}.timeframe = frames;
    if isempty(frames),
        errordlg('ERROR','YOU SHOULD SPECIFY A WINDOW!!');
        return;
    end
    delete(handle);
        
return

function Skip(handle)

    global TS;
    window = get(handle,'UserData');
    TSindex = window.TSindex;
    TS{TSindex}.timeframe = [];
    delete(handle);
        
return

function FullZoomOut(handle)

    window = get(handle,'UserData');
    window.xlim(1) = window.time(1);
    window.ylim(1) = window.yrange(1);
    window.xlim(2) = window.time(end);
    window.ylim(2) = window.yrange(end);
       
    set(handle,'UserData',window);
    
    Update(handle);
    
    return

        
function Update(handle)
    
    window = get(handle,'UserData');
    axes(window.axes);
    
    if isfield(window,'pacing'), 
        plot(window.pacing,'color',[0.7 0.7 0.7]);
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
    set(window.axes,'xlim',window.xlim,'ylim',window.ylim,'ytick',[]);
    window.events.box = [];
    window.events.selected = 0;
    window.events.ylim=window.ylim;
    window.events.axes=window.axes;
    
    if length(window.events.timepos)==2
      pos = window.events.timepos;
      ypos = window.ylim;
      window.events.box = patch('parent',window.axes,'XData',[pos(1) ...
	    pos(1) pos(2) pos(2)],'YData',[ypos(1) ypos(2) ypos(2) ypos(1)],'EraseMode','xor','FaceColor','b');
    end
   
    set(handle,'UserData',window);
   
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
      drawnow;
    end
    if events.selected==2
      pos = events.timepos;
      set(events.box,'XData',[pos(1) pos(1) t t]);
      events.timepos(2) = t;
      drawnow;
    end
    
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  AddEvent                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function events = AddEvent(events,t)
   
  if isempty(events.timepos)  
    ypos = events.ylim;
    events.box = patch('parent',events.axes,'XData',[t t t ...
	  t],'YData',[ypos(1) ypos(2) ypos(2) ypos(1)],'EraseMode','xor','FaceColor','b');
    events.timepos = [t t]; 
    drawnow;
  else
    set(events.box,'XData',[t t t t]);
    events.timepos = [t t];
    drawnow;
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
        t = point(1,1); y = point(1,2);
        if (t>window.xlim(1))&(t<window.xlim(2))&(y>window.ylim(1))&(y<window.ylim(2)),
            events = window.events;
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
            window.events = events;
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
       events = window.events;  
	   if events.selected > 0,
 	       point = get(window.axes,'CurrentPoint');
	       t = median([window.xlim(1),point(1,1),window.xlim(2)]);
  	       events = SetClosestEvent(events,t);   	
	       events.selected = 0;
	       window.events = events;  
	       set(handle,'UserData',window);
           global TS;
           TS{window.TSindex}.timeframe = sort(round(window.events.timepos)); 
	   end
	  
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
        events = window.events;  
	if events.selected > 0,
            point = get(window.axes,'CurrentPoint');
            t = median([window.xlim(1),point(1,1),window.xlim(2)]);
            events = SetClosestEvent(events,t);
            window.events = events;  
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

    if ~isnumeric(key), return; end

    switch key
    case {8, 127}  % delete and backspace keys
	if window.zoom == 0,   
            point = get(window.axes,'CurrentPoint');
            t = point(1,1); y = point(1,2);
            if (t>window.xlim(1))&(t<window.xlim(2))&(y>window.ylim(1))&(y<window.ylim(2)),
                events = window.events;
                events = FindClosestEvent(events,t);
                events = DeleteEvent(events);   
                window.events = events;
                set(handle,'UserData',window);
            end    
        end	
      case {122}
	ZoomOnOff(handle);
    otherwise
      fprintf(1,'%d',key)
    end

return

        
        
        
