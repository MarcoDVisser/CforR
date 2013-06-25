dyn.load("metrop.so")


c_metrop=function(nsim,jumpvar,k,n,shape1,shape2){
	  l=length(k)
	  Save1=rep(0,nsim)
	

           out <- .C("metrop",
		   	nsim=as.integer(nsim),
		   	jumpvar=as.double(jumpvar),	
			k=as.integer(k),
        	        n=as.integer(n),
			l=as.integer(l),
			shape1=as.double(shape1),
        	        shape2=as.double(shape2),
			Save1=as.double(Save1),
			Save2=as.double(Save1),
			a=as.double(0))
			 
                   

           return(out)
	   	
}

c_metrop(nsim=200,jumpvar=1,k=rpois(20,3),n=rep(100,20),shape1=2,shape2=2)


