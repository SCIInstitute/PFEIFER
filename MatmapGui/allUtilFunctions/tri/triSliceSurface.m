function surface = triSliceSurface(surface,origin,normal,varargin)
% FUNCTION surface = triSliceSurface(surface,origin,normal,options)
%
% DESCRIPTION
% This function slices a model in two and only keeps one part and fills up
% the sliced part
%
% INPUT
% surface     surface to be sliced
% origin      a point on the cutting plane
% normal      a normal to the cutting plane pointing outward
% 
% OPTIONS
% 'fill',distance   
%             fill the cutting plane and use distance as a measure for a regular grid
%
% OUTPUT
% surface     new surface
%
% SEE ALSO -


    if ~isfield(surface,'fac') & ~isfield(surface,'pts'),
        error('You should specify a pts and fac field');
    end

    surface = triCCW(surface);
    surface = SliceSurface(surface,origin,normal);
    
    fill = 0;
    sphere = 0;
    
    
    if nargin > 3,
        for p = 1:length(varargin),
        
            switch varargin{p},
            case 'fill'
                dist = varargin{p+1};
                fill = 1;
                p = p + 1;
            case 'sphere'
                radius = varargin{p+1};
                sphere = 1;
                p = p + 1;
            end    
        end
    end    
    
    if fill == 1,
        if sphere == 1,
            surface = FillSlice(surface,origin,normal,dist,radius);
        else
            surface = FillSlice(surface,origin,normal,dist);
        end    
    end

    surface = triCCW(surface);

return

