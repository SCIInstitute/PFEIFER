function [Pts,Fac] = triAlignFacPts(OldPts,Pts,Fac)
% function [Pts,Fac] = triAlignFacPts(OldPts,Pts,Fac)
%
% This function rearranges an Pts and Fac matrix so the order in the
% matrices matches that of the order given in the OldPts matrix
% the function assumes oldPts and Pts to derive from the same dataset of points
% although small deviations may occur between the nodes. The function uses a
% basic distance criterium to match points. So no translation or rotation is allowed
% at this point. (Perhaps some future version will do). 
% furthermore the functions does everything so you can still use the old mapping files
% 
% see ioWriteFac ioWritePts ioReadPts ioReadfac

% JG Stinstra 2002

Order = triOrderPts(OldPts,Pts); % just get my new mapping
InvOrder = triOrderPts(Pts,OldPts); % just the order way around Order(InvOrder)does now a one to one mapping

Pts = Pts(:,Order); % Reorder all points in the Node matrix

if ~isempty(find(Fac == 0)),
    Fac = Fac + 1; % Justy see whether a C-base indexing is used and correct it in that case
end

Fac = InvOrder(Fac); % Since the numbers are defined in a way that links the order way around than we assume in Order
                     % just use the inverse mapping order
                     
return                     