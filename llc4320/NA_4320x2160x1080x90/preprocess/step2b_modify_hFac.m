%load in step1 llc270aste output, expand and interp to 106k
clear all;

%get indices:
define_indices;

%set directory
set_directory;

dirIn  = dirOBCS;
dirOut = dirIn;

% load drF
rC0  =   (squeeze(rdmds([dirGrid0    'RC'])));
rC   =   (squeeze(rdmds([dirGrid_rF  'RC'])));
rF0  =   (squeeze(rdmds([dirGrid0    'RF'])));
rF   =   (squeeze(rdmds([dirGrid_rF  'RF'])));
drF0 =   (squeeze(rdmds([dirGrid0    'DRF'])));  nz0=length(drF0);
drF  =   (squeeze(rdmds([dirGrid_rF  'DRF'])));  nz =length(drF);

% load step 0 obcs structures
fIn0=[dirIn 'step1_obcs_' datestamp '.mat'];load(fIn0,'obcs0','T0','S0','U0','V0');

% load step 2a obcs structure:
fIn  =[dirOut 'step2a_obcs_' datestamp '.mat'];load(fIn);	%U,V,T,S,obcs

%define output file: 
fsave=[dirOut 'step2b_obcs_' datestamp '.mat'];

%calculating hFac using updated bathy:
hFacMin=0.2;
hFacMinDr=5.;
%hFacMin=0;
%hFacMinDr=0.1;

%define last obcs:
obcs2=obcs;
obcsstr='NSEW';
obcstype=[1 2 3 4];
obcsvelstr={'V','V','U','U'};
obcshfstr ={'S','S','W','W'};
obcsdsstr ={'x','x','y','y'};
obcsvelnulstr={'U','U','V','V'};

for iobcs=1:size(obcs,2);

  itype=find(obcsstr==obcs{iobcs}.obcsstr);
  velstr=obcsvelstr{itype};
  hfstr =obcshfstr{itype};
  dsstr =obcsdsstr{itype};
  velnulstr=obcsvelnulstr{itype};

%first, test that we can reproduce hf in obcs0:
  bathyo=obcs0{iobcs}.D1;  hfo    =obcs0{iobcs}.hfC1;
  [bathyop,hfop]=calc_hFacC(-abs(bathyo),hFacMin,hFacMinDr,drF0,rF0);	%1=ocean, 0=land
  tmp=bathyo-abs(bathyop);fprintf('%g %g\n',[sum(tmp) mean(tmp)]);	%[-6.6e-11  -2.4e-13]
  tmp=hfop-hfo;          ;fprintf('%g %g\n',[sum(tmp(:)) mean(tmp(:))]);%-7.03326e-14 -5.20982e-18

%note: yes, it works above because we're using drF0 , as soon as we switch to drF, 
%      the bathy obcs{iobcs}.D[1,2] will *NOT* give obcs{iobcs}.hfC[1,2].
%So, the steps below are:
% 1. Use obcs.D[1,2] to calculate what the hfC[1,2]intermediate would be
% 2. Because hfC[1,2]intermediate is not the same has hfC[1,2]old, we need to
%    remove extra ocean; This step will produce a new bathyn.
% 3. use this bathy_new to calculate the final hfC[1,2]new

%old bathy and hfacC
%1st/2nd wet pt
  for istr=1:2;

    istrp=num2str(istr);

%step 1: calculate intermediate hf[1,2] based on bathyo[1,2], which we expect to be different from hfo[1,2]
%        here, bathyo[1,2]p is not really used.  We're only interested in hf[1,2]

    eval(['bathyo' istrp ' = obcs{iobcs}.D'   istrp ';']);	%bathyo[1,2]=obcs{iobcs}.D[1,2]
