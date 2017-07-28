function [FN,SN] = triFindNeighbor(fac)

    NumFac = size(fac,2);
    NumPts  = max(fac(:));
    FN = cell(NumPts,1);
    SN = cell(NumPts,1);
    
    
    for p=1:NumPts,
        fn = zeros(1,NumPts);
        [i,j] = find(fac == p);

        fn(fac(:,j)) = 1;
        fn(p) = 0;
        
        FN{p} = find(fn);
    end
    
    for p=1:NumPts,
        sn = zeros(1,NumPts);
        
        fn = FN{p};
        for r = 1:length(fn),
            [i,j] = find(fac == fn(r));
            sn(fac(:,j)) = 1;
        end    
            
        sn(p) = 0;
        sn(fn) = 0;
        
        SN{p} = find(sn);
        
        end    
    
return    