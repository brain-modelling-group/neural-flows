function [mstruct_vel] = generate_flow3d_abc_unsteady_grid(abc, visual_debugging)
% Generates time-dependent (unsteady) Arnold-Beltrami-Childress (ABC) 3D flow 
%
% ARGUMENTS:
%        abc -- a tpts x 3 vector with the coefficients for the ABC flow.
%       
%
% OUTPUT: 
%       mstruct_vel -- a structure that holds the vector field, along with
%                      necessary information/fields to perform
%                      classification.
%
% REQUIRES: 
%
% USAGE:
%{
    
%}
% AUTHOR: Paula Sanz-Leon, QIMR August 2019 

max_t = size(abc, 1);

 for tt=1:max_t-1
     [ux, uy, uz, ~, ~, ~] = generate_flow3d_abc_grid(abc(tt, :), visual_debugging);
     mstruct_vel.ux(:, :, :, tt) =  ux;
     mstruct_vel.uy(:, :, :, tt) =  uy;
     mstruct_vel.uz(:, :, :, tt) =  uz;
 end
 [ux, uy, uz, X, Y, Z] = generate_flow3d_abc_grid(abc(max_t, :), visual_debugging);
 mstruct_vel.ux(:, :, :, max_t) =  ux;
 mstruct_vel.uy(:, :, :, max_t) =  uy;
 mstruct_vel.uz(:, :, :, max_t) =  uz;
 
 options.flow_calculation.grid_size = size(X);
  
 mstruct_vel.options = options;
 mstruct_vel.hx = Y(2)-Y(1);
 mstruct_vel.hy = Y(2)-Y(1);
 mstruct_vel.hz = Y(2)-Y(1);
 mstruct_vel.X =  X;
 mstruct_vel.Y =  Y;
 mstruct_vel.Z =  Z;


end % generate_flow3d_abc_unsteady_grid()
