clear all;

define_indices;
set_directory;

nxp=2*nfy(1);
a=readbin(fBathyOut,[nxp ny]);
hf1=ones(size(a));hf1(find(a==0))=0;
hf{1}=hf1(1:nfx(1),1:nfy(1));
hf{5}=reshape(hf1(1:nxp,sum(nfy(1:3))+nfx(4)+1:sum(nfy(1:3))+sum(nfx(4:5))),nfx(5),nfy(5));
%[hf1,hf]=get_aste_tracer(hf,nfx,nfy);%clear hf

factor(ncut1)      %2 2 2 2 3 3 3 5	%2160
factor(ncut2)	   %2 2 2 3 3 3   5	%1080

%possible tile size:
% 24 30 40 45 54 60 72 90 108 120 

for icase=1:9;
if(icase==1);dtilex=30;dtiley=30;       %total 5184, 3957
elseif(icase==2);dtilex=40;dtiley=40;	%total 2916, 2238 
elseif(icase==3);dtilex=45;dtiley=45;	%total 2304, 1779 
elseif(icase==4);dtilex=54;dtiley=54;	%total 1600, 1243 
elseif(icase==5);dtilex=60;dtiley=60;	%total 1296, 1006 
elseif(icase==6);dtilex=72;dtiley=72;	%total  900,  698 
elseif(icase==7);dtilex=90;dtiley=90;	%total  576,  456 
elseif(icase==8);dtilex=108;dtiley=108;	%total  400,  313 
elseif(icase==9);dtilex=120;dtiley=120;	%total  324,  257 
end;
print_fig=1;
%nx=nx;ny=2*nx1+nx2+nx;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];

cc=0;cc1=0;
for iface=[1,3,5]
  msk{iface}=0.*hf{iface};
end;

fOut=[dirGridOut 'exch2_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.txt'];
fid=fopen(fOut,'w');

for iface=[1,5];
  clear temp 
  temp=hf{iface};
  temp1=0.*temp;
  nnx=nfx(iface)/dtilex;
  nny=nfy(iface)/dtiley;

  for j=1:nny
    jy=(j-1)*dtiley+1:j*dtiley;
    for i=1:nnx
      cc1=cc1+1;
      ix=(i-1)*dtilex+1:i*dtilex;
      b=sum(sum(temp(ix,jy))); 
      if(b>0);
        cc=cc+1;
        lx(cc)=ix(floor(dtilex/2));
        ly(cc)=jy(floor(dtiley/2));
        ll(cc)=cc;
        temp1(ix,jy)=1;
      else;
        fprintf(fid,'%i,\n',cc1);
      end;
    end
  end
  msk{iface}=temp1;
end;
fclose(fid);

cc=0;
for iface=[1,5];
  temp=msk{iface};
  figure(iface);clf;colormap(gray(3));
  imagescnan(msk{iface}');axis xy;caxis([-1,2]);
  %temp1=yc{iface};title(['yc: [' num2str(nanmin(temp1(:)),3) ' ' num2str(nanmax(temp1(:)),3) ']']);
  set(gca,'Xtick',0:dtilex:nfx(iface),'Ytick',0:dtiley:nfy(iface));grid;
  hold on;[aa,bb]=contour(1:nfx(iface),1:nfy(iface),hf{iface}',[1 1]);hold off;
  set(bb,'color',.7.*[1,1,1],'linewidth',2);
  nnx=nfx(iface)/dtilex;
  nny=nfy(iface)/dtiley;
  for j=1:nny;
    jy=(j-1)*dtiley+1:j*dtiley;
    for i=1:nnx
      ix=(i-1)*dtilex+1:i*dtilex;
      if(sum(sum(temp(ix,jy)))>0);
        cc=cc+1;
        text(lx(cc),ly(cc),num2str(ll(cc)),'HorizontalAlignment','center');
      end;
    end;
  end;
  if(print_fig==1);
  if(iface==1);set(gcf,'paperunit','inches','paperposition',[0 0 10 16]);
  elseif(iface==3);set(gcf,'paperunit','inches','paperposition',[0 0 10 10]);
  elseif(iface==4);set(gcf,'paperunit','inches','paperposition',[0 0 8 10]);
  else;            set(gcf,'paperunit','inches','paperposition',[0 0 16 10]);end;
  figure(iface);fpr=[dirGridOut 'Face' num2str(iface) '_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.png'];
  print(fpr,'-dpng');fprintf('%s\n',fpr);
  end;
end;
  fprintf('tilex,tiley,total_tile,num_tile: [%i %i %i %i]\n',[dtilex,dtiley,nxp*ny/dtilex/dtiley,cc]);

keyboard
end;
