%20.Sep.2016
%spent a lot of time fixing bathy for llc1080, so let's use that
clear all;

define_indices;
set_directory;

%current llc1080 aste
ny=ncut1+nx+ncut2+ncut1;
nxstr=num2str(nx);
dirOut=[dirRoot '/run_template/'];

get_noncap_bathy=1;

if(get_noncap_bathy==1);
  strbathyIn='';
  %dirBathyGlobal='/nobackupp8/dmenemen/tarballs/llc_1080/run_template/';
  dirBathyGlobal='/scratch/atnguyen/llc1080/global/run_template/';
  temp=abs(readbin([dirBathyGlobal 'bathy1080_g5_r4'],[nx nx*13]));
  bpf{1}=temp(:,1:3*nx);
  bpf{3}=temp(:,6*nx+1:7*nx);
  bpf{4}=reshape(temp(:,7*nx+1:10*nx),3*nx,nx);
  bpf{5}=reshape(temp(:,10*nx+1:13*nx),3*nx,nx);
  bf{1}=bpf{1}(ix1,iy1);
  bf{3}=bpf{3}(ix3,iy3);
  bf{4}=bpf{4}(ix4,iy4);
  bf{5}=bpf{5}(ix5,iy5);
%change name of output:
%  extb='_noncap';
%  idot=find(fBathyOut=='.');
%  fBathyOut=[fBathyOut(1:idot-1) extb fBathyOut(idot:end)];
else;
%large llc1080 aste
  nx_temp=1080;nx1p=1800;nx2p=720;ny_temp=nx1p+nx_temp+nx2p+nx1p;
  nfx_temp=[nx_temp 0 nx_temp nx2p nx1p];nfy_temp=[nx1p 0 nx_temp nx_temp nx_temp];
  dirIn =['/nobackupp2/atnguye4/llc' nxstr '/aste_' num2str(nx_temp) 'x' num2str(nfy_temp(1)) 'x' num2str(nfx_temp(4)) '/run_template/'];
  strbathyIn='_v2';%'_v1';

  fIn =[dirIn  'bathy_aste' num2str(nx_temp) 'x' num2str(nx1p) 'x' num2str(nx2p) strbathyIn '.bin'];
%read in bathy
  temp=dir(fIn);precIn='real*4';if(temp.bytes/nx_temp/ny_temp/4==2);precIn='real*8';end;
  b0=readbin(fIn,[nx_temp ny_temp],1,precIn);

%now trimming:
  [bp,bpf]=get_aste_tracer(b0,nfx_temp,nfy_temp);

  for iface=[1,3,4,5];
    sz0=size(bpf{iface});
    if(iface==1);
      bf{iface}=bpf{iface}(:,sz0(2)-ncut1+1:sz0(2));
    elseif(iface==3);
      bf{iface}=bpf{iface};
    else;
      bf{iface}=bpf{iface}(1:nfx(iface),:);
    end;
  end;
end;

  for iface=[1,3:5];clf;
    subplot(121);mypcolor(bpf{iface}');mythincolorbar;
    subplot(122);mypcolor(bf{iface}');mythincolorbar;title(iface);
    pause;
  end;
  for iface=[1,3:5];clf;
    subplot(121);mypcolor(bpf{iface}');mythincolorbar;
    subplot(122);mypcolor(abs(bf{iface})');caxis([0 1e2]);mythincolorbar;title(iface);
    pause;
  end;

%%blanking out face4:
%ix=243:ncut2;         iy=732:1007;bf{4}(ix,iy)=0;  %Alaskan Stream
%ix=230:min(288,ncut2);iy=146:273; bf{4}(ix,iy)=0;  %Okhost Sea
%ix=229:ncut2;         iy=1:239;   bf{4}(ix,iy)=0;  %Okhost Sea

%South:
%face4:
iC4=494;
ix=iC4+1:540;iy=1:nx;bf{4}(ix,iy)=0;
%Okhost Sea:
ix=225:309;iy=135:257;bf{4}(ix,iy)=0;	
ix=270:405;iy=1:225;bf{4}(ix,iy)=0;
ix=405:495;iy=1:180;bf{4}(ix,iy)=0;

%face1: block out Pacific, 
ix=600:nx;iy=1:950;bf{1}(ix,iy)=0;
%Mediteranean Sea, 
ix=450:600;iy=600:850;bf{1}(ix,iy)=0;
ix=390:nx;iy=665:720;bf{1}(ix,iy)=0;	%Gibraltar Strait: stop at 390
%NorthSea
ix=600:850;iy=1000:1290;bf{1}(ix,iy)=0;
ix=560:600;iy=1000:1080;bf{1}(ix,iy)=0;
ix=580:590;iy=1080:1085;bf{1}(ix,iy)=0;
%White Sea
ix=800:975;iy=1250:1380;bf{1}(ix,iy)=0;

%face5:
%Pacific:
ix=1152:1440;iy=1:620;bf{5}(ix,iy)=0;
ix=1143:1152;iy=576:595;bf{5}(ix,iy)=0;
ix=1130:1150;iy=670:690;bf{5}(ix,iy)=0;
ix=400:1440;iy=1:362;bf{5}(ix,iy)=0;
ix=1040:1151;iy=350:475;bf{5}(ix,iy)=0;
ix=1088:1152;iy=475:530;bf{5}(ix,iy)=0;
ix=1140:1155;iy=530:540;bf{5}(ix,iy)=0;
ix=531:671;iy=421:638;bf{5}(ix,iy)=0;

%now put back into compact format:
b1=cat(2,bf{1},bf{3},reshape(bf{4},nfy(4),nfx(4)),reshape(bf{5},nfy(5),nfx(5)));
b1=-abs(b1);
writebin(fBathyIn,b1,1,'real*4');

%masking out: skipping for now, need to see what obcs looks like on face 4, then might return here.
mask_out=0;
if(mask_out==1);
%plotting
bp=get_aste_tracer(b1,nfx,nfy);
msk=zeros(size(bp));msk(find(bp==0))=1;%msk(1:780,600:end)=1;msk(1:552,300:600)=1;msk(750:1100,1500:end)=1;
figure(1);clf;mypcolor(-bp'.*(1-msk)');colorbar;grid;
shadeland(1:2*nx,1:ncut1+nx+ncut2,msk',[.7 .7 .7]);
set(gcf,'paperunits','inches','paperposition',[0 0 12 8]);
fpr=[dirOut 'bathy_aste' num2str(nx)  'x' num2str(ncut1)  'x' num2str(ncut2)  strbathyOut '.png'];
print(fpr,'-dpng');fprintf('%s\n',fpr);

strbathyOut=strbathyIn;
fOut=[dirOut 'bathy_aste' num2str(nx)  'x' num2str(ncut1)  'x' num2str(ncut2)  strbathyOut '.bin'];
end;
