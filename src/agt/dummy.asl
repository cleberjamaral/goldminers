// Agent dummy

{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }

/* 
 * By Joao Leite
 * Based on implementation developed by Rafael Bordini, Jomi Hubner and Maicon Zatelli
 */


/* Initial beliefs and rules */

/* Initial goals */

!start.
!send(0).

/* Plans */


+!start <- 
	.print("Starting... ");
	.wait(1000); 
	//message("hello world.");
	.broadcast(tell,hi); 
	!start.

+!send(X)  <- 
	.wait(1500); 
	.send(miner1, tell, hello(X)); 
	!send(X+1).

+hi[source(A)] <-
	.print(A, " said hi!").

/*
+!start : true <- 
 	.wait(2000);
	.print("Hi everyone!");
	.broadcast(tell,hello);
	//joinWorkspace("mining",Id);
	//lookupArtifact("mining.m4view",AId);
	.print("Hi again!");
	.broadcast(tell,hello);
	focus(AId);
	!start.*/ 

