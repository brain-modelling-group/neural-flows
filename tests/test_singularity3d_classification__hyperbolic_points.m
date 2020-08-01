function test_singularity3d_classification__hyperbolic_points(cp_type)
% This function test the accuracy of the singularity classification functions 
% called via singularity3d_classify_singularities(). The current function
% only tests the 8 canonical critical points in 3D. It first generates the 
% vector field with the requested singularity and then applies the
% classification. If the singularity is missclassified, an error message
% is displayed.
%
% ARGUMENTS:
%          cp_type  -- a string with the name of the singularity to test.
%                      Options: {'source', 
%                                'sink',
%                                '2-1-saddle', 
%                                '1-2-saddle', 
%                                'spiral-sink', 
%                                'spiral-source',
%                                '2-1-spiral-saddle', 
%                                '1-2-spiral-saddle',
%                                'all'}
% OUTPUT: 
%          None
%
% REQUIRES: 
%           generate_singularity3d_hyperbolic_critical_points()
%          
% USAGE:
%{     

%}
%
% MODIFICATION HISTORY:
%     Paula Sanz-Leon -- QIMR October 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargin < 1
    cp_type = 'all';
end

if strcmp(cp_type, 'all')
    s3d_list = s3d_get_base_singularity_list();
    s3d_list(9:end) = [];
else
    s3d_all_list = s3d_get_base_singularity_list();
    for ii=1:18
        if strcmp(cp_type, s3d_all_list{ii})
            this_cp = ii;
        end
    end
    s3d_list = s3d_all_list(this_cp);
end

for this_cp=1:length(s3d_list)
    cp_type = s3d_list(this_cp);
    [ux, uy, uz, X, Y, Z, p1, p2] = generate_singularity3d_hyperbolic_critical_points(cp_type{:});

    plot3d_hyperbolic_critical_point([], p1, p2, ux, uy, uz, X, Y, Z, cp_type{:})
    
    hx = X(1, 2, 1) - X(1, 1, 1);
    hy = Y(2, 1, 1) - Y(1, 1, 1);
    hz = Z(1, 1, 2) - Z(1, 1, 1);

    xyz = size(X);
    ii = floor(xyz(1)/2); % y
    jj = floor(xyz(2)/2); % x
    kk = floor(xyz(3)/2); % z

    [J3D] = singularity3d_jacobian([ii, jj, kk], ux, uy, uz, hx, hy, hz);
    out_classification{this_cp} = singularity3d_classify_critical_points(J3D);


     err_message = ['neural-flows' mfilename '::ClassificationError:: ', ...
                    'Input singularity type (' cp_type{:} ') does not match classification result '];


    assert(strcmp(out_classification{this_cp}, cp_type{:}), [err_message '(' out_classification{this_cp} ').']);

end
end %function test_singularity3d_classification_hyperbolic_points()
