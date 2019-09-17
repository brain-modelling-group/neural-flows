/* This file is part of CNEMLIB.
 
Copyright (C) 2003-2011
Lounes ILLOUL (illoul_lounes@yahoo.fr)
Philippe LORONG (philippe.lorong@ensam.eu)
Arts et Metiers ParisTech, Paris, France
 
CNEMLIB is free software: you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

CNEMLIB is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with Foobar.  If not, see <http://www.gnu.org/licenses/>.

Please report bugs to illoul_lounes@yahoo.fr */

//---------------------------------------------------------------------------//
//Initialisation_Point_de_Gauss:

#include "C_Meshless_3d.h"

void C_Meshless_3d::Initialisation_Point_de_Gauss_Tet()
{
    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Tet S_Point_de_Gauss_Temp;
    
    //-----------------------------------------------------------------------//
    
    S_Point_de_Gauss_Temp.Poids=1.;
    S_Point_de_Gauss_Temp.Poids_Position[0]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[3]=1./4.;
    List_SPoint_de_Gauss_Tet[0].push_back(S_Point_de_Gauss_Temp);
    
    //-----------------------------------------------------------------------//

    double a=0.138196601125011;
    double b=0.585410196624969;

    S_Point_de_Gauss_Temp.Poids=1./4.;

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[1].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[1].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[1].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[1].push_back(S_Point_de_Gauss_Temp);
    
    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Temp.Poids=-0.8;

    S_Point_de_Gauss_Temp.Poids_Position[0]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[3]=1./4.;
    List_SPoint_de_Gauss_Tet[2].push_back(S_Point_de_Gauss_Temp);

    a=0.5/3.;
    b=0.5;
    
    S_Point_de_Gauss_Temp.Poids=0.45;

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[2].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[2].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[2].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[2].push_back(S_Point_de_Gauss_Temp);

    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Temp.Poids=-0.013155555555556*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[3]=1./4.;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    a=0.071428571428571;
    b=0.785714285714286;
    
    S_Point_de_Gauss_Temp.Poids=0.007622222222222*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    a=0.399403576166799;
    b=0.100596423833201;

    S_Point_de_Gauss_Temp.Poids=0.024888888888889*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[3].push_back(S_Point_de_Gauss_Temp);

    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Temp.Poids=0.030283678097089;

    S_Point_de_Gauss_Temp.Poids_Position[0]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./4.;
    S_Point_de_Gauss_Temp.Poids_Position[3]=1./4.;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    a=1./3.;
    b=0.;

    S_Point_de_Gauss_Temp.Poids=0.006026785714286;

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    a=0.090909090909091;
    b=0.727272727272727;
    
    S_Point_de_Gauss_Temp.Poids=0.011645249086029;

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    a=0.066550153573664;
    b=0.433449846426336;

    S_Point_de_Gauss_Temp.Poids=0.010949141561386;

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=a;
    S_Point_de_Gauss_Temp.Poids_Position[1]=b;
    S_Point_de_Gauss_Temp.Poids_Position[2]=b;
    S_Point_de_Gauss_Temp.Poids_Position[3]=a;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=b;
    S_Point_de_Gauss_Temp.Poids_Position[1]=a;
    S_Point_de_Gauss_Temp.Poids_Position[2]=a;
    S_Point_de_Gauss_Temp.Poids_Position[3]=b;
    List_SPoint_de_Gauss_Tet[4].push_back(S_Point_de_Gauss_Temp);

    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Temp.Poids=-0.03932701*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2500000;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2500000;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2500000;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2500000;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids=0.004081316*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.6175872;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1274709;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.6175872;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1274709;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.6175872;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1274709;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1274709;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.6175872;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);


    S_Point_de_Gauss_Temp.Poids=0.0006580868*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.9037635;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03207883;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.9037635;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03207883;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.9037635;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03207883;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03207883;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.9037635;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);


    S_Point_de_Gauss_Temp.Poids=0.004384259*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.04977710;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);
 
    S_Point_de_Gauss_Temp.Poids_Position[0]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.04977710;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);
      
    S_Point_de_Gauss_Temp.Poids_Position[0]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.4502229;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);
    
    S_Point_de_Gauss_Temp.Poids_Position[0]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.04977710;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.4502229;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.04977710;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.4502229;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.4502229;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);


    S_Point_de_Gauss_Temp.Poids=0.01383006*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1837304;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1837304;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.3162696;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1837304;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.3162696;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1837304;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.3162696;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.3162696;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);


    S_Point_de_Gauss_Temp.Poids=0.004240437*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.02291779;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.5132800;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.02291779;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.2319011;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.5132800;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.5132800;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.02291779;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.2319011;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.02291779;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.5132800;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);
    
    
    S_Point_de_Gauss_Temp.Poids=0.002238740*6;

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.7303134;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1937465;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.7303134;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.03797005;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1937465;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.1937465;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.7303134;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);

    S_Point_de_Gauss_Temp.Poids_Position[0]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[1]=0.03797005;
    S_Point_de_Gauss_Temp.Poids_Position[2]=0.7303134;
    S_Point_de_Gauss_Temp.Poids_Position[3]=0.1937465;
    List_SPoint_de_Gauss_Tet[5].push_back(S_Point_de_Gauss_Temp);
}

