function Handle = guiCreateEditText(varargin)

% FUNCTION handle = guiCreateEditText([figurehandle],string,callback,position,text)
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
% text            Text left to the edit button
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

Handle = [];

global GUI;

Button = GUI.Template.Edit; % Obtain the template
Text = GUI.Template.Text; 

% This function only adjusts the string,position and callback of the button

k = 1;
if ishandle(varargin{k}),  % Is the first one a figure handle
    Button.Parent = varargin{k}; % YES, then ...
    Text.Parent = varargin{k};
    k = k + 1;
else
    Button.Parent = gcf;
    Text.Parent = gcf;
end

% Set the other missing values and create the button

Button.String   = varargin{k};
Button.Callback = varargin{k+1};

position = varargin{k+2};
position1 = position;
position1(3) = mean(position([1 3]));
position2 = position;
position2(1) = mean(position([1 3]));
Button.Position = guiTranslatePosition(position2,0);
Text.Position = guiTranslatePositionText(position1);
Text.string = varargin{k+3};
Text.Horizontalalignment = 'right';

Handle = uicontrol(Button);
uicontrol(Text);

return
