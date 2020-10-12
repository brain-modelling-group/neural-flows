%% Calculate Euclidean distance between points.
%  not in signal-processing toolbox...
%  
%  For an arbitrary dimensional space:
%    If a is a vector of length the dimension of the space, ie the coordinates of 
%    a single point, then y is the distance between that point and each of the 
%    points described by b.
%    Otherwise a and b should be the same size, describing two matched sets of 
%    point pairs, then y is the Euclidean distance between those sets of points. 
%
% ARGUMENTS:
%           a(Dimension of Space, 1 | Number of Point pairs) -- 1st point|s
%           b(Dimension of Space, Number of Point pairs) -- 2nd point|s
%
% OUTPUT: 
%           y(Number of point pairs, 1) -- Euclidean distance between the
%                                          set of input point pairs
%
% REQUIRES: 
%          none
%
% USAGE:
%{
       %The distance between one point a and a set of points b in a 2D plane,
        a = [2 ; 7];
        b = [6 3 -2; 9 71.5 3.7];
        y = dis(a,b)
%}
%{
       %The distance between two sets of points a and b in a 2D plane,
        a = [2 13.2 17 ; 7 27 -2.6];
        b = [6 3 -2 ; 9 71.5 3.7];
        y = dis(a,b)
%}
% MODIFICATION HISTORY:
%     MB(2003) -- Original 
%     SAK(07-08-2006) -- comment.
%     SAK(11-08-2008) -- optimised...
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function y=dis(a,b)

 if size(a)==size(b)
   y = sqrt(sum((a-b).^2));
 else
   [dim,szt]=size(a);
   d=zeros(1,szt);
   for i=1:dim
     d=d+((a(i,:)-b(i,:)).^2);
   end
   y=sqrt(d);
 end

end %function