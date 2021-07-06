function main_analysis(inparams)
%% Wrapper function to perform basic analysis:
%  (1): flows: svd decomposition
%  (2): flows: energy quantification
%  (3): singularity: quantification

display_info_banner(mfilename, 'STARTED ANALYSIS.', '#5c5393', false)

% Tic 
tstart = tik();

% Copy structure
%tmp_params = inparams;

%----------------------------FLOW DECOMPOSITION--------------------------------%
if inparams.flows.decomposition.svd.enabled
    % Check if we need to interpolate data
    perform_svd(inparams);
end
%--------------------------- LOCAL FLOW CLASSIFICATION -------------------------%

if inparams.flows.classification.enabled
   % If we want classify flows based on curl and divergence
   switch inparams.flows.classification.scale
       case {"local", "micro", "microscopic"}
        flows3d_perform_local_flow_classification(inparams);  
       case {"intermediate", "meso", "mesoscopic"}
            error(['neural-flows:' mfilename ':NotImplemented']);
       case {"global", "macro", "macroscopic", "whole-brain"}
            error(['neural-flows:' mfilename ':NotImplemented']);
       otherwise
            error(['neural-flows:' mfilename ':UnknownCase'], ...
                    'Requested unknown scale.');
   end
end


if inparams.flows.quantification.energy.enabled
    calculate_kinetic_energy(inparams);
end
%---------------------------SINGULARITY----------------------------------------%
if inparams.singularity.quantification.enabled
    analyse_nodal_singularity_occupancy(inparams);   
end

% Toc
tok(tstart, 'minutes');
display_info_banner(mfilename, 'FINISHED ANALYSIS.', '#5c5393', false)

end % function main_analysis()
