%% animate brain with nodes drawn as spheres colored by time series yp,
% using scatter 3. The z-direction is collapsed and the brain jiggles like
% particles on a drum.
%
% sphereax - handle to axes to plot the spheres in
% yp - time series
% timeax - handle to axes to overlay a sliding time marker line on
% tp - time, same length as yp, and assumed exactly this is plotted on axis
%      timeax
% timelinestyle - linestyle for the time line (e.g., 'r--')
% cmap - colormap (optional)
% USAGE: 
%{ 
   figure(1)
   sph_ax = subplot(2,1,1);
   time_ax = subplot(2, 1, 2);
   load('/home/paula/Work/Code/Networks/brain-waves/data/simulations/long_cd_ictime50_seg7999_outdt1_d1ms_W_coupling0.6_trial1.mat')
   load('/home/paula/Work/Code/Networks/brain-waves/data/513COG.mat')
   sphereanim_plot_withtimeline_PSL_20190109(sph_ax, soln, COG, time_ax, time, ':', colormap(gray)) 
%}

function sphereanim_plot_scatter3(yp, node_locs, cmap)


if nargin < 3
    cmap='gray';
end
max_val = abs(max(yp(:)));
crange = [-max_val, max_val];

try 
    crange = [-1, 1];
    yp= standardise_range(yp, crange);
    cmap = bluered(256);
catch
    disp('Could not rescale range or use diverging map.')
end

figure(200);
sphereax = subplot(1,1,1);
hold(sphereax, 'on')

colormap(cmap)
caxis(sphereax, crange)
colorbar(sphereax)
loc = node_locs;
t_start=20;

time = (0:size(yp,1))/1000;
sp = scatter3(sphereax, loc(:, 1)-max(loc(:, 1)), loc(:, 2), loc(:, 3), 100, yp(t_start, :), 'filled');

plot3(zeros(size(loc, 1), 1), loc(:, 2), loc(:, 3)+10*yp(t_start, :).', '.')
dyp = diff(yp);
dtime = (time(1:end-1) + time(2:end))/2;
y_coord = loc(:, 2);

 nnodes = size(yp, 2);
 %for ii=1:nnodes
     plot3(dtime(:, ones(1, nnodes)), y_coord(:, ones(1, length(dyp))), 10*dyp.')
 %end

colormap(cmap)

% Set the color range for the whole duration of the move
sphereax.CLim = crange;
sphereax.ZLim = [-40, 80];

for j=t_start:100:size(yp,1)
    sp.ZData = loc(:, 3)+10*yp(j,:).';
    sp.CData = yp(j,:).';    
    colormap(cmap)
    drawnow
    pause(0.1)
end

