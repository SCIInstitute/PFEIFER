function [X,Y] = guiMakeGrid(handle,xcol,ycol)

% function [X,Y] = guiMakeGrid(handle,rows,cols)
%
% handle - of the object where the grid has to be relative to
%          in case of a figure it is relative to the figure
%          in case of a frame it is relative to the frame
% rows   - The number of rows wanted, leave empty for default
% cols   - The number of cols wanted, leave empty for default
%
% JG Stinstra 2002


global GUI; %  get my default values

if isempty(GUI), % If it is not there just load it into memory
    guiInitGUI;
end

if ishandle(handle),
    % Try to look what kind of handle it is
    type = get(handle,'type');
    switch type
    case 'figure'
        x0 = GUI.Grid.XOffset;
        y0 = GUI.Grid.YOffset;
        position = get(handle,'position');
        width = position(3)-2*(GUI.Grid.XOffset);
        height = position(4)-2*(GUI.Grid.YOffset);
    case 'uicontrol'
        position = get(handle,'position');
        x0 = position(1);
        y0 = position(2);
        width = position(3);
        height = position(4);
    end
else
    errmsg('handle must be an handle to a figure or a frame\n');
end



% Get default height and width to make a default grid
defaultxstep = GUI.Grid.Width;
defaultystep = GUI.Grid.Height;

% make a fitting grid within

if (isempty(xcol))&(isempty(ycol)),
    xstep = defaultxstep;
    ystep = defaultystep;
    xcol = floor(height/ystep);
    ycol = floor(width/xstep);
    xoffset = x0+floor((width-xstep*ycol)/2);
    yoffset = y0+floor((height-ystep*xcol)/2);
    
    X = xoffset:xstep:(width+xoffset);
    Y = yoffset:ystep:(height+yoffset);  
end

if (isempty(ycol))&(~isempty(xcol)),
    xstep = defaultxstep;
    ystep = floor(height/xcol);
    yoffset = y0+floor((width-ystep*xcol)/2);
    ycol = floor(width/xstep);
    xoffset = x0+floor((height-xstep*ycol)/2);
    
    X = xoffset:xstep:(width+xoffset);
    Y = yoffset:ystep:(height+yoffset);  
end

if (isempty(xcol))&(~isempty(ycol)),
    ystep = defaultystep;
    xstep = floor(width/ycol);
    xoffset = x0+floor((width-xstep*ycol)/2);
    xcol = floor(height/ystep);
    yoffset = y0+floor((height-ystep*xcol)/2);
    
    X = xoffset:xstep:(width+xoffset);
    Y = yoffset:ystep:(height+yoffset);
end

% it is completely specified
if (~isempty(xcol))&(~isempty(ycol)),
    ystep = floor(height/xcol);
    xstep = floor(width/ycol);
    xoffset = x0+floor((width-xstep*ycol)/2);
    yoffset = y0+floor((height-ystep*xcol)/2);
    
    X = xoffset:xstep:(width+xoffset);
    Y = yoffset:ystep:(height+yoffset);
end

% Reverse direction of the Y-grid
% This makes programming easierer since matlab uses the bottom as the screen as zero
% whereas normally the upper part is chosen

Y = Y(end:-1:1); % reverse this direction

return
