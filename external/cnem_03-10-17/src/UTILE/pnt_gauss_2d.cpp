#include "pnt_gauss_2d.h"

void Initialisation_Point_de_Gauss(vector<S_Point_de_Gauss>* Lists_SPoint_de_Gauss)
{
	
	//-----------------------------------------------------------------------//

	S_Point_de_Gauss S_Point_de_Gauss_Temp;
	double w[3][4];
	double w_Temp[3];

	//-----------------------------------------------------------------------//
	
	S_Point_de_Gauss_Temp.Poids=1.;
	S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
	Lists_SPoint_de_Gauss[0].push_back(S_Point_de_Gauss_Temp);
    
	//-----------------------------------------------------------------------//

	w[0][0]=1./3.;
	w[1][0]=1./6.;
	w[2][0]=w[1][0];

	w_Temp[0]=1-w[1][0]-w[2][0];
	w_Temp[1]=w[1][0];
	w_Temp[2]=w[2][0];

	S_Point_de_Gauss_Temp.Poids=w[0][0];

	long i;
	for(i=0;i<3;i++)
	{
		S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[i];
	    S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(i+1)%3];
    	S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(i+2)%3];
		Lists_SPoint_de_Gauss[1].push_back(S_Point_de_Gauss_Temp);
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
		Lists_SPoint_de_Gauss[2].push_back(S_Point_de_Gauss_Temp);
	}
	
	//-----------------------------------------------------------------------//
	
	S_Point_de_Gauss_Temp.Poids=-27./48.;
	S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
	Lists_SPoint_de_Gauss[3].push_back(S_Point_de_Gauss_Temp);
	
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
    	Lists_SPoint_de_Gauss[3].push_back(S_Point_de_Gauss_Temp);
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
		
		for(long j=0;j<3;j++)
		{
			S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
	        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
        	S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
    		Lists_SPoint_de_Gauss[4].push_back(S_Point_de_Gauss_Temp);
		}
	}

	//-----------------------------------------------------------------------//
	
	S_Point_de_Gauss_Temp.Poids=9./40.;
	S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
	Lists_SPoint_de_Gauss[5].push_back(S_Point_de_Gauss_Temp);
	
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
		
		for(long j=0;j<3;j++)
		{
			S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
	        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
        	S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
    		Lists_SPoint_de_Gauss[5].push_back(S_Point_de_Gauss_Temp);
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
		
		for(long j=0;j<3;j++)
		{
			S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
	        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
        	S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
    		Lists_SPoint_de_Gauss[6].push_back(S_Point_de_Gauss_Temp);
		}
	}
	
	//-----------------------------------------------------------------------//

	S_Point_de_Gauss_Temp.Poids=-0.1495700444677;
	S_Point_de_Gauss_Temp.Poids_Position[0]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[1]=1./3.;
	S_Point_de_Gauss_Temp.Poids_Position[2]=1./3.;
	Lists_SPoint_de_Gauss[7].push_back(S_Point_de_Gauss_Temp);
	
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
		
		for(long j=0;j<3;j++)
		{
			S_Point_de_Gauss_Temp.Poids_Position[0]=w_Temp[j];
	        S_Point_de_Gauss_Temp.Poids_Position[1]=w_Temp[(j+1)%3];
     		S_Point_de_Gauss_Temp.Poids_Position[2]=w_Temp[(j+2)%3];
    		Lists_SPoint_de_Gauss[7].push_back(S_Point_de_Gauss_Temp);
		}
	}
	
	//-----------------------------------------------------------------------//
}
