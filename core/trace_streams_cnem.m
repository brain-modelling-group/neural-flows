function streams = trace_streams_cnem(locs, boundary_faces, flow_field, seed_locs, time_step, max_stream_length)
%% Traces streamlines using a velocity field defined on scattered points in space
%  based on traceStreamXYZUVW from matlab's stream3c.c, using CNEM
%  functions.
%
% ARGUMENTS:
%          locs     -- a 2D array of size [nodes x 3] with the x,y,z
%                      coordinates of the nodes/regions centroids.
%          boundary_faces -- a 2D array of size [num_faces x 3] with the
%                            triangulation of the brain's convex hull.
%          flow_field -- a 2D array of size [nodes x 3] with the 
%                        velocity components u, v, w at each point in locs.
%                        
%          seed_locs  -- a 2D array of size [num_seeds x 3] with the x, y,z 
%                        coordinates of the streamlines starting points. 
%          time_step  -- a float with the time step used to trace the
%                        streamlines.
%          max_streamline_length -- an integer with the maximum length acceptable 
%                                  for a streamlines (in points/samples).
%                                  Matlab's streamline functions call this number  
%                                  'max number of vertices'. In a way, this
%                                  is the maximum number of timesteps tht
%                                  we will integrate.
%                                  
%
% OUTPUT: 
%          streams -- velocity struct, with fields:
%            -- vnormp - magnitude of velocity (speed) [time x nodes]
%            -- vxp - x component of the vector field of size [time x nodes]
%            -- vyp - y component of the vector field of size [time x nodes]
%            -- vzp - z component of the vector field of size [time x nodes]
%
% REQUIRES: 
%          m_cnem3d_interpol()
%          
% USAGE:
%{     
    

%}
%
% MODIFICATION HISTORY:
%     JA Roberts, QIMR Berghofer, 2018
%     Paula Sanz-Leon, QIMR Berghofer, 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


if nargin<6
    max_stream_length = 200;
end

% CNEM parameter
Type_FF = 0;

% Number of streamlines
num_streams = size(seed_locs, 1);

% Streamlines that are still growing
live = true(num_streams, 1); 

embedding_dimension = 3;
% Preallocate, will prune later
streams(num_streams, embedding_dimension, max_stream_length) = 0; 

disp([mfilename ':: Tracing streamlines ...'])
    
for j=1:max_stream_length
    
    % stop if all streamlines are done
    if ~live
        break
    end
    
    % Make interpolation object
    FInterpol = m_cnem3d_interpol(locs, boundary_faces, seed_locs(live,:), Type_FF);
    
    % terminate any streamlines that have left the interior
    livej=live(live); % live streamlines this iteration (has same length as number of live points)
    livej=livej&FInterpol.In_Out;
    
    streams(live,:,j)=seed_locs(live,:);
    
    %if already been here, done
    % % how likely is this though!?
    
    % interpolate the vector data
    UVWinterp=FInterpol.interpolate(UVW); % has same length as number of live points
    
    % check if step length has hit zero
    validsteps=~all(~UVWinterp,2);
    %if any(~validsteps), fprintf('%d steps hit zero\n',sum(~validsteps)), end
    livej=livej&validsteps;
    
    % calculate step size
    % stream3c rescales the velocities by max(abs(vcomponent))
    UVWstep=UVWinterp*step./max(abs(UVWinterp)); % uses singleton expanson
    
    % update overall live list
    live(live)=livej;
    
    % update the current position
    SXYZ(live,:) = seed_locs(live,:) + UVWstep(livej,:);
    
    
end

disp([mfilename ':: Done.'])

if 0
%%
conn=zeros(3,3,3);
conn(2,2,:)=1;
conncomp=bwconncomp(streams,conn);
ids=conncomp.PixelIdxList; ids=reshape(ids,[],3);
slens=cellfun(@length,ids); %513x3
%any(any(diff(slens,[],2),2)) % false if all x,y,z components are same length
slens=max(slens,[],2);
%%
ns=size(streams,1);
scell=cell(1,ns);
for j=1:ns
    scell{j}=streams([ids{j,:}]);
end






end