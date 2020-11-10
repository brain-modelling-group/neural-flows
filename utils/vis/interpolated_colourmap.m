function cmap = interpolated_colourmap(colour_a, colour_b, colour_c, num_colours)

cmap(1, :) = colour_a;  % first row 
cmap(2, :) = colour_b;  % middle row
cmap(3, :) = colour_c;  % last row

[X,Y] = meshgrid([1:3],[1:num_colours]);  % mesh of indices

cmap = interp2(X([1, round(num_colours/2), num_colours],:),Y([1, round(num_colours/2), num_colours],:), cmap, X, Y); % interpolate colormap
end

% function interpolated_colourmap()