function[params] = singularity3d_track(params)
% This script prepare the input for simple tracker
% covnerts struct to cell, but also gets rid of 'unknown singularities'

    obj_singularity = load_iomat_singularity(params);
    t_start_idx = 1;
    t_end_idx = params.flows.data.shape.t;
    np3d_cell = s3d_build_particle_cell(obj_singularity, [t_start_idx, t_end_idx]);
    s3d_bifurcation_tracking(np3d_cell, params);



end %function singularity3d_track()


function s3d_bifurcation_tracking(np3d_cell, params)


%idx_start_stop = varargin{1};
%max_link_dis = varargin{2};    % in mm or unit of the locations of singularities
%max_gap_closing = varargin{3}; % in time samples

time_vec = 1: params.flows.data.shape.t;
[tracks, adjacency_tracks, A ] = simpletracker(np3d_cell, 'Debug', true, 'MaxLinkingDistance', 50, 'MaxGapClosing', 10);

%%
all_points = vertcat(np3d_cell{:} );
%%

figure;
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);
hold(ax1, 'on')
hold(ax2, 'on')
%%

for this_track=1:length(tracks)
    
    tpts_idx = find(~isnan(tracks{this_track}));
    x_idx = adjacency_tracks{this_track};
    x_val = all_points(x_idx, 1);
    y_val = all_points(x_idx, 2);
    z_val = all_points(x_idx, 3);
    
    plot3(ax1, x_val, y_val, z_val, 'color', [0.25 0.25 0.25], 'linewidth', 0.1)

    
    plot(ax2, time_vec(tpts_idx), x_val, 'color', [0.25 0.25 0.25], 'linewidth', 0.1)
    plot(ax2, time_vec(tpts_idx(1)), x_val(1), '.', 'markerfacecolor', [0.5 0.25 0.25], 'markersize', 0.0042)
    plot(ax2, time_vec(tpts_idx(end)), x_val(end), '.', 'markerfacecolor', [0.25 0.5 0.25], 'markersize', 0.0042)    
    
end
    

end % function s3d_bifurcation_tracking()



function np3d_cell = s3d_build_particle_cell(obj_singularity, idx_start_stop)

samples = idx_start_stop(1):idx_start_stop(2);
np3d = obj_singularity.nullflow_points3d;
np3d_cell = cell(1, length(samples));

% NOTE: parallel?
for tt = 1:length(samples)
    this_frame = obj_singularity.classification_num(1, samples(tt));
    good_idx = find(this_frame{:} < 9);
    
    if ~isempty(good_idx)
        np3d_cell{tt} = [np3d(samples(tt)).locs.x(good_idx) np3d(samples(tt)).locs.y(good_idx) np3d(samples(tt)).locs.z(good_idx)];
    else
        np3d_cell{tt} = [Inf Inf Inf]; % Put a particle at infinity, otherwise the particle tracker fails
    end
end


end % function s3d_get_clean_particle_cell()


