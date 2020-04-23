function[params] = singularity3d_track(params)
% This script prepare the input for simple tracker
% covnerts struct to cell, but also gets rid of 'unknown singularities'



function s3d_bifurcation_tracking(msings_obj, varargin)


np3d_cell = s3d_get_clean_particle_cell(msings_obj)

idx_start_stop = varargin{1};
max_link_dis = varargin{2};    % in mm or unit of the locations of singularities
max_gap_closing = varargin{3}; % in time samples

samples = idx_start_stop(1):idx_start_stop(2);

[tracks, adjacency_tracks, A ] = simpletracker(np3d_cell, 'Debug', true, 'MaxLinkingDistance', 25, 'MaxGapClosing', 2);

%%
 all_points = vertcat(np3d_cell{:} );
%%

figure;
ax = subplot(1,1,1);
hold(ax, 'on')

%%

for this_track=1:length(tracks)
    
    tpts_idx = find(~isnan(tracks{this_track}));
    x_idx = adjacency_tracks{this_track};
    x_val = all_points(x_idx, 1);
    y_val = all_points(x_idx, 2);
    z_val = all_points(x_idx, 3);
    
    %plot3(ax, x_val, y_val, z_val, 'color', [0.25 0.25 0.25], 'linewidth', 0.1)

    
    plot(ax, time_vec(tpts_idx), x_val, 'color', [0.25 0.25 0.25], 'linewidth', 0.1)
    plot(ax, time_vec(tpts_idx(1)), x_val(1), '.', 'markerfacecolor', [0.5 0.25 0.25], 'markersize', 0.0042)
    plot(ax, time_vec(tpts_idx(end)), x_val(end), '.', 'markerfacecolor', [0.25 0.5 0.25], 'markersize', 0.0042)    
    
end
    

end % function s3d_bifurcation_tracking()



function np3d_cell = s3d_get_clean_particle_cell(msing_obj, idx_start_stop)

np3d = msings_obj.null_points_3d;
singularity_list_num = s3d_str2num_label(msings_obj.singularity_classification_list);


samples = idx_start_stop(1):idx_start_stop(2);

% NOTE: parallel?
for tt = 1:length(samples)
    
    
    this_frame_sings = singularity_list_num{samples(tt)};
    good_idx = find(this_frame_sings < 9);
    
    if ~isempty(good_idx)
        np3d_cell{tt} = [np3d(time_vec(tt)).x(good_idx) np3d(time_vec(tt)).y(good_idx) np3d(time_vec(tt)).z(good_idx)];
    else
        np3d_cell{tt} = [Inf Inf Inf]; % Put a particle at infinity, otherwise the particle tracker fails
    end
end


end % function s3d_get_clean_particle_cell()


end %function singularity3d_track()
