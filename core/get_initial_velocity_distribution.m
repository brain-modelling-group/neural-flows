function [uxo, uyo, uzo] = get_initial_velocity_distribution(X, NAN_MASK, seed)
% X: domain shape
% NAN_MASK: logical mask of the same size as FA
if nargin < 3
    seed = 42;
end

  rng(seed) 
  a   = -0.125; % TODO: make it optional parameter based on data stats
  b   =  0.125; % TODO: make it optional parameter based on data stats
  uxo = a + (b-a).*rand(size(X));
  uyo = a + (b-a).*rand(size(X));
  uzo = a + (b-a).*rand(size(X));
  uxo(NAN_MASK) = NaN;
  uyo(NAN_MASK) = NaN;
  uzo(NAN_MASK) = NaN;
  
end