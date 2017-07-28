   
function x = polymin(sig)

    % Detection of the first derivative
    % Use a window of 7 frames and fit a 3rd order polynomial

    deg = 3;
    win = 7;

    % Detection of the minimum derivative
    % Use a window of 5 frames and fit a 2nd order polynomial
   
    win2 = 5;
    deg2 = 2;
    
    cen = ceil(win/2);
    X = zeros(win,(deg+1));
    L = [-(cen-1):(cen-1)]'; for p=1:(deg+1), X(:,p) = L.^((deg+1)-p); end
    E = inv(X'*X)*X';

    sig = [sig sig(end)*ones(1,cen-1)];
    
    a = filter(E(deg,[win:-1:1]),1,sig);
    dy = a(cen:end);

    [mv,mi] = min(dy(cen:end-cen));
    mi = mi(1)+(cen-1)
    
    win2 = 5;
    deg2 = 2;
    
    cen2 = ceil(win2/2);
    L2 = [-(cen-1):(cen-1)]';
    for p=1:(deg2+1), X2(:,p) = L2.^((deg2+1)-p); end
    c = inv(X2'*X2)*X2'*(dy(L2+mi)');
    
    dx = -c(2)/(2*c(1));
    
    x = mi+dx-1;
    