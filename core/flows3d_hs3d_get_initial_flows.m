function [uxo, uyo, uzo] = flows3d_hs3d_get_initial_flows(grid_shape, NAN_MASK, seed)

% X: domain shape
% NAN_MASK: logical mask of the same size as FA
if nargin < 3
    seed = 42;
end

  rng(seed) 
  a   = -0.125; % TODO: make it optional parameter based on data stats
  b   =  0.125; % TODO: make it optional parameter based on data stats
  uxo = a + (b-a).*rand(grid_shape);
  uyo = a + (b-a).*rand(grid_shape);
  uzo = a + (b-a).*rand(grid_shape);
  uxo(NAN_MASK) = NaN;
  uyo(NAN_MASK) = NaN;
  uzo(NAN_MASK) = NaN;
  
end %get_initial_velocity_distribution()
