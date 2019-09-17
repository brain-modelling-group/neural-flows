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

#include "C_Vec2d.h"
 
C_Vec2d::C_Vec2d():myX(0.),myY(0.){}
C_Vec2d::C_Vec2d(const double Xv,const double Yv)
{
    myX=Xv;
    myY=Yv;
}

C_Vec2d::C_Vec2d(const C_Pnt2d& P1,const C_Pnt2d& P2)
{
    myX=P2.X()-P1.X();
    myY=P2.Y()-P1.Y();
}

C_Vec2d::C_Vec2d(double* P1,double* P2)
{
    myX=P2[0]-P1[0];
    myY=P2[1]-P1[1];
}

void C_Vec2d::SetCoord(const double Xv,const double Yv)
{
    myX=Xv;
    myY=Yv;
}

void C_Vec2d::SetX(const double X)
{
    myX=X;
}

void C_Vec2d::SetY(const double Y)
{
    myY=Y;
}

double C_Vec2d::X() const
{
    return myX;
}

double C_Vec2d::Y() const
{
    return myY;
}

double C_Vec2d::Angle(const C_Vec2d& Other) const
{
    double Cr=Crossed(Other);
    double Do=Dot(Other);
    double MM=Magnitude()*Other.Magnitude();
    double a=acos(Do/MM);
    if(Cr<0)
        a*=-1.;
    return a;
}

double C_Vec2d::Magnitude() const
{
    double M=sqrt(pow(myX,2)+pow(myY,2));
    return M;
}

double C_Vec2d::SquareMagnitude() const
{
    double M=pow(myX,2)+pow(myY,2);
    return M;
}

void C_Vec2d::Normalize()
{
    double M=Magnitude();
    myX/=M;
    myY/=M;
}

C_Vec2d C_Vec2d::Normalized() const
{
    double M=Magnitude();
    C_Vec2d V(myX/M,myY/M);
    return V;
}

void C_Vec2d::Add(const C_Vec2d& Other)
{
    myX+=Other.myX;
    myY+=Other.myY;
}

C_Vec2d C_Vec2d::Added(const C_Vec2d& Other) const
{
    C_Vec2d V(myX+Other.myX,myY+Other.myY);
    return V;
}

double C_Vec2d::Crossed(const C_Vec2d& Right) const
{
    double Cr=myX*Right.myY-myY*Right.myX;
    return Cr;
}

void C_Vec2d::Divide(const double Scalar)
{
    myX/=Scalar;
    myY/=Scalar;
}

C_Vec2d C_Vec2d::Divided(const double Scalar) const
{
    C_Vec2d V(myX/Scalar,myY/Scalar);
    return V;
}

double C_Vec2d::Dot(const C_Vec2d& Other) const
{
    double Do=myX*Other.myX+myY*Other.myY;
    return Do;
}

void C_Vec2d::Multiply(const double Scalar)
{
    myX*=Scalar;
    myY*=Scalar;
}

C_Vec2d C_Vec2d::Multiplied(const double Scalar) const
{
    C_Vec2d V(myX*Scalar,myY*Scalar);
    return V;
}

void C_Vec2d::Reverse()
{
    myX=-myX;
    myY=-myY;
}

C_Vec2d C_Vec2d::Reversed() const
{
    C_Vec2d V(-myX,-myY);
    return V;
}

void C_Vec2d::Subtract(const C_Vec2d& Right)
{
    myX-=Right.myX;
    myY-=Right.myY;
}

C_Vec2d C_Vec2d::Subtracted(const C_Vec2d& Right) const
{
    C_Vec2d V(myX-Right.myX,myY-Right.myY);
    return V;
}
