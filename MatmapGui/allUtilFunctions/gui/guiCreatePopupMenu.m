function Handle = guiCreatePopupMenu(varargin)

% FUNCTION handle = guiCreatePopupMenu([figurehandle],string,callback,position,value)
%
% DESCRIPTION
% This function creates a popupmenu button and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
% string          Fields of the button (cellarray)
% callback        Callback to the function
% position        Position of the Button specified as [left top right bottom]- position
%                 Note this is different from the standard matlab way of denoting a position
% value           What is the default value
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
Button = GUI.Template.PopupMenu; % Obtain the template

% This function only adjusts the string,position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Button.Parent = varargin{k}; % YES, then ...
    k = k + 1;
end

% Set the other missing values and create the button

Button.String   = varargin{k};
Button.Callback = varargin{k+1};
Button.Position = guiTranslatePosition(varargin{k+2},0);

if nargin > k+2,
    Button.Value = varargin{k+3};
end    

Handle = uicontrol(Button);
return
