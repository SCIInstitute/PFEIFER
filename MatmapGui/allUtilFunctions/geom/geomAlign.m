function [pts2new] = geomAlign(channels1,pts1,channels2,pts2)

% FUNCTION [pts2new] = geomAlign(channels1,pts1,channels2,pts2)
%
%

l = max([channels1,channels2]);
index = zeros(1,l);
Cindex1 = index;
Cindex2 = index;
index(channels1) = 1;
index(channels2) = index(channels2) + 1;
Cindex1(channels1) = 1:length(channels1);
Cindex2(channels2) = 1:length(channels2);

common = find(index == 2);
pos1 = pts1(Cindex1(common),:);
pos2 = pts2(Cindex2(common),:);

% So we should match pos2 on pos1
% Both points now map one to one

T = mean(pos1,1);
T2 = mean(pos2,1);

ps1 = pos1 - ones(length(pos1),1)*T;
ps2 = pos2 - ones(length(pos2),1)*T2;

H = ps1'*ps2; [U,L,V] = svd(H);
R = V*U';

newpos2 = ps2*R+ones(length(pos2),1)*T;

err = sqrt(sum((pos1-newpos2).^2,2));

newpoints = find(err < 4);

pos1 = pos1(newpoints,:);
pos2 = pos2(newpoints,:);

T = mean(pos1,1);
T2 = mean(pos2,1);

ps1 = pos1 - ones(length(pos1),1)*T;
ps2 = pos2 - ones(length(pos2),1)*T2;

H = ps1'*ps2; [U,L,V] = svd(H);
R = V*U';

newpos2 = ps2*R+ones(length(pos2),1)*T;

err = sqrt(sum((pos1-newpos2).^2,2));

mean(err)

R
T

pts2new = (pts2-ones(length(pts2),1)*T2)*R+ones(length(pts2),1)*T;

pos2 = newpos2;

figure
plot3(pos1(:,1),pos1(:,2),pos1(:,3),'bo');
hold on
plot3(pos2(:,1),pos2(:,2),pos2(:,3),'rx');

rotate3d on;


