



%%
tt=1;
surf_handle = figure_surf(FV, ones(16384, 1), 'mwg');

max_val = max(abs(dEnergyF(:)));
min_val = min(abs(dEnergyF(:)));

for tt=1:99    
set(surf_handle, 'FaceColor', 'flat', 'FaceVertexCData', dEnergyF(:, tt))
caxis([min_val, max_val])
pause(0.1)
end
