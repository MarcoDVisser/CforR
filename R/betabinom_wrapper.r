dyn.load("fc.so")

cfc=function(n,k){
	 
          out <- .C("fc",
	   nin=as.integer(n),
	   ansin=as.double(k))

           return(out$ansin)
}


