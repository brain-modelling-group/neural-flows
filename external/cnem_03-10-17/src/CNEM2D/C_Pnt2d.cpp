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

#include "C_Pnt2d.h"

C_Pnt2d::C_Pnt2d():myX(0.),myY(0.){}
C_Pnt2d::C_Pnt2d(const double Xp,const double Yp)
{
    myX=Xp;
    myY=Yp;
}

void C_Pnt2d::SetCoord(const double Xp,const double Yp)
{
    myX=Xp;
    myY=Yp;
}

void C_Pnt2d::SetX(const double X)
{
    myX=X;
}

void C_Pnt2d::SetY(const double Y)
{
    myY=Y;
}

double C_Pnt2d::X()const
{
    return myX;
}

double C_Pnt2d::Y()const
{
    return myY;
}

double C_Pnt2d::Distance(const C_Pnt2d& Other)const
{
    double D=sqrt(pow((Other.myX-myX),2)+pow((Other.myY-myY),2));
    return D;
}

double C_Pnt2d::SquareDistance(const C_Pnt2d& Other)const
{
    double SD=pow((Other.myX-myX),2)+pow((Other.myY-myY),2);
    return SD;
}
