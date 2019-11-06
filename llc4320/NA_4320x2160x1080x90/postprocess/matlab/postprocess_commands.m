which read_slice
pwd
nx = 2160; ny = 2160; nz = 90;
a = read_slice('pickup.0000010560.data', nx, ny, 1+(3-1)*nz, 'real*8');
pwd
a1=a(:,1:1080);
a5=reshape(a(:,1081:2160),1080,2160);
size(a1)
size(a50
size(a50)
size(a5)
%a15=cat(1,a1,sym_g_mod(a5,7,0));
a15=cat(1,sym_g_mod(a5,7,0),a1);
figure(1);clf;pcolor(a15');shading flat;colorbar;grid
nx = 2160; ny = 2160; nz = 90;nfx=[nx 0 0 0 1080];nfy=[1080 0 0 0 nx];
u = read_slice('pickup.0000010560.data', nx, ny, 1+(1-1)*nz, 'real*8');
v = read_slice('pickup.0000010560.data', nx, ny, 1+(2-1)*nz, 'real*8');
[u,v]=get_aste_vector(u,v,nfx,nfy,1);
size(u)
uc=zeros(4320,1080);uc=(u(1:4320,1:1080)+u(2:4321,1:1080))./2;
vc=zeros(4320,1080);vc=(v(1:4320,1:1080)+v(1:4320,2:1081))./2;
sp=sqrt(uc.^2+vc.^2);
figure(1);clf;pcolor(sp');shading flat;colorbar;grid
ix=1:4320;iy=1:1080;
ix1=ix(1):4:ix(end);iy1=iy(1):4:iy(end);
size(ix1)
size(iy1)
ix1=ix(1):8:ix(end);iy1=iy(1):8:iy(end);
hold on;aa=myquiver(ix1,iy1,uc(ix1,iy1)',vc(ix1,iy1)',5);hold off;set(aa,'color',.8.*[1 1 1]);