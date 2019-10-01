function singularity_type = singularity3d_classify_orbits(E)
% Classifies hyperbolic periodic orbits (p. o.) in 3D space based on the 
% eigenvalues of the jacobian matrix -- Strictly speaking this is classification is 
% not correctm because the eigenvalues should be of the poincare map. 

% E -- vector with eigenvalues, one of the eigenvalues is zero

% ARGUMENTS:
%   E               -- eigenvalues of the 3D Jacobian matrix a vector with 3 elements. 
%
% OUTPUT       
%  singularity_type -- string with a human readable description of the
%                       singularity type.
% NOTES: Hyperbolic periodic orbits in 3D can be classified as follows:
%  --> Two real eigenvalues + one complex):
%      If real eigenvalues both inside the unit circle: source p.o 
%                          both outside unit circle:    sink p.o
%                          one inside, two outside: 
%                                                 both positive: saddle p.o                    
%                                                 bith negative: twisted p.o
% --> One real eigenvalue + two complex (complex conjugates)
%     complex eigenvalues outside the unit circle : spiral source p.o
%     complex eigenvalues inside the unit circle  : spiral sink p.o

% REQUIRES: 
%        None
%
% USAGE:
%{     


%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon, QIMR Berghofer 2018
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if ~isreal(E) % If we have complex numbers   
   % Check if we have complex conjugates
   if sum(imag(E)) == 0 % complex conjugate
      idx = find(E ~=0);
      l1 = E(idx(1));
      l2 = E(idx(2));
      if (norm(l1) > 1 &&  norm(l2) > 1)
          singularity_type='spiral-source-po';
      else
          singularity_type='spiral-sink-po';
      end
   end
else
    idx = find(E ~=0);
    l1 = E(idx(1));
    l2 = E(idx(2));
    if (norm(l1) > 1 &&  norm(l2) > 1)
        singularity_type = 'source-po';
    elseif (norm(l1) <= 1 &&  norm(l2) <= 1)
        singularity_type = 'sink-po';
    elseif ((norm(l1) > 1 && norm(l2) <=1) || (norm(l1) <= 1 && norm(l2) > 1))
        if (l1 > 0 && l2 > 0)
            singularity_type = 'saddle-po';
        elseif (l1 < 0 && l2 < 0)
            singularity_type = 'twisted-po';
        end
    
    end
end
end % function calssify_orbits_3d()
