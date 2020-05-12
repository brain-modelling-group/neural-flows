function fig_handle = plot3d_hyperbolic_critical_point(fig_handle, p1, p2, ux, uy, uz, X, Y, Z, cp_type)


if isempty(fig_handle)
	fig_name = ['nflows-singularity3d_hyperbolic-cp-' cp_type];
    fig_handle = figure('Name', fig_name);
end

% TODO: 
% Correct the 2D projections so they look prettier -- in particular the
% spiral saddles and sources/sinks --
% Get appropriate color
[cmap] = s3d_get_colours(cp_type);


fig_handle.Position = [1   18   19   17];
fig_handle.Color = [1, 1, 1];
ax(1) = subplot(2, 2, 4, 'Parent', fig_handle);
ax(2) = subplot(2, 2, 3, 'Parent', fig_handle);
ax(3) = subplot(2, 2, 2, 'Parent', fig_handle);
ax(4) = subplot(2, 2, 1, 'Parent', fig_handle);

hold(ax(1), 'on')
dsf = 2; % downsample factor
unorm = sqrt(ux.^2+uy.^2+uz.^2);
max_unorm = max(unorm(:));
quiv_handle = quiver3(X(1:dsf:end, 1:dsf:end, 1:dsf:end), ...
                      Y(1:dsf:end, 1:dsf:end,1:dsf:end), ...
                      Z(1:dsf:end, 1:dsf:end, 1:dsf:end), ...
                      ux(1:dsf:end,1:dsf:end,1:dsf:end)./max_unorm, ...
                      uy(1:dsf:end,1:dsf:end,1:dsf:end)./max_unorm, ...
                      uz(1:dsf:end,1:dsf:end,1:dsf:end)./max_unorm, 1);
                  
quiv_handle.Color = [0.2 0.2 0.2];
quiv_handle.LineWidth = 0.01;
quiv_handle.Parent = ax(1);

% Plot axes going through the centre
plot3(ax(1), [-1 1], [0 0], [0 0], 'color', [0.65 0.0 0.0], 'linewidth', 1.5)
plot3(ax(1), [0 0], [-1 1], [0 0], 'color', [0.0 0.65 0.0], 'linewidth', 1.5)
plot3(ax(1), [0 0], [0 0], [-1 1], 'color', [0.0 0.0 0.65], 'linewidth', 1.5)

% Plot the critical point at the origin
plot3(ax(1), 0, 0, 0, 'o', 'markerfacecolor', cmap(1:3), 'markersize', 12, 'markeredgecolor', cmap(1:3))

for ii=1:4
    ax(ii).XLim = [-1 1];
    ax(ii).YLim = [-1 1];
    ax(ii).ZLim = [-1 1];
end
ax(1).XLabel.String = 'x [mm]';
ax(1).YLabel.String = 'y [mm]';
ax(1).ZLabel.String = 'z [mm]';

% Spiral source
h1 = streamline(X, Y, Z, ux, uy, uz, p1(1), p1(2), p1(3));
h2 = streamline(X, Y, Z, ux, uy, uz, p1(1), p2(2), p2(3));

set(h1,'Color',[0.3 0.3 0.3]);
set(h2,'Color',[0.3 0.3 0.3]);
h1.Parent = ax(1);
h2.Parent = ax(1);

% Start points
plot3(ax(1), h2.XData(1), h2.YData(1), h2.ZData(1), 'x', 'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 6)
plot3(ax(1), h1.XData(1), h1.YData(1), h1.ZData(1), 'x', 'markerfacecolor', 'r', 'markeredgecolor', 'r', 'markersize', 6)

% End points
plot3(ax(1), h1.XData(end), h1.YData(end), h1.ZData(end), 'ko', 'markerfacecolor', 'k', 'markeredgecolor', 'w')
plot3(ax(1), h2.XData(end), h2.YData(end), h2.ZData(end), 'ko', 'markerfacecolor', 'k', 'markeredgecolor', 'w')

view(3);

% Copy graphical objects onto other subplots 
copyobj(get(ax(1),'Children'),ax(2));
copyobj(get(ax(1),'Children'),ax(3));
copyobj(get(ax(1),'Children'),ax(4));

% Other refinements
% ZY - plane
ax(1).XLabel.String = 'x';
ax(1).YLabel.String = 'y';
ax(1).ZLabel.String = 'z';
ax(1).View = [90 0];
ax(1).Title.String = 'ZY';

id_x = ceil(length(x)/(2*dsf)); % index of the slice laong x-we need to keep.
U = ax(1).Children(end).UData;
V = ax(1).Children(end).VData;
W = ax(1).Children(end).WData;
ax(1).Children(end).UData = zeros(size(V));
ax(1).Children(end).VData = zeros(size(V));
ax(1).Children(end).WData = zeros(size(V));

ax(1).Children(end).UData(:, id_x, :) = U(:, id_x, :);
ax(1).Children(end).VData(:, id_x, :) = V(:, id_x, :);
ax(1).Children(end).WData(:, id_x, :) = W(:, id_x, :);


% ZX - plane
ax(2).YLabel.String = 'y';
ax(2).XLabel.String = 'x';
ax(2).ZLabel.String = 'z';
ax(2).View = [0 0];
ax(2).Title.String = 'ZX';

id_y = ceil(length(y)/(2*dsf)); % index of the slice laong x-we need to keep.
U = ax(2).Children(end).UData;
V = ax(2).Children(end).VData;
W = ax(2).Children(end).WData;
ax(2).Children(end).UData = zeros(size(V));
ax(2).Children(end).VData = zeros(size(V));
ax(2).Children(end).WData = zeros(size(V));

ax(2).Children(end).UData(id_y, :, :) = U(id_y, :, :);
ax(2).Children(end).VData(id_y, :, :) = V(id_y, :, :);
ax(2).Children(end).WData(id_y, :, :) = W(id_y, :, :);

% XY - plane
ax(3).YLabel.String = 'y';
ax(3).XLabel.String = 'x';
ax(3).ZLabel.String = 'z';
ax(3).View = [0 90];
ax(3).Title.String = 'XY';


% 3D view
ax(4).YLabel.String = 'y';
ax(4).XLabel.String = 'x';
ax(4).ZLabel.String = 'z';
ax(4).View = [40 17];
ax(4).GridAlpha = 0;
ax(4).Children(end).LineStyle = 'none';

end