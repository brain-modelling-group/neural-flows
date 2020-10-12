function [uxo, uyo, uzo] = flows3d_hs3d_set_initial_flows(grid_shape, nan_mask, seed)
%% This function produces random initial conditions drawn from a uniform distribution
%
% ARGUMENTS:
%      - grid_shape  --    a three element vector with the size of the grid
%      - nan_mask    --    a 3D logical array with 'true' where elements are nans, elements outside boundaries
%      - seed        --    an integer for the random number generator 
% OUTPUT:
%   uxo, uyo, uxo -- 3D arrays with rando  velocity components along each of the
%                     3 orthogonal axes. 
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer December 2018
% USAGE:
%{
    
%}
%   REFERENCES:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

  rng(seed) 
  a   = -0.125; % TODO: make it optional parameter based on data stats
  b   =  0.125; % TODO: make it optional parameter based on data stats
  uxo = a + (b-a).*rand(grid_shape);
  uyo = a + (b-a).*rand(grid_shape);
  uzo = a + (b-a).*rand(grid_shape);
  uxo(nan_mask) = NaN;
  uyo(nan_mask) = NaN;
  uzo(nan_mask) = NaN;
  
end %flows3d_hs3d_get_initial_flows()
