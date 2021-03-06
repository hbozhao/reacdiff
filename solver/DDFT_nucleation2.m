addpath('../../CHACR/GIP')
runoptim = false;

tic;
L = [5,5];
N = [256,256];
n = prod(N);

params.N = N;
params.L = L;

if ~exist('tdata','var')
  [t1,y1,params] = solver_DDFT([],[],params);

  xx = linspace(0,L(1),N(1));
  yy = linspace(0,L(2),N(2));
  [xx,yy] = ndgrid(xx,yy);
  range = [1.5,3.5];
  thickness = 0.1;
  roi = roi_rectangle(xx,yy,range,range,thickness);
  center = L/2;
  radius = 0.06*L(1);
  thickness = 0.01*L(1);
  roi = roi_circle(xx,yy,center,radius,thickness);

  %nucleus
  y0 = y1(end,:)';
  roi = roi(:);
  rho = (sum(y0) - sum(roi.*y0)) / sum(1-roi);
  y0 = roi.*y0 + (1-roi)*rho;
  figure; imagesc(reshape(y0,N));

  tspan2 = linspace(0,1.05,100);
  tspan2 = linspace(0,1.5,100);
  [t2,y2] = solver_DDFT(tspan2,y0,params);

  figure; visualize([],[],[],y2(1:10:end,:),'c',false,'ImageSize',N);

  ind = 20:2:100;
  tdata = t2(ind);
  ydata = y2(ind,:);
  toc
end

kernelSize = [21,21];
Cspace = 'k';

resultpath = [largedatapath,'DDFT_nucleation2.mat'];
if runoptim
  save_history = true;
  options = optimoptions('fminunc');
  if save_history
    options = optimoptions(options,'OutputFcn', @(x,optimvalues,state) save_opt_history(x,optimvalues,state,resultpath));
  end

  x_opt = IP_DDFT(tdata,ydata,params,kernelSize,Cspace,options,x_opt);
  % [val,gradient] = IP_DDFT_debug(x_opt/max(x_opt)*1.2,tdata,ydata,params,[21,21],'k');
else
  meta.C.index = floor((prod(kernelSize)+1)/2);
  meta.C.exp = false;
  frameindex = [1,6,12,23,41];
  history_production(resultpath,[1,2,11,71,171],[],[],meta,tdata-tdata(1),ydata,params,kernelSize,Cspace,'FrameIndex',frameindex,'CtruthSubplot',[2,length(frameindex)]);
  f = gcf;
  f.Position = [680 337 522 641];
end
