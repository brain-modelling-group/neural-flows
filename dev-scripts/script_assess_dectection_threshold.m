%norm_u = sqrt(mfile_vel.ux(:, :, :, tt).^2 + mfile_vel.uy(:, :, :, tt).^2 + mfile_vel.uz(:, :, :, tt).^2); 
  %min_norm_u(tt) = nanmin(norm_u(:));
  %max_norm_u(tt) = nanmax(norm_u(:));
  
    %min_ux(tt) = nanmin(abs(ux(:)));
  %max_ux(tt) = nanmax(abs(ux(:)));
  
  %min_uy(tt) = nanmin(abs(uy(:)));
  %max_uy(tt) = nanmax(abs(uy(:)));
  
  %min_uz(tt) = nanmin(abs(uz(:)));
  %max_uz(tt) = nanmax(abs(uz(:)));
  
    min_uu(tt) = nanmin(uu(:));
