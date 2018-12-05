clear all;

load(['NA2160x1080_latlon_fortides.mat'],'Face1','Face5');

figure(2);clf;
plot(Face1.lonS,Face1.latS,'b.-');hold on;
plot(Face5.lonE,Face5.latE,'r.-');
plot(Face1.lonN,Face1.latN,'b.-');hold on;
plot(Face5.lonW,Face5.latW,'r.-');
hold off;grid;
title(['Lat North: ' num2str(mean(Face1.latN)) '; ' ...
       'Lat South: ' num2str(mean(Face1.latS))]);

load coast; %<--- this is something avail in old matlab; if not exist, just skip the next 2 lines
hold on;plot(long,lat,'k-');hold off;

axis([-92.0 23.9 17.7 52.6]);
set(gcf,'paperunits','inches','paperposition',[0 0 8 6]);
print([dirOut 'NA2160x1080_latlon_fortides.png'],'-dpng');

