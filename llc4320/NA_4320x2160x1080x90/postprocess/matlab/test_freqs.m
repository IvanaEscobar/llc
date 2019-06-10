clear all;warning off
tidestr={'m2','s2','n2','k2','k1','o1','p1','q1','mf','mm','m4','ms4','mn4'};
 tidalPeriod  =[ 44714.165, 43200.001, 45570.054, 43082.050, 86164.077, 92949.636, 86637.200, 96726.086, 1180295.546, 2380715.864, 22357.091, 21972.022, 22569.042];

nx=2160;
ny=2160;
%pick 5 points we will look at, aim

dirgrid=['/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_pk0000000001/GRID/'];
yc=rdmds([dirgrid 'YC']);yc=reshape(yc,nx,ny);
D=rdmds([dirgrid 'Depth']);D=reshape(D,nx,ny);
Df{1}=D(:,1:ny/2);
Df{5}=reshape(D(:,ny/2+1:ny),ny/2,nx);

%figure(1);clf;
%subplot(121);mypcolor(Df{1}');colorbar;grid;
%subplot(122);mypcolor(Df{5}');colorbar;grid;

%keyboard

%now pick our 5 points
ix_f1=[682 163 515];
iy_f1=[273 944 539];
ix_f5=[958 443 109];
iy_f5=[625 1606 1952];

%now put face5 indices back into compact format
tmp=zeros(size(Df{5}));
for i=1:length(ix_f5)
  tmp(ix_f5(i),iy_f5(i))=1;
end;
tmp=reshape(tmp,nx,ny/2);
ii5=find(tmp~=0);ii5=ii5+nx*ny/2;

ii1=(iy_f1-1)*nx+ix_f1;
ind=[ii1,ii5'];%588202,2037043,1162595,

lat0=yc(ind);
f0=(1./(2.*7.292115e-5.*sin(lat0.*pi./180)./2./pi))./3600;
%22.9,17.95,20.49,24.68,19.77,17.81 hrs]

 dirin=[dirgrid '../diags/STATE/'];
 varstr='state_2d_hourly';

 flist=dir([dirin varstr '.*.data']);

 L=length(flist);
dirout=[dirin '../../'];
fsave=[dirout 'Eta_sixpoints.mat'];
if(~exist(fsave));
   eta=zeros(L,length(ind));
   for i=1:L
     %tic;
     t1=clock;
     a=read_slice([dirin flist(i).name],nx,ny,1);
     %toc;
     eta(i,:)=a(ind);
     if(mod(i,24)==0);t2=clock;fprintf('%i %f ',[i etime(t2,t1)]);end;
   end;

   %now loop once more just ot get time 
     tt=zeros(L,6);
     idot=find(flist(1).name=='.');idot=idot(1)+1:idot(2)-1;
     for i=1:L
        ts=str2num(flist(i).name(idot));
        tmp=datevec(ts2dte(ts,90,2002,1,1));
        tt(i,1:4)=tmp(1:4);
        tt(i,5)=ts;
        tt(i,6)=datenum(tmp);
     end;
   save(fsave,'eta','tt','ind','dirin','-v7.3');
 else;
     load(fsave);
 end;
 
figure(1);clf;
for i = 1:length(ind)
    c=eta(:,i);
   [Pw_m,fw_m]=periodogram(c-mean(c));
   %[Pw_m,fw_m]=pmtm(c-mean(c));
    subplot(3,2,i);
    loglog(1./(fw_m./(2*pi)),Pw_m.*(2*pi).^2);grid;
    hold on;loglog([12 12],[1e-6 1e4],'r-','linewidth',2);
            loglog([24 24],[1e-6 1e4],'g-','linewidth',2);
            for j=1:length(tidalPeriod);%[1,2,5,6];
                loglog([tidalPeriod(j) tidalPeriod(j)]/3600,[1e-6 1e4],'k-','linewidth',2);
                text(tidalPeriod(j)/3600,1e4,tidestr{j});
            end;
            hold off;
     xlabel('Period in hours');ylabel('Spectral density [Pa^2/hr], NASA');%'JC');
end
savefig('spectral_wtides.fig');