%note hfo[1,2] ends up equal to hf[1,2] because it was calc using also calc_hFacC and obcs{iobcs}.D[1,2]
    eval(['hfo'    istrp ' = obcs{iobcs}.hfC' istrp ';']);      %   hfo[1,2]=obcs{iobcs}.hfC[1,2]
    eval(['[bathyo' istrp 'p,hf' istrp ']=calc_hFacC(-abs(bathyo' istrp '),hFacMin,hFacMinDr,drF,rF);']);%1=ocean, 0=land
    clear tmpa tmpb 
    eval(['tmpb=hfo'    istrp '-hf'         istrp ';']);
    fprintf(' before: iobcs, wetcell, mean resid hfo: %i %i %g\n',[iobcs istr mean(tmpb(:))]);%[1 [1,2] 0] <-- hfo1=hf1;

%step2: remove extra ocean to get the intermediate bathyn[1,2]: bathyn[1,2] should be identical to D[1,2]
    eval(['bathyn' istrp ' = remove_extra_ocean_hFacC(abs(bathyo' istrp 'p),hfo' istrp ',hf' istrp ',hFacMin,hFacMinDr,drF,abs(rF));']);%bathyn[1,2] identical to bathyo[1,2]p

%step4: use intermediate bathyn[1,2] to get final bathyn[1,2]p and hfa[1,2].
%       It is most likely that bathyn[1,2]p will differ from bathyn[1,2] even though we
%       modified it such that supposedly it would match with [hFacMin,hFacMinDr] to give us
%       the desired bathy.  As a result, the final values should be: hfa[1,2] and bathyn[1,2]p
%Can view them afteward, but there is no tests we can do here because we're getting totally different bathy and hf
    %bathyn[1,2]p identical to bathyn[1,2], to within precision of 10^-4: mean(bathyn1+bathyn1p) = -2.8755e-05
    eval(['[bathyn' istrp 'p,hfa' istrp ']=calc_hFacC(-abs(bathyn' istrp '),hFacMin,hFacMinDr,drF,rF);']);%1=ocean, 0=land   
  end;

%some final checking, if there's any inconsistencies, e.g., we still have "new" ocean here,
% will need to go back to modify  remove_extra_ocean_hFacC to take care of it.
  [iz,ix]=meshgrid(1:size(hfa1,2),1:size(hfa1,1));
  tmp=hf1-hfo1;
  ii=find(tmp(:)>0 & hfo1(:)==0);                                       %point of "new" ocean
  jj=find(tmp(:)>0 & hfo1(:)>0);                                        %point where new drF yields more fraction
  kk=find(tmp(:)<0 & hfo1(:)>=0);                                       %point where new drF yeilds less fraction, OK
  tmp=hfa1-hfo1;
  llp=find(tmp(:)>0 & hfo1(:)==0);                                       %point of "new" ocean
  mm=find(tmp(:)>0 & hfo1(:)>0);                                        %point where new drF yields more fraction
  nn=find(tmp(:)<0 & hfo1(:)>=0);                                       %point where new drF yields more fraction

%now compare old and new hf[W,S] to make sure there is no "new" ocean hole
  hfvel1n=cat(3,hfa1,hfa2);hfvel1n=min(hfvel1n,[],3);
  eval(['hfvel1=obcs{iobcs}.hf' hfstr ';']);
  tmp=hfvel1n-hfvel1;
  oo=find(tmp(:)>0 & hfvel1(:)==0);                                     %points of "new" ocean, need plug
  pp=find(tmp(:)>0 & hfvel1(:)>0);                                      %points of new more fraction, OK
  qq=find(tmp(:)<0 & hfvel1(:)>=0);                                     %points of new less fraction, OK
  fprintf('\n new ocean, need plug: %i %i %i\n',[length(ii) length(llp) length(oo)]);
  fprintf('new ocean where new drF yields more fraction, OK: %i %i %i\n',[length(jj) length(mm) length(pp)]);
  fprintf('new ocean where new drF yields less fraction, OK: %i %i %i\n',[length(kk) length(nn) length(qq)]);

