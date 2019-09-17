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

#include "C_Vec3d.h"

C_Vec3d::C_Vec3d():myX(0.),myY(0.),myZ(0.){}
C_Vec3d::C_Vec3d(const double Xv,const double Yv,const double Zv)
{
    myX=Xv;
    myY=Yv;
    myZ=Zv;
}

C_Vec3d::C_Vec3d(const C_Pnt3d& P1,const C_Pnt3d& P2)
{
    myX=P2.X()-P1.X();
    myY=P2.Y()-P1.Y();
    myZ=P2.Z()-P1.Z();
}

C_Vec3d::C_Vec3d(const double* P1,const double* P2)
{
    myX=P2[0]-P1[0];
    myY=P2[1]-P1[1];
    myZ=P2[2]-P1[2];
}

void C_Vec3d::SetCoord(const double Xv,const double Yv,const double Zv)
{
    myX=Xv;
    myY=Yv;
    myZ=Zv;
}

void C_Vec3d::SetX(const double X)
{
    myX=X;
}

void C_Vec3d::SetY(const double Y)
{
    myY=Y;
}

void C_Vec3d::SetZ(const double Z)
{
    myZ=Z;
}

double C_Vec3d::X() const
{
    return myX;
}

double C_Vec3d::Y() const
{
    return myY;
}

double C_Vec3d::Z() const
{
    return myZ;
}

double C_Vec3d::Magnitude() const
{
    double M=sqrt(pow(myX,2)+pow(myY,2)+pow(myZ,2));
    return M;
}

double C_Vec3d::SquareMagnitude() const
{
    double M=pow(myX,2)+pow(myY,2)+pow(myZ,2);
    return M;
}

void C_Vec3d::Normalize()
{
    double M=Magnitude();
    if(M!=0.)
    {
        myX/=M;
        myY/=M;
        myZ/=M;
    }
}

C_Vec3d C_Vec3d::Normalized() const
{
    C_Vec3d V=*this;

    V.Normalize();

    return V;
}

void C_Vec3d::Add(const C_Vec3d& Other)
{
    myX+=Other.myX;
    myY+=Other.myY;
    myZ+=Other.myZ;
}

C_Vec3d C_Vec3d::Added(const C_Vec3d& Other) const
{
    C_Vec3d V(myX+Other.myX,myY+Other.myY,myZ+Other.myZ);
    return V;
}

C_Vec3d C_Vec3d::Crossed(const C_Vec3d& Right) const
{
    C_Vec3d Cr(myY*Right.myZ-myZ*Right.myY,
              -myX*Right.myZ+myZ*Right.myX,
               myX*Right.myY-myY*Right.myX);

    return Cr;
}

void C_Vec3d::Divide(const double Scalar)
{
    myX/=Scalar;
    myY/=Scalar;
    myZ/=Scalar;
}

C_Vec3d C_Vec3d::Divided(const double Scalar) const
{
    C_Vec3d V(myX/Scalar,myY/Scalar,myZ/Scalar);
    return V;
}

double C_Vec3d::Dot(const C_Vec3d& Other) const
{
    double Do=myX*Other.myX+myY*Other.myY+myZ*Other.myZ;
    return Do;
}

void C_Vec3d::Multiply(const double Scalar)
{
    myX*=Scalar;
    myY*=Scalar;
    myZ*=Scalar;
}

C_Vec3d C_Vec3d::Multiplied(const double Scalar) const
{
    C_Vec3d V(myX*Scalar,myY*Scalar,myZ*Scalar);
    return V;
}

void C_Vec3d::Reverse()
{
    myX=-myX;
    myY=-myY;
    myZ=-myZ;
}

C_Vec3d C_Vec3d::Reversed() const
{
    C_Vec3d V(-myX,-myY,-myZ);
    return V;
}

void C_Vec3d::Subtract(const C_Vec3d& Right)
{
    myX-=Right.myX;
    myY-=Right.myY;
    myZ-=Right.myZ;
}

C_Vec3d C_Vec3d::Subtracted(const C_Vec3d& Right) const
{
    C_Vec3d V(myX-Right.myX,myY-Right.myY,myZ-Right.myZ);
    return V;
}
