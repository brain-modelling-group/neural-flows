function xyz_idx = switch_index_mode(xyz_lidx, index_mode, X)

        switch index_mode
            case 'linear'
                xyz_idx = xyz_lidx;
            case 'subscript' % NOTe: I vaguely remember this part not working properly.
                [x_idx, y_idx, z_idx] = ind2sub(size(X),xyz_lidx); 
                xyz_idx = [x_idx, y_idx, z_idx];
        end
end
