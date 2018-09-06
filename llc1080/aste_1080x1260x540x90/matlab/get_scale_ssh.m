clear all
dirGrid='/scratch/atnguyen/llc1080/global/GRID_noblank/';
dirOut='/scratch/atnguyen/aste_1080x1260x540x90/run_template/input_rads/';
nx=1080;ny=2*1260+540+nx;
nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

dx=readbin([dirGrid 'DXC.data'],[nx nx*13]);%dx=get_aste_tracer(dx,nfx,nfy);dx=aste_tracer2compact(dx,nfx,nfy);
dy=readbin([dirGrid 'DYC.data'],[nx nx*13]);%dy=get_aste_tracer(dy,nfx,nfy);dy=aste_tracer2compact(dy,nfx,nfy);

fac=3;%fac=9;3;
dxy=(dx+dy)./2;
sc0=fac.*dxy;
%f0=[dirOut 'sshv4_scale_' num2str(fac) 'points.bin'];writebin(f0,sc0,1,'real*4');fprintf('%s\n',f0);
sc0=get_aste_tracer(sc0,nfx,nfy);sc0=aste_tracer2compact(sc0,nfx,nfy);
f0=[dirOut 'sshv4_scale_' num2str(fac) 'points.bin'];writebin(f0,sc0,1,'real*4');fprintf('%s\n',f0);

%fac1=4.5;%1.5;
%fac1str=num2str(fac1);%*10);fac1str=[fac1str(1) 'p' fac1str(2)];
%sc1=fac1.*dxy;
%%f1=[dirOut 'sshv4_scale_' fac1str 'points.bin'];writebin(f1,sc1,1,'real*4');fprintf('%s\n',f1);
%sc1=get_aste_tracer(sc1,nfx,nfy);sc1=aste_tracer2compact(sc1,nfx,nfy);
%f1=[dirOut 'sshv4_scale_' fac1str 'points.bin'];writebin(f1,sc1,1,'real*4');fprintf('%s\n',f1);

