function labels = MapLayout

banks = [ 'A' 'B' 'C' 'D' ];
len = [ 48 48 48 48 48 16];

labels = cell(1,1024);

for b = 1:length(banks),
    for s=1:6,
        for k = 1:len(s),
            str = sprintf('%s%d(%02d)',banks(b),s,k);
            n = generatemap(str);
            labels{n} = str; 
        end
    end
end


fid = fopen('maplayout.txt','w');
fprintf(fid,'LAYOUT DATA ACQ: A-B (master) C-D (slave)\n\n');

for p =1:128,
    fprintf(fid,'%04d : %s   %04d : %s   %04d : %s   %04d : %s %04d : %s   %04d : %s   %04d : %s   %04d : %s\n',p,labels{p},p+128,labels{p+128},p+256,labels{p+256},p+384,labels{p+384},p+512,labels{p+512},p+640,labels{p+640},p+768,labels{p+768},p+896,labels{p+896});
end

fclose(fid)