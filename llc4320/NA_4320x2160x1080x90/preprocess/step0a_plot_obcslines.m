clear all;

define_indices;
set_directory;

a0=readbin( [dirs.parent.grid 'bathy_fill9iU42Ef_noStLA_v1.bin'],...
            [id.n.x0 id.n.y0],1,'real*8');
[a0,af0]=get_aste_tracer(a0,id.nf.x0,id.nf.y0);
idot=find(dirs.bathy.fIn=='.');extBathy='';%'_v2';
a=readbin([dirs.bathy.fIn(1:idot-1) extBathy '.bin'],[id.ncut{1} id.n.y]);
[a,af]=get_aste_tracer(a,id.nf.x,id.nf.y);
load([dirs.domain.obcs 'step0_obcs_' dirs.datestamp '.mat']);	%obcs0 obcs
clear extBathy a a0 idot;

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
clear af;

figure(1);set(gcf,'paperunits','inches','paperposition',[0 0 12 10]);
fpr=[dirs.domain.obcs 'NA' id.nx 'x' id.ncut1 'x' id.ncut2 '_obcsC.png'];
print(fpr,'-dpng');fprintf('%s\n',fpr);

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
fpr=[dirs.domain.obcs 'NA' id.nx 'x' id.ncut1 'x' id.ncut2 '_obcsC270.png'];
print(fpr,'-dpng');fprintf('%s\n',fpr);
clear af0 iface face  ii iloop iobcs cc jface obcstype ss ss1 type obcs ...
        obcs0 ll i fpr cc0 ccl;
