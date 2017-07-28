function Handle = guiCreateCheckBox(varargin)

% FUNCTION handle = guiCreateCheckBox([figurehandle],string,callback,position,[checked])
%
% DESCRIPTION
% This function creates a checkbox and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
% string          Name of the button
% callback        Callback to the function
% position        Position of the Button specified as [left top right bottom]- position
%                 Note this is different from the standard matlab way of denoting a position
% checked         A value 0 or 1 depending on the state of the checkbox
%                 The default value is 0 (not checked)
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
Button = GUI.Template.CheckBox; % Obtain the template

% This function only adjusts the string, position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Button.Parent = varargin{k}; % YES, then ...
    k = k + 1;
else
    Button.Parent = gcf;
end

% Set the other missing values and create the button

Button.String   = varargin{k};
Button.Callback = varargin{k+1};
Button.Position = guiTranslatePosition(varargin{k+2});
if nargin > k+2,
    Button.Value = varargin{k+3};
end

Handle = uicontrol(Button);

return
