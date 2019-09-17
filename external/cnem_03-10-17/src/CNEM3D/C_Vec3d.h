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

#pragma once

#include "C_Pnt3d.h"

class C_Vec3d
{
public:

// Methods PUBLIC
// 
C_Vec3d();
C_Vec3d(const double Xv,const double Yv,const double Zv);
C_Vec3d(const C_Pnt3d& P1,const C_Pnt3d& P2);
C_Vec3d(const double* P1,const double* P2);
void SetCoord(const double Xv,const double Yv,const double Zv) ;
void SetX(const double X) ;
void SetY(const double Y) ;
void SetZ(const double Z) ;
double X() const;
double Y() const;
double Z() const;

double Magnitude() const;
double SquareMagnitude() const;
void Normalize() ;
C_Vec3d Normalized() const;

void Add(const C_Vec3d& Other) ;
void operator +=(const C_Vec3d& Other) 
{
  Add(Other);
}

C_Vec3d Added(const C_Vec3d& Other) const;
C_Vec3d operator +(const C_Vec3d& Other) const
{
  return Added(Other);
}

C_Vec3d Crossed(const C_Vec3d& Right) const;
C_Vec3d operator ^(const C_Vec3d& Right) const
{
  return Crossed(Right);
}

void Divide(const double Scalar) ;
void operator /=(const double Scalar) 
{
  Divide(Scalar);
}

C_Vec3d Divided(const double Scalar) const;
C_Vec3d operator /(const double Scalar) const
{
  return Divided(Scalar);
}

double Dot(const C_Vec3d& Other) const;
double operator *(const C_Vec3d& Other) const
{
  return Dot(Other);
}

void Multiply(const double Scalar) ;
void operator *=(const double Scalar) 
{
  Multiply(Scalar);
}

C_Vec3d Multiplied(const double Scalar) const;
C_Vec3d operator *(const double Scalar) const
{
  return Multiplied(Scalar);
}

void Reverse() ;
C_Vec3d Reversed() const;
C_Vec3d operator -() const
{
  return Reversed();
}

void Subtract(const C_Vec3d& Right) ;
void operator -=(const C_Vec3d& Right) 
{
  Subtract(Right);
}

C_Vec3d Subtracted(const C_Vec3d& Right) const;
C_Vec3d operator -(const C_Vec3d& Right) const
{
  return Subtracted(Right);
}

private: 

    double myX;
    double myY;
    double myZ;
    
};
