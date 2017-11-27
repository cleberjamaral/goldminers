/* Based on implementation developed by Joao Leite */
{ include("$jacamoJar/templates/common-cartago.asl") }

/* beliefs */
free.

/* When free, agents wander around. */
+free <-  
	.abolish(cell(_,_,_));
	.abolish(gold(_,_));
	.drop_all_desires;
	.print("I am free!");
    !change_dir.
+free : true <- // gsize is unknown yet
	.wait(100); 
	-+free.
+!change_dir : gsize(_,W,H) <-
	.random(RX);
    .random(RY);
    !goto(math.floor(RX*W),math.floor(RY*H));
    .print("I am going to (",math.floor(RX*W),",", math.floor(RY*H),")").

/* Go to an exact position X,Y */
+!goto(X,Y) : not pos(X,Y) & carrying_gold <- //I've may be got stuck, so randomize and go again  
	!next_step(X,Y);
	?depot(_,DX,DY);
	!goto(DX,DY).
+!goto(X,Y) : not pos(X,Y) <- //I didn't reach the position 
	!next_step(X,Y);
	!goto(X,Y).
+!goto(X,Y) : free & pos(AgX,AgY) & gold(AgX,AgY) <-
	-gold(_,_); 
	pick;
	.print("Picked, let's go to the depot!");
	-free;
	?depot(_,DX,DY);
	!goto(DX,DY).    
+!goto(X,Y) : not free & pos(AgX,AgY) & depot(_,AgX,AgY) <- 
	drop;
	.print("Dropped, let's go for gold again!");
	-+free.
+!goto(X,Y) : gold(GX,GY) & free <- 
	.print("I know there is gold in ",GX,",",GY);
	!goto(GX,GY). 
+!goto(X,Y) <-
	.print("There is nothing here. Just wander around...");
	!change_dir.

/* Agent executes one step in the direction to X,Y */
+!next_step(X,Y) : pos(AgX,AgY) & (AgX < X) <- 
	right;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgX > X) <- 
	left;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY < Y) <-
	down;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY > Y) <-
	up;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
-!next_step(X,Y) : true <- // failure handling -> start again!
   !change_dir.
+stuck <-
	.print("Agent got stuck, try to change direction...");
	!change_dir.

/* Agent perceived gold */
+cell(X,Y,gold) : not gold(X,Y) & free <-
	.print("Gold perceived: ",gold(X,Y));
	+gold(X,Y).
+gold(X,Y) : free <- // atomic: so as not to handle another event until handle gold is initialised
	.drop_desire(goto(_,_));
    !goto(X,Y).

/* end of a simulation */
+end_of_simulation(S,_) : true 
  <- .drop_all_desires; 
     .abolish(gold(_,_));
     -+free;
     .print("-- END ",S," --").