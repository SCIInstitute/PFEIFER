function NewPosition = guiTranslatePositionText(Position)

% function NewPosition = guiTranslatePositionText(Position)
%
% This function translates from one coordinate system to another
% simplifying the way gui elements are located
% Make text appear in the middle

global GUI;

height = GUI.Font.Size+4;

NewPosition = [min(Position([1 3])) min(Position([2 4])) abs(Position(1)-Position(3)) abs(Position(2)-Position(4))];

rest = NewPosition(4)-height;
NewPosition(4) = height;
NewPosition(1) = NewPosition(1)+floor(rest/2);


return