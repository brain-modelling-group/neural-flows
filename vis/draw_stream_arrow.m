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
%           .curved_arrows        -- true or false, 0 or 1. Draws arrows at
%                                    the head of the streamline
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
options.stream_length_steps=42;
options.curved_arrow = 1;
options.start_points_mode = 'grid';

draw_stream_arrow(x(:, :, 1), y(:, :, 1), u(:, :, 1), v(:, :, 1), options)

%}
%
% REQUIRES:
%         standardise_range()
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make some options local variables
stream_length = options.stream_length_steps; 
curved_arrow  = options.curved_arrow;

% Vmag is used for colouring
options.Vmag = get_set_options(options,'Vmag', sqrt(U.^2 + V.^2));
options.cmap = get_set_options(options,'cmap', colormap(gray));
cmap = options.cmap;


% Number of colours available in the colormap
n_col = size(cmap, 1);
n_col = n_col -1;

% Graphics options
dx = abs(Y0(1,1)-Y0(1,2)); 
dy = abs(X0(1,1)-X0(2,1)); 
dd = min([dx dy]);

% Arrow/Dot options
rs    = dd/100;   % Dot size if we don't plot arrows

switch options.start_points_mode
    case {'grid', 'gridded'}
        XY = stream2(X0,Y0,U,V,X0,Y0);
        Vmag = standardise_range(options.Vmag);
        x0=X0(:); 
        y0=Y0(:);
        
    case {'random_sparse', 'random-sparse'}
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(floor(size(X0)./2));
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(floor(size(Y0)./2));
        XY = stream2(X0, Y0, U, V, start_X, start_Y);
        Vmag = standardise_range(options.Vmag);
        x0 = start_X(:); 
        y0 = start_Y(:);
        
    case {'random_dense', 'random-dense'}
        % This method may be slow:
        %Interpolate missing values of V
        start_X = min(X0(:)) + (max(X0(:)) - min(X0(:))) * rand(size(X0));
        start_Y = min(Y0(:)) + (max(Y0(:)) - min(Y0(:))) * rand(size(Y0));
        XY = stream2(X0,Y0,U,V,start_X, start_Y);
        Vmag = interp2(X0, Y0, options.Vmag, start_X, start_Y, 'cubic');
        Vmag = standardise_range(Vmag);
        x0 = start_X(:); 
        y0 = start_Y(:);
    otherwise
        error(['patchflow:' mfilename ':NotImplemented'], ...
              'The streamline init method you requested is not implemented yet.');
        
end


%  XY is a cell array that contains cells with streamlines
len_streams = zeros(1, length(XY));
for k=1:length(XY)
    [len_streams(k), ~] =  size(XY{k});
end

long_streams  = find(len_streams > 1);
short_streams = find(len_streams < 2); 

if curved_arrow
   head_marker = @plot_arrow;  
else
   head_marker = @plot_dot; 
end

for kk=1:length(long_streams)
    
    effective_length = min(len_streams(long_streams(kk)), stream_length);
     
    % Get the tail
    F0{1} = XY{long_streams(kk)}(1:effective_length, :);
    % Get head
    F1{1} = XY{long_streams(kk)}(effective_length-1:effective_length, :);
    
    % Get the index for the colormap
    vcol = floor(Vmag(long_streams(kk))*n_col)+1;
    if isnan(vcol)
        vcol = 1;
    end
    this_colour = cmap(vcol,:);
    
    % Plot this streamline
    stream_handle = streamline(F0);
    set(stream_handle,'color', this_colour,'linewidth',.5);
    
    head_marker(F1{1}, x0(long_streams(kk)), y0(long_streams(kk)), this_colour, rs)

end

if ~isempty(short_streams)
    head_marker = @plot_dot; 

    for kk=1:length(short_streams)
                
        % Get the tail
        F0{1} = XY{short_streams(kk)}(1, :);
        % Get head
        F1{1} = XY{short_streams(kk)}(1, :);
        
        % Get the index for the colormap
        vcol = floor(Vmag(short_streams(kk))*n_col)+1;
        this_colour = cmap(vcol,:);
        
        % Plot this streamline
        stream_handle = streamline(F0);
        set(stream_handle,'color', this_colour,'linewidth',.5);
        
        head_marker(F1, x0(short_streams(kk)), y0(short_streams(kk)), this_colour, rs)
        
    end
end

axis image

end % function draw_stream_arrows()


function plot_arrow(P, ~, ~, this_colour, ~) 
       alpha = 2;        % Size of arrow head relative to the length of the vector
       beta  = 0.2;      % Width of the base of the arrow head relative to the length

       x1 = P(1,1); 
       y1 = P(1,2); 
       
       x2 = P(2,1); 
       y2 = P(2,2);
       
       u = x1-x2; 
       v = y1-y2; 
       u = -u; 
       v = -v;
       
       xa1 = x2 +u-alpha*(u+beta*(v+eps)); 
       xa2 = x2 +u-alpha*(u-beta*(v+eps));
       ya1 = y2 +v-alpha*(v-beta*(u+eps)); 
       ya2 = y2 +v-alpha*(v+beta*(u+eps));
       
       % Make filled arrows cause they look prettier
       patch([xa1 x2 xa2 xa1],[ya1 y2 ya2 ya1], this_colour, 'EdgeColor', this_colour); hold on
       

end % function plot_arrow()


function plot_dot(~, x0, y0, this_colour, rs) 
  
     rectangle('position',[x0-rs/2 y0-rs/2 rs rs],'curvature',[1 1], ...
               'facecolor',this_colour, 'edgecolor', this_colour)

end % function plot_dot()
