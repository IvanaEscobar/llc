clear all;
nx=1080;ny=1260*2+nx+540;nz=90;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

i3=1:nfx(3);
j3=nfy(1)+1:nfy(1)+nfy(3);
nz1=80;				%printed out only 80 vertical lev

ix=116:515;Lx=length(ix);	%400
jy=171:600;Ly=length(jy);	%430
nz2=76;				%just need 76 vert lev to 3500m for now

use_method=0;			%0=read slice 1= full file

dirScratch='/scratch/03901/atnguyen/aste_1080x1260x540x90/';
dirWork='/work/03901/atnguyen/MITgcm_c67/mysetups/aste_1080x1260x540x90/';
dirGrid='/work/03901/atnguyen/llc1080/aste_1080x1260x540x90/GRID/';
RunStr='run_tides_it0000_pk0001270800';
dirRun=[dirWork RunStr '/'];if(~exist(dirRun));error('dirRun does not exist');end;
dirOut=[dirRun 'GRID_EArctic/'];if(~exist(dirOut));mkdir(dirOut);end;

var3D={'hFacC','hFacW','hFacS'};
var2D={'RAC','XC','YC','XG','YG','DXG','DYG','DXC','DYC','AngleCS','AngleSN','Depth','RAS','RAW','RAZ'};

for iloop=2:2;
  if(iloop==1);vv=var3D;else;vv=var2D;end;
  for ivar=13:size(vv,2);

    fprintf('%s ',vv{ivar});

    tmp=dir([dirGrid vv{ivar} '.data']);
    nz=tmp.bytes/nx/ny/4;

    fOut=[dirOut vv{ivar} '.data'];

    aout=zeros(Lx,Ly,nz);
    tmp=readbin([dirGrid vv{ivar} '.data'],[nx,ny,nz]);
    tmp=tmp(i3,j3,:);
    aout=tmp(ix,jy,:);

    writebin(fOut,aout,1,'real*4');

  end;ivar
  fprintf('\n');
 
end;%iloop

