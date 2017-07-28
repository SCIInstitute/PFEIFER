function Handle = guiFigure(Title,Position,Tag)

% FUNCTION handle = guiFigure(title,position,tag)
%
% DESCRIPTION
% This function generates a predefined figure window
% With no toolbar etc.
%
% INPUT
% title     Title of the figure
% position  Position of the figure in normalized coordinates
% tag       A tag for finding the window
%
% OUTPUT
% handle    A handle to the figure
%
% SEE ALSO -

global GUI; %  get my default values

if isempty(GUI), % If it is not there just load it into memory
    guiInitGUI;
end

Window = GUI.Template.Window;
Window.Name = Title;

if nargin > 1,
    Window.Position = Position;
end

if nargin > 2,
    Window.Tag = Tag;
end

Handle = figure(Window);

set(Handle,'units','pixels'); % I need this one as I get the size of the window

return