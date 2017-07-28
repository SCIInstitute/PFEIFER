function channels = triFindChannels(pts1,pts2)


if size(pts1,2) > size(pts2,2),
    temp = pts2;
    pts2  = pts1;
    pts1 = temp;
end

channels = [];

for p=1:size(pts1,2),
    R= (pts2(1,:)-pts1(1,p)).^2 + (pts2(2,:)-pts1(2,p)).^2 + (pts2(3,:)-pts1(3,p)).^2;
    channels(p) = find(R == min(R));
end

