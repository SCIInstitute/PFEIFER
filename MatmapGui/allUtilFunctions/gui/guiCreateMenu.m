function guiCreateMenu(HWindow,MenuTitle,Menu)

% function guiCreateMenu([HWindow],MenuTitle,Menu)
%
% HWindow     the handle to the figure in which the menu has to be created.
% MenuTitle   the title of the menu in the menubar
% Menu        a n by 2 cell array containing pairs of the menu-item-label
%             and the menu-item-callback
%
% For instance
% Menu = {'Front','view(90,0)'; 'Back','view(270,0)'};
% CreateMenu(gcf,'View',Menu);
% Creates a menu which selects the view of the figure
%
% If you want a separator between items, just make the menu-item-label between
% two items empty and a separator will be placed.
% If no HWindow is supplied the function assumes the current figure to be 
% the lucky one.
%
% dr. JG Stinstra 2002

if nargin == 2,
    Menu = MenuTitle; MenuTitle = HWindow; % swap order of items
    % No handle was supplied so assume the current one
    HWindow = gcf;
end


M = uimenu(HWindow,'label',MenuTitle);

Separator ='off';
for q = 1:size(Menu,2),
    label = Menu{q,1};
    callback = Menu{q,2};
    if isempty(label),
        Separator = 'on';
    else
       uimenu(M,'label',label,'callback',callback,'separator',Separator);
       Separator = 'off';
   end
end   

return