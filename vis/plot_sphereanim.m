function varargout = plot_sphereanim(data, locs, time, crange, cmap, animation_env)
% Animate brain with nodes drawn as spheres colored by timeseries in 'data'
% give the locations 'locs' of the nodes in a 3d Euclidean space.
%
% ARGUMENTS:
%        data  -- a 2D array of size [timepoints x nodes/channel/locations]
%        locs  -- a 2D array of size [nodes/channels/locations x 3] 
%        time  -- a vector of size [timepoints]
%        crange -- a vector of size [1 x 2] with the color/data range.
%        cmap  -- a 2D vector of size [N x 3] with rgb triplets
%        animation_env -- a string to determine the 'animation' behaviour 
%                         of this function. Default: 'workspace'
%                         'handle': returns the handles of the figure and
%                                   sphere (surf) objects. No animation.
%                         'workspace': Animates the figure if size(data, 1)> 1
%                         'movie': Animates the figure and saves a movie to
%                                  file.
%
% OUTPUT: 
%        varargout -- handles to figure and sphere objects.
%
% REQUIRES: 
%         None
% AUTHOR: 
%        James A. Roberts, QIMR 2010-2019 
%        Paula Sanz-Leon,  QIMR 2019, document and add 'animation_environment'
%                                     to save movie, plot the animation or
%                                     have the handles to the plot.
% USAGE:
%{
number_of_nodes = 512;
timepoints  = 64;
data = randn(timepoints, number_of_nodes);
locs = randn(number_of_nodes, 3);
time = 1:64;
plot_sphereanim(data, locs, time)


%}
%


% Animate brain with nodes drawn as spheres colored by time series yp
% give the locations of the nodes in 3d space
% 
% Derived from from brainwaves/spheranim_plot by James Roberts
%
% Modifications: this function (plot_sphereanim) does not call 'get_node_locations'.
% Locations of the spheres are an input arg. 
% New input argument: animation_env:
% 1) 'handle': returns the handles to figure and axes, no animation
% 2) 'workspace': displays the animation if size(yp, 1) > 1, but does not save the movie
% 3) 'movie': displays the animation and saves the movie -- avi on Linux,
% mpeg on other OS

if nargin < 3
    time = 1:1:size(data, 1);
end

if nargin < 4
    % quantiles because MOST points lie in a relatively fixed range, but
    % min and max can be way outside. 
    if length(data)>10000 % downsampling here for speed.
        crange=quantile(data(1:100:end),[0.001 0.999]); 
    else
        crange=quantile(data(1:end),[0.001 0.999]);
    end
end
if nargin<5
    cmap='parula';
end

if nargin < 6
    animation_env = 'workspace'; % animates the plot without saving
end
    
figure_handle = figure('Name', 'sphere animation'); 
colormap(cmap)
ax = axes('Parent', figure_handle);
caxis(crange)
colorbar

nnodes=size(data,2);

if nnodes==112
    sphereradius=0.5; % mouse brain is small
else
    sphereradius=4;
end

sp_handle = add_sphere_size_internal(locs(:,1),locs(:,2),locs(:,3),sphereradius*ones(nnodes,1),data(1,:));
set(sp_handle, 'facealpha', 0.3)
drawnow
cdata = get(sp_handle,'cdata');

switch animation_env
    case 'workspace'
        axis off;
        view(2)
    for ii=1:size(data,1)
        for k=1:nnodes 
            cdata(:,(k-1)*22 + (1:21))= data(ii,k);
        end
        title(['Time:' num2str(time(ii), '%.3f') ' s'])
        set(sp_handle, 'cdata', cdata)
        drawnow
        pause(0.1)
    end
    case 'movie'
        try
            vidfile = VideoWriter('sphere_animation.mp4','MPEG-4');
        catch
            vidfile = VideoWriter('sphere_animation.avi');
        end    
        vidfile.FrameRate = 30;
        open(vidfile);
        axis off; 
        view(2)
     for ii=1:length(time)
        for k=1:nnodes 
            cdata(:,(k-1)*22 + (1:21))=data(ii,k);
        end
        title(['Time:' num2str(time(ii), '%.3f') ' s'])
        set(sp_handle, 'cdata', cdata)
        writeVideo(vidfile, getframe(figure_handle));
     end
        close(vidfile)
    
    case 'handle'
       varargout(3) = {ax};
       varargout(2) = {sp_handle};
       varargout(1) = {figure_handle};
    
end 
end

function hout = add_sphere_size_internal( x, y, z, s, c)
% input:    x   Centrepoint of the sphere in the x direction
%           y   Centrepoint of the sphere in the y direction
%           z   Centrepoint of the sphere in the z direction
%           s   Size for each sphere
%           c   Value by which to color the sphere
%
% output: (optional) handles to the surfs
% 
%
%Anton Lord, UQ 2010
% James Roberts, QIMR Berghofer, 2014-2016

hold on;

n = 20; % number of faces each sphere has
c = double(c);
[x0,y0,z0] = sphere(n);

nspheres=length(x);
Xall=nan(n+1,nspheres*(n+2)); % each sphere is an (n+1)-by-(n+1) matrix
Yall=Xall;
Zall=Xall;
Call=Xall;

for jj = 1:length(x)
    if size(c,1) == 1
        intensity = zeros(n+1)+c(jj); 
    end
    Xall(:,(jj-1)*(n+2)+(1:(n+1)))=x0*s(jj)+x(jj);
    Yall(:,(jj-1)*(n+2)+(1:(n+1)))=y0*s(jj)+y(jj);
    Zall(:,(jj-1)*(n+2)+(1:(n+1)))=z0*s(jj)+z(jj);
    Call(:,(jj-1)*(n+2)+(1:(n+1)))=intensity;
end
h = surf(Xall,Yall,Zall,Call,'EdgeColor','none');
daspect([1 1 1])
if nargout > 0
    hout=h;
end
end