void C_Meshless_3d::Initialisation_Point_de_Gauss_Tri()
{
    S_Point_de_Gauss_Tri S_Point_de_Gauss_Temp;
    double w[3][4];
    double w_Temp[3];

    //-----------------------------------------------------------------------//
    
    S_Point_de_Gauss_Temp.Poids=1.;
    S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
    List_SPoint_de_Gauss_Tri[0].push_back(S_Point_de_Gauss_Temp);
    
    //-----------------------------------------------------------------------//

    w[0][0]=1./3.;
    w[1][0]=1./6.;
    w[2][0]=w[1][0];

    w_Temp[0]=1-w[1][0]-w[2][0];
    w_Temp[1]=w[1][0];
    w_Temp[2]=w[2][0];

    S_Point_de_Gauss_Temp.Poids=w[0][0];

    int i;
    for(i=0;i<3;i++)
    {
        S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[i];
        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(i+1)%3];
        S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(i+2)%3];
        List_SPoint_de_Gauss_Tri[1].push_back(S_Point_de_Gauss_Temp);
    }
    
    //-----------------------------------------------------------------------//

    w[0][0]=1./3.;
    w[1][0]=1./2.;
    w[2][0]=w[1][0];

    w_Temp[0]=1-w[1][0]-w[2][0];
    w_Temp[1]=w[1][0];
    w_Temp[2]=w[2][0];

    S_Point_de_Gauss_Temp.Poids=w[0][0];

    for(i=0;i<3;i++)
    {
        S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[i];
        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(i+1)%3];
        S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(i+2)%3];
        List_SPoint_de_Gauss_Tri[2].push_back(S_Point_de_Gauss_Temp);
    }
    
    //-----------------------------------------------------------------------//
    
    S_Point_de_Gauss_Temp.Poids=-27./48.;
    S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
    List_SPoint_de_Gauss_Tri[3].push_back(S_Point_de_Gauss_Temp);
    
    w[0][0]=25./48.;
    w[1][0]=1./5.;
    w[2][0]=w[1][0];
    
    w_Temp[0]=1-w[1][0]-w[2][0];
    w_Temp[1]=w[1][0];
    w_Temp[2]=w[2][0];

    S_Point_de_Gauss_Temp.Poids=w[0][0];    
    for(i=0;i<3;i++)
    {
        S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[i];
        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(i+1)%3];
           S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(i+2)%3];
        List_SPoint_de_Gauss_Tri[3].push_back(S_Point_de_Gauss_Temp);
    }
    
    //-----------------------------------------------------------------------//
    
    w[0][0]=(0.054975871827661)*2.;
    w[1][0]=0.091576213509771;
    w[2][0]=w[1][0];

    w[0][1]=(0.111690794839005)*2.;
    w[1][1]=0.445948490915965;
    w[2][1]=w[1][1];
    
    for(i=0;i<2;i++)
    {
        w_Temp[0]=1-w[1][i]-w[2][i];
        w_Temp[1]=w[1][i];
        w_Temp[2]=w[2][i];

        S_Point_de_Gauss_Temp.Poids=w[0][i];    
        
        int j;
        for(j=0;j<3;j++)
        {
            S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
            S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
            S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
            List_SPoint_de_Gauss_Tri[4].push_back(S_Point_de_Gauss_Temp);
        }
    }

    //-----------------------------------------------------------------------//
    
    S_Point_de_Gauss_Temp.Poids=9./40.;
    S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
    List_SPoint_de_Gauss_Tri[5].push_back(S_Point_de_Gauss_Temp);
    
    w[0][0]=(155.+sqrt(15.))/1200.;
    w[1][0]=(6.+sqrt(15.))/21.;
    w[2][0]=w[1][0];

    w[0][1]=(31./120.)-w[0][0];
    w[1][1]=(4./7.)-w[1][0];
    w[2][1]=w[1][1];

    for(i=0;i<2;i++)
    {
        w_Temp[0]=1-w[1][i]-w[2][i];
        w_Temp[1]=w[1][i];
        w_Temp[2]=w[2][i];

        S_Point_de_Gauss_Temp.Poids=w[0][i];    
        
        int j;
        for(j=0;j<3;j++)
        {
            S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
            S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
            S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
            List_SPoint_de_Gauss_Tri[5].push_back(S_Point_de_Gauss_Temp);
        }
    }
    
    //-----------------------------------------------------------------------//

    w[0][0]=(0.025422453185103)*2.;
    w[1][0]=0.063089014491502;
    w[2][0]=w[1][0];

    w[0][1]=(0.058393137863189)*2.;
    w[1][1]=0.249286745170910;
    w[2][1]=w[1][1];

    w[0][2]=(0.041425537809187)*2.;
    w[1][2]=0.310352451033785;
    w[2][2]=0.053145049844816;

    w[0][3]=w[0][2];
    w[1][3]=w[2][2];
    w[2][3]=w[1][2];
    
    for(i=0;i<4;i++)
    {
        w_Temp[0]=1-w[1][i]-w[2][i];
        w_Temp[1]=w[1][i];
        w_Temp[2]=w[2][i];

        S_Point_de_Gauss_Temp.Poids=w[0][i];    
        
        int j;
        for(j=0;j<3;j++)
        {
            S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
            S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
            S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
            List_SPoint_de_Gauss_Tri[6].push_back(S_Point_de_Gauss_Temp);
        }
    }
    
    //-----------------------------------------------------------------------//

    S_Point_de_Gauss_Temp.Poids=-0.1495700444677;
    S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
    S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
    List_SPoint_de_Gauss_Tri[7].push_back(S_Point_de_Gauss_Temp);
    
    w[0][0]=0.0533472356088;
    w[1][0]=0.0651301029022;
    w[2][0]=w[1][0];

    w[0][1]=0.1756152574332;
    w[1][1]=0.2603459660790;
    w[2][1]=w[1][1];

    w[0][2]=0.0771137608903;
    w[1][2]=0.3128654960049;
    w[2][2]=0.0486903154253;

    w[0][3]=w[0][2];
    w[1][3]=w[2][2];
    w[2][3]=w[1][2];
    
    for(i=0;i<4;i++)
    {
        w_Temp[0]=1-w[1][i]-w[2][i];
        w_Temp[1]=w[1][i];
        w_Temp[2]=w[2][i];

        S_Point_de_Gauss_Temp.Poids=w[0][i];    
        
        int j;
        for(j=0;j<3;j++)
        {
            S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
            S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
            S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
            List_SPoint_de_Gauss_Tri[7].push_back(S_Point_de_Gauss_Temp);
        }
    }
    
    //-----------------------------------------------------------------------//
}
