function fig_handles = plot_debug_boundary_masks(masks)
% A simple function to visually inspect interpolation boundary masks
% Input: masks a struct with the violumetric masks and the convex hull

% Needs: 
% get_number_subplots()


fig_innies = plot_boundary_volumetric_mask(masks.innies);

fig_outties = plot_boundary_volumetric_mask(masks.outties);

fig_betweenies = plot_boundary_volumetric_mask(masks.betweenies);

fig_handles = [fig_innies, fig_outties, fig_betweenies];

end % function plot_debug_boundary_masks()


function fig_handles = plot_boundary_volumetric_mask(this_mask)
fig_handles = cell(3, 1);
[m, n, p] = size(this_mask);
fig_handles{1} = figure;
fig_handles{2} = figure;
fig_handles{3} = figure;

[row_cols, ~] = get_number_subplots(m);
fig_handles{1} = plot_slices(fig_handles{1}, m, 1, row_cols(1), row_cols(2));

[row_cols, ~] = get_number_subplots(n);
fig_handles{2} = plot_slices(fig_handles{2}, n, 2, row_cols(1), row_cols(2));

[row_cols, ~] = get_number_subplots(p);
fig_handles{3} = plot_slices(fig_handles{3}, p, 3, row_cols(1), row_cols(2));

    function fig_handle = plot_slices(fig_handle, num_slices, dim, rr, cc)
        
        if dim==1
            for kk=1:num_slices
                subplot(rr, cc, kk, 'Parent', fig_handle)
                imshow(squeeze(this_mask(kk, :, :)))
            end
        elseif dim ==2
            for kk=1:num_slices
                subplot(rr, cc, kk, 'Parent', fig_handle)
                imshow(squeeze(this_mask(:, kk, :)))
            end
        else
            for kk=1:num_slices
                subplot(rr, cc, kk, 'Parent', fig_handle)
                imshow(squeeze(this_mask(:, :, kk)))
            end
        end
    end

end