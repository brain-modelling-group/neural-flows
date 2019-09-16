function singularity_type = singularity3d_classify_critical_points_3d(J3D)

% 3D classification of hyperbolic stationary points based on the eigenvalues
% the jacobian matrix of the vector field around one critical point
% Assumes nondegenerate jacobian
% J3D: 3 x 3 -- jacobian matrix around a point
% 
% l1: first  eigenvalue of Jacobian
% l2: second eigenvalue of Jacobian
% l3: third  eigenvalue of Jacobian
% 
% Classification of stationary points in 3D
% l1, l2, l3 are eigenvalues of the jacbian
% If l1, l2, l3 are all real then:
%    all positive > source
%    all negative > sink
%    1 positive, 2 negative > 1:2 saddle
%    2 positive, 1 negative > 2:1 saddle
% If one eigenvalue is real and the two imaginary eigenvalues are complex
% conjugates (a+ib, a-ib):
%    if real eigenvalue > 0
%                      if a > 0 --> spiral source
%                      if a < 0 --> spiral saddle  
%    if real eigenvalue < 0
%                      if a > 0 --> spiral saddle
%                      if a < 0 --> spiral sink
% Calculate matrix with eigenvalues of Jacobian

% Check if anything went wrong with the Jacobian calculation

if any(isnan(J3D(:)))
    singularity_type = 'nan';
    return
end

[~, D] = eig(J3D);

% Return only eigenvalues
E = diag(D);

tolerance = 1e-8; % arbitrary tolerance to determine the rank of V
% Check if the matrix is degenerate

% If the Jacobian is all zero
if sum(E) == 0
        singularity_type = 'zero';
        return
end       
if rank(J3D, tolerance) < 3
    singularity_type = classify_orbits_3d(E);
    return
end


% Check if we have complex numbers. NOTE: If there is at least one complex
% eigenvalue, then all the values in E are cast as complex 
if ~isreal(E)    
   % Check if the imaginary parts are all larger than 0
   if sum(abs(imag(E))) ~= 0
      singularity_type = classify_some_imaginary(E);      
   else 
       % Cast complex numbers with zero imaginary part into real
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
        
    elseif sum(sign(E)) == 0
        singularity_type = '1-1-0-saddle';
    end
    
end % function classify_all_real()


function singularity_type = classify_some_imaginary(E)
% E -- eigenvalues of the jacobian matrix
real_eigenvalue = find(imag(E) == 0);
imag_eigenvalues = E(~isreal(E));

if real(E(real_eigenvalue)) > 0
   if real(imag_eigenvalues(1)) > 0
       singularity_type = 'spiral-source';
   else 
       % 1 positive(out), two negatives (in)
       singularity_type = '1-2-spiral-saddle';
   end
elseif real(E(real_eigenvalue)) < 0
   if real(imag_eigenvalues(1)) > 0
       % 2 positives(in), one negative (in)
       singularity_type = '2-1-spiral-saddle';
   else 
       singularity_type = 'spiral-sink';
   end
end

end % function classify_some_imaginary()
