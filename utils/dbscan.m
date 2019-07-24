% DBSCAN DBSCAN clustering algorithm
%
% Usage:  [C, ptsC, centres] = dbscan(P, E, min_pts)
%
% INPUT ARGUMENTS:
%         P - dim x Npts array of points.
%         E - Distance threshold. Must be a positive number.
%         min_pts - Minimum number of points required to form a cluster.
%
% OUTPUT ARGUMENTS:
%         C   -- Cell array of length Nc listing indices of points associated with
%                each cluster.
%      labels -- Array of length Npts listing the cluster label associated with
%                each point.  If a point is denoted as noise (not enough nearby
%                elements to form a cluster) its cluster number is 0.
%       centres -- dim x Nc array of the average centre of each cluster.
% REQUIRES: 
%          -  utilis/dis()
% Reference:
% Martin Ester, Hans-Peter Kriegel, Jörg Sander, Xiaowei Xu (1996). "A
% density-based algorithm for discovering clusters in large spatial databases
% with noise".  Proceedings of the Second International Conference on Knowledge
% Discovery and Data Mining (KDD-96). AAAI Press. pp. 226-231.  
% Also see: http://en.wikipedia.org/wiki/DBSCAN
% MODIFICATION HISTORY:
%     Original, Peter Kovesi: check his awesome webpage: peterkovesi.com
%     Modified, PSL, QIMR Berghofer 2018, runs faster

function [C, labels, centres] = dbscan(P, E, min_pts)
    
    [dim, num_pts] = size(P);
    
    labels  = zeros(num_pts,1);
    C     = {};
    Nc    = 0;                  % Cluster counter.
    Pvisit = zeros(num_pts,1);  % Array to keep track of points that have been visited.
    
    for n = 1:num_pts
       if ~Pvisit(n)                            % If this point not visited yet
           Pvisit(n) = 1;                       % mark as visited
           neighbour_pts = find_neighbours(P, n, E); % and find its neighbours

           if length(neighbour_pts) < min_pts-1  % Not enough points to form a cluster
               labels(n) = 0;                   % Mark point n as noise.
           
           else                % Form a cluster...
               Nc = Nc + 1;    % Increment number of clusters and process
                               % neighbourhood.
           
               C{Nc} = n;    % Initialise cluster Nc with point n
               labels(n) = Nc;   % and mark point n as being a member of cluster Nc.
               
               ind = 1;        % Initialise index into neighbourPts array.
               
               % For each point P' in neighbourPts ...
               while ind <= length(neighbour_pts)
                   
                   nb = neighbour_pts(ind);
                   
                   if ~Pvisit(nb)        % If this neighbour has not been visited
                       Pvisit(nb) = 1;   % mark it as visited.
                       
                       % Find the neighbours of this neighbour and if it has
                       % enough neighbours add them to the neighbourPts list
                       neighbourPtsP = find_neighbours(P, nb, E);
                       if length(neighbourPtsP) >= min_pts
                           neighbour_pts = [neighbour_pts  neighbourPtsP];
                       end
                   end            
                   
                   % If this neighbour nb not yet a member of any cluster add it
                   % to this cluster.
                   if ~labels(nb)  
                       C{Nc} = [C{Nc} nb];
                       labels(nb) = Nc;
                   end
                   
                   ind = ind + 1;  % Increment neighbour point index and process
                                   % next neighbour
               end
           end
       end
    end
    
    % Find centres of each cluster
    centres = zeros(dim,length(C));
    for n = 1:length(C)
        centres(:,n) = mean(P(C{n}), 2);
    end

end % of dbscan    
    
%-------------------------------------------------------------------------%

function neighbours = find_neighbours(P, n, E)
% Find indices of all points within distance E of point with index n
% Arguments:
%              P - the dim x Npts array of data points
%              n - Index of point of linterest
%              E - Distance threshold

    E2 = E^2;   
    dist2 = dis(P, P(n)).^2;
    neighbours = find(dist2 < E2);
        
end % function find_neighbours