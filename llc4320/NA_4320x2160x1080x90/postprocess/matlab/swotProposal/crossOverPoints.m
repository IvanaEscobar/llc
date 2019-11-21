clear all; clc;
define_indices;

%% An's dirs:
%dirRoot='/work/03901/atnguyen/Ivana/llc4320/NA_4320x2160x1080x90/';
%dirRun=[dirRoot 'run_c67h_tidal_bc_pk0000000001/'];
%dirOut =[dirScratch 'extract_hourly/'];        if(~exist(dirOut)); mkdir(dirOut); end
%dirGrid=[dirRoot 'GRID/'];
%% Setting Directories and Domain Info: Escobar's NA setup
dirWork='/work/05427/iescobar/stampede2/llc/llc4320/NA_4320x2160x1080x90/';
dirScratch='/scratch/05427/iescobar/llc/llc4320/NA_4320x2160x1080x90/run_c67h_tidal_bc_pk0000000001/';
dirGrid=[dirWork 'GRID/'];
% Depth
depth=rdmds([dirGrid 'Depth']); depth=reshape(depth, id.n.x/2, id.n.y);
depf{1}=depth(:,1:id.n.y/2); depf{5}=depth(:,id.n.y/2+1:end);
depf{5}=reshape(depf{5},id.n.y/2,id.n.x/2);
% Latitude
yc=rdmds([dirGrid 'YC']); yc=reshape(yc, id.n.x/2, id.n.y);
ycf{1}=yc(:,1:id.n.y/2); ycf{5}=yc(:,id.n.y/2+1:end);
ycf{5}=reshape(ycf{5},id.n.y/2,id.n.x/2);
% Longitude
xc=rdmds([dirGrid 'XC']); xc=reshape(xc, id.n.x/2, id.n.y);
xcf{1}=xc(:,1:id.n.y/2); xcf{5}=xc(:,id.n.y/2+1:end);
xcf{5}=reshape(xcf{5},id.n.y/2,id.n.x/2);
%% Find yc closest to 35.74558 deg and xg closest to -73.95567 deg
% yc_id is i540 on ycf{5} for all j;
% xc_id is j435 on xcf{5} for all i;
% NOTE: use aste indices for get_wet_ind_single_section.m
% ycaste=get_aste_tracer(yc,id.nf.x,id.nf.y); xcaste=get_aste_tracer(xc,id.nf.x,id.nf.y); depaste=get_aste_tracer(depth,id.nf.x,id.nf.y);
% ix_prof=closest(-73.95,xcaste(:,540));
%% Plot YC or XC and find a point nearest the cross section center
%figure(1); clf; 
%subplot(121); mypcolor(depf{1}'); grid; 
%subplot(122); mypcolor(depf{5}'); grid;

%% Pick random points around the crossover point and store indices
idDist=5; idXC=435; idYC=541; numPts=200;
xc_list=[idXC round(idDist*randn(numPts,1)+idXC)'];
yc_list=[idYC round(idDist*randn(numPts,1)+idYC)'];

c_list=unique([xc_list;yc_list]','rows');
xc_list=c_list(:,1)';yc_list=c_list(:,2)';

save([dirScratch 'crossOverPoints2.mat'], '-v7.3', 'xc_list', 'yc_list');
%% NOTE: an improvement would be to make a uniform distribution about the
%       center lat lon and a standard deviation of a distance we like (like
%       the swath distance) then find the indices closest to those random
%       points. 