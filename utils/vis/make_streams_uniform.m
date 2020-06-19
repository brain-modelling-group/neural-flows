function verts = make_streams_uniform(verts)

% Remove nan vertices from streamlines (points outside the convex hull)                     
verts = cellfun(@remove_nans, verts, 'UniformOutput', false);
% Make all streamlines of the same length so we can use streamparticles
stream_lengths   = cellfun(@(c)  size(c, 1), verts);
max_length = max(stream_lengths);
wrap_func = @(verts) add_vertices(verts, max_length);
verts = cellfun(wrap_func, dummy_cell, 'UniformOutput', false);

end % function make_streams_uniform()

function x = remove_nans(x)
% Dummy function to be call by cellfun
    x(isnan(x)) = [];
    
end % function remove_nans()
