// miner agent

{ include("$jacamoJar/templates/common-cartago.asl") }

/* 
 * Based on implementation developed by Joao Leite
 */

/* beliefs */
last_dir(null). // the last movement I did
count(30).
free.

/* When free, agents wonder around. */
+free : gsize(_,W,H) <-  
	!start.
+free : true // gsize is unknown yet
   <- .wait(100); -+free.

+!start : gsize(_,W,H) <-
	.random(RX);
    .random(RY);
    .random(C);
    -+count(math.floor(C*30));
    .drop_desire(go_near(_,_));
    !go_near(math.floor(RX*W),math.floor(RY*H));
    .print("I am going to go near (",math.floor(RX*W),",", math.floor(RY*H),")").
       
/* Agent is near and still free, it goes to a random location again*/
+near(X,Y) : free <- -+free.

/* When the agent is free, clean position and go to X,Y */
+!go_near(X,Y) : free
  <- -near(_,_); 
     -last_dir(_); 
     !near(X,Y). 

/* Agent is near X,Y */
+!near(X,Y) : pos(AgX,AgY) & jia.neighbour(AgX,AgY,X,Y) 
   <- .print("I am at ", "(",AgX,",", AgY,")", " which is near (",X,",", Y,")");
      +near(X,Y).
+!near(X,Y) : pos(AgX,AgY) & last_dir(skip) // There are no paths to there 
   <- .print("I am at ", "(",AgX,",", AgY,")", " and I can't get to' (",X,",", Y,")");
      +near(X,Y).
+!near(X,Y) : not near(X,Y)
   <- !next_step(X,Y);
      !near(X,Y).
+!near(X,Y) : true 
   <- !near(X,Y).

/* Agent executes one step in the direction of X,Y */
+!next_step(X,Y) : pos(AgX,AgY) & (AgX < X) <- 
	-+last_dir(right); 
	right.
+!next_step(X,Y) : pos(AgX,AgY) & (AgX > X) <- 
	-+last_dir(left); 
	left.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY < Y) <-
	-+last_dir(down); 
	down.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY > Y) <-
	-+last_dir(up); 
	up.
+!next_step(X,Y) : pos(AgX,AgY) <-
	-+last_dir(down); 
	down.
+!next_step(X,Y) : not pos(_,_) // I still do not know my position
   <- !next_step(X,Y).
-!next_step(X,Y) : true <- // failure handling -> start again!
   -+free.//To restart

/* The following plans encode how an agent should go to an exact position X,Y. 
 * Unlike the plans to go near a position, this one assumes that the 
 * position is reachable. If the position is not reachable, it will loop forever.
 */

+!pos(X,Y) : not pos(X,Y) & count(N) & N > 1 <- 
	!next_step(X,Y);
   	!pos(X,Y);
   	-+count(N-1).
+!pos(X,Y) <- //The dumb miner continues to wonder around
	-+free.//To restart


/* Gold-searching Plans */

/* The following plan encodes how an agent should deal with a newly found piece 
 * of gold, when it is not carrying gold and it is free. 
 * The first step changes the belief so that the agent no longer believes it is free. 
 * Then it adds the belief that there is gold in position X,Y, and 
 * prints a message. Finally, it calls a plan to handle that piece of gold.
 */

// perceived golds are included as self beliefs (to not be removed once not seen anymore)
+cell(X,Y,gold) <- +gold(X,Y).

@pcell[atomic]           // atomic: so as not to handle another event until handle gold is initialised
+gold(X,Y) 
   :  not carrying_gold & free
   <- -free;
      .print("Gold perceived: ",gold(X,Y));
      -+gold(X,Y);
      !init_handle(gold(X,Y)).
     
/* Handle a piece of gold*/     

@pih1[atomic]
+!init_handle(Gold) 
  :  .desire(near(_,_)) 
  <- .print("Dropping near(_,_) desires and intentions to handle ",Gold);
     .drop_desire(near(_,_));
     !init_handle(Gold).
@pih2[atomic]
+!init_handle(Gold)
  :  pos(X,Y)
  <- .print("Going for ",Gold);
     !handle(Gold). // must use !! to perform "handle" as not atomic

+!handle(gold(X,Y)) : true <-
	.print("Handling ",gold(X,Y)," now.");
    //!pos(X,Y);
	//.print("Handling ",gold(X,Y)," now.2");
    !ensure(pick,gold(X,Y));
	.print("Handling ",gold(X,Y)," now.3");
    ?depot(_,DX,DY);
	.print("Handling ",gold(X,Y)," now.4");
    !pos(DX,DY);
	.print("Handling ",gold(X,Y)," now.5");
    !ensure(drop, 0);
    .print("Finish handling ",gold(X,Y)).
-!handle(G) : true <- // if ensure(pick/drop) failed, pursue another gold
	?gold(X,Y);
	.print("failed to handle ",G,", BB has: gold(",X,",",Y,") ");
	-+free.//To restart

/* The next plans deal with picking up and dropping gold. */

+!ensure(pick,_) : pos(X,Y) & gold(X,Y)
  <- pick; 
     ?carrying_gold; 
     -gold(X,Y). 

+!ensure(drop, _) : carrying_gold & pos(X,Y) & depot(_,X,Y)
  <- drop.

/* end of a simulation */
+end_of_simulation(S,_) : true 
  <- .drop_all_desires; 
     .abolish(gold(_,_));
     .abolish(picked(_));
     -+free;
     .print("-- END ",S," --").