function [r,center] = triFitCircle(varargin)
% FUNCTION [r,center] = triFitCircle(pts)
%
% DESCRIPTION
% This function fits a circle through the points and tries to
% minimise the distance between the points and the circle in a
% least squares sence
%
% INPUT
% pts     2D points array
% 
% OUTPUT
% r       radius of circle
% center  the center of the circle
%
% SEE ALSO -

    if nargin == 2,
        X = varargin{1};
        R = X(1);
        cx = X(2);
        cy = X(3);
        pts = varargin{2};
        r = sum((sqrt((pts(1,:)-cx).^2 + (pts(2,:)-cy).^2) - R).^2);
        return
    end
    
    pts = varargin{1};
    meanpts = mean(pts,2);
    stdpts = std(pts,2);
    
    X0 = [norm(0) meanpts' ];
    OPTIONS = optimset;
    % OPTIONS.Display ='iter';
    X = fminsearch(@triFitCircle,X0,OPTIONS,pts);
    
    r = X(1);
    center = X([2 3]);
    
    R = sqrt((pts(1,:)-center(1)).^2 + (pts(2,:)-center(2)).^2);
    r = max(R);
    
return                    