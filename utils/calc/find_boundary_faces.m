 function F = find_boundary_faces(T) 
  % BOUNDARY_FACES
  % F = boundary_faces(T)
  % Determine boundary faces of tetrahedra stored in T
  %
  % Input:
  %  T  tetrahedron index list, m by 4, where m is the number of tetrahedra
  %
  % Output:
  %  F  list of boundary faces, n by 3, where n is the number of boundary faces
  %

  % get all faces
  allF = [ ...
    T(:,1) T(:,2) T(:,3); ...
    T(:,1) T(:,3) T(:,4); ...
    T(:,1) T(:,4) T(:,2); ...
    T(:,2) T(:,4) T(:,3)];
  % sort rows so that faces are reorder in ascending order of indices
  sortedF = sort(allF,2);
  % determine uniqueness of faces
  [u, m, n] = unique(sortedF,'rows');
  % determine counts for each unique face
  counts = accumarray(n(:), 1);
  % extract faces that only occurred once
  sorted_exteriorF = u(counts == 1,:);
  % find in original faces so that ordering of indices is correct
  F = allF(ismember(sortedF,sorted_exteriorF,'rows'),:);
  
  % V are your vertex positions, T are your tet indices
  % get boundary faces 
  F = boundary_faces(T);
  % get boundary vertices
  b = unique(F(:));
  subplot(1,2,1);
  % plot boundary positions
  plot3(V(b,1),V(b,2),V(b,3),'.');
  subplot(1,2,2);
  % plot just  boundary faces
  trisurf(F,V(:,1),V(:,2),V(:,3),'FaceAlpha',0.3)
end