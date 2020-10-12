function [uxo, uyo, uzo] = flows3d_cnem_set_initial_flows(num_nodes, seed)
%% This function produces random initial conditions drawn from a uniform distribution
%
% ARGUMENTS:
%      - num_nodes  --    an integer with the number of nodes in the
%                         unstructured dataset.
%      - seed       --    an integer for the random number generator 
% OUTPUT:
%   uxo, uyo, uxo -- 1D arrays with random  velocity components along each of the
%                    3 orthogonal axes. 
%
% AUTHOR:
%     Paula Sanz-Leon, QIMR Berghofer April 2020
% USAGE:
%{
    
%}
%   REFERENCES:

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    

  rng(seed) 
  a   = -0.125; 
  b   =  0.125; 
  uxo = a + (b-a).*rand([num_nodes, 1]);
  uyo = a + (b-a).*rand([num_nodes, 1]);
  uzo = a + (b-a).*rand([num_nodes, 1]);
  
end %flows3d_cnem_get_initial_flows()
