%----- define size, grid ---------
nx0=270;
ny0=1350; nz0=50; nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
sum_nfac0=nfy0(1)+nfy0(2)+nfy0(3)+nfx0(4)+nfx0(5);

deltaT=1200;yrStart=2002;moStart=1;

nx =1080;nxstr=num2str(nx);
fac=nx/nx0;
nz =90;
ncut1=1440;				%540
ncut2=540;				%540
ny=2*ncut1+nx+ncut2;

%----- define indices of domain ---------
nfx=[nx 0 nx ncut2 ncut1];nfy=[ncut1 0 nx nx nx];

ix1=1:nx;                                       %global [   1 1080] 
iy1=3*nx-ncut1+1:3*nx;                          %global [1801 3240]
fprintf('ix1  : %6i %6i ',[ix1(1) ix1(end)]);fprintf('; iy1  : %6i %6i\n',[iy1(1) iy1(end)]);

ix3=1:nx;					%global [   1 1080]
iy3=1:nx;					%global [   1 1080]
fprintf('ix3  : %6i %6i ',[ix3(1) ix3(end)]);fprintf('; iy3  : %6i %6i\n',[iy3(1) iy3(end)]);

ix4=1:ncut2;					%global [   1  540]
iy4=1:nx;					%global [   1 1080]
fprintf('ix4  : %6i %6i ',[ix4(1) ix4(end)]);fprintf('; iy4  : %6i %6i\n',[iy4(1) iy4(end)]);

ix5=3*nx-[iy1(end):-1:iy1(1)]+1;                %global [   1 1440]
iy5=sort(nx-ix1)+1;                             %global [   1 1080]
fprintf('ix5  : %6i %6i ',[ix5(1) ix5(end)]);fprintf('; iy5  : %6i %6i\n',[iy5(1) iy5(end)]);

ix1_0=ceil(ix1(1)/fac):ix1(end)/fac;            %global [   1  270]
iy1_0=[floor(iy1(1)/fac):ceil(iy1(end)/fac)];   %global [ 450  810]
fprintf('ix1_0: %6i %6i ',[ix1_0(1) ix1_0(end)]);fprintf('; iy1_0: %6i %6i\n',[iy1_0(1) iy1_0(end)]);

ix3_0=1:nx0;
iy3_0=1:nx0;
fprintf('ix3_0: %6i %6i ',[ix3_0(1) ix3_0(end)]);fprintf('; iy3_0: %6i %6i\n',[iy3_0(1) iy3_0(end)]);

ix4_0=1:ncut2/fac;				%global [   1  135]
iy4_0=1:nx0;					%global [   1  270]
fprintf('ix4_0: %6i %6i ',[ix4_0(1) ix4_0(end)]);fprintf('; iy4_0: %6i %6i\n',[iy4_0(1) iy4_0(end)]);

ix5_0=sort(3*nx0-(iy1_0)+1);                    %global [   1  361]
iy5_0=ceil(iy5(1)/fac):iy5(end)/fac;            %global [   1  270]
fprintf('ix5_0: %6i %6i ',[ix5_0(1) ix5_0(end)]);fprintf('; iy5_0: %6i %6i\n',[iy5_0(1) iy5_0(end)]);

%-------------
%the variables ncut[1,2] below inherit their names from some existing code i have, where i cut
%the various faces or dimension (x,y), so they don't really have any meaning other than being
%two variables for use from now on.

fprintf('[ncut1 ncut2] = %i %i\n',[ncut1 ncut2]);	%[450 360]
