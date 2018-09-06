%load in step1 llc270aste output, expand and interp to 106k or 90k or certain klevs
clear all;

%get indices:
define_indices;

%set directory
set_directory;

dirIn  = dirOBCS;
dirOut = dirIn;

%calculating hFac using updated bathy:
hFacMin=0.2;
hFacMinDr=5.;
%hFacMin=0;
%hFacMinDr=0.1;

eyeballing_Gibraltar=1;

% load drF
rC0  =   (squeeze(rdmds([dirGrid0    'RC'])));
rC   =   (squeeze(rdmds([dirGrid_rF  'RC'])));
rF0  =   (squeeze(rdmds([dirGrid0    'RF'])));
rF   =   (squeeze(rdmds([dirGrid_rF  'RF'])));
drF0 =   (squeeze(rdmds([dirGrid0    'DRF'])));  nz0=length(drF0);
drF  =   (squeeze(rdmds([dirGrid_rF  'DRF'])));  nz =length(drF);

% load step 0 obcs structures
fIn=[dirIn 'step0_obcs_' datestamp '.mat'];load(fIn,'obcs');
fIn=[dirIn 'step1_obcs_' datestamp '.mat'];load(fIn,'obcs0','T0','S0','U0','V0');

nt=size(T0{1},3);
fsave=[dirOut 'step2a_obcs_' datestamp '.mat'];

%initialize
for iobcs=1:size(obcs,2);	%8
  iface=obcs{iobcs}.face;
  ix=unique(obcs{iobcs}.iC1(2,:));Lix=length(ix);
  jy=unique(obcs{iobcs}.jC1(2,:));Ljy=length(jy);
  iv=unique(obcs{iobcs}.ivel(2,:));
  jv=unique(obcs{iobcs}.jvel(2,:));

  ixp=zeros(1,length(obcs0{iobcs}.iC1(1,:)).*fac);
  jyp=zeros(1,length(obcs0{iobcs}.jC1(1,:)).*fac);
  if(length(ix)==1);
    for k=1:length(obcs0{iobcs}.iC1(1,:));
      i1=(obcs0{iobcs}.jC1(1,k)-1)*fac+1;i2=(obcs0{iobcs}.jC1(1,k))*fac;
      jyp((k-1)*fac+1:k*fac)=i1:i2;
      ixp((k-1)*fac+1:k*fac)=ix;
    end;
    [a,b]=intersect(jyp,obcs{iobcs}.jC1(1,:));
  elseif(length(jy)==1);
    for k=1:length(obcs0{iobcs}.iC1(1,:));
      i1=(obcs0{iobcs}.iC1(1,k)-1)*fac+1;i2=(obcs0{iobcs}.iC1(1,k))*fac;
      ixp((k-1)*fac+1:k*fac)=i1:i2;
      jyp((k-1)*fac+1:k*fac)=jy;
    end;
    [a,b]=intersect(ixp,obcs{iobcs}.iC1(1,:));
  end;

  if(iv~=0 & jv==0);                  %either E or W
    T{iobcs}=zeros(Ljy,nz,nt);
  elseif(jv~=0 & iv==0);              %either N or S
    T{iobcs}=zeros(Lix,nz,nt);
  end;
  ind{iobcs}=b';
  S{iobcs}=T{iobcs};
  U{iobcs}=T{iobcs};
  V{iobcs}=T{iobcs};
end;

iznan=find(abs(rC)<abs(rC0(1)));
flagXX=[1 0];flagNZ=0;flaghFac=0;
%now do first round of interpolation
varstr={'T','S','U','V'};

%12Jan2018: found out that interp of T,S,U,V leave more/less NaN points
%than hFacS. Need a new way to fill this in:
% for U,V: set land to zeros instead of NaN so that vel will simply interp to zero toward land.
% for T,S: set land to bottom-most non-NaN value to avoid spurious values toward zeros.

for iobcs=1:size(obcs,2);
  fprintf('iobcs: %i ',iobcs);
  for ivar=1:size(varstr,2);
    fprintf('varstr: %s ',varstr{ivar});
    clear sz0 szp tmp tmp0 tmpp z0 x0 z x

    eval(['tmp0=' varstr{ivar} '0{iobcs};']);
    %sz0=size(T0{iobcs});				%[nx0 nz0 nt]
    %sz =size(T{iobcs});					%[nx0 nz0 nt]
    %[z0,x0]=meshgrid(rC0,1:sz(1));
    %[z ,x ]=meshgrid(rC ,1:sz(1));

