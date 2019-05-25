% Summary: This script analyses the effect of the threshold used to detect 
%          regions of almost null velocity. 
%
% Author: Paula Sanz-Leon QIMR 2019

%% 00. Detect critical points using the velocity fields
num_values = 3;
values = [0.01, 0.1, 1];
%values = linspace(1, 10, num_values);

xyz_cell = cell(num_values, 1);
tpts = size(mfile_vel, 'ux', 4); %#ok<GTARG>

% Get locations of critical points
for cc=1:num_values
    for tt=1:tpts
        ux = mfile_vel.ux(:, :, :, tt);
        uy = mfile_vel.uy(:, :, :, tt);
        uz = mfile_vel.uz(:, :, :, tt);
        uu = abs(ux(:) .* uy(:) .* uz(:));
        xyz_idx(tt).xyz_idx = find(uu < values(cc)*eps);
  
    end
   % Save results
   xyz_cell{cc} = xyz_idx;
   clear xyz_idx
end

%% 01. Classify the critical points detected

singularity_classification = cell(length(xyz_cell), 1);
for cc=1:length(xyz_cell)
    [singularity_classification{cc}] =   classify_singularities(xyz_cell{cc}, mfile_vel);
end

%% 02. Plot total number of singularities detected
fh_num_sing = figure;
ax_numsing = subplot(1,1,1);
hold(ax_numsing, 'on')

cmap = linspace(0, 0.85, length(xyz_cell));
for cc=1:length(xyz_cell)
    num_sing = cellfun(@length, singularity_classification{cc});
    plot(ax_numsing, num_sing, 'color', [cmap(cc) cmap(cc) cmap(cc)], 'displayname', strcat(num2str(values(cc)), '*eps'))
end

leg = legend('show');
title(leg,'threshold')
ylabel('log_{10} # critical points')
xlabel('time [ms]')
%ylim([1.5 3.5])

%% 03. Plot total number of singularities divided up in clases. 
label_cell = cell(num_values, 1);
out = cell(num_values, 1);

for cc = 1:num_values
    singularity_temp = singularity_classification{cc};
    num_sing = cellfun(@length, singularity_classification{cc});
    for tt=1:tpts
        for ss=1:num_sing(tt)
            [label(tt).label(ss), color_map(tt).colormap(ss, :)] = map_str2int(singularity_temp{tt}{ss});
        end
    end
    label_cell{cc} = label;
    out{cc} = count_singularities(label);
end


%% Get text labels
singularity_list = get_singularity_list();

% Get colours                
for ii=1:length(singularity_list)
  [~, cmap(ii, :)] = map_str2int(singularity_list{ii});
end

%%
figure_handle = figure;
for ii=1:8
    ax(ii) = subplot(4,2,ii);
    hold(ax(ii), 'on')
end

for cc=1:num_values
    temp = out{cc};
    temp1 = out{1};
    for ii=1:8
        stairs(ax(ii), log10(temp(:, ii)), 'color', [cmap(ii, 1:3) cc*0.1], 'linewidth', 2)
        ax(ii).Title.String = singularity_list{ii};
    end
end

for ii=1:2:8
ax(ii).YLabel.String = 'log_{10}(#)';
end

ax(7).XLabel.String = 'time [ms]';
ax(8).XLabel.String = 'time [ms]';


%%
figure_handle_nan = figure;
for ii=1:8
    ax_nan = subplot(1,1,1);
    hold(ax_nan, 'on')
end

for cc=1:num_values
    temp = out{cc};
    for ii=16
        stairs(ax_nan, temp(:, ii), 'color', [cmap(ii, 1:3) 0.1], 'linewidth', 2)
        ax_nan.Title.String = singularity_list{ii};
    end
end
