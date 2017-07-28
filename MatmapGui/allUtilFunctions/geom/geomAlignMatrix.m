function RT = geomAlignMatrix(channels1,pts1,channels2,pts2,errlevel)

% FUNCTION RT = geomAlignMatrix(channels1,pts1,channels2,pts2,[error])
%
% DESCRIPTION
% This function will generate a 4D translation rotation matrix.
% The matrix is based on the common points in set 1 and 2 (channels+pts)
% of geometry.
%
% INPUT
% channels1       channels file of the firstset (one dimensional vector, use ioReadMap not ioReadChannels)
% pts1            points set 1 (use ioReadPts)
% channels2       idem chanbels file for second set
% pts2            points set 2
% error           (defaul 4mm) After matching the points the points with an error higher than <error> will
%                 be discarded and the matching will be performed once more.
%
% OUTPUT
% RT              rotation-translation matrix for projecting set 2 onto set 1
%


if nargin == 4,
    errlevel = 10;
end    

% find the common points in both sets
% and put the indices in common
% Cindex1 and Cindex2 correspond to the points present in both sets

l = max([channels1,channels2]);
index = zeros(1,l);
Cindex1 = index;
Cindex2 = index;
index(channels1) = 1;
index(channels2) = index(channels2) + 1;
Cindex1(channels1) = 1:length(channels1);
Cindex2(channels2) = 1:length(channels2);
common = find(index == 2);

if length(common) < 4,
    error('Impossible to link both sets on the basis of 3 common points');
end    

% in case of 4D vectors make them 3D again

if size(pts1,1) == 4,
    pts1 = triVector3(pts1);
end

if size(pts2,1) == 4,
    pts2 = triVector3(pts2);
end    

% Get common point and put them in pos1 and pos2
% so each set in both should correspond to eachother
% and are only a rotation and tranlation apart

C1 = Cindex1(common);
C2 = Cindex2(common);

pos1 = pts1(:,C1);
pos2 = pts2(:,C2);

% So we should match pos2 on pos1
% Both points now map one to one

T1 = mean(pos1,2);
T2 = mean(pos2,2);

ps1 = pos1 - T1*ones(1,size(pos1,2));
ps2 = pos2 - T2*ones(1,size(pos2,2));

H = ps1*ps2'; [U,L,V] = svd(H);
R = U*V';

if det(R) < 0,
    error('Somehow the rotation got mirrored');
end    

% Do a first level correction and remove all points
% That are far off from the target point after rotation
% and tranlation.

newpos2 = R*ps2 + T1*ones(1,size(pos2,2));
err = sqrt(sum((pos1-newpos2).^2,1));
newpoints = find(err < errlevel);

fprintf(1,'Phase 1: The mean fit error = %3.2f\n',mean(err));
disp('channel  |  error (distance)')
disp([ channels1(C1([1:length(err)]))' err'])

if length(newpoints) < 4,
    keyboard
    error('After correction not enough points are left for doing a match of coordinate systems');
end    

% Redo algorithm but with fewer points

pos1 = pos1(:,newpoints);
pos2 = pos2(:,newpoints);

T1 = mean(pos1,2);
T2 = mean(pos2,2);

ps1 = pos1 - T1*ones(1,size(pos1,2));
ps2 = pos2 - T2*ones(1,size(pos2,2));

H = ps1*ps2'; [U,L,V] = svd(H);
R = U*V';

newpos2 = R*ps2 + T1*ones(1,size(pos2,2));
err = sqrt(sum((pos1-newpos2).^2,1));

fprintf(1,'Phase 2: The mean fit error = %3.2f\n',mean(err));
disp('channel  |  error (distance)')
disp([channels1(C1(newpoints))'  err'])

errlevel = 5;
newpoints2 = find(err < errlevel);

if length(newpoints2) < 4,
    keyboard
    error('After correction not enough points are left for doing a match of coordinate systems');
end  

% Redo algorithm but with fewer points

pos1 = pos1(:,newpoints2);
pos2 = pos2(:,newpoints2);

T1 = mean(pos1,2);
T2 = mean(pos2,2);

ps1 = pos1 - T1*ones(1,size(pos1,2));
ps2 = pos2 - T2*ones(1,size(pos2,2));

H = ps1*ps2'; [U,L,V] = svd(H);
R = U*V';

newpos2 = R*ps2 + T1*ones(1,size(pos2,2));
err = sqrt(sum((pos1-newpos2).^2,1));

fprintf(1,'Phase 3: The mean fit error = %3.2f\n',mean(err));
number1 = channels1(C1(newpoints(newpoints2)));
number2 = channels2(C2(newpoints(newpoints2)));

disp('channel  |  error (distance)')
disp([number1'  err'])

T = T1 - R*T2;
RT = [ R T ; 0 0 0 1]; 

fprintf(1,'Aligned the sets on points: '); fprintf(1,'%d ',number1); fprintf(1,'\n\n\n')

dpos = pos1 - newpos2;

for p = 1:length(pos1),
    fprintf(1,'for point %2d (%2d in fixed set and %2d in rotated set)\n',p,number1(p),number2(p));
    fprintf(1,'fixed: %3.2f %3.2f %3.2f; aligned: %3.2f %3.2f %3.2f\n',pos1(1,p),pos1(2,p),pos1(3,p),newpos2(1,p),newpos2(2,p),newpos2(3,p));
    fprintf(1,'with difference = %3.2f %3.2f %3.2f = %3.2f\n\n',dpos(1,p),dpos(2,p),dpos(3,p),err(p));
end

fprintf(1,'Error statistics\nmean: %2.2f\nmax: %2.2f\nrms: %2.2f\n\n',mean(err),max(err),sqrt(mean(err.^2)));

fprintf(1,'The rotation/translation matrix:\n'); disp(RT);
fprintf(1,'\nAnd for right multiplication:\n'); disp(RT');
fprintf(1,'\n');


return




