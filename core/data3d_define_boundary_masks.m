function [masks, params] = data3d_define_boundary_masks(locs, X, Y, Z, params)
    % Alpha radius has to be adjusted depending on the location data
    % (mostly, granularity of parcellation).
    if isfield(inparams.interpolation.boundary, 'alpha_radius')
        bdy_alpha_radius = params.interpolation.boundary.alpha_radius;
    end
    
    % Get a mask with the gridded-points that are inside and outside the convex hull
    % NOTE: This mask underestimates the volume occupied by the scattered
    % points
    [mask_innies, ~] = data3d_calculate_boundary(locs, X(:), Y(:), Z(:), bdy_alpha_radius);

    mask_innies = reshape(mask_innies, params.interpolation.data.shape.grid);
    % Get a mask that is slightly larger so we can define a shell with a thickness that will be 
    % the boundary of our domain. 
    [mask_outties, mask_betweenies] = data3d_calculate_interpolation_mask(mask_innies, ...
                                                                          params.interpolation.boundary.thickness);

    masks.innies = mask_innies;
    masks.outties = mask_outties;
    masks.betweenies = mask_betweenies;

end % function data3d_define_boundary_masks()