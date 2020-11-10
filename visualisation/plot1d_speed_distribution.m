function figure_handle = plot1d_speed_distribution(params, varargin)
%        varargin   -- for the time being a 1 x 2 cell array with
%                      {'Visible', 'off'}:

obj_flows = load_iomat_flows(params);

numsubplot = 2;
figure_handle = figure('Name', 'nflows-speed-distribution', varargin{:});
ax = gobjects(numsubplot);

for jj=1:numsubplot
    ax(jj) = subplot(1, numsubplot, jj, 'Parent', figure_handle);
    hold(ax(jj), 'on')
end

if strcmp(params.flows.modality, 'amplitude')
   uxyz = obj_flows.uxyz;
else
   uxyz(:, 1, :) = obj_flows.vx; 
   uxyz(:, 2, :) = obj_flows.vy; 
   uxyz(:, 3, :) = obj_flows.vz; 
end

un = squeeze(sqrt(uxyz(:, 1, :).^2+uxyz(:, 2, :).^2+uxyz(:, 3, :).^2));

hh(1) = histogram(ax(1), un, 'Normalization', 'pdf');
hh(2) = histogram(ax(2), log10(un), 'Normalization', 'pdf');

for jj=1:numsubplot
   hh(jj).EdgeColor = 'none';
   hh(jj).FaceAlpha = 0.5;
   ax(jj).YLabel.String = 'pdf';
end

ax(1).XLabel.String = ['speed [' params.data.resolution.units.space '/'  params.data.resolution.units.time ']'];
ax(2).XLabel.String = ['log10(speed) [' params.data.resolution.units.space '/'  params.data.resolution.units.time ']'];


end