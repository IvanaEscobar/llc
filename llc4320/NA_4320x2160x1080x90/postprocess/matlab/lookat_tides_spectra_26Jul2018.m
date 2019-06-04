%run lookat_tides first to load in time series


tt=ta.*24;
%signal=(a-mean(a))-(b-mean(b));

tt=ta.*24;
%signal=(a-mean(a))-(b-mean(b));
%[Pw,fw]=pmtm(signal);

%[Pw_m1,fw_m1]=periodogram(b-mean(b));
%[Pw_m3,fw_m3]=periodogram(c-mean(c));
%[Pw_jc,fw_jc]=periodogram(a-mean(a));
[Pw_m3,fw_m3]=pmtm(c-mean(c));
[Pw_jc,fw_jc]=pmtm(a-mean(a));

%figure(3);clf;
figure(1);%clf;
%subplot(411);plot(tt,signal,'-');grid;xlabel('hour');
%             ylabel('resid=(JC-mean(JC)) minus (MM1-mean(MM1)) [Pa]');
%             set(gca,'Ylim',[-25 20]);
subplot(313);loglog(1./(fw_jc./(2*pi)),Pw_jc.*(2*pi).^2);grid;
     hold on;loglog([12 12],[1e-6 1e12],'r-','linewidth',2);
             loglog([24 24],[1e-6 1e12],'r-','linewidth',2);hold off;
     xlabel('Period in hours');ylabel('Spectral density [Pa^2/hr], NASA');%'JC');
     set(gca,'Xlim',[2 10^(5.5)],'Ylim',[1e-7 1e12]);
     text(24.6,1e11,'24 hr');text(12.3,1e11,'12 hr');
     %set(gca,'fontsize',24,'linewidth',1);
subplot(312);loglog(1./(fw_m3./(2*pi)),Pw_m3.*(2*pi).^2);grid;
     hold on;loglog([12 12],[1e-6 1e12],'r-','linewidth',2);
             loglog([24 24],[1e-6 1e12],'r-','linewidth',2);hold off;
     xlabel('Period in hours');ylabel('Spectral density [Pa^2/hr], Mueller\_new');% MM1');
     set(gca,'Xlim',[2 10^(5.5)],'Ylim',[1e-7 1e12]);
     text(24.6,1e11,'24 hr');text(12.3,1e11,'12 hr');
     %set(gca,'fontsize',24,'linewidth',1);
%subplot(414);loglog(1./(fw./(2*pi)),Pw.*(2*pi).^2);grid;
%     hold on;loglog([12 12],[1e-6 1e8],'r-','linewidth',2);
%             loglog([24 24],[1e-6 1e8],'r-','linewidth',2);hold off;
%     xlabel('Period in hours');ylabel('Spectral density, JC minus MM1');
%     set(gca,'Xlim',[2 10^(5.5)],'Ylim',[1e-7 1e8]);
%     text(24.6,1e7,'24 hr');text(12.3,1e7,'12 hr');
%

set(gcf,'paperunits','inches','paperposition',[0 0 10 10]);
fpr=[dirRoot 'tidalpotential_spectrapower_26Jul2018.png'];print(fpr,'-dpng');

%signal =(a-mean(a))-(b-mean(b));	%std:   6.3Pa
%signalc=(a-mean(a))-(c-mean(c));	%std:  237Pa
%signald=(a-mean(a))-(d'-mean(d));	%std: 1375Pa


