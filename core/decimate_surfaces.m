function decimated_surf_obj = decimate_surfaces(mfile_surf, fraction_to_keep)
% This function is a wrapper of reducepatch. 
% It takes as input a matfile with the full resolution iossurfaces of zero
% veolcity and outputs structure (surf_obj) with the decimated version.
% The output can be then used to track singularities with the surface
% intersection methods. 


% Get a decimated version of a surface
% Maybe we should compute this when we're calculatinhg the surfaces

if nargin < 2
    % Agressive decimation based on the running times estimates
    % of singularity tracking methods
    fraction_to_keep = 0.1;
end
decimated_surf_obj.isosurfs =  struct([]);

tpts = size(mfile_surf, 'isosurfs', 2);

for tt=1:tpts
   
   isosurfs =  mfile_surf.isosurfs(1, tt);
   
   [F, V] = reducepatch(isosurfs.faces_x, isosurfs.vertices_ux, fraction_to_keep);
   decimated_surf_obj.isosurfs(1, tt).vertices_ux = V;
   decimated_surf_obj.isosurfs(1, tt).faces_x = F;
   
   [F, V] = reducepatch(isosurfs.faces_y, isosurfs.vertices_uy, fraction_to_keep);
   decimated_surf_obj.isosurfs(1, tt).vertices_uy = V;
   decimated_surf_obj.isosurfs(1, tt).faces_y = F;
   
   [F, V] = reducepatch(isosurfs.faces_z, isosurfs.vertices_uz, fraction_to_keep);
   decimated_surf_obj.isosurfs(1, tt).vertices_uz = V;
   decimated_surf_obj.isosurfs(1, tt).faces_x = F;
   
end
% function decimate_surfaces()