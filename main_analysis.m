function main_analysis(inparams)
%% Wrapper function to perform basic analysis:
%  (1): flows: svd decomposition
%  (2): flows: energy quantification
%  (3): singularity: quantification

 disp('------------------------------------------------------------------------')
 fprintf('%s \n', strcat('neural-flows:: ', mfilename, '::Info:: ANALYSIS.'))              
 disp('------------------------------------------------------------------------')

% Tic 
tstart = tik();

% Copy structure
%tmp_params = inparams;

%---------------------------------DECOMPOSITION-------------------------%
if inparams.flows.decomposition.svd.enabled
    % Check if we need to interpolate data
    perform_svd(inparams);
end

if inparams.flows.quantification.energy.enabled
    calculate_kinetic_energy(inparams);
end
%---------------------------SINGULARITY---------------------------------%
if inparams.singularity.quantification.enabled
    %analyse_nodal_singularity_occupancy(inparams);   
end
% TODO: write output parameters if reequired

% Toc
tok(tstart, 'minutes');
end % function main_analysis()
