clear all;

%get indices:
define_indices;

%set directory
set_directory;

dirIn  = dirOBCS;
dirOut = dirIn;

% load drF
rC0  =   (squeeze(rdmds([dirGrid0    'RC'])));
rC   =   (squeeze(rdmds([dirGrid_rF  'RC'])));
rF0  =   (squeeze(rdmds([dirGrid0    'RF'])));
rF   =   (squeeze(rdmds([dirGrid_rF  'RF'])));
drF0 =   (squeeze(rdmds([dirGrid0    'DRF'])));  nz0=length(drF0);
drF  =   (squeeze(rdmds([dirGrid_rF  'DRF'])));  nz =length(drF);

% load step 0 obcs structures
fIn0=[dirIn 'step1_obcs_' datestamp '.mat'];load(fIn0,'obcs0','T0','S0','U0','V0');

% load step 2a obcs structure:
fIn  =[dirOut 'step2a_obcs_' datestamp '.mat'];load(fIn);       %U,V,T,S,obcs


v0=V0{1}(:,:,1);
v1=V{1}(:,:,1);

A0=(drF0*obcs0{1}.dxg)';
A1=obcs{1}.dxg'*drF';

hfS0=obcs0{1}.hfS;hfS0(find(hfS0==0))=nan;
hfS1=obcs{1}.hfS; hfS1(find(hfS1==0))=nan;i1=find(isnan(hfS1(:))==0);

%after investigation, the problem is due to interp of v0 to v1 causing more NaN point than present in hfS1
%so the scheme could be to fill in the blank as follows,
for i=1:size(hfS1,1);
  clear v1c hfS1c
  v1c=v1(i,:);
  hfS1c=hfS1(i,:);
  clear ii;ii=find(isnan(v1c)==1&isnan(hfS1c)==0);
  if(length(ii)==1);%!must be only 1 or zero!
    v1c(ii)=v1c(ii-1);
  elseif(length(ii)>1);
    error('case1: need to see why there are more NaN point at bottom that just 1');
  end;
  clear ij;ij=find(isnan(v1c)==0&isnan(hfS1c)==1);
  if(length(ij)==1);%!just be only 1 or zero!
    v1c(ij)=nan;
  elseif(length(ij)>1);
    error('case2: need to see why there are more NaN point at bottom that just 1');
  end;
  v1(i,:)=v1c;
end;

tr0=A0.*hfS0.*v0;sumtr0=nansum(tr0(:));
tr1=A1.*hfS1.*v1;sumtr1=nansum(tr1(:));

difftr=sumtr0-sumtr1;
rAeff=1./(A1.*hfS1);	%should not be divided by any zero here
dvel1=difftr.*rAeff./length(i1);	%need to div by length(i1)
dtr=dvel1.*A1.*hfS1;
sum(nansum(dtr(:))-difftr)	%need to be 10^-8, yes! -2.65e-09
v1u=v1+dvel1;		%add, if tr0>tr1, v1u>v1
tr1u=A1.*hfS1.*v1u;

[nansum(tr0(:)) nansum(tr1(:)) nansum(tr1u(:))]
sum(nansum(tr0(:))-nansum(tr1u(:)))/sumtr0		%-4.17e-14!! YES! conserved finally


>> tmp=sum(sum(obcs2{iobcs1}.V(:,:,1).*A1.*obcs2{iobcs1}.hfS))+sum(sum(obcs2{iobcs4}.U(:,:,1).*A4.*obcs2{iobcs4}.hfW))-sum(sum(obcs2{3}.U(:,:,1).*A1E.*obcs2{3}.hfW));
A1E=drF*obcs2{3}.dyg;A1E=A1E'.*obcs2{3}.hfW;%[1080 x 90]


