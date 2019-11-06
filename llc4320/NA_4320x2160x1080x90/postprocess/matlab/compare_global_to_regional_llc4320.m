clear all

%% Get Lat Lon from global MITgcm output
ptsDir=['/work/05427/iescobar/NA4320-data/MITgcm48_BArbic/AmPhsingle/'];
fName=['ampphaseSingle'];

% Initialize data tensors
npts=35; tpts=4320;
latlist=zeros(1,npts); 
lonlist=zeros(1,npts);
sshlist=zeros(tpts, npts);

for i=1:npts
    load([ptsDir, fName, num2str(i, '%02d'), '.mat']);
    latlist(1, i)=latl; lonlist(1, i)=lonl; 
    sshlist(:, i)= ssh;
end

%% Find same lat lon in regional domain
binDir=['/work/05427/iescobar/stampede2/llc/llc4320/'...
    'NA_4320x2160x1080x90/root/run_template/input_binaries/'];
gridlist=dir([binDir 'tile*.mitgrid']);

fldNames={'XC','YC','DXF','DYF','RAC','XG','YG','DXV','DYU','RAZ',...
    'DXC','DYC','RAW','RAS','DXG','DYG'};

nx=2160;
ncut2=1080;
ny=2*ncut2;
nfx=[nx 0 0 0 ncut2];nfy=[ncut2 0 0 0 nx];

face1=1;
xc=read_slice([binDir gridlist(face1).name],nfx(face1)+1,nfy(face1)+1,1,'real*8');
yc=read_slice([binDir gridlist(face1).name],nfx(face1)+1,nfy(face1)+1,2,'real*8');
xg=read_slice([binDir gridlist(face1).name],nfx(face1)+1,nfy(face1)+1,6,'real*8');
yg=read_slice([binDir gridlist(face1).name],nfx(face1)+1,nfy(face1)+1,7,'real*8');

