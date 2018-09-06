clear all;

define_indices;
set_directory;

dirIn=[dirRoot0 'run_template/input_binaries/'];

ny=2*ncut1+nx+ncut2;%nz=50;

dirOut=[dirRoot 'run_template/'];
ext=['_llc' nxstr];

nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

rC0 =   (squeeze(rdmds([dirGrid0    'RC'])));
rC  =   (squeeze(rdmds([dirGrid_rF  'RC'])));
drF0=abs(squeeze(rdmds([dirGrid0    'DRF'])));	nz0=length(drF0);%[50 x 1]
drF =abs(squeeze(rdmds([dirGrid_rF  'DRF'])));	nz =length(drF); %[90 x 1]

flist={'WOA09v2_T_llc270_JAN.bin','WOA09v2_S_llc270_JAN.bin',...
       'diffkr_basin_v1m9EfC.bin','AREAaste_Jan2002_270x1350.bin',...
       'HEFFaste_Jan2002_270x1350.bin','HSNOWaste_Jan2002_270x1350.bin'};%'Diffkr_basin_v1m9EfB_Method2.bin',

flagXX=[1 1];flagNZ=0;flagHF=0;
for ifile=1:size(flist,2);

  fIn=[flist{ifile}];idot=find(fIn=='.');idash=find(fIn=='_');
  if(length(strfind(fIn,'llc'))>0);
    fOut=[dirOut fIn(1:idash(2)-1) ext fIn(idash(3):end)];
  elseif(length(strfind(fIn,'270x1350'))>0);
    fOut=[dirOut fIn(1:idash(2)) nxstr 'x' num2str(ny) fIn(idot:end)];
  else;
    fOut=[dirOut fIn(1:idot-1) ext '.bin'];
  end;

  if(exist(fOut)==0);

  clear FF
  temp=dir([dirIn fIn]);nzp=temp.bytes/nx0/ny0/8;
  FF=readbin([dirIn fIn],[nx0 ny0 nzp],1,'real*8');

  FF=get_aste_faces(FF,nfx0,nfy0);

  for iface=1:5;
    clear tmp
    eval(['tmp=exist(''ix' num2str(iface) ''',''var'');']);

    if(tmp>0);
      clear ix0 jy0 ix jy i j ijx ijy

      eval(['ix0=ix' num2str(iface) '_0;']);	%global llc270
      eval(['jy0=iy' num2str(iface) '_0;']);	%global llc270

      xshift=0;yshift=0;if(iface==1);yshift=-360;end;

      FFp{iface}=FF{iface}(ix0,jy0+yshift,:);
      FFq{iface}=interp_llc270toXXXX_v6(FFp{iface},flagXX,flagNZ,flagHF,nx,drF0,drF);

%trim
      ix_hi=(ix0(1)-1)*fac+1:ix0(end)*fac;	%global llc1080
      jy_hi=(jy0(1)-1)*fac+1:jy0(end)*fac;	%global llc1080

      eval(['ix=ix' num2str(iface) ';']);
      eval(['jy=iy' num2str(iface) ';']);

      [i,j,ijx]=intersect(ix,ix_hi);
      [i,j,ijy]=intersect(jy,jy_hi);
      FFq{iface}=FFq{iface}(ijx,ijy,:);

%now do vertical interp
      sz=size(FFq{iface});if(length(sz)==2);sz=[sz 1];end;
      if(sz(3)==nz0);
        z0=abs(rC0');z1=abs(rC');
        tmp=zeros(sz(1),sz(2),nz);
        for k=1:nz;
          iz=sort(closest(z1(k),z0,2));
          ss=prod(sign(z0(iz)-z1(k)));
          if(ss>0&sign(z0(iz(1))-z1(k))>0);         %above z0(1)
            w1=1;w2=0;
          elseif(ss>0&sign(z0(iz(1))-z1(k))<0);     %below z0(end)
            w1=0;w2=1;
          else;
            dz=z0(iz(2))-z0(iz(1));                 %positive
            dz1=z1(k)-z0(iz(1));w1=1-dz1/dz;
            dz2=z0(iz(1))-z1(k);w2=1-w1;
          end;
          tmp(:,:,k)=w1.*FFq{iface}(:,:,iz(1))+w2.*FFq{iface}(:,:,iz(2));
        end;
        FFq{iface}=tmp;
      end;

    end;
  end;
  FF_hi=aste_tracer2compact(FFq,nfx,nfy);

  writebin(fOut,FF_hi,1,'real*4');
  clear FF FFp FFq FF_hi temp

  end;%exist(fOut)

end;
