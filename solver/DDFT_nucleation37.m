%based on DDFT_nucleation29
%5 snapshots. kernelSize = 10
addpath('../../CHACR/GIP')
runoptim = true;

tic;
L = [5,5];
N = [256,256];
n = prod(N);

params.N = N;
params.L = L;

[k2,k] = formk(N,L);
k0 = 10;
alpha = 5;
params.C = exp(-(sqrt(k2)-k0).^2/(2*alpha^2))*0.95;

[t1,y1,params] = solver_DDFT([],[],params);

xx = linspace(0,L(1),N(1));
yy = linspace(0,L(2),N(2));
[xx,yy] = ndgrid(xx,yy);
center = L/2;
radius = 0.06*L(1);
thickness = 0.01*L(1);
roi = roi_circle(xx,yy,center,radius,thickness);

%nucleus
y0 = y1(end,:)';
roi = roi(:);
y02 = 0.045;
rho = (y02*n - sum(roi.*y0)) / sum(1-roi);
y0 = roi.*y0 + (1-roi)*rho;

tspan2 = linspace(0,2.5,100);
[t2,y2] = solver_DDFT(tspan2,y0,params);

ind = 1:20:100;
tdata = t2(ind);
ydata = y2(ind,:);
toc


kernelSize = 300;
Cspace = 'isotropic_fourier_scale';
params.moreoptions = moreodeset('gmresTol',1e-5);


resultpath = [largedatapath,'DDFT_nucleation37.mat'];

kmax = floor(params.N(1)/2+1)/params.L(1)*2*pi;
if runoptim
  [hessian,hessian_t,dy] = IP_DDFT(tdata,ydata,params,kernelSize,Cspace,[],[],'discrete',true,'cutoff',kmax,'assign_suppress',{'C'},'mode','sens');
  save(resultpath,'hessian','hessian_t','dy');
else
  load(resultpath);
end
