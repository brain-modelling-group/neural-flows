function singularity_type = classify_orbits_3d(E)
% classification of periodi orbits (p. o) in 3D based on the eigenvalues of the jacobian
% matrix
% E -- vector with eigenvalues
%Hyperbolic periodic orbits in 3D can be classified as follows:
% Two real eigenvalues (one complex):
%  If real eigenvalues inside the unit circle: source p.o 
%                      both outside unit circle: sink p.o
%                      one inside, two outside: 
%                                             both positive: saddle p.o                    
%                                             bith negative: twisted p.o
% One real eigenvalue, two complex conjugate:
% complex eigenvalues outside the unit circle : spiral source p.o
% complex eigenvalues inside the unit circle  : spiral sink p.o
singularity_type = 'orbit?';

end