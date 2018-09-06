%07Feb2018
%use bathy derived from aste_1080x1440x540x90, should be identical
% because obcs is above jy=180 (1440-1260)=180
clear all;

define_indices;
set_directory;

bathyIn=['/scratch/atnguyen/aste_1080x1440x540x90/run_template/bathy_aste1080x1440x540_obcs13Jan2018_v2.bin'];
b0=readbin(bathyIn,[nx 2*1440+nx+540]);
b0f{1}=b0(:,1:1440);
b0f{3}=b0(:,1441:1440+nx);
b0f{4}=reshape(b0(:,1440+nx+1:1440+nx+540),540,nx);
b0f{5}=reshape(b0(:,1440+nx+540+1:1440+nx+540+1440),1440,nx);

%now recut:
b1f{1}=b0f{1}(:,1440-ncut1+1:1440);
b1f{3}=b0f{3};
b1f{4}=b0f{4};
b1f{5}=b0f{5}(1:ncut1,:);

b1=cat(2,b1f{1},b1f{3},reshape(b1f{4},nx,ncut2),reshape(b1f{5},nx,ncut1));

fOut=[dirGridOut 'bathy_aste' nxstr 'x' num2str(ncut1) 'x' num2str(ncut2) '_obcs13Jan2018_v2.bin'];
writebin(fOut,b1,1,'real*4');
