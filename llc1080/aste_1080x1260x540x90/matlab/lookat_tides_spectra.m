clear all;
dirRoot='/scratch/atnguyen/aste_1080x1260x540x90/';
%dirRun=[dirRoot 'run_tides_it0000_pk0000010800/diags/'];
dirRun=[dirRoot 'run_tides_it0000_pk0000032041/'];
dirGrid=[dirRoot 'GRID/'];
dirOut=[dirRun 'matlab/'];if(~exist(dirOut));mkdir(dirOut);end;

nx=1080;ny=1260*2+540+nx;
ix=[ 303, 263, 391, 736, 272];
iy=[1775,1775,1448,1457, 564];
str_b={'Yermak','Yermak','Barents','Nansen','N.Atlantic'};

xc=readbin([dirGrid 'XC.data'],[nx ny]);   for j=1:length(ix);xc1(j)=xc(ix(j),iy(j));end;
yc=readbin([dirGrid 'YC.data'],[nx ny]);   for j=1:length(ix);yc1(j)=yc(ix(j),iy(j));end;
D =readbin([dirGrid 'Depth.data'],[nx ny]);for j=1:length(ix);D1(j) =D(ix(j) ,iy(j));end;

%SSH, need both SIheff and SIhsnow to correct for ETAN, but missing SIhsnow for now

fsave=[dirOut 'spectra_3mo.mat'];

if(~exist(fsave));
  flist=dir([dirRun 'diags/STATE/state_2d_set1.*.data']);
  idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
  tt=zeros(length(flist),6);
  
  ice2wtr=0.8856;snow2wtr=0.3212;
  ssh=zeros(length(flist),length(ix));
  sih=zeros(length(flist),length(ix));
  sia=zeros(length(flist),length(ix));
  for i=1:length(flist);
    ts=str2num(flist(i).name(idot));
    tmp=datevec(ts2dte(ts,240,2002,1,1));
    tt(i,1:4)=tmp(1:4);tt(i,5)=ts;tt(i,6)=datenum(tmp);
    eta=read_slice([dirRun 'diags/STATE/' flist(i).name],nx,ny,1);	%ETAN
    siarea=read_slice([dirRun 'diags/STATE/' flist(i).name],nx,ny,2);	%SIarea
    siheff=read_slice([dirRun 'diags/STATE/' flist(i).name],nx,ny,3);	%SIheff
    eta=eta+(ice2wtr.*siheff+0);%snow2wtr.*sis).*hfacm;
    for j=1:length(ix);
      ssh(i,j)=eta(ix(j),iy(j));
      sia(i,j)=siarea(ix(j),iy(j));
      sih(i,j)=siheff(ix(j),iy(j));
    end;
  
    if(mod(i,24*5)==0);fprintf('%i ',i);end;
  end
  save(fsave,'ssh','sia','sih','tt');
else
  load(fsave);%ssh, sia, sih, tt
end;

ps={  'M2','S2', 'N2',   'K2',   'K1',   'O1',   'P1',   'Q1',   'Mf',   'Mm','m4','ms4','mn4'};
pp=[12.4206 12 12.6583 11.9672 23.9345 25.8193 24.0659 26.8684 327.8599 661.31 6.21 6.10 6.27];

figure(2);clf;
for j=1:length(ix);

  sshp=ssh(:,j)-mean(ssh(:,j));
  [Pw,fw]=pmtm(sshp);

  subplot(3,2,j);
  loglog(1./(fw./(2*pi)),Pw.*(2*pi).^2,'.-');grid;hold on;
  for i=1:length(pp);
    loglog([pp(i) pp(i)],[1e-7 1e2],'r-');%,'linewidth',2);
    text(pp(i),10^(-7.5),ps{i});
  end;
  hold off;axis([0 4100 1e-8 500]);%tight;
  xlabel('period (hour)');ylabel('power');
  str=[str_b{j} '; (i,j)=(' num2str(ix(j)) ',' num2str(iy(j)) '); [lon,lat]=[' ...
        num2str(xc1(j),3) ',' num2str(yc1(j),3) ']; z = ' num2str(D1(j),4) 'm'];
  title(str);
end;

set(gcf,'paperunits','inches','paperposition',[0 0 18 12]);
fpr=[dirOut 'spectra_3mo.png'];
keyboard;
saveas(gcf,fpr,'png');

