clear all;

define_indices;
set_directory;

a0=readbin([dirGrid0 'bathy_fill9iU42Ef_noStLA.bin'],[nx0 ny0],1,'real*8');[a0,af0]=get_aste_tracer(a0,nfx0,nfy0);
idot=find(fBathyIn=='.');extBathy='';%'_v2';
a=readbin([fBathyIn(1:idot-1) extBathy '.bin'],[ncut1 ny]);[a,af]=get_aste_tracer(a,nfx,nfy);
load([dirOBCS 'step0_obcs_' datestamp '.mat']);	%obcs0 obcs

figure(1);clf;
iface=[1,5];
for i=1:length(iface);
  subplot(1,2,i);mypcolor(af{iface(i)}');caxis([-1e2 0]);mythincolorbar;
   title(['Face' num2str(iface(i))]);;
end;

obcstype='NSEW';

%ss=['^s^s^s^s^s'];
ss=['sssss'];
ss1=['^^^^^'];
cc=['cmcmcmcmcm'];

iloop=[0 0 0];
clear type face
figure(1);clf;
for iobcs=[1,2,size(obcs,2),3,4];%:size(obcs,2)-1];
  fprintf('%s\n',obcs{iobcs}.name);
  face(iobcs)=obcs{iobcs}.face;
  jface(iobcs)=find(iface==face(iobcs));
  type(iobcs)=obcs{iobcs}.obcstype;

  if(type(iobcs)>0);
  ii=find(obcs{iobcs}.imask>0);

  if(iloop(jface(iobcs))==0);
    subplot(1,2,jface(iobcs));
    mypcolor(af{face(iobcs)}');caxis([-1e2 0]);mythincolorbar;
    title(['Face' num2str(face(iobcs)) '; pt: vel, sq: 1st, tri: 2nd']);
    iloop(jface(iobcs))=1;
  end;
  hold on;
  if(type(iobcs)<=2);	%NS
    plot(obcs{iobcs}.iC1(2,ii),obcs{iobcs}.jC1(2,1),'k.','Marker',ss(iobcs),'color',cc(iobcs));
    plot(obcs{iobcs}.iC1(2,ii),obcs{iobcs}.jC2(2,1),'k.','Marker',ss1(iobcs),'color',cc(iobcs));
    plot(obcs{iobcs}.iC1(2,ii),obcs{iobcs}.jvel(2,1),'k.');
  else;			%EW
    plot(obcs{iobcs}.iC1(2,1), obcs{iobcs}.jC1(2,ii),'k.','Marker',ss(iobcs),'color',cc(iobcs));
    plot(obcs{iobcs}.iC2(2,1), obcs{iobcs}.jC1(2,ii),'k.','Marker',ss1(iobcs),'color',cc(iobcs));
    plot(obcs{iobcs}.ivel(2,1),obcs{iobcs}.jC1(2,ii),'k.');
  end;
  end;
  hold off;
  %keyboard
end;

figure(1);set(gcf,'paperunits','inches','paperposition',[0 0 12 10]);
fpr=[dirOBCS 'NA' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_obcsC.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);

iloop=[0 0 0];
clear type face
figure(2);clf;
for iobcs=[1,2,size(obcs,2),3,4];%:size(obcs,2)-1];
  face(iobcs)=obcs0{iobcs}.face;
  jface(iobcs)=find(iface==face(iobcs));
  type(iobcs)=obcs0{iobcs}.obcstype;

  ii=find(obcs0{iobcs}.imask>0);

  if(iloop(jface(iobcs))==0);
    subplot(1,2,jface(iobcs));
    mypcolor(af0{face(iobcs)}');caxis([-1e2 0]);mythincolorbar;
    title(['Face' num2str(face(iobcs)) '; pt: vel, sq: 1st, tri: 2nd']);
    iloop(jface(iobcs))=1;
  end;
  hold on;
  if(type(iobcs)>0);
  if(type(iobcs)<=2);
    plot(obcs0{iobcs}.iC1(2,ii),obcs0{iobcs}.jC1(2,1),'k.','Marker',ss(iobcs),'color',cc(iobcs));
    plot(obcs0{iobcs}.iC1(2,ii),obcs0{iobcs}.jC2(2,1),'k.','Marker',ss1(iobcs),'color',cc(iobcs));
    plot(obcs0{iobcs}.iC1(2,ii),obcs0{iobcs}.jvel(2,1),'k.');
  else;
    plot(obcs0{iobcs}.iC1(2,1), obcs0{iobcs}.jC1(2,ii),'k.','Marker',ss(iobcs),'color',cc(iobcs));
    plot(obcs0{iobcs}.iC2(2,1), obcs0{iobcs}.jC1(2,ii),'k.','Marker',ss1(iobcs),'color',cc(iobcs));
    plot(obcs0{iobcs}.ivel(2,1),obcs0{iobcs}.jC1(2,ii),'k.');
  end;
  end;
  hold off;

end;

figure(2);set(gcf,'paperunits','inches','paperposition',[0 0 12 10]);
fpr=[dirOBCS 'NA' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_obcsC270.png'];print(fpr,'-dpng');fprintf('%s\n',fpr);

