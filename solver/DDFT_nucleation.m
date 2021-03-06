tic;
L = [5,5];
N = [256,256];
n = prod(N);

params.N = N;
params.L = L;

[t1,y1,params] = solver_DDFT([],[],params);

xx = linspace(0,L(1),N(1));
yy = linspace(0,L(2),N(2));
[xx,yy] = ndgrid(xx,yy);
range = [1.5,3.5];
thickness = 0.1;
roi = roi_rectangle(xx,yy,range,range,thickness);
center = L/2;
radius = 0.18*L(1);
thickness = 0.01*L(1);
roi = roi_circle(xx,yy,center,radius,thickness);

%nucleus
y0 = y1(end,:)';
roi = roi(:);
rho = (sum(y0) - sum(roi.*y0)) / sum(1-roi);
y0 = roi.*y0 + (1-roi)*rho;
figure; imagesc(reshape(y0,N));

tspan2 = linspace(0,0.4,100);
[t2,y2] = solver_DDFT(tspan2,y0,params);

figure; visualize([],[],[],y2(1:10:end,:),'c',false,'ImageSize',N);

ind = 1:5:100;
tdata = t2(ind);
ydata = y2(ind,:);
toc

% x_opt = IP_DDFT(tdata,ydata,params,[21,21],'k'); %this stagnates at iter 17 after 63 func counts

% x_opt = IP_DDFT(tdata,ydata,params,[61,61],'real');

options = optimoptions('fminunc','HessianFcn','objective','Algorithm','trust-region');
x_opt = IP_DDFT(tdata,ydata,params,10,'isotropic',options);

% ind = 10:3:61;
% tdata = t1(ind);
% ydata = y1(ind,:);
% x_opt = IP_DDFT(tdata,ydata,params,[21,21],'k'); %this stagnates at iter 1 after 37 func counts
