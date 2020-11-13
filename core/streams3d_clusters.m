function out=streams3d_clusters(s, opts)
%  cluststruct = streamlineclusters(s,opts)
% dense clusters of points from streamlines, looking only at streamlines
% longer than a minimum length, only taking a subset of points from the
% end, and with params for determining which cluster (if any) these points
% belong to.
%
% inputs: s - cell array of streamlines (each element is an N-by-3 matrix)
%         opts - options struct with fields (defaults shown):
%               dbscanminpts=10;     % minimum number of points to be deemed a cluster
%               dbscaneps=6;         % radius (in mm) for identifying clusters
%               minstreamlength=20;  % minimum streamline length (want the ones that ran for a while)
%               taillen=5;           % only count this many points at the end
% AUTHOR: James A. Roberts, QIMRB 2017-2018 (original: streamscluster)
%         Paula Sanz-Leon, QIMRB, 2020

if nargin<2
    dbscanminpts=10;     % minimum number of points to be deemed a cluster
    dbscaneps=6;         % radius (in mm) for identifying clusters
    minstreamlength=20;  % minimum streamline length (want the ones that ran for a while)
    taillen=5;           % only count this many points at the end
else
    dbscanminpts=opts.dbscanminpts;
    dbscaneps=opts.dbscaneps;
    minstreamlength=opts.minstreamlength;
    taillen=opts.taillen;
end

slong=s(cellfun(@length,s)>=minstreamlength);
slongtail=cellfun(@(x) x(end-(taillen-1):end,:),slong,'uniformoutput',false);
slongtailcat=vertcat(slongtail{:});
[sclustLabel,~]=dbscan(slongtailcat,dbscanminpts,dbscaneps);

out.sclustPoints=slongtailcat;
out.sclustLabel=sclustLabel;

end % function streams3d_clusters
