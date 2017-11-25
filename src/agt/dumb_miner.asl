// miner agent

{ include("$jacamoJar/templates/common-cartago.asl") }

/* 
 * Based on implementation developed by Joao Leite
 */

/* beliefs */
free.

/* When free, agents wonder around. */

+free : gsize(_,W,H) <-  
	.random(RX);
    .random(RY);
	.abolish(cell(_,_,_));
	.abolish(gold(_,_));
	.drop_all_desires;
    !goto(math.floor(RX*W),math.floor(RY*H));
    .print("I am going to go near (",math.floor(RX*W),",", math.floor(RY*H),")").
+free : true <- // gsize is unknown yet
	.wait(100); 
	-+free.

/* Go to an exact position X,Y */

+!goto(X,Y) : not pos(X,Y) <- //I didn't reach the position 
	!next_step(X,Y);
   	!goto(X,Y).
+!goto(X,Y) : free & pos(AgX,AgY) & gold(GX,GY) & GX == AgX & GY == AgY <-
	-gold(_,_); 
	pick;
	.print("Picked, let's go to the depot!");
	-free;
	?depot(_,DX,DY);
	!goto(DX,DY).    
+!goto(X,Y) : not free & pos(AgX,AgY) & depot(_,DX,DY) & DX == AgX & DY == AgY <- 
	drop;
	.print("Dropped, let's go for gold again!");
	-+free.
+!goto(X,Y) : gold(GX,GY) & free <- 
	.print("I know there is gold in ",GX,",",GY);
	!goto(GX,GY). 
+!goto(X,Y) : not free & depot(_,DX,DY) <-
	.print("I am carrying gold to ",DX,",",DY);
	!pos(DX,DY). 
+!goto(X,Y) : pos(X,Y) & gsize(_,W,H)<-//I've reached a dumb position
	.print("Let's go to somewhere else...");
	.random(RX);
    .random(RY);
    !goto(math.floor(RX*W),math.floor(RY*H)). 
+!goto(X,Y) <- //The dumb miner continues to wonder around
	.print("Reseting...");
	-+free.//To restart

/* Agent executes one step in the direction of X,Y */
+!next_step(X,Y) : pos(AgX,AgY) & (AgX < X) <- 
	right.
+!next_step(X,Y) : pos(AgX,AgY) & (AgX > X) <- 
	left.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY < Y) <-
	down.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY > Y) <-
	up.
+!next_step(X,Y) : pos(AgX,AgY) <-
	down.
-!next_step(X,Y) : true <- // failure handling -> start again!
   -+free.//To restart

// Perceived gold
+cell(X,Y,gold) <-
	.print("Gold perceived: ",gold(X,Y));
	-+gold(X,Y).

+gold(X,Y) : free <- // atomic: so as not to handle another event until handle gold is initialised
	.drop_desire(goto(_,_));
    !goto(X,Y).

/* end of a simulation */
+end_of_simulation(S,_) : true 
  <- .drop_all_desires; 
     .abolish(gold(_,_));
     .abolish(picked(_));
     -+free;
     .print("-- END ",S," --").