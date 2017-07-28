function InitGUI

% function InitGUI
%
% This functions does nothing more then setting up a global called GUI
% in which all settings regarding the GUI are stored
% Defining it global prevents local copies being made which
% only would make the system slow and would waste some memory
%
% JG Stinstra 2002

global GUI;

GUI = []; % make sure it is empty

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Obtain current screensize

ScreenSize = get(0,'screensize');
GUI.Screen = [ScreenSize(3) ScreenSize(4)]; % Alter this setting to simulate a smaller screen
GUI.ScreenSize = [ScreenSize(3)-5, ScreenSize(4)-71];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the default fonts to be used

GUI.Font.Name = 'Helvetica';
GUI.Font.Size = 8;


if GUI.ScreenSize(1) > 1024,
    GUI.Font.Size = 12;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define the colors
% Set the default colors for the different display elements
% A new color can be added here

Color.Window = [1 0.9 0.7]; 
Color.Window2 = [0.6 0.6 0.8];
Color.Button = [0.7 0.7 0.7];
Color.Edit = [ 0.9 0.9 0.9];
Color.Text = [0 0 0];
GUI.Color = Color;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for different kind of buttons and fields

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a textfield
Text.Parent = []; % To be set by CreateText function
Text.String = ''; % To be set by CreateText function
Text.Units = 'pixels';
Text.Position = []; % To be set by CreateText function
Text.Style = 'text';
Text.HorizontalAlignment = 'right';
Text.BackgroundColor = GUI.Color.Window;
Text.ForegroundColor = GUI.Color.Text;
Text.FontName = GUI.Font.Name;
Text.FontSize = GUI.Font.Size;
GUI.Template.Text = Text; % Load the settings in the global

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a pushbutton
PushButton = GUI.Template.Text; % Just take the settings of the textfield and adjust them
PushButton.Style = 'pushbutton';
PushButton.HorizontalAlignment = 'center';
PushButton.BackgroundColor = GUI.Color.Button;
GUI.Template.PushButton = PushButton;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a Edit field
Edit = GUI.Template.Text;
Edit.Style = 'edit';
Edit.HorizontalAlignment = 'left';
Edit.BackgroundColor = GUI.Color.Edit;
GUI.Template.Edit = Edit;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a Frame that surrounds groups of buttons
Frame.Units = 'pixels';
Frame.Position = [];  % Has to be filled by CreateFrame
Frame.Style = 'frame';
Frame.BackGroundColor = GUI.Color.Window2;
GUI.Template.Frame = Frame;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a checkbox
CheckBox = GUI.Template.PushButton;
CheckBox.Style = 'checkbox';
CheckBox.HorizontalAlignment = 'left';
CheckBox.BackgroundColor = GUI.Color.Window;
GUI.Template.CheckBox = CheckBox;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a listbox
ListBox = GUI.Template.Edit;
ListBox.Style = 'listbox';
ListBox.Unit = 'Pixels';
ListBox.Min = 0;
ListBox.Max = 1;
GUI.Template.ListBox = ListBox;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a popupmenu
PopupMenu = GUI.Template.Edit;
PopupMenu.Style = 'popupmenu';
PopupMenu.Unit = 'Pixels';
PopupMenu.Min = 0;
PopupMenu.Max = 1;
GUI.Template.PopupMenu = PopupMenu;

%%%%%%%%%%%%%%%%%%%%%%%%%%

Axes.Unit = 'pixels';
GUI.Template.Axes = Axes;

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Template for a slider
Slider = GUI.Template.PushButton;
Slider.Style = 'slider';
Slider.Min = 0;
Slider.Max = 1;
GUI.Template.Slider = Slider;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set properties of SelectionBox
GUI.SelectionBox.Face = 'none';
GUI.SelectionBox.Edge = [0 0 0];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set default window settings

Window.Units = 'normalized';  % Be sure this one is before position
Window.Position = [100 100 600 500];
Window.NumberTitle = 'off';

Window.Color = Color.Window;
Window.Resize = 'off';
Window.MenuBar = 'none';
GUI.Template.Window = Window;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set default window grid

GUI.Grid.Width = 120;
GUI.Grid.Height = 20;
GUI.Grid.XOffset = 10;
GUI.Grid.YOffset = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Everything is loaded into a global and hence
% available to each gui function. Since it is global
% one has not to worry about supplying each function with
% these settings, they are just there :)