%slow, but best this way?
    sz=size(tmp0);
    if(varstr{ivar}=='U'|varstr{ivar}=='V');
      ii=find(isnan(tmp0(:))==1);tmp0(ii)=0;
    else;
      tmphf=obcs0{iobcs}.hfC1;tmphf(find(tmphf(:)==0))=nan;tmphf(find(tmphf>0))=1;
      tmp0=tmp0.*repmat(tmphf,[1 1 sz(3)]);
      for i=1:sz(1);
        tmp0a=squeeze(tmp0(i,:,:));
        ii=find(isnan(tmp0a(:,1))==1);
        if(length(ii)>=1&length(ii)<sz(2));
          tmp0a(ii,:)=repmat(tmp0a(ii(1)-1,:),[length(ii) 1]);
          tmp0(i,:,:)=tmp0a;
        end;
      end;
    end;

    tmpp=interp_llc270toXXXX_v6(tmp0,flagXX,flagNZ,flaghFac,nx,drF0,drF);
    tmpp=tmpp(ind{iobcs},:,:);

%fix special case of Gibraltar Strait
    if(eyeballing_Gibraltar==1 & obcs{iobcs}.flag_case==1);
      tmpp=nan(size(tmpp));
%in the case of eyeballing, will match exactly
      ik =find(obcs{iobcs}.imask==1);            %2 or 4 or 6 or etc.
      ik0=find(obcs0{iobcs}.imask==1);           %2 pts
      eval(['tmp1=nan.*' varstr{ivar} '{iobcs};']);
      eval(['tmp0=' varstr{ivar} '0{iobcs};']);
      for i=1:length(ik);
        tmpp(ik(i),:,:,:)=tmp0(ik0(1),:,:,:);   %assuming same nz
      end;
%annoyingly the eyeballing indices are with respect to 1st index and not to ind
      %tmpp=tmpp(1:sz(1),:,:);
    %else;
      %tmpp=tmpp(ind{iobcs},:,:);
    end;

    z0=abs(rC0');z1=abs(rC');
    tmp=zeros(size(tmpp,1),nz,size(tmpp,3));
    for k=1:nz;
      iz=sort(closest(z1(k),z0,2));
      ss=prod(sign(z0(iz)-z1(k)));
      if(ss>0&sign(z0(iz(1))-z1(k))>0);		%above z0(1)
        w1=1;w2=0;
      elseif(ss>0&sign(z0(iz(1))-z1(k))<0);	%below z0(end)
        w1=0;w2=1;
      else;
        dz=z0(iz(2))-z0(iz(1));			%positive
        dz1=z1(k)-z0(iz(1));w1=1-dz1/dz;
        dz2=z0(iz(1))-z1(k);w2=1-w1;
      end;
      tmp(:,k,:)=w1.*tmpp(:,iz(1),:)+w2.*tmpp(:,iz(2),:);
    end;

    %sz_tmp0=size(tmp0);if(length(sz_tmp0)==2);sz_tmp0=[sz_tmp0 1];end;
    %tmp=zeros(sz(1),nz,sz_tmp0(3));	%	<-- need fixing
    %for it=1:sz_tmp0(3);
    %  tmp(:,:,it)=griddata(x0,z0,tmpp(:,:,it),x,z,'linear');
    %  if(mod(it,12)==0|it==sz_tmp0(3));fprintf('%i ',it);end;
    %end;
    %for k=1:length(iznan);
    %  tmp(:,iznan(k),:)=tmpp(:,1,:);	%	<-- need fixing
    %  fprintf('%i ',k);
    %end;
    %fprintf('\n');

    eval([varstr{ivar} '{iobcs}=tmp;']);
  end;
end;


%check obcs:
for iobcs=1:size(obcs0,2);
  fnames=fieldnames(obcs0{iobcs});
  clear sz0 szp iz ix tmp tmp0 z0 x0 z x
  sz0=size(T0{iobcs});					%[nx0 nz0 nt]
  sz =size(T{iobcs});					%[nx0 nz0 nt]
  [z0,x0]=meshgrid(rC0,1:sz(1));
  [z ,x ]=meshgrid(rC ,1:sz(1));

  for ifld=1:size(fnames,1);
    clear fnamep iz ix szp tmp
    fnamep=char(fnames(ifld));

    if(isfield(obcs{iobcs},fnamep)==0);			%if field does not exist in obcs
