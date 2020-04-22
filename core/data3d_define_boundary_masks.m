function [params] = data3d_define_boundary_masks()
    % Alpha radius has to be adjusted depending on the location data
    % (mostly, granularity of parcellation).
    if isfield(inparams.interpolation.boundary, 'alpha_radius')
        bdy_alpha_radius = params.interpolation.boundary.alpha_radius;

%-------------------------- GRID AND MASK -------------------------------------%    

    
    % Get a mask with the gridded-points that are inside and outside the convex hull
    % NOTE: This mask underestimates the volume occupied by the scattered
    % points
    [in_bdy_mask, ~] = data3d_calculate_boundary(locs, X(:), Y(:), Z(:), bdy_alpha_radius);
    %[in_bdy_mask] = data3d_check_boundary_mask(in_bdy_mask, locs, hr);

    in_bdy_mask = reshape(in_bdy_mask, params.interpolation.data.grid_size);
    % Get a mask that is slightly larger so we can define a shell with a thickness that will be 
    % the boundary of our domain. 
    mask_thickness = params.interpolation.boundary.thickness;
    [interp_mask, diff_mask] = data3d_calculate_interpolation_mask(in_bdy_mask, ...
                                                                   params.interpolation.boundary.thickness);

end % function data3d_define_boundary_masks()