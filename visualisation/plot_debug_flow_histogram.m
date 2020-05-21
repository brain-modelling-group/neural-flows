function plot_debug_flow_histogram(fig_handle, obj_flows, params)


switch params.flows.method.data.mode
    case {'amplitude'}
         switch params.data.grid.type 
 
            case {'structured'}
                ux = obj_flows.ux(2:end-1, 2:end-1, 2:end-1, :);
                uy = obj_flows.uy(2:end-1, 2:end-1, 2:end-1, :);
                uz = obj_flows.uz(2:end-1, 2:end-1, 2:end-1, :);
                un = obj_flows.un(2:end-1, 2:end-1, 2:end-1, :);

            case {'unstructured'}
                ux = obj_flows.uxyz(:, 1, :);
                uy = obj_flows.uxyz(:, 2, :);
                uz = obj_flows.uxyz(:, 3, :);
                un = obj_flows.uxyz_n;
         end
    case {'phase'}
        ux = obj_flows.vx;
        uy = obj_flows.vy;
        uz = obj_flows.vz;
        un = obj_flows.vn; 
end
        
unit_label = strcat('[', params.data.units.space, '/', ...
                         params.data.units.time, ']');

subplot(1, 4, 1, 'Parent', fig_handle)
hist_handle(1) = histogram(ux(:), 'Normalization', 'pdf');
xlabel(strcat('ux ',  unit_label))
 
subplot(1, 4, 2, 'Parent', fig_handle)
hist_handle(2) = histogram(uy(:), 'Normalization', 'pdf');
xlabel(strcat('uy ',  unit_label))
 
subplot(1, 4, 3, 'Parent', fig_handle)
hist_handle(3) = histogram(uz(:), 'Normalization', 'pdf');
xlabel(strcat('uz ',  unit_label))
 
subplot(1, 4, 4, 'Parent', fig_handle)
hist_handle(4) = histogram(un(:), 'Normalization', 'pdf');
xlabel(strcat('u_{norm} ',  unit_label))

for hh=1:length(hist_handle)
    hist_handle(hh).EdgeColor = [0.5 0.5 0.5];
    hist_handle(hh).FaceColor = [0.5 0.5 0.5];
end

end %function plot_debug_flow_histogram