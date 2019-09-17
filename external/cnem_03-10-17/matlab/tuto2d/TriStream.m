% Matthew Wolinsky
% http://www.mathworks.com/matlabcentral/fileexchange/11278
%   TRISTREAM Trace streamlines on a triangular mesh using nodal velocities
%
%   FlowP=TriStream(tri,x,y,u,v,x0,y0) computes streamlines on the triangular mesh 
%   specified by tri with nodal coordinates [x,y]. Streamlines are traced using the 
%   nodal velocities u and v, and one streamline is produced for each seed point in 
%   the input vectors [x0,y0]. Streamlines are traced until one of four conditions
%   is met: 1) The particle travels beyond the mesh. 2) The particle intersects its
%   own path, creating a cycle. 3) The particle enters a stagnant zone (U~V~0). 
%   4) A maximum number of iterations is exceeded. The output of TRISTREAM is a 
%   structure array, FlowP, containing particle flowpaths, and can be displayed using 
%   PLOTTRISTREAM.
%
%   FlowP=TriStream(tri,x,y,u,v,x0,y0,verbose,maxits,Ltol,dLtol) allows enabling of a
%   progress report as TRISTREAM computes streamlines if verbose=1 (default verbose=0). 
%
%
%   FlowP=TriStream(tri,x,y,u,v,x0,y0,verbose,maxits,Ltol,dLtol) allows additional control
%   on the streamline tracing process. The parameter maxits gives the maximum number
%   of iterations to proceed before halting. The parameter Ltol (<<1) gives the minimum
%   distance (iun barycentric coordinates) beyond an edge which is considered to 
%   "oustide" of a triangle. The parameter dLtol (<1 typically) controls how much of a
%   change in the orientation of the particle trajectory is needed before a new trajectory 
%   must be calculated. Decreasing dLtol allows greater resolution of curved streamlines, 
%   but also requires a larger number of iterations. Note that for small values of dLtol, 
%   the value of maxits may need to be increased to prevent "short" streamlines.
%
%   Algorithm: 
%   TRISTREAM follows the approach outlined in the paper
%       "Efficient Streamline Computations on Unstructured Grids" by Mihai Dorobantu
%       http://citeseer.ist.psu.edu/40044.html
%   This algorithm uses a second-order Runge-Kutta method to integrate particle paths.
%   TRISTREAM uses a crude adaptive "time stepping" determined by dLtol/dt < |B|,
%   where dt is "pseudo-time" and |B| is the 1-norm of matrix B, which is the local
%   velocity-interpolation matrix within the current triangle. Cyclic paths are crudely
%   detected by checking to see if the distance between the current and starting positions
%   is less than the distance traveled during the last pseudo-time-step.
function FlowP=TriStream(tri,x,y,u,v,x0,y0,verbose,maxits,Ltol,dLtol)

if(nargin<8 )  verbose=0; end; % flag to report progress
if(nargin<9 ) maxits=1e3; end; % maximum number of iterations
if(nargin<10)  Ltol=1e-2; end; % flowpath "out-of-triangle" tolerance
if(nargin<11) dLtol=5e-1; end; % flowpath "curvature" tolerance

dt_max=1e24; % maximum timestep

Nnd=length(x); Ntri=length(tri); Npaths=length(x0);

% make sure orientations are correct
x=x(:)'; y=y(:)'; x0=x0(:)'; y0=y0(:)'; u=u(:)'; v=v(:)';
if(size(tri,1)~=3) tri=tri'; end;

% initialize flowpaths
Xbeg=x0; Ybeg=y0;

% store flowpaths
FlowP=struct('x',num2cell(Xbeg),'y',num2cell(Ybeg),'t',num2cell(zeros(1,Npaths)),'done',num2cell(zeros(1,Npaths)));
queue=1:Npaths;

