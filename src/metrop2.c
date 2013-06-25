/*Metropolis survival model fit in C */
#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <R.h>
#include <Rmath.h>

void dbbf(int *lin, int *k, int *nin,  double *ain, double *bin, double *x)
{
    int l = lin[0];
    int n = nin[0];
    double a = ain[0];
    double b = bin[0];

    int i;
    

   for (i = 0; i < l; i++) {
    x[i] = gamma(n+1)/(gamma(k[i]+1)*gamma((n-k[i])+1))*beta(k[i]+a,(n-k[i])+b)/beta(a,b);
	}

}

void metrop(int *nsim, double *jumpvar,double *k, double *n, int *l, double *shape1,
double *shape2, double *Save1, double *Save2, double *a,double *r){

/*Prepare inputs */
int NSIM = nsim[0], L=l[0];
double J = jumpvar[0];

/*Save results, shape1, shape2, their proposals and the acceptance rate */
double  S1=shape1[0], S2=shape2[0];
double  S1p, S2p, A=a[0];
/*The acceptance probability */
double  R=r[0];
/*used for summation */
double x,y;
/*Iteration counters*/
int i, j;



	/* start sampling */
	for(i=0; i<NSIM; i++) {

	/* propose new value for shape1 */
	S1p = fmax2(S1+rnorm(0,J),0.1);

	/* Acceptance prob on log scale */
	
	    R = dbbf();		
	

	if (log(runif(0,1))<R) { 
	   S1=S1p;	/*  Update shape1 if proposal is accepted */
	   A=A+1;		/*  Update acceptance rate */ 
				/*  So may want to tune */
	   }



	/* propose new value for shape2 */
	S2p = fmax2(S2+rnorm(0,J),0.1);
	
	/* Acceptance prob on log scale */
	R=0;

	 for (j = 0; j < L; j++) {
	    x = log(gamma(n[j]+1)/(gamma(k[j]+1)*gamma((n[j]-k[j])+1))*beta(k[j]+S1,(n[j]-k[j])+S2p)/beta(S1,S2p));
	    y = log(gamma(n[j]+1)/(gamma(k[j]+1)*gamma((n[j]-k[j])+1))*beta(k[j]+S1,(n[j]-k[j])+S2)/beta(S1,S2));
	    R +=(x-y);		
	}

	if (log(runif(0,1))<R) { 
	   S2=S2p;	/*  Update shape1 if proposal is accepted */
	   A=A+1;		/*  Update acceptance rate */ 
				/*  So may want to tune */
	   }

	  Save1[i]=S1;
	  Save2[i]=S2;

	}
	a[0]=A;
	r[0]=R;
}
	

