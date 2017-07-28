function varargout = winDataBrowser(varargin)

% function [handle] = winDataBrowser
%
% if no arguements are passed the window is initiated
% This GUI window allows the user to load data into memory and to select the data series
%
% JG Stinstra 2002

% There are two ways of launching the window
% 1) just do not pass any argument
% 2) just pass the string 'Init'
% As the first string refers the function to call it calls the startup function anyway
%
% Function names are assigned with a starting capital to avoid any resemblence to an internal matlab function


% the following structure is also used by matlab code to function as a portal to internal functions
% the first parameter just describes the function which has to be called
% Since it is an elegant solution it has been copied here.

if nargin == 0,
    fig = Init; % do the initiation
    if nargout > 0,
        varnargout{1} = fig;
    end
elseif ischar(varargin{1})
    feval(varargin{:}); % main entry point to the functionality of the GUI
end
return    


% The Init function looks whether a copy of the window is already open, if so deletes it
% There is no use for two of these windows
% It establishes an unique name for the window. Next it generates a virtual grid mapped onto the
% window and allocates button and listboxes to the virtual ancor points of the grid

function handle = Init % no arguements

global Program

WindowName =[Program.Name ':DataBrowser'];

% delete any existing figure
oldhandle = findobj(allchild(0),'tag',WindowName);
if ishandle(oldhandle), delete(oldhandle); end

Position = [0.100 0.100 0.600 0.500]; 

handle = guiFigure(WindowName,Position,WindowName);

[X,Y] = guiMakeGrid(handle,[],6);

% Create the  buttons and stuff
guiCreateText(handle,'TimeSeries',[X(1) Y(3) X(3) Y(4)],'center');
guiCreateText(handle,'Description',[X(3) Y(3) X(6) Y(4)],'center');
Window.ListBoxData = guiCreateListBox(handle,'','winDataBrowser(''SetTimeSeries'',gcf)',[X(1) Y(4) X(3) Y(end)],0);

Window.ListBoxDescription = guiCreateListBox(handle,'','',[X(3) Y(4) X(6) Y(end)],0);

Window.Load = guiCreateButton(handle,'Load','winDataBrowser(''Load'',gcf)',[X(1) Y(1) X(2) Y(2)]);
Window.Save = guiCreateButton(handle,'Save','winDataBrowser(''Save'',gcf)',[X(1) Y(2) X(2) Y(3)]);

Window.Import = guiCreateButton(handle,'Import','winDataBrowser(''Import'',gcf)',[X(2) Y(1) X(3) Y(2)]);
Window.Export = guiCreateButton(handle,'Export','winDataBrowser(''Export'',gcf)',[X(2) Y(2) X(3) Y(3)]);

Window.CurrentTS  = 0; % set a default value

set(handle,'UserData',Window); % Set these things in the userdata
% so when the window is destroyed so is its data

Update;

return

% Update entry point from out of file
% Since it is not a callback the current callback canot be traced
% Hence we have to get it from elsewhere 

function Update

global Program;

% retrieve handle to window
WindowName =[Program.Name ':DataBrowser'];
handle = findobj(allchild(0),'tag',WindowName);

%%%%%%%%%%%%%%%%%%
% Here functions are called that are responsible for the actual updating
UpdateTimeSeries(handle);
UpdateDescription(handle);

return


%%%%%%%%%%%%%%% CALLBACKS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function UpdateTimeSeries(handle)

Window = get(handle,'UserData');

global TS;

if ~isempty(TS),
    name = [];
    for p=1:length(TS),
        if isfield(TS{p},'name'), name{p} =  TS{p}.name;
        elseif isfield(TS{p},'label'), name{p} = TS{p}.label;
        else name{p} = 'UNKNOWN';
	    end
    end
    set(Window.ListBoxData,'string',name,'max',1);
    Window.CurrentTS = median([1 get(Window.ListBoxData,'value') length(TS)]); % simple filter to check boundaries
    set(Window.ListBoxData,'value',Window.CurrentTS);
else
    set(Window.ListBoxData,'string',[],'max',0);
    Window.CurrentTS = 0; % none selected
end

set(handle,'UserData',Window);

return



function SetTimeSeries(handle)

Window = get(handle,'UserData');

global TS;

Window.CurrentTS =  median([1 get(Window.ListBoxData,'value') length(TS)]);
set(Window.ListBoxData,'value',Window.CurrentTS);

set(handle,'UserData',Window);

UpdateDescription(handle);
return



function UpdateDescription(handle)

Window = get(handle,'UserData');

if Window.CurrentTS > 0,
    Info = tsDescription(Window.CurrentTS);
    FN = fieldnames(Info);
    Fields = [];
    for p = 1:length(FN),
        Field = getfield(Info,FN{p}); % Get the value of the field
        if ischar(Field),
            Fields{p} = sprintf('%s = %s',FN{p},Field);
        elseif isnumeric(Field)
            Fields{p} = sprintf('%s = %d',FN{p},Field);
        end
    end
    set(Window.ListBoxDescription,'string',Fields); % Put the data to display
end

return


%%%%%%%%%%%%%%%%%%%%% LOAD/SAVE functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% Load a matlab saved file %%%%

function Load(handle)

Window = get(handle,'UserData');    
result = ioLoadMat; % will return the number of timeseries loaded

if result > 0,
    Window.CurrentTS = 1; % set a default selected time series
    set(handle,'UserData',Window);
end

% Here functions are called that are responsible for the updating the window
UpdateTimeSeries(handle);
UpdateDescription(handle);

return


%%% Save a matlab file %%%%%%%%%

function Save(handle)

result = ioSaveMat; % will return 1 if successful

% Here the functions are called that are responsible for the updating the window
UpdateTimeSeries(handle);
UpdateDescription(handle);

return


function Import(handle)

uiwait(errordlg('test','test'));

return

function Export(handle)

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%