function surface = SliceSurface(surface,origin,normal)

    % RM is a four dimensional rotation translation matrix

    pts4 = triVector4(surface.pts);
    RM = triRotMatrix4(origin,normal);
    RMinv = inv(RM);
    
    % Translate and rotate coordinates
    pts4 = RM*pts4;

    fac = surface.fac;
    pts = surface.pts;

    facnew = [];
    ptsnew = pts;
    
    connect = sparse(size(pts,2),size(pts,2));
    ptsnum = size(pts,2)+1;

    tol = 1e-5*(max(pts(:))-min(pts(:)));
    edgenodes = [];

    for k = 1:size(fac,2),
        N = fac(:,k);
        Z = pts4(3,N);
        
        tolindex = find(abs(Z) < tol);
        Z(tolindex) = 0;
        
        F = find((Z < 0));
 
        if length(F) == 3,
            facnew = [facnew fac(:,k)];  % add this one to the list
        end
         
        if (~isempty(F)&(length(F)<3)),
            
            nv1 = cross(ptsnew(:,N(1))-ptsnew(:,N(2)),ptsnew(:,N(2))-ptsnew(:,N(3)));

            [ZZ,index] = sort(Z);
            NN = N(index);
            
            if ZZ(2) > 0,
            
                nf =  [ NN(1) ];
                       
                for p = 2:3,
                    n = sort(NN([p 1]));
                    cc = connect(n(1),n(2));
                    if cc == 0,
                        if ZZ(1) == 0,
                            connect(n(1),n(2)) = NN(1);
                            nf = [nf NN(1)];
                        elseif ZZ(p) == 0,
                            connect(n(1),n(2)) = NN(p);
                            nf = [nf NN(p)];
                        else    
                            l = ZZ(1)./(ZZ(1)-ZZ(p));
                            ptsnew = [ptsnew (pts(:,NN(1))+l*(pts(:,NN(p))-pts(:,NN(1))))];
                            connect(n(1),n(2)) = ptsnum;
                            nf = [nf ptsnum];
                            ptsnum = ptsnum + 1;
                        end    
                    else    
                        nf = [nf cc];
                    end    
                end
                
                nv2 = cross(ptsnew(:,nf(1))-ptsnew(:,nf(2)),ptsnew(:,nf(2))-ptsnew(:,nf(3)));
                if dot(nv1,nv2) < 0, nf = nf([1 3 2]); end
            
                edgenode(nf(2)) = nf(3);            
                facnew = [facnew nf'];
                
            else     
            
                nf  = NN([2 1])';
                nv1 = cross(ptsnew(:,N(1))-ptsnew(:,N(2)),ptsnew(:,N(2))-ptsnew(:,N(3)));                

                for p = 1:2,
                    n = sort(NN([p 3]));
                    cc = connect(n(1),n(2));
                    if cc == 0,
                        if ZZ(p) == 0,
                            connect(n(1),n(2)) = NN(p);
                            nf = [nf NN(p)];
                        elseif ZZ(3) == 0,
                            conect(n(1),n(2)) = NN(3);
                            nf = [nf NN(3)];
                        else    
                            l = ZZ(p)./(ZZ(p)-ZZ(3));
                            ptsnew = [ptsnew (pts(:,NN(p))+l*(pts(:,NN(3))-pts(:,NN(p))))];
                            connect(n(1),n(2)) = ptsnum;
                            nf = [nf ptsnum];
                            ptsnum = ptsnum + 1;
                        end    
                    else    
                        nf = [nf cc];
                    end    
                end
                        
                nv2 = cross(ptsnew(:,nf(1))-ptsnew(:,nf(2)),ptsnew(:,nf(2))-ptsnew(:,nf(3)));
                if dot(nv1,nv2) < 0, nf = nf([2 1 4 3]); end                     
                        
                d1 = sum((ptsnew(:,nf(1))-ptsnew(:,nf(3))).^2);
                d2 = sum((ptsnew(:,nf(2))-ptsnew(:,nf(4))).^2);
                     
                if d1 < d2,
                    facnew = [facnew nf([1 2 3])' nf([3 1 4])'];
                else
                    facnew = [facnew nf([1 2 4])' nf([4 2 3])'];
                end    
                
                edgenode(nf(3)) = nf(4);                    
            
            end
        end
    end
    
    firstnode = max(edgenode);
    edgenodes = firstnode;
    k = firstnode;
    while edgenode(k) ~= firstnode,
        k = edgenode(k);
        edgenodes = [edgenodes k];
    end    

    
    for p = 1:floor(length(edgenodes)/2),
    
        c  = edgenodes([1:end 1]);
        d = sum((ptsnew(:,c(2:end))-ptsnew(:,c(1:end-1))).^2);
        [dummy,k] = min(d);
        oldnum = c(k);
        newnum = c(k+1);
        facnew(find(facnew == oldnum)) = newnum;
        edgenodes(k) = 0;
        edgenodes = edgenodes(find(edgenodes));          
    end
 
    keep = ones(1,size(facnew,2));
    l = find((facnew(1,:)==facnew(2,:))|(facnew(2,:)==facnew(3,:))|(facnew(3,:)==facnew(1,:)));
    keep(l) = 0;
    facnew = facnew(:,find(keep));    
          
    % filter out none used points
    
    keep = zeros(1,size(ptsnew,2));
    for p =1:size(ptsnew,2),
        if ~isempty(find(facnew == p)),
            keep(p) = 1;
        end
    end
            
    channels = find(keep(1:size(pts,2)));
    renumber = zeros(1,size(ptsnew,2));
    l = find(keep);
    renumber(l) = 1:length(l);
    
    ptsnew = ptsnew(:,l);
    facnew = renumber(facnew);
    edgenodes = renumber(edgenodes);
    original  = renumber(channels);

    surface.channels = channels;
    surface.original = original;
    surface.edgenodes = edgenodes;                                
    surface.fac = facnew;
    surface.pts = ptsnew;
                      
return


function surface = FillSlice(surface,origin,normal,dist,radius)

    pts = surface.pts;
    fac = surface.fac;
    edgenodes = surface.edgenodes;

    % RM is a four dimensional rotation translation matrix

    pts4 = triVector4(pts);
    RM = triRotMatrix4(origin,normal);
    RMinv = inv(RM);
    
    % Translate and rotate coordinates
    pts4 = RM*pts4;

    xlim = [min(pts4(1,edgenodes)) max(pts4(1,edgenodes))];
    ylim = [min(pts4(2,edgenodes)) max(pts4(2,edgenodes))];
    
    xlen = xlim(2)-xlim(1); xstep = xlen/floor(xlen/dist)-eps;
    ylen = ylim(2)-ylim(1); ystep = ylen/floor(ylen/dist)-eps;
     
    xgrid = xlim(1):xstep:xlim(2);
    ygrid = ylim(1):ystep:ylim(2);
    
    [X,Y] = meshgrid(xgrid,ygrid);
    
    ptsnew = [ X(:)' ; Y(:)'];
    
    index  = ones(1,size(ptsnew,2));
    
    for p = edgenodes,
    
        d = sqrt(sum((ptsnew - pts4([1 2],p)*ones(1,size(ptsnew,2))).^2));

        index(find(d <  0.4*dist)) = 0;
    end    

    ptsnew = ptsnew(:,find(index));

    ptsedge = pts4([1 2],edgenodes);
    I = ones(1,length(edgenodes));
    
    keep = [];
    
    for p = 1:size(ptsnew,2),
    
        r = ptsnew(:,p)*I - ptsedge;
        
        an = angle(r(1,:)+i*r(2,:));
        an = an([2:end 1])-an(1:end);
        index = find(an < -pi);
        an(index) = an(index) + 2*pi;
        index = find(an > pi);
        an(index) = an(index) - 2*pi;
        an = abs(sum(an));
        
        if an > pi,
            keep = [keep p];
        end
       
    end
    
    ptsnew = ptsnew(:,keep);
    
    ptsd = [ ptsnew ptsedge ];
    edgecirc = [1:length(edgenodes) 1]+size(ptsnew,2);
    
    newfac = delaunay(ptsd(1,:),ptsd(2,:))';

    ptsd = [ptsd ; zeros(1,size(ptsd,2))];
    nv = cross(ptsd(:,newfac(1,:))-ptsd(:,newfac(2,:)),ptsd(:,newfac(2,:))-ptsd(:,newfac(3,:)));
    turn = find(nv(3,:) > 0);
    newfac(:,turn) = newfac([1 3 2],turn);
    
    keep = ones(1,size(newfac,2));
    
    
    for p = 1:length(edgenodes),
    
        k = find((newfac(1,:)==edgecirc(p))&(newfac(2,:)==edgecirc(p+1)));
        if ~isempty(k), keep(k) = 0; end

        k = find((newfac(2,:)==edgecirc(p))&(newfac(3,:)==edgecirc(p+1)));
        if ~isempty(k), keep(k) = 0; end

        k = find((newfac(3,:)==edgecirc(p))&(newfac(1,:)==edgecirc(p+1)));
        if ~isempty(k), keep(k) = 0; end

    end
   
    for p=1:size(newfac,2),
        if length(intersect(newfac(:,p),edgecirc(1:length(edgenodes)))) == 3,
            keep(p) = 0;
        end
    end
    
    newfac = newfac(:,find(keep));
      
    I = ones(1,size(ptsnew,2));    
    ptsnew = [ptsnew ; 0*I; I]; 
    
    if nargin > 4,
        [R,Center] = triFitCircle(ptsedge);
        if radius < R, radius = R; end
        r2 = (ptsnew(1,:)-Center(1)).^2 + (ptsnew(2,:)-Center(2)).^2;
        Z = - sqrt(radius^2-R^2) + sqrt(radius^2-r2);
        ptsnew(3,:) = Z;
    end    
        
    ptsnew = RMinv*ptsnew;
    I = size(pts,2)+size(ptsnew,2)+[1:length(edgenodes)];

    fac = [fac newfac+size(pts,2)];
    pts = [pts triVector3(ptsnew)];
    
  
    
    for p =1:length(I),
        index = find(fac==I(p));
        fac(index) = edgenodes(p);
    end    

    surface.pts = pts;
    surface.fac = fac;    
return