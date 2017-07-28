function openAllFigures()

guide('winMyFidsDisplay.fig')
guide('mainMenu.fig')
guide('SettingsDisplay.fig')
guide('winMySliceDisplay.fig')
guide('winSelectLoopOrder.fig')
guide('winSelectRungroupFiles.fig')


figures={'winMyFidsDisplay.fig','mainMenu.fig','SettingsDisplay.fig','winMySliceDisplay.fig','winSelectRungroupFiles.fig'};


% for s=1:length(figures)
%     fig=openfig(figures{s});
%     for p=1:length(fig.Children)
%         if isprop(fig.Children(p),'Fontsize') && isprop(fig.Children(p),'Extent') && isprop(fig.Children(p),'Style')
%             if strcmp(fig.Children(p).Style,'text')
%             needed_width=fig.Children(p).Extent(3);
%             needed_height=fig.Children(p).Extent(4);
%             fig.Children(p).Position(3)=needed_width+0.001;
%             fig.Children(p).Position(4)=needed_height+0.001;
%             end
%         end
%     end
% 
%     savefig(fig,figures{s})
% end



% s=5;
% fig=openfig(figures{s});
% for p=1:length(fig.Children)
%     if isprop(fig.Children(p),'Fontsize') && isprop(fig.Children(p),'Extent') && isprop(fig.Children(p),'Style')
%         if strcmp(fig.Children(p).Style,'text')
%         needed_width=fig.Children(p).Extent(3);
%         needed_height=fig.Children(p).Extent(4);
%         fig.Children(p).Position(3)=needed_width+0.001;
%         fig.Children(p).Position(4)=needed_height+0.001;
%         end
%     end
% end
% savefig(fig,figures{s})






