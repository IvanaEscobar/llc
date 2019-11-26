clear all;

clearfig=input('clearfig? [1=yes,0=no] ');
if(clearfig==0);colc=input('color? [default is blue, "bgmc"] ');if(isempty(colc)==1);colc='b';end;end;

ext=input('Extension ["_ad"] for ad: ');
dirRoot=['/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90/' ];
RunStr=input('RunStr ["run21"] ');yrStart=2002;dt=30;
clear fname;fname=input('filename? "STDOUT.0000=default" or "stdout.pk2232" etc: ');
if(length(fname)==0);fname='STDOUT.0000';end;
filein=[dirRoot RunStr '/' fname];
dirOut=[dirRoot RunStr '/matlab/'];if(exist(dirOut)==0);mkdir(dirOut);end;

%%ff={'time\_tsnumber',
ff={'ke\_max','dynstat\_eta\_max','dynstat\_eta\_mean',...
    'dynstat\_uvel\_max','dynstat\_uvel\_min','dynstat\_vvel\_max','dynstat\_vvel\_min',...
    'dynstat\_wvel\_max','dynstat\_wvel\_min','dynstat\_theta\_mean','dynstat\_theta\_min',...
    'dynstat\_salt\_mean','dynstat\_salt\_min','advcfl\_uvel\_max','advcfl\_vvel\_max','advcfl\_wvel\_max'};
%%
vals3D=mitgcmhistory(filein,... %'time_tsnumber',...
                   'ke_max','dynstat_eta_max','dynstat_eta_mean',...
                   'dynstat_uvel_max','dynstat_uvel_min','dynstat_vvel_max','dynstat_vvel_min',...
                   'dynstat_wvel_max','dynstat_wvel_min','dynstat_theta_mean','dynstat_theta_min',...
                   'dynstat_salt_mean','dynstat_salt_min','advcfl_uvel_max','advcfl_vvel_max','advcfl_wvel_max');

ts=mitgcmhistory(filein,'time_tsnumber');ts=ts(1:size(vals3D,1));
t2d=ts.*dt/3600/24/365.25+yrStart;
t3d=ts.*dt/3600/24/365.25+yrStart;

%t2d=vals2D(:,1).*dt/3600/24/365.25+yrStart;
%t3d=vals3D(:,1).*dt/3600/24/365.25+yrStart;

%figure(1);
%if(clearfig==1);clf;colc='r';linestyle='-';else;linestyle='--';end;
%for k=1:size(ff2D,2);subplot(4,4,k);
%  if(clearfig==0);hold on;end;
%  plot(t2d,vals2D(:,k),linestyle,'color',colc);
%  if(clearfig==1);grid;else;hold off;end;
%  title(vals2D{k},'interpreter','none');axis tight;
%end;
%fpr=[dirRoot RunStr '/matlab/stdout_seaice.png'];
%set(gcf,'paperunits','inches','paperposition',[0 0 9 7]);print(fpr,'-dpng');

figure(2);
if(clearfig==1);clf;colc='r';linestyle='-';else;linestyle='-';end;
for k=1:16;subplot(4,4,k);
  if(clearfig==0);hold on;end;
  plot(t3d,vals3D(:,k),linestyle,'color',colc);
  if(clearfig==1);grid;else;hold off;end;
  title(ff{k},'interpreter','none');axis tight;
end;
fpr=[dirRoot RunStr '/matlab/stdout_state.png'];
set(gcf,'paperunits','inches','paperposition',[0 0 18 14]);print(fpr,'-dpng');

