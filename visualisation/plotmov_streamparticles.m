function fig_handle = plotmov_streamparticles(params, output_modality)	
% params: structure with all the parameters for neural-flows

if nargin < 2
    output_modality = "streamlines";
end

% Load file handles
obj_flows = load_iomat_flows(params);
obj_streams = load_iomat_streams(params);

% Load info we need for visualisation
xyz_lims = obj_flows.xyz_lims; 
num_frames = params.flows.data.shape.t;

% Create figure
fig_handle = figure('Name', 'nflows-flows-streamparticles-movie');

% Create axes
ax_handle = subplot(1, 1, 1,'Parent', fig_handle);
ax_handle.DataAspectRatio = [1 1 1];
% Set axes props
ax_handle.XLim = [xyz_lims{1}(1), xyz_lims{1}(2)];
ax_handle.YLim = [xyz_lims{2}(1), xyz_lims{2}(2)];
ax_handle.ZLim = [xyz_lims{3}(1), xyz_lims{3}(2)];
ax_handle.XLabel.String = "X";
ax_handle.YLabel.String = "Y";
ax_handle.ZLabel.String = "Z";
ax_handle.Position = [0.1300    0.1100    0.7750    0.8150];
ax_handle.View = [90 0];
set(ax_handle,'DrawMode','fast')

switch output_modality
    case {"particles"}
        % Create movie object
        fname = generate_temp_filename("p3_particle-movie", 3);
        vid_obj = VideoWriter([char(fname), '.avi']);
        vid_obj.FrameRate = 4; 
        open(vid_obj);
        for ff=1:num_frames
            stream_verts = get_verts(ff);
            sl = streamline(stream_verts);
            set(sl,'LineWidth',0.5);
            set(sl,'Color',[0.5 0.5 0.5 0.9]); % looks weird in the movie otherwise 
            [~, M{ff}] = streamparticlesMod(ax_handle, stream_verts, 2, 'animate', 1, 'ParticleAlignment', 'on', ...
                                          'MarkerfaceColor', 'red', 'MarkerSize', 2);
            %movie([M{:}], 1, 75)   % play the movie. Do not close the figure window before playing the movie
            %writeVideo(vid_obj, [M{:}]);
            set(sl,'Color',[0.5 0.5 0.5 0.0]); % looks weird in the movie otherwise
            cla(ax_handle)
        end
        %
        %movie([M{:}], 1, 75)   % play the movie. Do not close the figure window before playing the movie
        writeVideo(vid_obj, [M{:}]);
    case {"streamlines"}
        fname = generate_temp_filename("p3_streamlines-movie", 3);
        vid_obj = VideoWriter([char(fname), '.avi']);
        vid_obj.FrameRate = 10; 
        open(vid_obj);
        for ff=1:num_frames
            stream_verts = get_verts(ff);
            sl = streamline(stream_verts);
            set(sl,'LineWidth',0.5);
            set(sl,'Color',[0.5 0.5 0.5 0.9]); % looks weird in the movie otherwise 
            M(ff) = getframe(ax_handle);
            writeVideo(vid_obj, M(ff));
            set(sl,'Color',[0.5 0.5 0.5 0.0]); % looks weird in the movie otherwise
            cla(ax_handle)
        end
        
end
% Close file
close(vid_obj);

function verts = get_verts(idx)
  tmp = obj_streams.streamlines(1, idx);
  verts = tmp.paths;
  verts = make_streams_uniform(verts);
end % get_verts()

end % function plot3d_streamparticles()
