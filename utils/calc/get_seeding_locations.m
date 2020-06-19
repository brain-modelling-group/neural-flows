function seed_locs = get_seeding_locations(locs, modality, seed)

if nargin < 3
    seed = 2020;
end

switch modality
    case {"nodes", "regions", "nodal"}
        seed_locs = locs;
        % do something
    case {"random-dense", "random_dense"}
        % seeds 2*num nodes streamlines
        rng(seed)
        node_idx1 = randi([1, size(locs, 1)], size(locs, 1),  1);
        node_idx2 = randi([1, size(locs, 1)], size(locs, 1),  1);
        seed_locs = (locs(node_idx1, :) + locs(node_idx2, :))/2;
        seed_locs = vertcat(seed_locs, locs);
     case {"random-sparse", "random_sparse"}
        % seeds 2*num nodes streamlines
        rng(seed)
        node_idx1 = randi([1, size(locs, 1)], round(size(locs, 1)/2), 1);
        node_idx2 = randi([1, size(locs, 1)], round(size(locs, 1)/2), 1);
        seed_locs = (locs(node_idx1, :) + locs(node_idx2, :))/2;
        seed_locs = vertcat(seed_locs, locs);
    otherwise
        error(['neural-flows:' mfilename ':UnknownCase'], ...
               'Requested unknown method. Options: {"nodes", "random"}');
end
end % function get_seeding_locations()