clear all;

%define_indices;
%set_directory;

dirRoot='/work/03901/atnguyen/llc90/aste_90x150x60/run_template/';
if(~exist(dirRoot));error('dirroot not exist');end;
dirOut=[dirRoot '+tile/'];if(~exist(dirOut));mkdir(dirOut);end;
nx1=150;
nx2=60;
nx=90;ny=2*nx1+nx+nx2;nfx=[nx 0 nx nx2 nx1];nfy=[nx1 0 nx nx nx];
a=readbin([dirRoot 'bathy_eccollcaste_90x50_min2pts.bin'],[nx ny],1,'real*4');
hf=ones(size(a));hf(find(a==0))=0;
[hf1,hf]=get_aste_tracer(hf,nfx,nfy);%clear hf

factor(nx)      %2 2 2 3 3 3 5
factor(nx1)	%2 2   3 3   5 7
factor(nx2)	%2 2   3 3 3 5
for icase=[1:3];                 %+org   full  v1iC1_494
  if(icase==1);dtilex=30;dtiley=30;       %total  3450,      	     		1784    38*48
  elseif(icase==2);dtilex=15;dtiley=18;   %total   552,     	     		 320     7*48
  elseif(icase==3);dtilex=15;dtiley=15;   %total   828,     	     		 463    10*48
  end;
print_fig=1;

cc=0;cc1=0;
for iface=[1,3:5]
  msk{iface}=0.*hf{iface};
end;

fOut=[dirOut 'exch2_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.txt'];
fid=fopen(fOut,'w');

for iface=[1,3:5];
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
for iface=[1,3:5];
  temp=msk{iface};
  figure(iface);clf;colormap(gray(3));
  imagescnan(msk{iface}');axis xy;caxis([-1,2]);
  title([num2str(dtilex) ' ' num2str(dtiley)]);
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
  if(iface==1);set(gcf,'paperunit','inches','paperposition',[0 0 12 14]);
  elseif(iface==3);set(gcf,'paperunit','inches','paperposition',[0 0 10 10]);
  elseif(iface==4);set(gcf,'paperunit','inches','paperposition',[0 0 8 10]);
  else;            set(gcf,'paperunit','inches','paperposition',[0 0 14 10]);end;
  figure(iface);fpr=[dirOut 'Face' num2str(iface) '_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.png'];
  print(fpr,'-dpng');fprintf('%s\n',fpr);
  end;
end;
  fprintf('tilex,tiley,total_tile,num_tile: [%i %i %i %i]\n',[dtilex,dtiley,nx*ny/dtilex/dtiley,cc]);
keyboard
end;
