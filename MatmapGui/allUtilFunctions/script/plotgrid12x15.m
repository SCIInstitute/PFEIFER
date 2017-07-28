function handle = plotgrid12x15(tsdata,filename)

handle = figure;
ax = axes;
axis([0 15 0 12.5]);
axis off;

potvals = tsdata.potvals;

chmax = max(potvals(:));
chmin = min(potvals(:));

scale = 1/(chmax-chmin);
potvals = (potvals - chmin).*scale;

timeaxis = 1:size(potvals,2);
timeaxis = timeaxis./(length(timeaxis)*1.15);

hold on;

for p=1:12,
    for q = 1:15,
        plot(timeaxis+(q-1),potvals(p+(q-1)*12,:)+(p-1),'k');
        text((q-1),p,sprintf('%d',p+(q-1)*12),'fontsize',5);
    end
end

info = sprintf('FILENAME: %s   LABEL: %s',tsdata.filename,tsdata.label);
text(0,12.5,info,'fontsize',6);

set(ax,'position',[0.04 0.04 0.92 0.92]);
set(handle,'paperorientation','landscape');
set(handle,'paperposition',[0.25 0.25 10.5 8]);

if nargin == 2,
    print('-depsc','-r300','-loose',[filename '.eps']);
%    print('-dpng','-r300','-loose',[filename '.png']);
end


