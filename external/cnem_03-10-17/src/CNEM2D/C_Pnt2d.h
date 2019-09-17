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

#ifndef C_Pnt2d_H
#define C_Pnt2d_H

#include "Global_Header.h"

class C_Pnt2d 
{

public:

// Methods PUBLIC
// 
C_Pnt2d();
C_Pnt2d(const double Xp,const double Yp);
void SetCoord(const double Xp,const double Yp) ;
void SetX(const double X) ;
void SetY(const double Y) ;
double X() const;
double Y() const;
double Distance(const C_Pnt2d& Other) const;
double SquareDistance(const C_Pnt2d& Other) const;

private: 

    double myX;
    double myY;
    
};

#endif
