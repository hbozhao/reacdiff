%based on DDFT_nucleation29
%5 snapshots. kernelSize = 10
addpath('../../CHACR/GIP')
runoptim = false;

tic;
L = [5,5];
N = [256,256];
n = prod(N);

params.N = N;
params.L = L;

[k2,k] = formk(N,L);
k0 = 10;
alpha = 5;
modelfunc = @(x) exp(-(x-k0).^2/(2*alpha^2))*0.95;
params.C = modelfunc(sqrt(k2));

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


kernelSize = 10;
Cspace = 'user';
params.moreoptions = moreodeset('gmresTol',1e-5);

%basis function here is hermitefunction scaled by 1/sqrt(eigenvalue), where eigenvalue is (2n+1) as in x^2 y(x) - y''_n(x) = (2n+1) y_n(x)
% customfunc = @(x) hermitefunction(x/k0,kernelSize,[],1) ./ sqrt(1:2:(2*kernelSize-1));
%get mu parameters at truth
% xfit = linspace(0,3*k0,20)';
% x_start = customfunc(xfit) \ modelfunc(xfit);
%provide Csensval

%I changed my mind, just use normalized hermitefunction, so prior is just exp(-||C(k)||_2^2/2)
customfunc = @(x) hermitefunction(x/k0,kernelSize,[],1);
k = sqrt(k2);
params.Csensval = reshape(customfunc(k(:)), [size(k),kernelSize]);

logpdf = @(x) IP_DDFT(tdata,ydata,params,kernelSize,Cspace,[],x,'Nmu',0,'discrete',true,'cutoff',k0,'mode','eval');

% name = 'DDFT_nucleation30_DILI_MAP';
% resultpath = [largedatapath,name,'.mat'];
% if ~exist(resultpath,'file')
%   %find MAP
%   x_guess = zeros(1,kernelSize);
%   optoptions = optimoptions('fminunc','SpecifyObjectiveGradient',true,'Display','iter-detailed','MaxIterations',50,'StepTolerance',1e-6,'FunctionTolerance',1e-6,'HessianFcn','objective','Algorithm','trust-region');
%   optoptions = optimoptions(optoptions,'OutputFcn',@(x,optimvalues,state) save_opt_history(x,optimvalues,state,resultpath));
%   [x_start, Smin] = IP_DDFT(tdata,ydata,params,kernelSize,Cspace,optoptions,x_guess,'Nmu',0,'discrete',true,'cutoff',k0);
% else
%   varload = load(resultpath);
%   x_start = varload.history(end,:);
% end

%use result from DDFT_nucleation30 directly
varload = load([largedatapath,'DDFT_nucleation30']);
x_start = varload.history(end,:);

options = [];
options.init = x_start;
options.N = 20000;
options.logpdf = logpdf;
options.eigthresh = 0.1;
options.eigthresh_local = 1e-4;
options.tLIS = 0.1;
options.tCS = 1;
options.nlag = 100;
options.nb = 50; %have nlag and nb when constr is used, try see if less infeasible samples are taken
options.nmax = 100;
options.verbose = true;
options.proposal = 'LI_Prior';
options.sigmae = 1e-4;
options.resultpath = [largedatapath,'DDFT_nucleation30_DILI'];
options.saveperstep = 100;

rng(1);
if rundili
  [chain,result] = mcmc_DILI(options);
end