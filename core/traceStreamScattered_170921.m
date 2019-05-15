function streams=traceStreamScattered(XYZ,IN_Tri_Ini,UVW,SXYZ,step,maxVert)
% streamlines for scattered velocity points
% based on traceStreamXYZUVW from matlab's stream3c.c

%/*
% * 3D streamline(x,y,z,u,v,w,sx,sy,sz)
% */



numVerts = 0;

if nargin<6
    maxVert=200; % What's max vert? Maximum vertices/length of streamlines
end

Type_FF=0;

% Number of streamlines
ns=size(SXYZ,1);
% 
live=true(ns,1); % streamlines that are still going

%streams=cell(1,ns);
streams=zeros(ns, 3, maxVert); % preallocate, will prune later


for j=1:maxVert
    %fprintf('%d ',j)
    
    % stop if all streamlines are done
    if ~live
        break
    end
    
    % make interpolation object
    Interpol=m_cnem3d_interpol(XYZ,IN_Tri_Ini,SXYZ(live,:),Type_FF);
    
    % terminate any streamlines that have left the interior
    livej=live(live); % live streamlines this iteration (has same length as number of live points)
    livej=livej&Interpol.In_Out;
    
    streams(live,:,j)=SXYZ(live,:);
    
    %if already been here, done
    % % how likely is this though!?
    
    % interpolate the vector data
    UVWinterp=Interpol.interpolate(UVW); % has same length as number of live points
    
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
    SXYZ(live,:)=SXYZ(live,:)+UVWstep(livej,:);
    
    
end


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