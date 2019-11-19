function singularity_type = singularity3d_classify_critical_points(J3D)

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
%    1 positive, 2 negative > 1:2 saddle -->
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

% REFERENCES:
% FlowVisual: A Visualization App for Teaching and Understanding 3D Flow Field Concepts
% Wang, Tao, Ma, Shen, circa 2016

% Check if anything went wrong with the Jacobian calculation
if any(isnan(J3D(:)))
    singularity_type = 'nan';
    return
end

% Calculate eigenvalues
[~, D] = eig(J3D);

% Return only eigenvalues
E = diag(D);

tolerance = 1e-8; % arbitrary tolerance to determine the rank of V

% If the eigenvals of Jacobian are all zero, which is a weird case
% This check will fail if eigenvals of the Jacobian are complex
if sum(abs(E)) == 0 || sum(abs(E)) < 1e-17 
   singularity_type = 'zero';
   return
end

% Check if the Jacobian matrix is degenerate
if rank(J3D, tolerance) == 2
    singularity_type = singularity3d_classify_orbits(E);
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
        % Two negative:One positive: 2(in):1(out) -- attracting/sink saddle
        % saddle node.
        singularity_type = '2-1-saddle';
        
    elseif sum(sign(E)) > 0
        % One negative:Two positive: 1(in):2(out) saddle node -- repelling/source
        % saddle node.
        singularity_type = '1-2-saddle';
        
    elseif sum(sign(E)) == 0
        singularity_type = '1-1-0-saddle';
    end
    
end % function classify_all_real()


function singularity_type = classify_some_imaginary(E)
% E -- eigenvalues of the jacobian matrix
real_eigenvalue = find(imag(E) == 0);
imag_eigenvalues = E(imag(E) ~= 0);

if real(E(real_eigenvalue)) > 0
   if real(imag_eigenvalues(1)) > 0
       singularity_type = 'spiral-source';
   elseif  real(imag_eigenvalues(1)) < 0
       % two negatives (in), 1 positive(out)
       singularity_type = '2-1-spiral-saddle';
   end
elseif real(E(real_eigenvalue)) < 0
   if real(imag_eigenvalues(1)) > 0
       % one negative (in), 2 positives(out) 
       singularity_type = '1-2-spiral-saddle';
   elseif  real(imag_eigenvalues(1)) < 0 
       singularity_type = 'spiral-sink';
   end
elseif real(E(real_eigenvalue)) == 0 % may be a centre, although we should never reach this part of the code
    if (sum(abs(real(imag_eigenvalues))) == 0) && (sum(abs(imag(imag_eigenvalues))) ~= 0)
        singularity_type = 'centre';
    end
end
    
   
end % function classify_some_imaginary()
