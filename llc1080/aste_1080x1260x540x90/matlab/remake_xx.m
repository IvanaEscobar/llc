%if restarting from a different pickup, re-calculating which record xx needs, then zeros out what's behind.

%but since we're running a short run, say 1 mo, it's not nesc to generate a very long record, 
%just long enough that ctrl vector won't run out by end of 1mo, so 5 rec is already enough


clear all;
nx=1080;ny=1260*2+540+nx;
dirRoot='/scratch/atnguyen/llc1080/aste_1080x1260x540x90/';
dirIn=[dirRoot 'output_ad/run_c65q_jra55_it0011_pk0000000002/'];
iter_in=11;

dt=240;dt_xx=1209600.;

t_pickup=32041;%21240;

nrec_start=ceil(t_pickup*dt/dt_xx);	%5 for 21240

nrec_total=nrec_start+10;		%add 10 records
L=nrec_total-nrec_start+1;
fprintf('[nrec_start nrec_total L]: %i %i %i\n',[nrec_start nrec_total L]);

a=zeros(nx,ny,nrec_total);
a(:,:,1:L)=...
 read_slice([dirIn 'ADXXfiles/xx_precip.' sprintf('%10.10i',iter_in) '.data'],nx,ny,nrec_start:nrec_total);

dirOut=[dirIn 'ADXXfiles_' sprintf('%10.10i',t_pickup) '_L' sprintf('%5.5i',nrec_total) '/'];
if(~exist(dirOut));mkdir(dirOut);end;
writebin([dirOut 'xx_precip.' sprintf('%10.10i',iter_in) '.data'],a,1,'real*4');


validating_pickup=0;
if(validating_pickup==1);
%validating: yes! it's w/in 10^-5 , which is the precision of state_2d_set1

  dirRoot='/scratch/atnguyen/aste_1080x1260x540x90/';
  dirIn0=[dirRoot 'run_tides_it0000_pk0000010800/diags/'];
  dirIn1=[dirRoot 'run_tides_it0000_pk0000021240/diags/'];
  nx=1080;ny=1260*2+540+nx;nfx=[nx 0 nx 540 1260];nfy=[1260 0 nx nx nx];

  hf=read_slice([dirRoot 'GRID/hFacC.data'],nx,ny,1);hf(find(hf>0))=1;ii=find(hf(:)>0);

  ts=21255:15:21600;
  aa=zeros(size(ts));

  for i=1:length(ts);
    tsstr=sprintf('%10.10i',ts(i));
    a=read_slice([dirIn0 'state_2d_set1.' tsstr '.data'],nx,ny,1);			%first is ETAN
    a1=read_slice([dirIn1 'state_2d_set1.' tsstr '.data'],nx,ny,1);
    tmp=a-a1;aa(i)=mean(tmp(ii));
    if(i==length(ts));
      figure(1);clf;colormap(bbmap);
      subplot(131);mypcolor(get_aste_tracer(a,nfx,nfy)');mythincolorbar;grid;
      subplot(132);mypcolor(get_aste_tracer(a1,nfx,nfy)');mythincolorbar;grid;
      subplot(133);mypcolor(get_aste_tracer(a-a1,nfx,nfy)');cc1=.05.*max(abs(caxis));caxis([-cc1 cc1]);mythincolorbar;grid;
    end;
  end;

  fprintf('%3.1e ',aa); %mean(aa): 3.2e-05
  %9.3e-07 3.1e-06 5.2e-06 7.5e-06 9.7e-06 1.2e-05 1.4e-05 1.7e-05 1.9e-05 2.2e-05 2.4e-05 2.7e-05 
  %3.0e-05 3.4e-05 3.7e-05 4.1e-05 4.5e-05 4.8e-05 5.2e-05 5.6e-05 6.0e-05 6.4e-05 6.8e-05 7.2e-05
end;
