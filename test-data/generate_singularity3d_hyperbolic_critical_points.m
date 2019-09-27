function generate_singularity3d_hyperbolic_critical_points(cp_type)


% Grid - display the critical points in a cube of side 2 in (-1, 1)
% perhaps use the resolution as parameters.
% Paula Sanz-Leon, September 2019, QIMR

x = -1:2^-4:1;
y = -1:2^-4:1;
z = -1:2^-4:1;

[X, Y, Z] = meshgrid(x, y, z);

switch cp_type
    case {'source', 'reppelor', 'unstable-focus'}
        ux = X;
        uy = Y;
        uz = Z;
        
        p1 = [0.01 0.01  0.1];
        p2 = [0.01 0.01 -0.1];
        
    case {'sink', 'attractor', 'stable-focus'}
        ux = -X;
        uy = -Y;
        uz = -Z;
        
        p1 = [ 0.5  0.5  0.5];
        p2 = [-0.5 -0.5 -0.5];
            
    case {'1-2-saddle', 'sink-saddle', 'attractive-saddle'}
        TH = atan2(Y, X);
        R = sqrt(X.^2+Y.^2);
        ux = -R.* cos(TH);
        uy = -R.* sin(TH);
        uz = Z;
        
        p1 = [ 0.1  0.1  1];
        p2 = [ 0.1  0.1 -1];
        
    case {'2-1-saddle', 'source-saddle', 'repellent-saddle'}
        TH = atan2(Y, X);
        R = sqrt(X.^2+Y.^2);
        ux = R.* cos(TH);
        uy = R.* sin(TH);
        uz = -Z;
        
        p1 = [ 0.1  0.1  1];
        p2 = [ 0.1  0.1 -1];
           
    case {'spiral-sink'}
        ux =  Y-X;
        uy = -X-Y;
        uz = -Z;
        
        p1 = [ 0.5, -0.5,  0.05];
        p2 = [-0.5, -0.5, -0.05];
        
    case {'spiral-source'}
        
        %NOTE: I'm not sure this critical point is entirely correct, as it 
        % basically becomes a limit cycle - centre 
        
        [ux, uy, uz] = spiral_source();
        % Seed xyz points for sample trajectory
        p1 = [0.0, 0.01,  0.01];
        p2 = [0.0, 0.01, -0.01];
 
    case {'spiral-1-2-saddle', 'sink-spiral-saddle'}
        [ux, uy, uz] = spiral_source();
        ux = -ux;
        uy = -uy;
        p1 = [ 0.5, -0.5,  0.05];
        p2 = [-0.5, -0.5, -0.05];
        p1 = [ 0.5, -0.5,  0.05];
        p2 = [-0.5, -0.5, -0.05];
        
    case {'spiral-2-1-saddle', 'source-spiral-saddle'}
        % Source Spiral saddle - 2-out 1-in 
        [ux, uy, uz] = spiral_source();
        uz = -uz;
        
        p1 = [0.01, 0.01,  0.5];
        p2 = [0.01, 0.01, -0.5];
        
    otherwise
        error(['neural-flows::' mfilename '::UnknownType'], 'Unknown type of critical points')

end


fig_sing3d = figure('Name', 'nflows-singularity3d_hyperbolic-cp');
fig_sing3d.Position = [1   18   18   18];
fig_sing3d.Color = [1, 1, 1];
ax = subplot(1, 1, 1, 'Parent', fig_sing3d);
hold(ax, 'on')
quiv_handle = quiver3(X, Y, Z, ux, uy, uz);
quiv_handle.Color = [0.2 0.2 0.2 0.01];
quiv_handle.LineWidth = 0.5;
plot3(ax, [-1 1], [0 0], [0 0], 'r', 'linewidth', 1.5)
plot3(ax, [0 0], [-1 1], [0 0], 'g', 'linewidth', 1.5)
plot3(ax, [0 0], [0 0], [-1 1], 'b', 'linewidth', 1.5)
ax.XLim = [-1 1];
ax.YLim = [-1 1];
ax.ZLim = [-1 1];

ax.XLabel.String = 'x [mm]';
ax.YLabel.String = 'y [mm]';
ax.ZLabel.String = 'z [mm]';

% Spiral source
h1 = streamline(X, Y, Z, ux, uy, uz, p1(1), p1(2), p1(3));
h2 = streamline(X, Y, Z, ux, uy, uz, p1(1), p2(2), p2(3));

set(h1,'Color',[0.3 0.3 0.3]);
set(h2,'Color',[0.3 0.3 0.3]);

% Start points
plot3(h2.XData(1), h2.YData(1), h2.ZData(1), 'kx')
plot3(h1.XData(1), h1.YData(1), h1.ZData(1), 'kx')

% End points
plot3(h1.XData(end), h1.YData(end), h1.ZData(end), 'ko', 'markerfacecolor', 'k')
plot3(h2.XData(end), h2.YData(end), h2.ZData(end), 'ko', 'markerfacecolor', 'k')

view(3);

%%   
%options.stream_length_steps=11;
%options.curved_arrow = 1;
%options.start_points_mode = 'grid';
% try to draw without normalisation by the norm because it is used as the
% cmap.

%[st_handle, options] = draw_stream_arrow(squeeze(X(17, :, :))', squeeze(Z(17, :, :))', squeeze(U(17, :, :))', squeeze(W(17, :, :))', options);


function [ux, uy, uz] = spiral_source()
        a = 0.2;
        b = 0.5;
        ux =  a*Y-(a.*abs(z)).*X;
        uy = -a*X-(a.*abs(z)).*Y;
        uz = -((b*Z)); %zeros(size(Z));
        uz(isnan(uz)) = 0;
        
        ux = -ux;
        uy = -uy;
        UV = sqrt(ux.^2 + uy.^2);
        ux = ux./UV; % This normalisation is basically for visaulisation purposes
        uy = uy./UV;
        ux(isnan(ux)) = 0; 
        uy(isnan(uy)) = 0;
        uz = -uz;
end
end
