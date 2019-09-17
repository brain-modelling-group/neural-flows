///////////////////////////////////////////////////////////////////////////////
//                                                                           // 
// illoul_amran@yahoo.fr                                                     // 
//                                                                           // 
// ILLOUL Lounes, LMSP, ENSAM Paris.                                         //
///////////////////////////////////////////////////////////////////////////////

#pragma once

#include <map>
#include <math.h>
#include <iostream>
#include <fstream>

using namespace std;

struct comp_pos_mat
{
    bool operator()(const pair<size_t,size_t>& lhs, const pair<size_t,size_t>& rhs)const
    {
        if(lhs.first<rhs.first)return 1;
        else
        {
            if(lhs.first==rhs.first)
            {
                if(lhs.second<rhs.second)return 1;
                else return 0;
            }
            else return 0;
        }
    }
};

typedef map<pair<size_t,size_t>,double,comp_pos_mat> Map_KPL_D;

struct Mat_Map
{
    size_t m_Size;
    size_t n_Size;
    bool Row_Major;
    Map_KPL_D Mat;
};
