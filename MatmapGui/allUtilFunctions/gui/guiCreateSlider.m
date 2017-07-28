function Handle = guiCreateSlider(varargin)

% FUNCTION handle = guiCreateSlider([figurehandle],callback,position,[value],[max min],[step])
%
% DESCRIPTION
% This function creates a slider and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
% callback        Callback to the function
% position        Position of the Button specified as [left top right bottom]- position
%                 Note this is different from the standard matlab way of denoting a position
% value           Start value of the slider
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
Button = GUI.Template.Slider; % Obtain the template

% This function only adjusts the string, position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Button.Parent = varargin{k}; % YES, then ...
    k = k + 1;
else
    Button.Parent = gcf;
end

% Set the other missing values and create the button

Button.String   = '';
Button.Callback = varargin{k};
Button.Position = guiTranslatePosition(varargin{k+1});

if nargin > k+2,
    Button.Value = varargin{k+2};
end

if nargin > k+3,
    Button.Min = varargin{k+3}(1);
    Button.Max = varargin{k+3}(2);
end

if nargin > k+4,
    Button.Step = varargin{k+4};
end


Handle = uicontrol(Button);

return
