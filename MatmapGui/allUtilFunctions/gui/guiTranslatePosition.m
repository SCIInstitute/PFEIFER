function NewPosition = guiTranslatePosition(Position,mode)

% FUNCTION newposition = guiTranslatePosition(position,mode)
%
% DESCRIPTION
% This function translates from one coordinate system to another
% simplifying the way gui elements are located.
%
% INPUT
% position      A postion in [left top right bottom] coordinates
% mode          Specifies whether coordinates need adjusting
%               0 - regular button (carve off some space so buttons do not touch eachother)
%               1 - text or frame
%               2 - axes (leave some space for text along axis)
%
% OUTPUT      
% newposition   Position in [left bottom width height]-coordinates
%
% SEE ALSO -

NewPosition = [min(Position([1 3])) min(Position([2 4])) abs(Position(1)-Position(3)) abs(Position(2)-Position(4))];

if nargin == 2,
    if mode == 0,
        NewPosition = NewPosition + [2 1 -4 -2];
    elseif mode == 1,
        NewPosition = NewPosition + 4*[2 1 -4 -2];
    elseif mode == 2,
        width = abs(Position(1)-Position(3));
        height = abs(Position(2)-Position(4));
        NewPosition = [min(Position([1 3]))+0.1*width min(Position([2 4]))+0.15*height 0.8*width 0.8*height];
    elseif mode ==3,
        NewPosition = NewPosition+[-2 -2 4 4];
    end        
    
end

return