function fig_handles = plot_debug_boundary_masks(masks)
% A simple function to visually inspect interpolation boundary masks
% Input: masks a struct with the violumetric masks and the convex hull

% Needs: 
% get_number_subplots()

% Plot innies


fig_innies = plot_boundary_volumetric_mask(masks.innies);

fig_outties = plot_boundary_volumetric_mask(masks.outties);

fig_betweenies = plot_boundary_volumetric_mask(masks.betweenies);

fig_handles = [fig_innies, fig_outties, fig_betweenies];

end % function plot_debug_boundary_masks()


function fig_handles = plot_boundary_volumetric_mask(this_mask)
fig_handles = cell(3, 1);
[m, n, p] = size(this_mask);
fig_handles{1} = figure(1);
fig_handles{2} = figure(2);
fig_handles{3} = figure(3);

[rows, cols] = get_number_subplots(m);
fig_handles{1} = plot_slices(fig_handles{1}, m, rows, cols);

[rows, cols] = get_number_subplots(n);
fig_handles{2} = plot_slices(fig_handles{2}, n, rows, cols);

[rows, cols] = get_number_subplots(p);
fig_handles{3} = plot_slices(fig_handles{3}, p, rows, cols);

    function fig_handle = plot_slices(fig_handle, num_slices, rr, cc)
        for kk=1:num_slices
            subplot(rr, cc, kk, 'Parent', fig_handle)
            imshow(squeeze(this_mask(:, kk, :)))
        end
    end

end