% iobcs=1: new ocean, need plug: 0 0 0 <-- yes! because the original hf was calc using calc_hFac
%new ocean where new drF yields more fraction, OK: 0 352 344
%new ocean where new drF yields less fraction, OK: 0 220 224

  if(length(oo)>0);
    fprintf('there is new ocean in hf %s ',obcs{iobcs}.obcsstr);
  end;

%if thincolorbar (old matlab, before 2015) doesn't work, switch to colorbar (new matlab)
  figure(iobcs);clf;colormap(jet(20));
    subplot(331);mypcolor(hfo1');mythincolorbar;grid;title('hfo1 - using calc\_hFac');
    subplot(332);mypcolor(hf1');mythincolorbar;grid;title('hf1 - get from new drF');
    subplot(333);mypcolor(hf1'-hfo1');mythincolorbar;grid;title('hf1-hfo1');
     hold on;plot(ix(ii),iz(ii),'b.');plot(ix(jj),iz(jj),'.','color',.7.*[1 1 1]);plot(ix(kk),iz(kk),'k.');hold off;
    subplot(334);mypcolor(hfa1');mythincolorbar;grid;title('hfa1; new hfa to remove new ocean');
    subplot(336);mypcolor(hfa1'-hfo1');mythincolorbar;grid;title('hfa1-hfo1, expect <=0');
     hold on;plot(ix(llp),iz(llp),'b.');plot(ix(mm),iz(mm),'.','color',.7.*[1 1 1]);plot(ix(nn),iz(nn),'k.');hold off;
    subplot(337);mypcolor(hfvel1');mythincolorbar;grid;title('original hf[S,W]');
    subplot(338);mypcolor(hfvel1n');mythincolorbar;grid;title('new hf[S,W]');
    subplot(339);mypcolor(hfvel1n'-hfvel1');grid;mythincolorbar;title('new minus old, want to be <0');
     hold on;plot(ix(oo),iz(oo),'m.');plot(ix(pp),iz(pp),'.','color',.7.*[1 1 1]);plot(ix(qq),iz(qq),'k.');hold off;
    set(gcf,'paperunits','inches','paperposition',[0 0 13 7]);
    fpr=[dirOut 'figure01_step02b_iobcs' num2str(iobcs) '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);

%compute transport: what are we comparing?  
%It is best to always simply compare with parent grid's transports because there we have exact values.
%However, if we want to compare to child grid via interpolation, the tests above already indicate
%this is also conserved.  Thus, can compare either (a) or (b) with (c): 
% (a) [U,V]0, obcs0.d[x,y]0, drF0, obcs0.hf[W,S] , or
% (b) [U,V] , obcs.d[x,y]  , drF , obcs.hf[W,S] , obcs.scale[X,Y]  (<--- don't forget scale factors!!)
% (c) [U,V] , obcs.d[x,y]  , drF , mean(hf[1,2]), obcs.scale[X,Y] 
% in order to arrive at a new set of scaled [U,V]_final

%****** IMPORTANT *******
% should check if any bogus points outside the domain have been removed from hfac so that we get a true transport,
% e.g., if somehow the Pacific is still present in Southern Atlantic, or Gulf of Mexico, which later was blanked
% out in bathy but left unattended here.  This will cause bogus balancing of tranps.

clear hfvel0 ds0 vel0 hfvel1 ds1 vel1 scale1 sz tr0 tr1 tr1n scalen

%parent grid:
  eval(['hfvel0=obcs0{iobcs}.hf' hfstr ';']);
  eval(['ds0   =obcs0{iobcs}.d' dsstr 'g;']);
  eval(['vel0  =' velstr '0{iobcs};']);

%
  eval(['hfvel1=obcs{iobcs}.hf' hfstr ';']);
  eval(['ds1   =obcs{iobcs}.d' dsstr 'g;']);
  eval(['vel1  =' velstr '{iobcs};']);
  eval(['scale1=obcs2{iobcs}.scale' upper(dsstr) ';']);			%size [1 nx]
  sz=size(vel1);
  scale1=repmat(scale1',[1 sz(2) sz(3)]);				%[nx nz nt]

  tr0 =compute_gate_transport(vel0,ds0,drF0,hfvel0);
  tr1 =compute_gate_transport(vel1.*scale1,ds1,drF ,hfvel1);
  tr1n=compute_gate_transport(vel1.*scale1,ds1,drF ,hfvel1n);

%take ratio
  scalen=tr1./tr1n;	%size [1 nt], should be 1: YES!			%ratio old transport / new transport

%saving:
  eval(['obcs2{iobcs}.scale' upper(dsstr) 'n=scalen;']);		%saving ratio to scale[X,Y]n, size [1 nt]
%here we're saving velocity that are already scaled. So if want to conserve relative to original hf, 
%need to divide by scalen

  clear tmp;tmp=repmat(scalen',[1 sz(1) sz(2)]);tmp=permute(tmp,[2 3 1]);%[nx nz nt]
  fprintf('obcs2{iobcs}.%c=%c{iobcs}.*scale1.*tmp;\n',[velstr velstr]);
  fprintf('obcs2{iobcs}.%c=0.*obcs2{iobcs}.%c;\n',[velnulstr velstr]);
  eval(['obcs2{iobcs}.' velstr '=' velstr '{iobcs}.*scale1.*tmp;']);clear tmp;
  eval(['obcs2{iobcs}.' velnulstr '=0.*obcs2{iobcs}.' velstr ';']);	%zeroing out the tangential component
  obcs2{iobcs}.T =T{iobcs};
  obcs2{iobcs}.S =S{iobcs};
  obcs2{iobcs}.D1=bathyn1;
  obcs2{iobcs}.D2=bathyn2;
  obcs2{iobcs}.hfC1=hfa1;
  obcs2{iobcs}.hfC2=hfa2;
  fprintf('obcs2{iobcs}.hf%c=hfvel1;\n',hfstr);
  eval(['obcs2{iobcs}.hf' hfstr '=hfvel1;']);%n;']);

  obcs2{iobcs}.D1_o=bathyo1;			%saving old bathy as well
  obcs2{iobcs}.D2_o=bathyo2;
  obcs2{iobcs}.hfC1_o=hfo1;			%saving old hfac for the purpose of conservation
  obcs2{iobcs}.hfC2_o=hfo2;
  eval(['obcs2{iobcs}.hf' hfstr '_o=hfvel1;']);	%saving old hfac[S,W] for purpose of recalculation of conservation
  fprintf('obcs2{iobcs}.hf %s _o=hfvel1;\n',hfstr);

%now compute the last transport, make sure it matches with tr0 and tr1, especially b/c we're taking the ratio to tr1:
  clear vel2 hf ds
  eval(['vel2=obcs2{iobcs}.' velstr ';']);
  eval(['hf  =obcs2{iobcs}.hf' hfstr ';']);
  eval(['ds  =obcs2{iobcs}.d' dsstr 'g;']);
  tr2=compute_gate_transport(vel2,ds,drF,hf);

  figure(iobcs+length(obcs));clf;
             subplot(411);plot(tr0,'-');hold on;plot(tr1,'r-');plot(tr1n,'g-');plot(tr2,'m');hold off;grid;
             title([num2str(iobcs) ':' obcs2{iobcs}.name '; b:tr270; r:tr\_90lev, g:tr\_90lev\_hf, m:tr\_90lev\_hfbl']);
  a=tr0 -tr1;subplot(412);plot(a,'-');grid;
             title([num2str(sum(a)) ',' num2str(mean(a)) '; tr270 - tr\_90lev, nonconserved']);
  a=tr1n-tr1;subplot(413);plot(a,'-');grid;
             title([num2str(sum(a)) ',' num2str(mean(a)) '; tr\_90lev - tr\_90lev\_hf, conserved']);
  a=tr2 -tr1;subplot(414);plot(a,'-');grid;
             title([num2str(sum(a)) ',' num2str(mean(a)) '; tr\_90lev\_fixed\_scaled - tr\_90lev\_hf, conserved']);

  set(gcf,'paperunits','inches','paperposition',[0 0 8 10]);
  fpr=[dirOut 'figure02_step02b_iobcs' num2str(iobcs) '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);

end;

save(fsave,'obcs2','-v7.3');fprintf('%s\n',fsave);

obcs_balance=1;
if(obcs_balance==1);

  drF=abs(squeeze(rdmds([dirGrid_rF 'DRF'])));
%South Atlantic:
  i=1;f1S=compute_gate_transport(obcs2{i}.V,obcs2{i}.dxg,drF',obcs2{i}.hfS);
  j=3;f5E=compute_gate_transport(obcs2{j}.U,obcs2{j}.dyg,drF',obcs2{j}.hfW);
%North Atlantic
  i=2;f1N=compute_gate_transport(obcs2{i}.V,obcs2{i}.dxg,drF',obcs2{i}.hfS);
  j=4;f5W=compute_gate_transport(obcs2{j}.U,obcs2{j}.dyg,drF',obcs2{j}.hfW);
%GibraltarStrait
  j=5;f1E=compute_gate_transport(obcs2{j}.U,obcs2{j}.dyg,drF',obcs2{j}.hfW);

%computing incoming:
%South Atlantic, positive into domain
  fSA=f1S-f5E;
%North Atlantic, positive into domain
  fNA=-f1N+f5W;
%GibraltarStrait, positive into domain
  fGi=-f1E;

  figure(1);clf;colormap(seismic(21));
  %subplot(321);j=5;mypcolor(1:nfy(1),-[1:nz],-mean(obcs2{j}.U,3)');ccp=max(abs(caxis));caxis([-ccp ccp]);
  %                 mythincolorbar;title('face1 Gibraltar, +=intoMediter');grid;
  %                 ii=find(obcs{j}.imask==1);set(gca,'Xlim',[ii(1)-5 ii(end)+5]);% -32 -1]);
  subplot(322);i=1;mypcolor(1:ncut1,-[1:nz], mean(obcs2{i}.V,3)');ccp=max(abs(caxis));caxis([-ccp ccp]);
		   mythincolorbar;grid;title('face1S, + =northward');
  subplot(323);j=3;mypcolor(1:ncut1,-[1:nz],-mean(obcs2{j}.U,3)');ccp=0.05.*max(abs(caxis));caxis([-ccp ccp]);
		   mythincolorbar;title('face5E, + = northward');
  subplot(324);j=2;mypcolor(1:ncut1,-[1:nz],-mean(obcs2{j}.V,3)');ccp=max(abs(caxis));caxis([-ccp ccp]);
                   mythincolorbar;title('face1N , +=S');grid;
  subplot(321);j=4;mypcolor(1:ncut1,-[1:nz], mean(obcs2{j}.U,3)');ccp=max(abs(caxis));caxis([-ccp ccp]);
                   mythincolorbar;title('face5W , +=S');grid;
  nt=size(f1S);nt=nt(2);
  subplot(349);plot(1:nt,fSA,'b-',1:nt,fGi,'g-',1:nt,fNA,'r-');grid;legend('fSA','fGi','fNA');
  %subplot(3,4,10);plot(f15,'b-');hold on;plot(-f4,'r');grid;legend('f15','f4');

  imbl = fSA+fNA+fGi;				%1 x 168
  nt = max(size(imbl));
  subplot(3,4,10);plot(1:nt,imbl,'b-');grid;title('imbalance');

%which face to add to?? face4 is easiest because it's only 1 face.  However, it is RIGHT at the Bering Strait,
%adding a net here would significantly change the flux.  If add to f15, will just have to make sure ration
%properly across the faces

  iobcs1S=1;	iobcs5E=3;
  iobcs1N=2;	iobcs5W=4;	iobcsGi=5;
  A1S=drF*obcs2{iobcs1S}.dxg;A1S=A1S'.*obcs2{iobcs1S}.hfS;%[2160 x 90]
  A1N=drF*obcs2{iobcs1N}.dxg;A1N=A1N'.*obcs2{iobcs1N}.hfS;%[2160 x 90]
  A5E=drF*obcs2{iobcs5E}.dyg;A5E=A5E'.*obcs2{iobcs5E}.hfW;%[2160 x 90]
  A1E=drF*obcs2{iobcsGi}.dyg;A1E=A1E'.*obcs2{iobcsGi}.hfW;%[2160 x 90]
  A5W=drF*obcs2{iobcs5W}.dyg;A5W=A5W'.*obcs2{iobcs5W}.hfW;%[2160 x 90]
  A15S=cat(1,A5E,A1S);			   %[4320 x 90];
%  A15=A1;
  
  dvel=imbl./sum(A15S(:));

  obcs2{iobcs1S}.dV =  repmat(dvel',[1 ncut1 nz]);obcs2{iobcs1S}.dV=permute(obcs2{iobcs1S}.dV,[2 3 1]);
  obcs2{iobcs5E}.dU = -repmat(dvel',[1 ncut1,nz]);obcs2{iobcs5E}.dU=permute(obcs2{iobcs5E}.dU,[2 3 1]);
  obcs2{iobcs5W}.dU = zeros(size(obcs2{iobcs5W}.U));
  obcs2{iobcs1N}.dV = zeros(size(obcs2{iobcs1N}.V));

%South Atlantic
  f1Sbl=compute_gate_transport(obcs2{iobcs1S}.V-obcs2{iobcs1S}.dV,obcs2{iobcs1S}.dxg,drF',obcs2{iobcs1S}.hfS);
  f5Ebl=compute_gate_transport(obcs2{iobcs5E}.U-obcs2{iobcs5E}.dU,obcs2{iobcs5E}.dyg,drF',obcs2{iobcs5E}.hfW);
%North Atlantic
  f1Nbl=compute_gate_transport(obcs2{iobcs1N}.V-obcs2{iobcs1N}.dV,obcs2{iobcs1N}.dxg,drF',obcs2{iobcs1N}.hfS);
  f5Wbl=compute_gate_transport(obcs2{iobcs5W}.U-obcs2{iobcs5W}.dU,obcs2{iobcs5W}.dyg,drF',obcs2{iobcs5W}.hfW);

  fSAbl=f1Sbl-f5Ebl;
  resid=fSAbl+(f5Wbl-f1Nbl)+(fGi);
  subplot(3,4,11);plot(f1Sbl-f1S,'b-');grid;hold on;plot(-f5Ebl+f5E,'r-');hold off;legend('f1Sbl-f1S','f5Ebl-f5E');
  subplot(3,4,12);plot(resid,'b-');grid;title(num2str(sum(resid)));legend('resid');%,'imbl');hold on;plot(imbl,'r-');
  %subplot(323);mypcolor(1:nx,-[1:nz],-mean(obcs2{iobcs5E}.U-obcs2{iobcs5E}.dU,3)');grid;
% 	cc1=max(abs(caxis));caxis([-cc1 cc1]);title('face5Ebl, + = northward');
  %subplot(324);mypcolor(1:nx,-[1:nz],mean(obcs2{iobcs1S}.V-obcs2{iobcs1S}.dV,3)');
%	cc1=max(abs(caxis));caxis([-cc1 cc1]);mythincolorbar;grid;title('face1Sbl, + =northward');
  set(gcf,'paperunits','inches','paperposition',[0 0 15 8]);
  fpr=[dirOut 'figure02_step02b_bl' '.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);

%updating vel to include balancing correction

  obcs2{iobcs5E}.U=obcs2{iobcs5E}.U-obcs2{iobcs5E}.dU;
  obcs2{iobcs1S}.V=obcs2{iobcs1S}.V-obcs2{iobcs1S}.dV;

  fsave_bl=[dirOut 'step2b_obcs_' datestamp '_bl.mat'];
  save(fsave_bl,'obcs2','-v7.3');fprintf('%s\n',fsave_bl);

end
