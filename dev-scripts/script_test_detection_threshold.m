

for tt=1:200
    
  %norm_u = sqrt(mfile_vel.ux(:, :, :, tt).^2 + mfile_vel.uy(:, :, :, tt).^2 + mfile_vel.uz(:, :, :, tt).^2); 
  %min_norm_u(tt) = nanmin(norm_u(:));
  %max_norm_u(tt) = nanmax(norm_u(:));
  ux = mfile_vel.ux(:, :, :, tt);
  uy = mfile_vel.uy(:, :, :, tt);
  uz = mfile_vel.uz(:, :, :, tt);

  %min_ux(tt) = nanmin(abs(ux(:)));
  %max_ux(tt) = nanmax(abs(ux(:)));
  
  %min_uy(tt) = nanmin(abs(uy(:)));
  %max_uy(tt) = nanmax(abs(uy(:)));
  
  %min_uz(tt) = nanmin(abs(uz(:)));
  %max_uz(tt) = nanmax(abs(uz(:)));
  
  uu = abs(ux(:) .* uy(:) .* uz(:));
  %min_uu(tt) = nanmin(abs(uu(:)));
  xyz_idx(tt).xyz_idx = find(uu < 4*eps);
  
end


%% 


figure

subplot(1,3,1)
histogram(abs(min_ux))
subplot(1,3,2)
histogram(min_uy)
subplot(1,3,3)
histogram(min_uz)