%12 pad 26 D1 27 D2 28 hfC1 29 hfC2 30 hfS 31 hfW 32 rF 33 drF 34 tt 35 RunStr 36 RunStrShort
      %fprintf('%i ',ifld);fprintf('%s ',fnamep);
      eval(['tmp0=obcs0{iobcs}.' fnamep ';']);
      szp=size(tmp0);
      iz=find(szp==sz0(2));	%nz0
      ix=find(szp==sz0(1));	%nx0
      if(length(szp)==2);szp=[szp 1];end;

      if(ix==1);
        if(isempty(iz)==1);
          tmp=interp_llc270toXXXX_v6(tmp0,flagXX,0,0,nx,drF0,drF);
          if(eyeballing_Gibraltar==1 & obcs{iobcs}.flag_case==1);
            tmp=zeros(size(tmp));
            ik =find(obcs{iobcs}.imask==1);            %2 or 4 or 6 or etc.
            ik0=find(obcs0{iobcs}.imask==1);           %2 pts
            for i=1:length(ik);
              eval(['tmp(ik(i))=obcs0{iobcs}.' fnamep '(ik0(1));']);
            end; 
            tmp=tmp(1:length(ind{iobcs}),:);
          else;
            tmp=tmp(ind{iobcs},:);
          end;
        elseif(iz==2);
          if(length(strfind(fnamep,'hf'))>0);			%skipping hf[S,W] for now
            if(fnamep(3)=='C');
              fprintf('%s ',fnamep);
              eval(['D=interp_llc270toXXXX_v6(obcs0{iobcs}.D' fnamep(4) ',flagXX,0,0,nx,drF0,drF);']);
              if(eyeballing_Gibraltar==1 & obcs{iobcs}.flag_case==1);
%in the case of eyeballing, will match exactly
                D=0.*D;
                ik =find(obcs{iobcs}.imask==1);            %2 or 4 or 6 or etc.
                ik0=find(obcs0{iobcs}.imask==1);           %2 pts
                for i=1:length(ik);
                  eval(['D(ik(i))=obcs0{iobcs}.D' fnamep(4) '(ik0(1));']);
                end; 
                D=D(1:length(ind{iobcs}),:);
              else;
                D=D(ind{iobcs},:);
              end;
              [junk,hfnew]=calc_hFacC(-abs(D),hFacMin,hFacMinDr,drF,rF);
              tmp=hfnew;
            elseif(fnamep(3)=='S'|fnamep(3)=='W');
              fprintf('%s ',fnamep);
              tmp=nan(length(ind{iobcs}),length(iz),szp(3));
            end;
          else;
            tmpp=interp_llc270toXXXX_v6(tmp0,flagXX,0,0,nx,drF0,drF);
            tmpp=tmpp(ind{iobcs},:,:);

            z0=abs(rC0');z1=abs(rC');
            tmp=zeros(size(tmpp,1),nz,size(tmpp,3));
            for k=1:nz;
              izp=sort(closest(z1(k),z0,2));
              ss=prod(sign(z0(izp)-z1(k)));
              if(ss>0&sign(z0(izp(1))-z1(k))>0);		%above z0(1)
                w1=1;w2=0;
              elseif(ss>0&sign(z0(izp(1))-z1(k))<0);		%below z0(end)
                w1=0;w2=1;
              else;
                dz=z0(izp(2))-z0(izp(1));			%positive
                dz1=z1(k)-z0(izp(1));w1=1-dz1/dz;
                dz2=z0(izp(1))-z1(k);w2=1-w1;
              end;
              tmp(:,k,:)=w1.*tmpp(:,izp(1),:)+w2.*tmpp(:,izp(2),:);
            end;

            %sz_tmp0=size(tmp0);if(length(sz_tmp0)==2);sz_tmp0=[sz_tmp0 1];end;
            %tmp=zeros(sz(1),nz,sz_tmp0(3));	%	<-- need fixing
            %for it=1:sz_tmp0(3);
            %  tmp(:,:,it)=griddata(x0,z0,tmpp(:,:,it),x,z,'linear');
            %end;
            %for k=1:length(iznan);
            %  tmp(:,iznan(k),:)=tmpp(:,1,:);	%	<-- need fixing
            %end;
          end;
        end; %iz
        eval(['obcs{iobcs}.' fnamep '=tmp;']);

      end;   %ix
    end;     %isfield
    %fprintf('\n');
  end;       %ifld
  str=obcs{iobcs}.obcsstr;
  tmp=cat(3,obcs{iobcs}.hfC1,obcs{iobcs}.hfC2);
  if(str=='S'|str=='N');
    obcs{iobcs}.hfS=min(tmp,[],3);
  elseif(str=='E'|str=='W');
    obcs{iobcs}.hfW=min(tmp,[],3);
  end;
  