% trace flowpaths ...
for its=1:maxits
    
    % find containing triangle
    TRI = tsearch(x,y,tri',Xbeg,Ybeg);

    % remove completed flowpaths from queue
    done=find(isnan(TRI)); TRI(done)=[]; Xbeg(done)=[]; Ybeg(done)=[];
    % note completed flowpaths
    if(~isempty(done)); [FlowP(queue(done)).done]=deal(1); queue(done)=[]; end;
    if(verbose)
        disp(['iteration ' num2str(its) ', finished ' num2str(Npaths-length(TRI)) ' of ' num2str(Npaths) ' flowpaths...']); 
    end
    if(isempty(TRI)) break; end;

    % get vertex coordinates and velocities
    X=x(tri(:,TRI)); Y=y(tri(:,TRI));
    U=u(tri(:,TRI)); V=v(tri(:,TRI));
    if(length(TRI)==1) X=X'; Y=Y'; U=U'; V=V'; end;
    
    % compute transform to triangular (area) coordinates: L=A*P , P=[X;Y;1]
    detA = 1./( Y(1,:).*(X(3,:)-X(2,:)) + Y(2,:).*(X(1,:)-X(3,:)) + Y(3,:).*(X(2,:)-X(1,:)) );
    A11=( Y(2,:)-Y(3,:) ).*detA; A12=( X(3,:)-X(2,:) ).*detA; A13=( X(2,:).*Y(3,:)-X(3,:).*Y(2,:) ).*detA;
    A21=( Y(3,:)-Y(1,:) ).*detA; A22=( X(1,:)-X(3,:) ).*detA; A23=( X(3,:).*Y(1,:)-X(1,:).*Y(3,:) ).*detA;
    A31=( Y(1,:)-Y(2,:) ).*detA; A32=( X(2,:)-X(1,:) ).*detA; A33=( X(1,:).*Y(2,:)-X(2,:).*Y(1,:) ).*detA;    

    % transform starting point
    L = [ A11.*Xbeg+A12.*Ybeg+A13; A21.*Xbeg+A22.*Ybeg+A23; A31.*Xbeg+A32.*Ybeg+A33 ];
    
    % compute velocity transform in triangular coordinates: V(L)=B*V
    B11=A11.*U(1,:)+A12.*V(1,:); B12=A11.*U(2,:)+A12.*V(2,:); B13=A11.*U(3,:)+A12.*V(3,:);
    B21=A21.*U(1,:)+A22.*V(1,:); B22=A21.*U(2,:)+A22.*V(2,:); B23=A21.*U(3,:)+A22.*V(3,:);
    B31=A31.*U(1,:)+A32.*V(1,:); B32=A31.*U(2,:)+A32.*V(2,:); B33=A31.*U(3,:)+A32.*V(3,:);    
    
    % Form the mid-point method update matrix from quadratic polynomial of velocity matrix: 
    %           L = Qh(B)*L0 , Qh(B) = I + dt*B + 0.5*dt^2*B^2
    %
    % We must now construct the three polynomials in dt, i.e.
    %           Q(dt) = 0.5*(B^2*L0)*dt^2 + (B*L0)*dt + L0
    %           Q(dt) = a*dt^2 + b*dt + c , c=L0; b=B*c; a=0.5*B*b 
    %
    % The timestep bound to not step out of a triangle is given by the
    % smallest positive real root (if any) of the three quadratics, Q(dt)=0
    c=L;
    b=[ B11.*c(1,:)+B12.*c(2,:)+B13.*c(3,:); B21.*c(1,:)+B22.*c(2,:)+B23.*c(3,:); B31.*c(1,:)+B32.*c(2,:)+B33.*c(3,:); ];
    a=[ B11.*b(1,:)+B12.*b(2,:)+B13.*b(3,:); B21.*b(1,:)+B22.*b(2,:)+B23.*b(3,:); B31.*b(1,:)+B32.*b(2,:)+B33.*b(3,:); ]*0.5;
    
    % as the default, assume that there is no time step limitation
    dt_c=repmat(dt_max,size(a));

    for r=1:3
        % check determinant to see if any real roots
        Qdet=b(r,:).^2-4*a(r,:).*c(r,:);
        ir=find((Qdet>0));
    
        if(~isempty(ir))
            % for Qdet>0, compute larger of two real roots (i.e. the '+' one)
            % use stable method, to avoid catastrophic roundoff errors (from Numerical Recipes)        
            q = -0.5*( b(r,ir) + sign(b(r,ir)).*sqrt(Qdet(ir)) );
            R=[q./a(r,ir);c(r,ir)./q];
            
            % find smallest positive root, and set dt_c
            ineg=find(R<0); R(ineg)=dt_max;            
            dt_c(r,ir)= min(R);
            
        end        
    end
    % set dt_c to slightly outside of current triangle  
    dt_c=(1+Ltol)*min(dt_c);
    
    % compute flowpath curvature bound for adaptive "time stepping"
    B1=sum(abs([B11;B21;B31])); B2=sum(abs([B12;B22;B32])); B3=sum(abs([B13;B23;B33])); % absolute column sums of B matrix    
    Bnrm = max([B1;B2;B3]); % 1-norm of B matrix
    dt_crv = dLtol./Bnrm;
    
    % set timestep
    dt=min(dt_c,dt_crv);
    
    % compute update
    dt=repmat(dt,[3,1]);
    L = dt.*( a.*dt + b ) + c;
    dt=dt(1,:);
    
    % transform back to physical coordinates
    Xend=L(1,:).*X(1,:)+L(2,:).*X(2,:)+L(3,:).*X(3,:);
    Yend=L(1,:).*Y(1,:)+L(2,:).*Y(2,:)+L(3,:).*Y(3,:);
    
    % update starting points
    Xbeg=Xend; Ybeg=Yend;

    % store flowpaths
    for p=1:length(queue)
        FlowP(queue(p)).x(its+1)=Xend(p); FlowP(queue(p)).y(its+1)=Yend(p); FlowP(queue(p)).t=FlowP(queue(p)).t+dt(p);      
    end

    %--------------------------------------------------------------------------
    %-----------Note: The following code does not work too well!---------------
    %--------------------------------------------------------------------------
    
    %--------------------------------------------------------------------------
    % check for cyclic paths ... remove completed flowpaths from queue
    %--------------------------------------------------------------------------
    done=[]; 
    for p=1:length(queue)
        F=FlowP(queue(p));
        if( norm([F.x(1)-Xend(p),F.y(1)-Yend(p)]) < norm([F.x(its)-Xend(p),F.y(its)-Yend(p)]) )
            FlowP(queue(p)).x(its+2)=F.x(1); FlowP(queue(p)).y(its+2)=F.y(1); FlowP(queue(p)).t=0;      
            done=[done,p];
        end
    end

    %--------------------------------------------------------------------------
    % check for stagnant zones ... remove completed flowpaths from queue
    %--------------------------------------------------------------------------
    done=[done,find(dt_c>dt_max)];

    % note completed flowpaths
    TRI(done)=[]; Xbeg(done)=[]; Ybeg(done)=[];
    if(~isempty(done)); [FlowP(queue(done)).done]=deal(1); queue(done)=[]; end;
    
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    %--------------------------------------------------------------------------
    
end

