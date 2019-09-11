function xyz_idx = switch_index_mode(xyz_lidx, index_mode, X)
% A dummy function that wraps ind2sub

        switch index_mode
            case 'linear'
                xyz_idx = xyz_lidx;
            case 'subscript' % Note: I vaguely remember this part not working properly.
                [x_idx, y_idx, z_idx] = ind2sub(size(X), xyz_lidx); 
                xyz_idx = [x_idx, y_idx, z_idx];
        end
end % function switch_index_mode()
