clear all;

dirRoot='/scratch/atnguyen/aste_1080x1260x540x90/';
RunStr={'run_tides_it0000_pk0000000004','run_tides_it0000_pk0000010800',...
        'run_tides_it0000_pk0000021240','run_tides_it0000_pk0000032041'};

dt=[300,240,240,240];
figure(1);clf;
cc1='brgmc';
for i=1:4;
  dirIn=[dirRoot RunStr{i} '/'];
  a=load([dirIn 'dynstat_eta_mean.txt']);
  ta=load([dirIn 'time_tsnumber.txt']);ta=ta.*dt(i)/3600/24/365.25;
  plot(ta,a,'-','color',cc1(1));hold on;
end;
hold off;grid;
ylabel('dynstat\_eta\_mean [m]');xlabel('yr');title('run\_tides');

%now load in old run to see how the drifts are:
dir1=[dirRoot '../+notuse/aste_1080x1440x540x90/run_obcs_prof2_ctrl_kpp_smx9_it0000_pk0000000004/'];
b=load([dir1 'dynstat_eta_mean.txt']);
tb=load([dir1 'time_tsnumber.txt']);tb=tb.*360/3600/24/365.25;
hold on;plot(tb,b,'k-');hold off;

dir1=[dirRoot '../+notuse/aste_1080x1440x540x90/run_obcs_prof2_ctrl_kpp_smx6_it0000_pk0000000004/'];
b=load([dir1 'dynstat_eta_mean.txt']);
tb=load([dir1 'time_tsnumber.txt']);tb=tb.*360/3600/24/365.25;
hold on;plot(tb,b,'-','color',.5.*[1 1 1]);hold off;

dir1=[dirRoot '../+notuse/aste_1080x1440x540x90/run_obcs_prof2_ctrl_kpp_pk0000000004/'];
b=load([dir1 'dynstat_eta_mean.txt']);
tb=load([dir1 'time_tsnumber.txt']);tb=tb.*360/3600/24/365.25;
hold on;plot(tb,b,'-','color',.7.*[1 1 1]);hold off;

dir1=['/scratch/atnguyen/aste_540x720x360/run_c65q_bp_varwei_diag_sal0sp_spvollead_blsm6xol4gm_it0000_pk0000000002/'];
c=load([dir1 'dynstat_eta_mean.txt']);
tc=load([dir1 'time_tsnumber.txt']);tc=tc.*720/3600/24/365.25;
hold on;plot(tc,c-c(1)+b(1),'-','color','m');hold off;

dir1=['/scratch/atnguyen/aste_540x720x360/run_c65q_bp_varwei_diag_sal0sp_spvollead_ublsm9xol4gm_it0000_pk0000000002/'];
c=load([dir1 'dynstat_eta_mean.txt']);
tc=load([dir1 'time_tsnumber.txt']);tc=tc.*720/3600/24/365.25;
hold on;plot(tc,c-c(1)+b(1),'-','color','g');hold off;

dir1='/scratch/atnguyen/aste_270x450x180/run_c65q_jra55_it0007_pk0000000002_rerunpk2yr/';
d=load([dir1 'dynstat_eta_mean_iter7rerunpk2yr.txt']);
td=load([dir1 'time_tsnumber.txt']);td=td.*1200/3600/24/365.25;ii=1:length(d);%find(td<=14);
hold on;plot(td(ii),d(ii)-d(1)+b(1),'-','color','r');hold off;

dir1='/scratch/atnguyen/aste_270x450x180/run_c65q_jra55_it0000_pk0000000002/';
clear d;d=load([dir1 'dynstat_eta_mean_iter0.txt']);
clear td ii;td=load([dir1 'time_tsnumber.txt']);td=td.*1200/3600/24/365.25;ii=find(td<=14);
hold on;plot(td(ii),d(ii)-d(1)+b(1),'-','color',[.5 0 0]);hold off;

dir2='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0000000004/';
f=load([dir2 'dynstat_eta_mean.txt']);
tf=load([dir2 'time_tsnumber.txt']);tf=tf.*240/3600/24/365.25;
hold on;plot(tf,f-f(1)+b(1),'-','color','c');hold off;
dir2='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0000065160/';
f=load([dir2 'dynstat_eta_mean.txt']);
tf=load([dir2 'time_tsnumber.txt']);tf=tf.*240/3600/24/365.25;
hold on;plot(tf,f-f(1)+b(1),'-','color','c');hold off;
dir2='/scratch/atnguyen/aste_1080x1260x540x90/run_notides_it0000_pk0001166400/';
g=load([dir2 'dynstat_eta_mean.txt']);
tg=load([dir2 'time_tsnumber.txt']);tg=tg.*240/3600/24/365.25;
ii=find(tg==tf(end));ii=ii(1):length(tg);
hold on;plot(tg(ii),g(ii)-g(ii(1))+b(1)+f(end),'-','color','c');hold off;

legend('tides','tides','tides','tides','blsmx9','blsmx6','blnosmooth','aste540blsm6xol4gm',...
       'aste540ublsm9xol4gm','aste270iter7bl','aste270iter0','ublnotidesjra55xx','location','northwest');

%dirOut=[dirRoot RunStr{end} '/'];
dirOut=[dirRoot 'run_notides_it0000_pk0001166400' '/'];
fpr=[dirOut 'dynstat_eta_mean.png'];
saveas(gcf,fpr,'png');

