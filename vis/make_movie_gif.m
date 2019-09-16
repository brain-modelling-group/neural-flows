function make_movie_gif(data, save_anim)

% data should be (space dim 1, space dim 2, time)
% save_anim  boolean, 0 - do not save, 1 save animation in gif

% =====================================================================
if nargin < 2
    
   save_anim = 0;
end
%  Enter file name
temp_fname = generate_temp_filename('gif_anim', 3);
anim_name = [temp_fname 'gif'];

%  Delay in seconds before displaying the next image  
    delay = 0;  
%  Frame counter start
  
nt = 1;
tpts = size(data, 3);


figure('Name', 'nflows-gifanim')
pos = [0.6 0.05 0.35 0.40];
set(gcf,'Units','normalized');
set(gcf,'Position',pos);
set(gcf,'color','w');

for cc =1:tpts
  xy = data;
  pcolor(xy)
  shading interp
  axis off
  % NOTE: these parameters should be passed as options
  colormap(parula(1024))
  caxis([-40 10])
  
  if save_anim == 1
       frame = getframe(3);
       im = frame2im(frame);
       [imind,cm] = rgb2ind(im, 256);
       %  On the first loop, create the file. In subsequent loops, append.
       if nt == 1
         imwrite(imind, cm, anim_name,'gif','DelayTime', delay,'loopcount',inf);
       else
         imwrite(imind, cm, anim_name,'gif','DelayTime', delay,'writemode','append');
       end
       nt = nt+1;
  end
  pause(1)
end

end % make_gif_animation()
