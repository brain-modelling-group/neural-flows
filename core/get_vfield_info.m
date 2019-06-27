function mfile_vel = get_vfield_info(mfile_vel, ux, uy, uz, this_tpt)

    mfile_vel.min_ux(1,this_tpt) = nanmin(ux(:));
    mfile_vel.max_ux(1,this_tpt) = nanmax(ux(:));

    mfile_vel.min_uy(1,this_tpt) = nanmin(uy(:));
    mfile_vel.max_uy(1,this_tpt) = nanmax(uy(:));

    mfile_vel.min_uz(1,this_tpt) = nanmin(uz(:));
    mfile_vel.max_uz(1,this_tpt) = nanmax(uz(:));

    mfile_vel.sum_ux(1, this_tpt) = nansum(ux(:));
    mfile_vel.sum_uy(1, this_tpt) = nansum(uy(:));
    mfile_vel.sum_uz(1, this_tpt) = nansum(uz(:));

    uu = abs(ux(:) .* uy(:) .* uz(:));

    mfile_vel.min_uu(1, this_tpt) = nanmin(uu(:));
    mfile_vel.max_uu(1, this_tpt) = nanmax(uu(:));


    [~, norm_vf] = normalise_vector_field([ux(:) uy(:) uz(:)], 2);

    mfile_vel.min_nu(1, this_tpt) = nanmin(norm_vf(:));
    mfile_vel.max_nu(1, this_tpt) = nanmax(norm_vf(:));
    
end % function get_vfield_info()
