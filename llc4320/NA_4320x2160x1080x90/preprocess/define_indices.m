%% SETTING REGIONAL DOMAIN INDICIES OF LLC GRID
% Call first

%% ================ PARENT REGIONAL SIZE ======================================
% Information provided by An with previous regional cuts in llc270
nx0=270;
ny0=1350; nz0=50; nfx0=[nx0 0 nx0 180 450];nfy0=[450 0 nx0 nx0 nx0];
sum_nfac0=nfy0(1)+nfy0(2)+nfy0(3)+nfx0(4)+nfx0(5);

deltaT=1200;yrStart=2002;moStart=1;

%% ================ DOMAIN REGIONAL SIZE ======================================
nx =    4320;nxstr=num2str(nx);
fac =   nx/nx0;
nz =    90;
ncut1 = 2160;				%
ncut2 = 1080;				%
ny =    2*ncut2;			% 2160
%remember: read in dim is 2160 x ny

nfx=[ncut1 0 0 0 ncut2];nfy=[ncut2 0 0 0 ncut1];

%% ================ DOMAIN INDICES ============================================
ix1=1:ncut1;                    % global:   [ 1   2160] 
iy1=9377:9377+ncut2-1;			%           [9377 10456]

ix5=3*nx-[iy1(end):-1:iy1(1)]+1;        % global [2505 3584]
iy5=sort(nx-ix1)+1;                     % global [2161 4320]

%% ================ PARENT INDICES ============================================
ix1_0=ceil(ix1(1)/fac):ix1(end)/fac;            %global [   1  135]
iy1_0=[floor(iy1(1)/fac):ceil(iy1(end)/fac)];   %global [ 586  654]

ix5_0=sort(3*nx0-(iy1_0)+1);                    %global [157  225]
iy5_0=ceil(iy5(1)/fac):iy5(end)/fac;            %global [136  270]

% ---------- Print regional ids of domain and parent ----------
fprintf('ix1  : %6i %6i ',[ix1(1) ix1(end)]);
fprintf('; iy1  : %6i %6i\n',[iy1(1) iy1(end)]);
fprintf('ix5  : %6i %6i ',[ix5(1) ix5(end)]);
fprintf('; iy5  : %6i %6i\n',[iy5(1) iy5(end)]);
fprintf('ix1_0: %6i %6i ',[ix1_0(1) ix1_0(end)]);
fprintf('; iy1_0: %6i %6i\n',[iy1_0(1) iy1_0(end)]);
fprintf('ix5_0: %6i %6i ',[ix5_0(1) ix5_0(end)]);
fprintf('; iy5_0: %6i %6i\n',[iy5_0(1) iy5_0(end)]);

fprintf('[ncut1 ncut2] = %i %i\n',[ncut1 ncut2]);	%[2160 1080]

%% ================ SAVE STRINGS ==============================================
id.nx = num2str(nx);
id.nx0 = num2str(nx0);
id.ncut1 = num2str(ncut1);
id.ncut2 = num2str(ncut2);
id.nz = num2str(nz);
