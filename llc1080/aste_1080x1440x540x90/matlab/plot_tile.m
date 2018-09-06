clear all;

define_indices;
set_directory;

nx1=ncut1;
nx2=ncut2;
dirGrid=dirGridOut;
iC4=494;remove_Okhost=1;
ext_bathy='';
if(iC4==497);ext_bathy='_iC4_497';
if(remove_Okhost==1);ext_bathy='_iC1_497a';end;end;
%if(iC4==494);ext_bathy='_iC4_494';
%if(remove_Okhost==1);ext_bathy='_iC4_494a';end;end;
%idot=find(fBathyIn=='.');
%fBathyIn1=[fBathyIn(1:idot-1) ext_bathy fBathyIn(idot:end)];
%a=readbin([fBathyIn1],[nx ny],1,'real*4');
a=readbin([dirRoot 'run_template/bathy_aste1080x1440x540_obcs13Jan2018_v2.bin'],[nx ny],1,'real*4');
hf=ones(size(a));hf(find(a==0))=0;
[hf1,hf]=get_aste_tracer(hf,nfx,nfy);%clear hf

factor(nx)      %2 2 2 3 3 3 5
factor(nx1)	%2     3 3   5 5
factor(nx2)	%2 2   3 3 3 5
for icase=[1:4,6:8,5];                   %+org   full  v1iC1_494
%for icase=[5];                            %+org   full  v1iC1_494 v2           v3      Okhost
  if(icase==1);dtilex=30;dtiley=30;       %total  5400, 2955 	 2585		2484    2642
  elseif(icase==2);dtilex=90;dtiley=90;   %total   600,  385	  332		 320     340
  elseif(icase==3);dtilex=90;dtiley=60;   %total   900,  560	  481		 463     494
  elseif(icase==4);dtilex=60;dtiley=90;   %total   900,  553	  484		 466	 494
% case5: (41: -22, f3: -16, f4: -10, f5: -30): 804-78=726	
  elseif(icase==5);dtilex=60;dtiley=60;   %total  1350,  804	  686 <-- this	 659     703
  elseif(icase==6);dtilex=60;dtiley=45;   %total  1800, 1057	  919		 878     941
%f3(-6)
  elseif(icase==7);dtilex=45;dtiley=60;   %total  1800, 1048	  896 <-- this	 860     916
% case8: (f1:-40, f3: -30, f4: -12, f5: -16
% f1:-8, f3: -22, f4: -1, f5: -3
  elseif(icase==8);dtilex=45;dtiley=45;   %total  2400, 1372 	 1202		1149    1227
  end;
print_fig=1;

cc=0;cc1=0;
for iface=[1,3:5]
  msk{iface}=0.*hf{iface};
end;

fOut=[dirGrid 'exch2_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.txt'];
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
  figure(iface);fpr=[dirGrid 'Face' num2str(iface) '_tile' sprintf('%2.2i',dtilex) 'x' sprintf('%2.2i',dtiley) '.png'];
  print(fpr,'-dpng');fprintf('%s\n',fpr);
  end;
end;
  fprintf('tilex,tiley,total_tile,num_tile: [%i %i %i %i]\n',[dtilex,dtiley,nx*ny/dtilex/dtiley,cc]);
keyboard
end;
