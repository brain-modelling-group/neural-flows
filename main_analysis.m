function ouparams = main_analysis(inparams)
%% Wrapper function to perform basic analysis:
%  (1): svd decomposition
%  (2): singularity analysis

% Tic
tstart = tik();

% Copy structure
tmp_params = inparams;

%---------------------------------DECOMPOSITION-------------------------%
if inparams.flows.decomposition.svd.enabled
    % Check if we need to interpolate data
    perform_svd_mode_decomposition(inparams);

end

if inparams.flows.qunatification.energy.enabled
    calculate_kinetic_energy(inparams)
end
%---------------------------SINGULARITY---------------------------------%
if inparams.singularity.quantification.enabled
    analyse_nodal_singularity_occupancy(inparams)   
end
% TODO: write output parameters if reequired

% Toc
 tok(tstart, 'seconds');
 tok(tstart, 'minutes');
 tok(tstart, 'hours');

end % function main_analysis()
