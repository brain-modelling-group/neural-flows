function fmri_waves_movies()
% This function runs visualisation functions on 
% flow and stream data generated after running fmri_waves()

% This is the json file that fmri_waves() generated. 
params_filename  = 'fmri-waves_unstructured-amplitude-hs-meshbased_subject-20_output.json';
params_dir = 'examples/configs';
json_mode = 'read';

% Load options
ouparams = read_write_json(params_filename, params_dir, json_mode);
plotmov_streamparticles(ouparams, 'particles',  10);
plotmov_streamparticles(ouparams, 'streamlines', 10);

end