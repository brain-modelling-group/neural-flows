function singularity_type = classify_singularities_3d(J3D)
% 3D classification of hyperbolic stationary points based on the jacobian
% matrix of the vector field around one point
% Assumes nondegenerate jacobian
% J3D: 3 x 3 -- jacobian matrix around a point
% 
% l1: first  eigenvalue of Jacobin
% l2: second eigenvalue
% l3: third  eigenvalue
% 
% Classification of stationary points in 3D
% l1, l2, l3 are eigenvalues of the jacbian
% If l1, l2, l3 are real then:
%    all positive > source
%    all negative > sink
%    1 positive, 2 negative > 1:2 saddle
%    2 positive, 1 negative > 2:1 saddle
% If one eigenvalue is real and the two imaginary eigenvalues are complex
% congjugates (a+ib, a-ib):
%    if real eigenvalue > 0
%                      if a > 0 --> spiral source
%                      if a < 0 -- spiral saddle  
%    if real eigenvalue < 0
%                      if a > 0 -- spiral saddle
%                      if a < 0 -- spiral sink
% Calculate matrix with eigenvalues of Jacobian
E = eig(J3D);

% Check if we have complex number
if sum(~isreal(E))    
   % Check if the imaginary part is larger than 0
   if sum(imag(E)) > 0
      singularity_type = classify_some_imaginary();
      
   else
       % cast complex numbers with zero imaginary part into real
       % eigenvalues
       E = real(E);
       singularity_type = classify_all_real(E);
   end
else
    singularity_type = classify_all_real(E);
end

    
end % function classify_singularities_3d()

function singularity_type = classify_all_real(E)
% E - eigenvalues of the Jacobian

% Classification if all the eigenvalues are real
    if all(E > 0)
       singularity_type = 'source'; 

    elseif all(E < 0)
       singularity_type = 'sink';

    elseif sum(sign(E)) < 0
        % One positive: Two negative: 1:2 saddle node
        singularity_type = '1-2-saddle';
        
    elseif sum(sign(E)) > 0
        % Two positive: One negative: 2:1 saddle node
        singularity_type = '2-1-saddle';
        
    end
    
end % function classify_all_real()


function singularity_type = classify_some_imaginary(E)
% E -- eigenvalues of the jacobian matrix
real_eigenvalue = find(imag(E) == 0);
imag_eigenvalues = E(~isreal(E));

if real(E(real_eigenvalue)) > 0
   if real(imag_eigenvalues(1)) > 0
       singularity_type = 'spiral_source';
   else 
       % 1 positive, two negatives
       singularity_type = '1-2-spiral_saddle';
   end
elseif real(E(real_eigenvalue)) < 0
   if real(imag_eigenvalues(1)) > 0
       % 2 positives, one negative
       singularity_type = '2-1-spiral_saddle';
   else 
       singularity_type = 'spiral_sink';
   end
else % assume real eigenvalue is 0
    singularity_type = 'cycle';
end

end % function classify_some_imaginary()
