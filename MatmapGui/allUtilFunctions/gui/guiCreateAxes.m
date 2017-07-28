function Handle = guiCreateAxes(varargin)

% FUNCTION handle = guiCreateAxes([figurehandle],position,[xlim],[ylim],[showaxes])
%
% DESCRIPTION
% This function creates a static text field and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
% position        Position of the Button specified as [left top right bottom]- position
%                 Note this is different from the standard matlab way of denoting a position
% xlim            The xlimits 
% ylim            The ylimits
% showaxes        To turn off the text along the axes (0 == off and 1 == on (default))
%
% OUTPUT
% handle          The handle of the button
%
% NOTE
% Before running the gui creation tools, run guiInitGUI() to setup global templates for the buttons 
%
% SEE ALSO guiCreateListBox guiCreateEdit guiCreateSlider guiCreateText guiCreateCheckBox guiCreateButton


% In GUI templates for all button are described
% This more or less deals with color settings etc

global GUI;
Axes = GUI.Template.Axes; % Obtain the template

% This function only adjusts the string,position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Axes.Parent = varargin{k}; % YES, then ...
    k = k + 1;
else
    Axes.Parent = gcf;
end

% Set the other missing values and create the button

Axes.Position = guiTranslatePosition(varargin{k},2);

if nargin > k,
    Axes.XLim = varargin{k+1};
end

if nargin > k+1,
    Axes.YLim = varargin{k+2};
end

if nargin > k+2,
    if varargin{k+3} == 0,
        Axes.XTick = [];
        Axes.YTick = [];
    end    
end

Handle = axes(Axes);

return
