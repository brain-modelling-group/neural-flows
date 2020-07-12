function fig_handle = plot3d_streamparticles(params, these_frames)	
% Set info we need
%these_frames = params.stremalines.visualisation.particles.frames;
%display_modality =  "workspace" or "movie"
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
    axs_handle{ff} = p3_streamparticles(fig_handle{ff}, stream_verts, xyz_lims, "movie");
end

function verts = get_verts(idx)
  tmp = obj_streams.streamlines(1, idx);
  verts = tmp.paths;
  verts = make_streams_uniform(verts);
end % get_verts()

end % function plot3d_streamparticles()
