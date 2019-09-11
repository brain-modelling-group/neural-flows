
## Brain Waves: Generation, detection and classification of measured spatiotemporal patterns in brain network models.
## Patch Flow
## Neural Flows
If you use this toolbox, please cite:

Roberts JA, Gollo LL, Abeysuriya R, Roberts G, Mitchell PB, Woolrich MW, Breakspear M. Metastable brain waves. (2018) (submitted). [Preprint available on bioarxiv.](https://www.biorxiv.org/content/early/2018/10/03/347054)



#### Dependencies:


1. [Brain Dynamics Toolbox](http://www.bdtoolbox.org/)
    - this code has been tested with version 2017c, available at:
      https://github.com/breakspear/bdtoolkit/releases/download/2017c/bdtoolkit-2017c.zip

2. [Constrained Natural Element Method (CNEM)](https://m2p.cnrs.fr/sphinxdocs/cnem/index.html)
    - used version (v03, 2014-05-04) available here: https://ff-m2p.cnrs.fr/frs/?group_id=14
    - aka cnemlib: https://au.mathworks.com/matlabcentral/linkexchange/links/3875

3. A connectivity matrix:
    - an n-by-n matrix giving the strength of connectivity between each pair of n nodes, with zeros on the
      diagonal (no self connections).



### Contents:


+ `brainwaves_sim.m` - script to simulate the model, using the Brain Dynamics Toolbox.


+ `cohcorrgram.m` - function to calculate the time-windowed cross-correlation between the phase coherences of 
                two groups of nodes (e.g. left hemisphere vs right hemisphere).


+ `corrgram.m` - (slightly modified) version of `corrgram.m` from the MATLAB File Exchange, URL:
             https://au.mathworks.com/matlabcentral/fileexchange/15299-windowed-cross-correlation--corrgram-


+ `phases_nodes.m` - helper function to calculate instantaneous phase for all nodes of the network.


+ `phaseflow_cnem.m` - function to calculate phase flow (velocity vector field) at all points (uses CNEM).


+ `traceStreamScattered.m` - function to calculate streamlines for a velocity vector field sampled at scattered points in 3-D (uses CNEM).


+ `grad_cnem.m` - helper function to calculate gradient for scattered points (uses CNEM).


+ `grad_B_cnem.m` - helper function to calculate the B matrix for grad_cnem (uses CNEM).

