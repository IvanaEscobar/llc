clear all;
addpath('/home/atnguyen/llc1080/aste_1080x1440x540x90/matlab/');
define_indices;

dir270='/scratch/atnguyen/aste_270x450x180/run_template/input_sigma/';
dirGrid='/scratch/atnguyen/aste_270x450x180/GRID/';
dir270_it11='/scratch/atnguyen/aste_270x450x180/run_c65q_jra55_it0011_pk0000000002/ADXXfiles/';

dir1080_out='/scratch/atnguyen/aste_1080x1440x540x90/run_template/input_sigma/';
if(~exist(dir1080_out));mkdir(dir1080_out);fprintf('mkdir %s\n',dir1080_out);end;
dir1080_it11='/scratch/atnguyen/llc1080/aste_1080x1440x540x90/output_ad/run_c65q_jra55_it0011_pk0000000002/ADXXfiles/';
if(~exist(dir1080_it11));mkdir(dir1080_it11);fprintf('mkdir %s\n',dir1080_it11);end;

drF0=squeeze(abs(rdmds([dirGrid 'DRF'])));
drF1=drF0;


flaghFac=0;
flagZ=0;
flagXX=[1 1];

for iloop=2:2;

  if(iloop==1);
%xx files:
    dirIn1=dir270_it11;
    dirOut1=dir1080_it11;
    %flist=dir([dirIn1 'xx_*.data']); 
    tsstr=sprintf('%10.10i',11);
    flist={['xx_atemp.' tsstr '.data'],['xx_aqh.' tsstr '.data'],['xx_precip.' tsstr '.data'],...
           ['xx_lwdown.' tsstr '.data'],['xx_swdown.' tsstr '.data'],['xx_uwind.' tsstr '.data'],['xx_vwind.' tsstr '.data']};
           
  else;
%input_sigma: (less complicated because it's only 2d fields, no time dimensions)
    dirIn1=dir270;
    dirOut1=dir1080_out;
    flist={'Tair_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Qair_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Uwind_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Vwind_Ev2linearcapsmm9Eb_MezenB.bin','Rain_Ev2linearcapsmm9Eb_MezenB.bin',...
           'LwDn_Ev2linearcapsmm9Eb_MezenB.bin','SwDn_Ev2linearcapsmm9Eb_MezenB.bin'};
           
  end;

  for ifile=1:size(flist,2)
    %if(length(strfind(flist(ifile).name,'effective'))==0);
      tmp=dir([dirIn1 flist{ifile}]);
      nrec=tmp.bytes/nx0/ny0/4;
      %if(nrec~=nz);
        fprintf('processing %s ',flist{ifile});
        fprintf('%i ',nrec);
        fid=fopen([dirIn1 flist{ifile}],'r','b');
        fidout=fopen([dirOut1 flist{ifile}],'w','b');
        fprintf('%s ',[dirOut1 flist{ifile}]);
        for irec=1:nrec; % every 2 weeks for 1-1-2001 to 12-31-2015
          %a0=read_slice([dir270_it11 flist{ifile}],nx0,ny0,irec);
          a0=fread(fid,[nx0 ny0],'float32');
          a0=get_aste_tracer(a0,nfx0,nfy0);
          a1=interp_llc270toXXXX_v6(a0,flagXX,flagZ,flaghFac,nx,nz,drF0,drF1);	 %ASTE format
  
          temp=aste_tracer2compact(a1,nfx0.*fac,nfy0.*fac);
          [temp,a1_faces]=get_aste_tracer(temp,nfx0.*fac,nfy0.*fac);
  
          a1_faces_new{1}=a1_faces{1}(:,fac*nfy0(1)-nfy(1)+1:fac*nfy0(1),:);
          a1_faces_new{3}=a1_faces{3};
          a1_faces_new{4}=a1_faces{4}(1:nfx(4),:,:);
          a1_faces_new{5}=a1_faces{5}(1:nfx(5),:,:);
  
          a1_compact=cat(2,a1_faces_new{1},a1_faces_new{3},reshape(a1_faces_new{4},nfy(4),nfx(4)),...
                                                           reshape(a1_faces_new{5},nfy(5),nfx(5)));
  
          fwrite(fidout,a1_compact,'float32');
  
          % if(irec==1);
          %   figure(1);clf;
          %   subplot(221);pcolor(a0');shading flat;mythincolorbar;title('llc270 in aste size');
          %   subplot(222);pcolor(a1');shading flat;mythincolorbar;title('llc1080 in old aste size');
          %   subplot(223);pcolor(a1_compact');shading flat;mythincolorbar;title('llc1080 in compact size');
          %   subplot(224);pcolor(get_aste_tracer(a1_compact,nfx,nfy)');shading flat;mythincolorbar;title('llc1080 in new aste size');
          % end;
          if(mod(irec,30)==0);fprintf('%i ',irec);end;
        end;
        fclose(fid);
        fclose(fidout);
        fprintf('\n');
      %end;
    %end;
  end;


end;%iloop

%getting weights
dirIn ='/scratch/atnguyen/aste_1080x1440x540x90/run_template/input_sigma/';
dirOut='/scratch/atnguyen/aste_1080x1440x540x90/run_template/input_weight/';

    flist={'Tair_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Qair_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Uwind_Ev2linearcapsmm9Eb_MezenB.bin',...
           'Vwind_Ev2linearcapsmm9Eb_MezenB.bin','Rain_Ev2linearcapsmm9Eb_MezenB.bin',...
           'LwDn_Ev2linearcapsmm9Eb_MezenB.bin','SwDn_Ev2linearcapsmm9Eb_MezenB.bin'};

  for ifile=1:size(flist,2)
      tmp=dir([dirIn flist{ifile}]);

      a=readbin([dirIn flist{ifile}],[nx ny]);
      ii=find(a(:)==0);
      b=1./(a.^2);b(ii)=0;

      fOut=['w' flist{ifile}];
      writebin([dirOut fOut],b,1,'real*4');
      fprintf('%s\n',fOut);
  end;
