// miner agent

{ include("$jacamoJar/templates/common-cartago.asl") }

/* 
 * Based on codes by: Joao Leite, Rafael Bordini, Jomi Hubner and Maicon Zatelli
 */

/* beliefs */
last_dir(null). // the last movement I did
free.

/* When free, agents wonder around. */
+free : gsize(_,W,H) 
   <-  .random(RX);
       .random(RY);
       !go_near(math.floor(RX*W),math.floor(RY*H));
       .print("I am going to go near (",RX*W,",", RY*H,")").
+free : true // gsize is unknown yet
   <- .wait(100); -+free.
   
/* Agent is near and still free, it goes to a random location again*/
+near(X,Y) : free <- -+free.

/* The following plans encode how an agent should go to near a location X,Y. 
 * Since the location might not be reachable, the plans succeed 
 * if the agent is near the location, given by the internal action jia.neighbour, 
 * or if the last action was skip, which happens when the destination is not 
 * reachable, given by the plan next_step as the result of the call to the 
 * internal action jia.get_direction.
 * These plans are only used when exploring the grid, since reaching the 
 * exact location is not really important.
 */

+!go_near(X,Y) : free
  <- -near(_,_); 
     -last_dir(_); 
     !near(X,Y).


// I am near to some location if I am near it 
+!near(X,Y) : pos(AgX,AgY) & jia.neighbour(AgX,AgY,X,Y) 
   <- .print("I am at ", "(",AgX,",", AgY,")", " which is near (",X,",", Y,")");
      +near(X,Y).
   
// I am near to some location if the last action was skip (there are no paths to there)
+!near(X,Y) : pos(AgX,AgY) & last_dir(skip) 
   <- .print("I am at ", "(",AgX,",", AgY,")", " and I can't get to' (",X,",", Y,")");
      +near(X,Y).

+!near(X,Y) : not near(X,Y)
   <- !next_step(X,Y);
      !near(X,Y).
+!near(X,Y) : true 
   <- !near(X,Y).


/* These are the plans to have the agent execute one step in the direction of X,Y.
 * They are used by the plans go_near above and pos below. It uses the internal 
 * action jia.get_direction which encodes a search algorithm. 
 */

+!next_step(X,Y) : pos(AgX,AgY) <- // I already know my position
   	  //.print("My position is AgX:",AgX," and AgY:",AgY," received(",X,",",Y,"Y)"," D:",D);
   	  jia.get_direction(AgX, AgY, X, Y, D);
   	  //.print("My position is AgX:",AgX," and AgY:",AgY," received(",X,",",Y,"Y)"," D:",D);
      -+last_dir(D);
      D.
+!next_step(X,Y) : not pos(_,_) // I still do not know my position
   <- !next_step(X,Y).
-!next_step(X,Y) : true  // failure handling -> start again!
   <- -+last_dir(null);
      !next_step(X,Y).

/* The following plans encode how an agent should go to an exact position X,Y. 
 * Unlike the plans to go near a position, this one assumes that the 
 * position is reachable. If the position is not reachable, it will loop forever.
 */

+!pos(X,Y) : pos(X,Y) 
   <- .print("I've reached ",X,"x",Y).
+!pos(X,Y) : not pos(X,Y)
   <- !next_step(X,Y);
      !pos(X,Y).

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
      !init_handle(gold(X,Y)).
     
// if I see gold and I'm not free but also not carrying gold yet
// (I'm probably going towards one), abort handle(gold) and pick up
// this one which is nearer
@pcell2[atomic]
+gold(X,Y)
  :  not carrying_gold & not free &
     .desire(handle(gold(OldX,OldY))) &   // I desire to handle another gold which
     pos(AgX,AgY) &
     jia.dist(X,   Y,   AgX,AgY,DNewG) &
     jia.dist(OldX,OldY,AgX,AgY,DOldG) &
     DNewG < DOldG                        // is farther than the one just perceived
  <- .drop_desire(handle(gold(OldX,OldY)));
     .print("Giving up current gold ",gold(OldX,OldY)," to handle ",gold(X,Y)," which I am seeing!");
     !init_handle(gold(X,Y)).
 
     
/* The next plans encode how to handle a piece of gold.
 * The first one drops the desire to be near some location, 
 * which could be true if the agent was just randomly moving around looking for gold.
 * The second one simply calls the goal to handle the gold.
 * The third plan is the one that actually results in dealing with the gold. 
 * It raises the goal to go to position X,Y, then the goal to pickup the gold, 
 * then to go to the position of the depot, and then to drop the gold and remove 
 * the belief that there is gold in the original position. 
 * Finally, it prints a message and raises a goal to choose another gold piece.
 * The remaining two plans handle failure.
 */     

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
     !!handle(Gold). // must use !! to perform "handle" as not atomic

+!handle(gold(X,Y)) 
  :  not free 
  <- .print("Handling ",gold(X,Y)," now.");
     !pos(X,Y);
     !ensure(pick,gold(X,Y));
     ?depot(_,DX,DY);
     !pos(DX,DY);
     !ensure(drop, 0);
     .print("Finish handling ",gold(X,Y));
  	 !!choose_gold.

// if ensure(pick/drop) failed, pursue another gold
-!handle(G) : G
  <- .print("failed to catch gold ",G);
     .abolish(G); // ignore source
     !!choose_gold.
-!handle(G) : true
  <- .print("failed to handle ",G,", it isn't in the BB anyway");
     !!choose_gold.

/* The next plans deal with picking up and dropping gold. */

+!ensure(pick,_) : pos(X,Y) & gold(X,Y)
  <- pick; 
     ?carrying_gold; 
     -gold(X,Y). 
// fail if no gold there or not carrying_gold after pick! 
// handle(G) will "catch" this failure.

+!ensure(drop, _) : carrying_gold & pos(X,Y) & depot(_,X,Y)
  <- drop.

/* The next plans encode how the agent can choose the next gold piece 
 * to pursue (the closest one to its current position) or, 
 * if there is no known gold location, makes the agent believe it is free.
 */
+!choose_gold 
  :  not gold(_,_)
  <- -+free.

// Finished one gold, but others left
// find the closest gold among the known options, 
+!choose_gold 
  :  gold(_,_)
  <- .findall(gold(X,Y),gold(X,Y),LG);
     !calc_gold_distance(LG,LD);
     .length(LD,LLD); LLD > 0;
     .print("Gold distances: ",LD,LLD);
     .min(LD,d(_,NewG));
     .print("Next gold is ",NewG);
     !!handle(NewG).
-!choose_gold <- -+free.

+!calc_gold_distance([],[]).
+!calc_gold_distance([gold(GX,GY)|R],[d(D,gold(GX,GY))|RD]) 
  :  pos(IX,IY)
  <- jia.dist(IX,IY,GX,GY,D);
     !calc_gold_distance(R,RD).
+!calc_gold_distance([_|R],RD) 
  <- !calc_gold_distance(R,RD).

/* end of a simulation */

+end_of_simulation(S,_) : true 
  <- .drop_all_desires; 
     .abolish(gold(_,_));
     .abolish(picked(_));
     -+free;
     .print("-- END ",S," --").