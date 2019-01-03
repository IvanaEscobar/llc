clear all;

define_indices;
set_directory;

dirIn0=[dirRoot0 'run_template/'];
dir_field={'input_sst_reynolds','input_sst','input_sst_remss','input_rads','input_mdt',...
           'input_ICESat','input_icevel','input_icon_reproc','input_grace','input_weight',...
           'input_sigma','input_rads_monthly','input_ICESat_monthly','input_si_IAN',...
           'input_err_IAN','input_binaries','input_climatology','input_err','input_grace_maskedcoast5'};
%dir_field={'input_binaries'};

for i=1:size(dir_field,2);
    %index for input_binaries
    if(strcmp(dir_field{i},'input_binaries'));idir0=i;end;
end;

ny=2*ncut1+nx+ncut2;

ext=['llc' nxstr];

nfxa=ceil([nx0 0 nx0 nfx(4)/fac nfx(5)/fac]);nfya=ceil([nfy(1)/fac 0 nx0 nx0 nx0]);

rC0 =   (squeeze(rdmds([dirGrid0    'RC'])));
rC  =   (squeeze(rdmds([dirGrid_rF  'RC'])));
drF0=abs(squeeze(rdmds([dirGrid0    'DRF'])));	nz0=length(drF0);%[50 x 1]
drF =abs(squeeze(rdmds([dirGrid_rF  'DRF'])));	nz =length(drF); %[90 x 1]
[wei,ind]=get_z_weight(rC,rC0,1);

flagXX=[1 1];flagNZ=0;flagHF=0;
for idir=idir0;%size(dir_field,2); 
  precIn='float32';nprec=4;precOut='float32';nprecOut=8;
  if(strcmp(dir_field{idir},'input_binaries'));precIn='float64';nprec=8;end;
  dirIn=[dirIn0 '/' dir_field{idir} '/'];
  dirOut=[dirRoot '/run_template/' dir_field{idir} '/'];if(~exist(dirOut));mkdir(dirOut);end;
  flist=dir([dirIn '/WOA09v2*']); % grabbing initial T, S files ONLY

  for ifile=1:size(flist,1);
  
    clear tmp_int;tmp_int=flist(ifile).bytes/nx0/ny0/nprec;

    if(isreal(tmp_int)&rem(tmp_int,1)==0&tmp_int>0)

      fIn=[flist(ifile).name];

      fOut=[fIn];
      idash=strfind(fOut,'llc');
      if(length(idash)>0);			%/*{{{*/ [4]
        fOut=[fOut(1:idash(1)-1) ext fOut(idash(1)+6:end)];
      end;
      idash=strfind(fOut,'270x1350');
      if(length(idash)>0);
        fOut=[fOut(1:idash(1)-1) nxstr 'x' num2str(ny) fOut(idash(1)+8:end)];
      end;					%/*}}}*
      fOut=[dirOut fOut];fprintf('%i ',tmp_int);fprintf('%s\n',fOut);
    
      %if(exist(fOut)==0);				%/*{{{*/ [4]
    
        clear FF
        temp=dir([dirIn '/' fIn]);nzp=tmp_int;

%        if(nzp~=nz0);					%separate 2d
        if(mod(nzp,nz0)~=0);				%separate 2d
          fid=fopen([dirIn fIn],'r','b');
          fidout=fopen([fOut],'w','b');
          for it=1:nzp;
            FF=fread(fid,[nx0 ny0],precIn);
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
              end;%tmp>0
            end;%iface

            FF_hi=aste_tracer2compact(FFq,nfx,nfy);
            fwrite(fidout,FF_hi,precIn);
            clear FF FFp FFq FF_hi temp
          end;
          fclose(fidout);
          fclose(fid);

        elseif(nzp>0);						%3d

          fid=fopen([dirIn fIn],'r','b');
          fidout=fopen(fOut,'w','b');
          for irec=1:nzp/nz0;
            FF=fread(fid,[nx0*ny0*nz0 1],precIn);
            FF=reshape(FF,nx0,ny0,nz0);
            FF=get_aste_faces(FF,nfx0,nfy0);
        
            for iface=1:5;					%/*{{{*/ [5]
              clear tmp
              eval(['tmp=exist(''ix' num2str(iface) ''',''var'');']);
          
              if(tmp>0);					%/*{{{*/ [6]
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
                if(sz(3)==nz0);				%/*{{{*/ [7]
                  tmp=zeros(sz(1),sz(2),nz);
                  for k=1:nz;				%/*{{{*/ [8]
                    tmp(:,:,k)=wei(k,1).*FFq{iface}(:,:,ind(k,1))+wei(k,2).*FFq{iface}(:,:,ind(k,2));
                  end;					%/*}}}*/
                  FFq{iface}=tmp;
                end;					%/*}}}*/
          
              end;%tmp>0						%/*}}}*/
            end;%iface					%/*}}}*/

            FF_hi=aste_tracer2compact(FFq,nfx,nfy);
            fwrite(fidout,FF_hi,precOut);
            clear FF FFp FFq FF_hi temp
          end;%irec

          fclose(fid);
          fclose(fidout);

        end;%mod(nzp,nz0)~=0, 2d vs 3d
      
      %end;%exist(fOut)					%/*}}}*/

    end;%isreal
  
  end;	%ifile
end; %idir