end;         %iobcs

%fix special case Gibraltar strait
for iobcs=1:size(obcs,2);
  if(obcs{iobcs}.flag_case==1 & eyeballing_Gibraltar==0);
%   Lx=length(obcs{iobcs}.ix);
    ij=find(obcs{iobcs}.imask==0);
    str={'D1','D2','hfC1','hfC2','hfW','hfS'};
    for istr=1:size(str,2);
      if(isfield(obcs{iobcs},str{istr})==1);
        %eval(['obcs{iobcs}.' str{istr} '=obcs{iobcs}.' str{istr} '(1:Lx,:);']);
        eval(['obcs{iobcs}.' str{istr} '(ij,:)=0;']);
      end;
    end;
    str={'T','S','U','V'};
    for istr=1:size(str,2);
      eval([str{istr} '{iobcs}=' str{istr} '{iobcs}(1:Lx,:,:);']);
    end;
  end;
end;


%prior to updating hFac: check transport:
%note at the moment it's hard-coded to test a very specific set up NA540x270 only.
%If have other set up, set the str[1,2,3] appropriately.

check_transport=1;

if(check_transport==1);
  str1={'V','V','U','U','U'};
  str2={'x','x','y','y','y'};
  str3={'S','S','W','W','W'};
  %str1={'V','U','U','U'};
  %str2={'x','y','y','y'};
  %str3={'S','W','W','W'};

  for iobcs=1:size(obcs,2);
    clear tmp sc vel ds hf tmp0 vel0 ds0 hf0 a
    
    eval(['sc =repmat(obcs{iobcs}.scale' upper(str2{iobcs}) ''',[1 nz nt]);']);%sc =repmat(obcs{iobcs}.scaleX',[1 nz nt]);
    eval(['vel=' str1{iobcs} '{iobcs}.*sc;']);					%vel=V{iobcs}.*sc;
    eval(['ds =obcs{iobcs}.d' str2{iobcs} 'g'';']);				%ds =obcs{iobcs}.dxg';
    eval(['hf =obcs{iobcs}.hf' str3{iobcs} ';']);				%hf =obcs{iobcs}.hfS;
    tmp=compute_gate_transport(vel,ds,drF,hf);
  
    eval(['vel0=' str1{iobcs} '0{iobcs};']);
    eval(['ds0 =obcs0{iobcs}.d' str2{iobcs} 'g'';']);
    eval(['hf0 =obcs0{iobcs}.hf' str3{iobcs} ';']);
    tmp0=compute_gate_transport(vel0,ds0,drF0,hf0);
  
    a=tmp-tmp0;fprintf('iobcs: %i , [sum,mean] resid transport: %g %g\n',[iobcs,sum(a),mean(a)]);
    if(obcs{iobcs}.flag_case==1);
      fprintf('Gibralta mean transport [obcs0,obcs]: %f %f\n',[mean(tmp0) mean(tmp)]./1e6);
      fprintf('Correct Gibralta mean transport is 0.046344737627870 Sv\n');		%eccov4r3
    end;
  end;
% from aste_1080x1260x540x90:
  %iobcs: 1 , [sum,mean] resid transport: -3.99128e+07 -237576
  %iobcs: 2 , [sum,mean] resid transport: -4.86207e+07 -289409
  %iobcs: 3 , [sum,mean] resid transport:  3.14668e+06 18730.2
  %Gibralta mean transport [obcs0,obcs]:   0.046192    0.064922
  %Correct Gibralta mean transport is 0.046344737627870 Sv
% from this set up, NA_4320x2160x1080
  %iobcs: 2 , [sum,mean] resid transport: -3.89819e+06 -23203.5
  %iobcs: 3 , [sum,mean] resid transport: 1.65813e+07 98698.5
  %iobcs: 4 , [sum,mean] resid transport: 3.4871e+07 207566
  %iobcs: 5 , [sum,mean] resid transport: 3.14668e+06 18730.2
  %Gibralta mean transport [obcs0,obcs]: 0.046192 0.064922
  %Correct Gibralta mean transport is 0.046344737627870 Sv

  clear tmp sc vel ds hf tmp0 vel0 ds0 hf0 a str1 str2 str3
end;

str={'T','S','U','V'};
for iobcs=1:size(obcs,2);
  for istr=1:size(str,2);
    if(isfield(obcs{iobcs},str{istr}));
      eval([str '{istr}=obcs{iobcs}.' str '{istr};']);
    end;
  end;
end;

save(fsave,'obcs','T','S','U','V','-v7.3');fprintf('%s\n',fsave);

