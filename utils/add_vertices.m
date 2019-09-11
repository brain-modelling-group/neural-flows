function x = add_vertices(x, max_length)
% dummy function that adds vertices to the streamlines, so they are all of
% the same length -- necessary to use streamparticles
this_length = size(x, 1);
last_values = x(end, :);

x(this_length:max_length, :) = last_values(ones((max_length-this_length)+1, 1), :); 

end