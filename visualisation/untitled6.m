
load wind
vidObj = VideoWriter('mymovie.avi');
open(vidObj);
[sx, sy, sz] = meshgrid(80,20:1:55,5);
verts = stream3(x,y,z,u,v,w,sx,sy,sz);
sl = streamline(verts);
iverts = interpstreamspeed(x,y,z,u,v,w,verts,.025);
axis tight; view(30,30); daspect([1 1 .125])
camproj perspective; camva(8)
set(gca,'DrawMode','fast')
box on
[h, M]=streamparticlesMod(iverts,35,'animate',2,'FrameRate',100,'ParticleAlignment','on');
movie(M, 2, 100)   % play the movie. Do not close the figure window before playing the movie
writeVideo(vidObj, M);