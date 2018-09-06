%after 1 run, mdt misfits are huge near lands, likely interpolation problem
%between lowres and hires landmask.
%now create a mask in err to mask these points out, choose 5 points away from coast

clear all;
nx=1080;ny=2*1260+540+nx;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];
dirRoot='/scratch/atnguyen/aste_1080x1260x540x90/';
dirIn=[dirRoot 'run_obcs_prof2_ctrl_kpp_ecco_debug_smx9_mdsio4_it0000_pk0000000004/'];

%c=readbin([dirIn 'misfits_mdt.data'],[nx ny]);
mdte=readbin([dirRoot 'run_template/input_mdt/mdt_dtu13_error_m_areascaled_fill9iU42Ef_noStLA.bin'],[nx ny]);
hf=readbin([dirIn 'hFacC.data'],[nx ny]);hf(find(hf<1))=0;

%ca=get_aste_tracer(c,nfx,nfy);
hfa=get_aste_tracer(hf,nfx,nfy);
mdte_a=get_aste_tracer(mdte,nfx,nfy);

mdte_a_cap=mdte_a;

%mask out land
mdte_a_cap(find(hfa==0))=0;

%find coast
num_grid_coast=12;
icoast=locate_coast(hfa,num_grid_coast);

mdte_a_cap(find(icoast>0))=0;	%yes! perfect, now max is 90 in Okhost Sea

%now, just need to mask out Okhost Sea
%ix=992*2-1:2*nx*2;iy=1378*2-1:1520*2;mdte_a_cap(ix,iy)=0;
%ix=960*2-1:992*2;iy=1378*2-1:1439*2;mdte_a_cap(ix,iy)=0;
%ix=950*2-1:960*2;iy=1378*2-1:1405*2;mdte_a_cap(ix,iy)=0;
%%yes! now max is only < 35

%now check out
msk=ones(size(mdte_a_cap));
msk(find(mdte_a_cap==0))=0;

%figure(1);clf;mypcolor(ca'.*msk');colorbar;grid;shadeland(1:2*nx,1:720+360+nx,1-hfa',[.7 .7 .7]);
figure(1);clf;mypcolor(mdte_a_cap'.*msk');colorbar;grid;shadeland(1:2*nx,1:1260+540+nx,1-hfa',[.7 .7 .7]);

mdte_c=aste_tracer2compact(mdte_a_cap,nfx,nfy);
fOut=[dirRoot 'run_template/input_mdt/mdt_dtu13_error_m_areascaled_maskedaste1080.bin'];
writebin(fOut,mdte_c,1,'real*4');

