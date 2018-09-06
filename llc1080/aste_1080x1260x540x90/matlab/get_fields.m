%get from aste_1080x1440x540x90

clear all;

define_indices;
set_directory;

dirIn='/scratch/atnguyen/aste_1080x1440x540x90/run_template/';
dirOut='/scratch/atnguyen/aste_1080x1260x540x90/run_template/';

for iloop=6:6;
  if(iloop==1);
    flist={'AREAaste_Jan2002_1080x4500.bin','diffkr_basin_v1m9EfC_llc1080.bin',...
           'HEFFaste_Jan2002_1080x4500.bin','HSNOWaste_Jan2002_1080x4500.bin',...
           'WOA09v2_S_llc1080_JAN.bin','WOA09v2_T_llc1080_JAN.bin'};
    ext='';prec='float32';prec1=4;
  elseif(iloop==2);
    ext='input_sigma/';prec='float32';prec1=4;
    tmp=dir([dirIn ext '*.bin']);
    for i=1:length(tmp);flist{i}=tmp(i).name;end;
  elseif(iloop==3);
    ext='input_weight/';prec='float32';prec1=4;
    tmp=dir([dirIn ext '*.bin']);
    for i=1:length(tmp);flist{i}=tmp(i).name;end;
  elseif(iloop==4);
    ext='input_smooth/';prec='float32';prec1=4;
    flist={'smooth2Dnorm001_6x.data','smooth2Dnorm001_9x.data','smooth2Doperator001.data',...
           'smooth2Dscales001_12x','smooth2Dscales001_3x','smooth2Dscales001_6x',...
           'smooth2Dscales001_9x','smooth3DscalesH001_12x','smooth3DscalesH001_3x',...
           'smooth3DscalesH001_6x','smooth3DscalesH001_9x'};
  elseif(iloop==5);
    dirIn='/scratch/atnguyen/llc1080/aste_1080x1440x540x90/output_ad/run_c65q_jra55_it0011_pk0000000002/ADXXfiles/';
    dirOut='/scratch/atnguyen/llc1080/aste_1080x1260x540x90/output_ad/run_c65q_jra55_it0011_pk0000000002/ADXXfiles/'
    ext='/';prec='float32';prec1=4;
    flist={'xx_aqh.0000000011.data','xx_atemp.0000000011.data','xx_lwdown.0000000011.data',...
           'xx_precip.0000000011.data','xx_swdown.0000000011.data','xx_uwind.0000000011.data',...
           'xx_vwind.0000000011.data'};
  else;
    dirIn='/scratch/atnguyen/aste_1080x1440x540x90/run_obcs_prof2_ctrl_kpp_pk0000000004/';
    dirOut='/scratch/atnguyen/aste_1080x1260x540x90/run_obcs_prof2_ctrl_kpp_pk0000000004/';
    ext='/';prec='float64';prec1=8;
    flist={'pickup.0000000004.data','pickup_seaice.0000000004.data'};
  end;
  if(~exist([dirOut ext]));mkdir([dirOut ext]);end;

  for i=1:size(flist,2);
  
    clear tmp nk a0 a0f a1 a1f fOut
  
    istr=[];istr=strfind(flist{i},'4500');
    if(length(istr)>0);
      fOut=[dirOut ext flist{i}(1:istr-1) num2str(2*ncut1+nx+ncut2) flist{i}(istr(1)+4:end)];
    else;
      fOut=[dirOut ext flist{i}];
    end;
  
    tmp=dir([dirIn ext flist{i}]);
    nk=tmp.bytes/(1440*2+ncut2+nx)/nx/prec1;
  
    fidout=fopen(fOut,'w','b');
    fid=fopen([dirIn ext flist{i}],'r','b');

    
    for j=1:nk
      a0=fread(fid,[nx 1440*2+ncut2+nx],prec);
      %a0=readbin([dirIn ext flist{i}],[nx 1440*2+ncut2+nx nk]);
      a0f{1}=a0(:,1:1440);%,:);
      a0f{3}=a0(:,1440+1:1440+nx);%,:);
      a0f{4}=reshape(a0(:,1440+nx+1:1440+nx+ncut2,:),ncut2,nx);%,nk);
      a0f{5}=reshape(a0(:,1440+nx+ncut2+1:1440*2+nx+ncut2,:),1440,nx);%,nk);
    
    %now cutting
      a1f{1}=a0(:,(1440-ncut1)+1:1440);%,:);
      a1f{3}=a0f{3};
      a1f{4}=a0f{4};
      a1f{5}=a0f{5}(1:ncut1,:);%,:);
    
    %put back to compact
      %a1=cat(2,a1f{1},a1f{3},reshape(a1f{4},nx,ncut2,nk),reshape(a1f{5},nx,ncut1,nk));
      a1=cat(2,a1f{1},a1f{3},reshape(a1f{4},nx,ncut2,1),reshape(a1f{5},nx,ncut1,1));
    
      %writebin(fOut,a1,1,'real*4');
      fwrite(fidout,a1,prec);

    end;
    fprintf('%s\n',fOut);
    fclose(fid);
    fclose(fidout);
  
  end;%ifile
end;%iloop
