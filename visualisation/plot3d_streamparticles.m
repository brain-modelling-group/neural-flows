function fig_handle = plot3d_streamparticles(params)	
% Set info we need
%these_frames = params.stremalines.visualisation.particles.frames;
these_frames = [10];

% Load file handles
obj_flows = load_iomat_flows(params);
obj_streams = load_iomat_streams(params);

% Load info we need for visualisation
xyz_lims = obj_flows.xyz_lims; 

for ff=1:length(these_frames)
    stream_verts = get_verts(these_frames(ff));
    fig_handle{ff} = figure('Name', 'nflows-flows-streamparticles')
    axs_handle{ff} = p3_streamparticles(fig_handle, verts, xyz_lims)
end

function verts = get_verts(idx)
  tmp = obj_streams.streamlines(1, idx);
  verts = tmp.paths;
  verts = make_streams_uniform(verts);
end % get_verts()

end % function plot3d_streamparticles()


