function [h, hs] = plot_velocity_field(vf, M, options)

% plot_vf - plot a vector field with 
%   an optional image in the background.
%
% plot_vf(vf, M, options);
%
%   WORKS ONLY FOR 2D VECTOR FIELDS
%
%   set options.display_streamlines=1 to display streamlines.
%   
%   See also: plot_tensor_field.
%
%   Copyright (c) 2004 Gabriel Peyre

if nargin<2
    M = [];
end

if iscell(vf)
    % Assume is a 1 x ncols or nrows x ncols cell
    num_plots = numel(vf);
    
    nrows = size(A, 1);
    ncols = size(A, 2);
    lgd = getoptions(options, 'lgd', []);
    
    for this_vf=1:num_plots
        if iscell(M)
            Mi = M{this_vf};
        else
            Mi = M;
        end
        subplot(nrows, ncols, this_vf);
        plot_velocity_field(vf{this_vf}, Mi, options);
        if iscell(lgd)
            title(lgd{this_vf});
        else
            title(lgd);
        end        
        axis tight;
    end
    return;
end

options.null = 1;
is_oriented   = getoptions(options, 'is_oriented', 1);
strech_factor = getoptions(options, 'strech_factor', .6);
reorient  = getoptions(options, 'reorient', 0);
linestyle = getoptions(options, 'linestyle', 'b');
display_streamlines = getoptions(options, 'display_streamlines', 0);
streamline_density  = getoptions(options, 'streamline_density', 8);
streamline_width    = getoptions(options, 'streamline_width', 1);
line_width = getoptions(options, 'line_width', 1);
display_arrows = getoptions(options, 'display_arrows', 1);
subsampling    = getoptions(options, 'subsampling', []);
normalize_flow = getoptions(options, 'normalize_flow', 0);

if display_streamlines && ~isfield(options, 'display_arrows')
    display_arrows = 0;
end

if display_arrows==1 && not(isempty(subsampling))
    vf = vf(1:subsampling:end,1:subsampling:end,:);
end

if size(vf,3)~=2
    warning('Dimension > 2, cropping ...');
    vf = vf(:,:,1:2);
end

if reorient
    % reorient the vf to x>0
    epsi = sign(vf(:,:,1));
    epsi(epsi==0) = 1;
    vf(:,:,1) = vf(:,:,1).*epsi;
    vf(:,:,2) = vf(:,:,2).*epsi;
end

if normalize_flow
    vf = perform_vf_normalization(vf);
end

n = size(vf,1);
p = size(vf,2);

x = 0:1/(n-1):1;
y = 0:1/(p-1):1;

[Y,X] = meshgrid(y,x);

hold on;
if display_arrows
    imagesc(x,y,M');
    if is_oriented
        h = quiver(X,Y,vf(:,:,1),vf(:,:,2), strech_factor, linestyle);
    else
        h = quiver(X,Y, vf(:,:,1), vf(:,:,2), strech_factor*0.7, linestyle);
        h = quiver(X,Y,-vf(:,:,1),-vf(:,:,2), strech_factor*0.7, linestyle);
    end
    axis xy;
    axis equal;
    set(h, 'LineWidth', line_width);
end


if display_streamlines
    if not(isempty(M))
        imagesc(M');
    end
    [X,Y] = meshgrid(1:n,1:p);
    [XY,~] = streamslice(X,Y, vf(:,:,2), vf(:,:,1), streamline_density);
    % reverse stream
    for this_vf=1:length(XY)
        XY{this_vf} = XY{this_vf}(:,2:-1:1);
    end
    hs = streamline(XY);
    set(hs, 'LineWidth', streamline_width);
    axis ij;
end

axis off;
hold off;