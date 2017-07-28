function Handle = guiCreateEdit(varargin)

% FUNCTION handle = CreateEdit([figurehandle],string,callback,position)
%
% DESCRIPTION
% This function creates an edit field and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
% string          Name of the button
% callback        Callback to the function
% position        Position of the Button specified as [left top right bottom]- position
%                 Note this is different from the standard matlab way of denoting a position
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
Button = GUI.Template.Edit; % Obtain the template

% This function only adjusts the string,position and callback of the button

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

Handle = uicontrol(Button);
return
