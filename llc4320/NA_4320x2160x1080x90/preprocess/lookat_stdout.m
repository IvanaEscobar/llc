clear all;

clearfig=input('clearfig? [1=yes,0=no] ');
if(clearfig==0);colc=input('color? [default is blue, "bgmc"] ');if(isempty(colc)==1);colc='b';end;end;

%dirRoot='/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/output/';
%RunStr='bobLeithBasin5Piomas92bathyf3';%'bobLeithBasin4_llc90tsuv';
ext=input('Extension ["_ad"] for ad: ');
%dirRoot=['/net/nares/raid8/ecco-shared/llc270/aste_270x450x180/output' ext '/'];
%dirRoot=['/scratch/atnguyen/aste_540x720x360/'];
dirRoot=['/scratch/ivana/llc/llc4320/NA_4320x2160x1080x90/' ];
RunStr=input('RunStr ["run21"] ');yrStart=2002;dt=30;
clear fname;fname=input('filename? "STDOUT.0000=default" or "stdout.pk2232" etc: ');
if(length(fname)==0);fname='STDOUT.0000';end;
filein=[dirRoot RunStr '/' fname];
dirOut=[dirRoot RunStr '/matlab/'];if(exist(dirOut)==0);mkdir(dirOut);end;

%%ff2D={'seaice\_tsnumber',
%ff2D={'seaice\_uice\_min','seaice\_uice\_mean','seaice\_uice\_max','seaice\_uice\_sd',...
%      'seaice\_vice\_min','seaice\_vice\_mean','seaice\_vice\_max','seaice\_vice\_sd',...
%      'seaice\_heff\_max','seaice\_heff\_mean','seaice\_heff\_sd','seaice\_heff\_del2',...
%      'seaice\_hsnow\_mean','seaice\_hsnow\_mean','seaice\_hsnow\_sd','seaice\_hsnow\_del2'};

%vals2D=mitgcmhistory(filein,... %'seaice_tsnumber',...
%	'seaice_uice_min','seaice_uice_mean','seaice_uice_max','seaice_uice_sd',...
%     'seaice_vice_min','seaice_vice_mean','seaice_vice_max','seaice_vice_sd',...
%     'seaice_heff_max','seaice_heff_mean','seaice_heff_sd','seaice_heff_del2',...
%     'seaice_hsnow_mean','seaice_hsnow_mean','seaice_hsnow_sd','seaice_hsnow_del2');

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

