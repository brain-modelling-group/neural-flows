function fig_handle = plot3d_streamparticles(params, these_frames, display_modality)	
% params: structure with all the parameters for neural-flows
% these_frames  vector with indices of time frames to plot
% display_modality =  "workspace" or "movie"

if nargin < 3
    display_modality = "workspace";
end
% Set info we need
%these_frames = params.stremalines.visualisation.particles.frames;
%params.stremalines.visualisation.particles.display.modality;
%these_frames = [174];
%these_frames = [50];

% Load file handles
obj_flows = load_iomat_flows(params);
obj_streams = load_iomat_streams(params);

% Load info we need for visualisation
xyz_lims = obj_flows.xyz_lims; 
num_frames = length(these_frames);
fig_handle = cell(num_frames, 1);
axs_handle = cell(num_frames, 1);

for ff=1:num_frames
    stream_verts = get_verts(these_frames(ff));
    fig_handle{ff} = figure('Name', 'nflows-flows-streamparticles');
    axs_handle{ff} = p3_streamparticles(fig_handle{ff}, stream_verts, xyz_lims, display_modality);
end

function verts = get_verts(idx)
  tmp = obj_streams.streamlines(1, idx);
  verts = tmp.paths;
  verts = make_streams_uniform(verts);
end % get_verts()

end % function plot3d_streamparticles()
