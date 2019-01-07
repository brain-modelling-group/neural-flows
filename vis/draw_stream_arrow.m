function [stream_handle, options] = draw_stream_arrow(X0, Y0, U, V, options)
%% Identifies open figures from handles in graphics object array.
%
% ARGUMENTS: 
%    X0 -- 
%    Y0 -- 
%    U  --
%    V  --
%    options
%           .stream_length_steps  -- an integer number of 'time' steps to
%                                    display. It determines the length of
%                                    the streamlines.
%
% OUTPUT:
%    stream_handle -- streamline objects handle
%
% AUTHOR:
%    Paula Sanz-Leon, (2018), QIMR Berghofer
%
% USAGE:
%{ 

load wind
options.stream_length_steps=4;
options.curved_arrow = 1;
draw_stream_arrow()

%}
%
% REQUIRES:
%         standardise_range()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stream_length = options.stream_length_steps; 
curved_arrow  = options.curved_arrow;

% Vmag is used for colouring
options.Vmag = get_set_options(options,'Vmag', sqrt(U.^2+V.^2));
options.cmap = get_set_options(options,'cmap', colormap(gray));
cmap = options.cmap;



% number of colours available in the colormap
n_col = size(cmap, 1);
n_col = n_col -1;

% Graphics
DX = abs(X0(1,1)-X0(1,2)); 
DY = abs(Y0(1,1)-Y0(2,1)); 
DD = min([DX DY]);

ks    = DD/100;   % Size of the "dot" for the tuft graphs
alpha = 2;        % Size of arrow head relative to the length of the vector
beta  = 0.2;      % Width of the base of the arrow head relative to the length

switch options.start_points_mode
    case 'grid'
        XY = stream2(X0,Y0,U,V,X0,Y0);
        Vmag = standardise_range(options.Vmag);
        x0=X0(:); 
        y0=Y0(:);
        
    case 'random_sparse'
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0));
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0));
        XY = stream2(X0,Y0,U,V,start_X, start_Y);
        Vmag = standardise_range(options.Vmag);
        x0 = start_X(:); 
        y0 = start_Y(:);
        
    case 'random_dense'
        % This method may be slow:
        %Interpolate missing values of V
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0)*2);
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0)*2);
        XY = stream2(X0,Y0,U,V,start_X, start_Y);
        Vmag = interp2(X0, Y0, options.Vmag, start_X, start_Y, 'cubic');
        Vmag = standardise_range(Vmag);
        x0 = start_X(:); 
        y0 = start_Y(:);
    otherwise
        error(['patchflow:' mfilename ':NotImplemented'], ...
              'The streamline init method you requested is not implemented.');
        
end


% Find indices of streamlines with L = 1

% short_streamlines = [];
% 
% for kk=1:length(XY);
%     

for k=1:length(XY)
    
    F = XY(k); 
    [L, ~] = size(F{1});
    
        if L < stream_length
            F0{1} = F{1}(1:L,:);
            
            if L==1
                F1{1}=F{1}(L,:);
            else
                F1{1}=F{1}(L-1:L,:);
            end
            
        else
            F0{1}=F{1}(1:stream_length,:);
            F1{1}=F{1}(stream_length-1:stream_length,:);
        end
        
    % Tail    
    P = F1{1};

    vcol = floor(Vmag(k)*n_col)+1;
    this_colour = cmap(vcol,:);
    

    stream_handle = streamline(F0);
    set(stream_handle,'color',this_colour,'linewidth',.5);
    
    % Plot arrows
    if curved_arrow == 1 && L>1
       x1=P(1,1); 
       y1=P(1,2); 
       
       x2=P(2,1); 
       y2=P(2,2);
       
       u = x1-x2; 
       v = y1-y2; 
       u=-u; 
       v=-v;
       
       xa1 = x2+u-alpha*(u+beta*(v+eps)); 
       xa2 = x2+u-alpha*(u-beta*(v+eps));
       ya1 = y2+v-alpha*(v-beta*(u+eps)); 
       ya2 = y2+v-alpha*(v+beta*(u+eps));
       plot([xa1 x2 xa2],[ya1 y2 ya2],'color', this_colour); hold on
   else
    rectangle('position',[x0(k)-ks/2 y0(k)-ks/2 ks ks],'curvature',[1 1], ...
              'facecolor',this_colour, 'edgecolor', this_colour)
   end
    
            
     
end

axis image

end % function draw_stream_arrows()
