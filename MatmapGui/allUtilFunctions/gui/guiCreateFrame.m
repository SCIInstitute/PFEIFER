function Handle = guiCreateFrame(varargin)

% FUNCTION handle = guiCreateFrame([figurehandle],position)
%
% DESCRIPTION
% This function creates a push button and fills out all default fields like
% colors etc, based on the template found in the global GUI
%
% INPUT
% figurehandle    Handle figure (optional)
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

% In the global GUI, templates for all button are described
% This more or less deals with color settings etc

global GUI;
Frame = GUI.Template.Frame; % Obtain the template

% This function only adjusts the string,position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Frame.Parent = varargin{k}; % YES, then ...
    k = k + 1;
else
    Frame.Parent = gcf;
end

% Set the other missing values and create the button

Frame.Position = guiTranslatePosition(varargin{k},3); % make a small border surrounding button
Handle = uicontrol(Frame);

return
