function figure_handle = plot1d_speed_distribution(mflows_obj, varargin)

numsubplot = 2;
figure_handle = figure('Name', 'nflows-speed-distribution', varargin{:});
ax = gobjects(numsubplot);

for jj=1:numsubplot
    ax(jj) = subplot(1, numsubplot, jj, 'Parent', figure_handle);
    hold(ax(jj), 'on')
end

uxyz = mflows_obj.uxyz_sc;

un = squeeze(sqrt(uxyz(:, 1, :).^2+uxyz(:, 2, :).^2+uxyz(:, 3, :).^2));

hh(1) = histogram(ax(1), un, 'Normalization', 'pdf');
hh(2) = histogram(ax(2), log10(un), 'Normalization', 'pdf');

for jj=1:numsubplot
    hh(jj).EdgeColor = 'none';
    hh(jj).FaceAlpha = 0.5;
    ax(jj).YLabel.String = 'pdf';
end

ax(1).XLabel.String = 'speed [m/s]';
ax(2).XLabel.String = 'log10(speed) [m/s]';


end