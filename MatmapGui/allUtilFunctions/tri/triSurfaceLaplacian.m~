function L = triSurfaceLaplacian(surface)
% FUNCTION L = triSurfaceLaplacian(surface)
%
% DESCRIPTION
% This function computes the surface laplacian matrix for a given 
% surface.
%
% INPUT
% surface         Surface to be used in laplacian operation
%
% OUTPUT
% L               Surface laplacian matrix
%
% SEE ALSO

    if ~isfield(surface,'pts') & ~isfield(surface,'fac'),
        if isfield(surface,'surface'),
            model = surface;
            for p = 1:length(model.surface),
                if ~isfield(model.surface{p},'pts') & ~isfield(model.surface{p},'fac'),
                    error('You should at least specify a pts and fac field');
                end    
                model.surface{p}.laplacian = CalcLaplacian(model.surface{p});
            end    
            L = model;
        else
            error('You should at least specify a pts and a fac field');
        end
    else
        L = CalcLaplacian(surface);
    end        
    
return
 
function L = CalcLaplacian(surface)

    pts = surface.pts;
    fac = surface.fac;

    L = zeros(size(pts,2),size(pts,2));

    for p = 1:size(pts,2),
        index = zeros(1,size(pts,2));
        [dummy,triindex] = find(fac==p); 
        points = fac(:,triindex); 
        index(points(:)) = 1; 
        index(p) = 0; 
        neighbors = find(index);
        hij = sqrt(sum( (pts(:,neighbors) - pts(:,p)*ones(1,length(neighbors))).^2,1));
        hi = 1/mean(hij);
        ihi = mean(1./hij);
        n = length(neighbors);
        L(p,p) = -4*ihi*hi;
        L(p,neighbors) = (4*hi/n)./hij;
    end
    
return
          





       