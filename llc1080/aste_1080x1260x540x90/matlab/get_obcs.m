%08.Feb.2018
%get obcs from aste_1080x1440x540x90 because it's the identical obcs
clear all;

define_indices;
set_directory;

dirIn='/scratch/atnguyen/aste_1080x1440x540x90/run_template/input_obcs/';
nS0=nx+nx+ncut2+1440;
nE0=1440+nx+nx+nx;
% OB_Jsouth =   1080*256, 3060*0,
% OB_Ieast  =   680*0, 4*387, 756*0, 1080*0, 1080*494, 1080*1185,

dirOut='/scratch/atnguyen/aste_1080x1260x540x90/run_template/input_obcs/';
nS1=nx+nx+ncut2+ncut1;
nE1=ncut1+nx+nx+nx;
% OB_Jsouth =   1080*76, 3060*0,
% OB_Ieast  =   500*0, 4*387, 756*0, 1080*0, 1080*494, 1080*1185,

%East: 680 --> 680-(1440-ncut1) = 680-180=500
flist0=dir([dirIn 'OBE*.bin']);
nt=flist0(1).bytes/nE0/nz/4;

for i=1:length(flist0);
  a0=readbin([dirIn flist0(i).name],[nE0,nz,nt]);
  a1=a0((1440-ncut1)+1:nE0,:,:);

%blanking out Okhost Sea here to make sure when balancing mass we're not
%reading in flows that is not part of the obcs

%face4:
  i4_1=1260+1080+1;i4_2=1260+2*1080;
  izeros=1:180;
  tmp=a1(i4_1:i4_2,:,:);tmp(izeros,:,:)=0;
  a1(i4_1:i4_2,:,:)=tmp;

  idash=find(flist0(i).name=='_');
  fOut=[flist0(i).name(1:idash(1)) num2str(nE1) flist0(i).name(idash(1)+5:end)];

  writebin([dirOut fOut],a1,1,'real*4');
  fprintf('%s\n',[dirOut fOut]);
end;

%South: 256-180=76
flist0=dir([dirIn 'OBS*.bin']);
nt=flist0(1).bytes/nS0/nz/4;

for i=1:length(flist0);
  a0=readbin([dirIn flist0(i).name],[nS0,nz,nt]);
  a1=a0(1:nS0-(1440-ncut1),:,:);

  idash=find(flist0(i).name=='_');
  fOut=[flist0(i).name(1:idash(1)) num2str(nS1) flist0(i).name(idash(1)+5:end)];

  writebin([dirOut fOut],a1,1,'real*4');
  fprintf('%s\n',[dirOut fOut]);
end;


