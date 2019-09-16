function streams3d_tracing_grid(mfile_vel, singularity_classification, seed_locs)

% Trace streamlines for one frame 

tt=2;

X = mfile_vel.X;
Y = mfile_vel.Y;
Z = mfile_vel.Z;


x_dim = 1;
y_dim = 2;
z_dim = 3;

% Trace streamlines
verts = stream3(X, Y, Z, 10000*mfile_vel.ux(:, :, :, tt), ...
                         10000*mfile_vel.uy(:, :, :, tt), ...
                         10000*mfile_vel.uz(:, :, :, tt), ...
                         seed_locs(:, x_dim), ...
                         seed_locs(:, y_dim), ...
                         seed_locs(:, z_dim), [2^-12]); % TODO: adjuts parameters

% Remove nan vertices from streamlines (points outside the convex hull)                     
verts = cellfun(@remove_nans, verts, 'UniformOutput', false);
% Make all streamlines of the same length so we can use streamparticles
stream_lengths   = cellfun(@(c)  size(c, 1), verts);
max_length = max(stream_lengths);
wrap_func = @(verts) add_vertices(verts, max_length);
verts = cellfun(wrap_func, dummy_cell, 'UniformOutput', false);

%verts = cellfun(@add_vertices, verts, 'UniformOutput', false);

sl = streamline(verts);
set(sl,'LineWidth',1);
set(sl,'Color',[0.5 0.5 0.5 0.5]);
%set(sl,'Visible','off');
% interpolated vertices
%iverts = interpstreamspeed(X, Y, Z, mfile_vel.ux(:, :, :, tt), ...
%                                    mfile_vel.uy(:, :, :, tt), ....
%                                    mfile_vel.uz(:, :, :, tt), verts,.5);
%
%axis tight; view(30,30); 
haxes = gca;
%haxes.SortMethod = 'ChildOrder';
%camproj perspective; box on
%camva(44); camlookat; camdolly(0,0,.4, 'f');
%h = line;
haxes.XLim = [min(X(:)), max(X(:))];
haxes.YLim = [min(Y(:)), max(Y(:))];

haxes.ZLim = [min(Z(:)), max(Z(:))];

streamparticles(haxes, verts, 42, 'animate', Inf, 'ParticleAlignment', 'on', 'MarkerfaceColor', 'blue');

displaynow 


end


function x = remove_nans(x)
% Dummy function to be call by cellfun
    x(isnan(x)) = [];
    
end




