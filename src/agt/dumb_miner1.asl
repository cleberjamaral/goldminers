/* Based on implementation developed by Joao Leite */
{ include("$jacamoJar/templates/common-cartago.asl") }

!start.

+!start <- //This change is related with a problem in RMI when artifacts are created by JCM
	joinRemoteWorkspace(mining,"debian",WId);
//	joinWorkspace(mining,WId);
	makeArtifact(m1view,"mining.MiningPlanet",[4,0],AId)[wid(WId)];
	focus(AId)[wid(WId)];
	.print("I am in ",WId," and focusing on ",AId);
	-+free.
/* When free, agents wander around. */
+free <- //I am free! 
	.abolish(cell(_,_,_));
	.abolish(gold(_,_));
	.drop_all_desires;
	.print("I am free!");
    !change_dir.
+free : true <- // gsize is unknown yet
	.wait(100); 
	-+free.
+!change_dir : gsize(_,W,H) <- //Randomize!
	.random(RX);
	.random(RY);
	!goto(math.floor(RX*W),math.floor(RY*H));
	.print("I am going to (",math.floor(RX*W),",", math.floor(RY*H),")").

/* Go to an exact position X,Y */
+!goto(X,Y) : not pos(X,Y) & carrying_gold & depot(_,DX,DY) <- //I've may be got stuck, so randomize and go again  
	!next_step(X,Y);
	!goto(DX,DY).
+!goto(X,Y) : not pos(X,Y) <- //I didn't reach the position 
	!next_step(X,Y);
	!goto(X,Y).
+!goto(X,Y) : free & pos(AgX,AgY) & gold(AgX,AgY) & depot(_,DX,DY) <- //I've found gold!
	-gold(_,_); 
	pick;
	.print("Picked, let's go to the depot!");
	-free;
	!goto(DX,DY).    
+!goto(X,Y) : not free & pos(AgX,AgY) & depot(_,AgX,AgY) <- //I've reached depot 
	drop;
	.print("Dropped, let's go for gold again!");
	-+free.
+!goto(X,Y) : gold(GX,GY) & free <- //Go for gold!
	.print("I know there is gold in ",GX,",",GY);
	!goto(GX,GY). 
+!goto(X,Y) <- //Nothing here...
	.print("There is nothing here. Just wander around...");
	!change_dir.

/* Agent executes one step in the direction to X,Y */
+!next_step(X,Y) : pos(AgX,AgY) & (AgX < X) <- //Go step by step 
	right;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgX > X) <- //Go step by step
	left;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY < Y) <- //Go step by step
	down;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
+!next_step(X,Y) : pos(AgX,AgY) & (AgY > Y) <- //Go step by step
	up;
	?pos(NX,NY);
	if ((NX == AgX) & (NY == AgY)) {-+stuck;}.
-!next_step(X,Y) : true <- // failure handling -> start again!
   !change_dir.
+stuck <- //I've got stuck!
	.print("Agent got stuck, try to change direction...");
	!change_dir.

/* Agent perceived gold */
+cell(X,Y,gold) : not gold(X,Y) & free <- //By the artifact, I've perceived gold! 
	.print("Gold perceived: ",gold(X,Y));
	+gold(X,Y).
+gold(X,Y) : free <- //I've found gold!!!
	.drop_desire(goto(_,_));
	!goto(X,Y).