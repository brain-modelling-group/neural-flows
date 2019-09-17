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

#ifndef C_Vec2d_H
#define C_Vec2d_H

#include "C_Pnt2d.h"

class C_Vec2d
{

public:

// Methods PUBLIC
// 
C_Vec2d();
C_Vec2d(const double Xv,const double Yv);
C_Vec2d(const C_Pnt2d& P1,const C_Pnt2d& P2);
C_Vec2d(double* P1,double* P2);
void SetCoord(const double Xv,const double Yv) ;
void SetX(const double X) ;
void SetY(const double Y) ;
double X() const;
double Y() const;

double Angle(const C_Vec2d& Other) const;
double Magnitude() const;
double SquareMagnitude() const;
void Normalize() ;
C_Vec2d Normalized() const;

void Add(const C_Vec2d& Other) ;
void operator +=(const C_Vec2d& Other) 
{
  Add(Other);
}

C_Vec2d Added(const C_Vec2d& Other) const;
C_Vec2d operator +(const C_Vec2d& Other) const
{
  return Added(Other);
}

double Crossed(const C_Vec2d& Right) const;
double operator ^(const C_Vec2d& Right) const
{
  return Crossed(Right);
}

void Divide(const double Scalar) ;
void operator /=(const double Scalar) 
{
  Divide(Scalar);
}

C_Vec2d Divided(const double Scalar) const;
C_Vec2d operator /(const double Scalar) const
{
  return Divided(Scalar);
}

double Dot(const C_Vec2d& Other) const;
double operator *(const C_Vec2d& Other) const
{
  return Dot(Other);
}

void Multiply(const double Scalar) ;
void operator *=(const double Scalar) 
{
  Multiply(Scalar);
}

C_Vec2d Multiplied(const double Scalar) const;
C_Vec2d operator *(const double Scalar) const
{
  return Multiplied(Scalar);
}

void Reverse() ;
C_Vec2d Reversed() const;
C_Vec2d operator -() const
{
  return Reversed();
}

void Subtract(const C_Vec2d& Right) ;
void operator -=(const C_Vec2d& Right) 
{
  Subtract(Right);
}

C_Vec2d Subtracted(const C_Vec2d& Right) const;
C_Vec2d operator -(const C_Vec2d& Right) const
{
  return Subtracted(Right);
}

private: 

    double myX;
    double myY;
    
};

#endif
