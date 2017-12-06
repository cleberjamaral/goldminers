package mining;

import jason.environment.grid.GridWorldModel;
import jason.environment.grid.Location;

import java.util.HashSet;
import java.util.Set;
import java.util.logging.Logger;

import mining.MiningPlanet.Move;

public class WorldModel extends GridWorldModel {

    public static final int   GOLD  = 16;
    public static final int   DEPOT = 32;
    public static final int   ENEMY = 64;

    Location                  depot;
    Set<Integer>              agWithGold;  // which agent is carrying gold
    int                       goldsInDepot   = 0;
    int                       initialNbGolds = 0;

    private Logger            logger   = Logger.getLogger("jasonTeamSimLocal.mas2j." + WorldModel.class.getName());

    private String            id = "WorldModel";
    
    // singleton pattern
    protected static WorldModel model = null;
    
    synchronized public static WorldModel create(int w, int h, int nbAgs) {
        if (model == null) {
            model = new WorldModel(w, h, nbAgs);
        }
        return model;
    }
    
    public static WorldModel get() {
        return model;
    }
    
    public static void destroy() {
        model = null;
    }

    private WorldModel(int w, int h, int nbAgs) {
        super(w, h, nbAgs);
        agWithGold = new HashSet<Integer>();
    }

    public String getId() {
        return id;
    }
    public void setId(String id) {
        this.id = id;
    }
    public String toString() {
        return id;
    }
    
    public Location getDepot() {
        return depot;
    }

    public int getGoldsInDepot() {
        return goldsInDepot;
    }
    
    public boolean isAllGoldsCollected() {
        return goldsInDepot == initialNbGolds;
    }
    
    public void setInitialNbGolds(int i) {
        initialNbGolds = i;
    }
    
    public int getInitialNbGolds() {
        return initialNbGolds;
    }

    public boolean isCarryingGold(int ag) {
        return agWithGold.contains(ag);
    }

    public void setDepot(int x, int y) {
        depot = new Location(x, y);
        data[x][y] = DEPOT;
    }

    public void setAgCarryingGold(int ag) {
        agWithGold.add(ag);
    }
    public void setAgNotCarryingGold(int ag) {
        agWithGold.remove(ag);
    }

    /** Actions **/

    boolean move(Move dir, int ag) throws Exception {
        Location l = getAgPos(ag);
        switch (dir) {
        case UP:
            if (isFree(l.x, l.y - 1)) {
                setAgPos(ag, l.x, l.y - 1);
            }
            break;
        case DOWN:
            if (isFree(l.x, l.y + 1)) {
                setAgPos(ag, l.x, l.y + 1);
            }
            break;
        case RIGHT:
            if (isFree(l.x + 1, l.y)) {
                setAgPos(ag, l.x + 1, l.y);
            }
            break;
        case LEFT:
            if (isFree(l.x - 1, l.y)) {
                setAgPos(ag, l.x - 1, l.y);
            }
            break;
        }
        return true;
    }

    boolean pick(int ag) {
        Location l = getAgPos(ag);
        if (hasObject(WorldModel.GOLD, l.x, l.y)) {
            if (!isCarryingGold(ag)) {
                remove(WorldModel.GOLD, l.x, l.y);
                setAgCarryingGold(ag);
                return true;
            } else {
                logger.warning("Agent " + (ag + 1) + " is trying the pick gold, but it is already carrying gold!");
            }
        } else {
            logger.warning("Agent " + (ag + 1) + " is trying the pick gold, but there is no gold at " + l.x + "x" + l.y + "!");
        }
        return false;
    }

    boolean drop(int ag) {
        Location l = getAgPos(ag);
        if (isCarryingGold(ag)) {
            if (l.equals(getDepot())) {
                goldsInDepot++;
                logger.info("Agent " + (ag + 1) + " carried a gold to depot!");
            } else {
                add(WorldModel.GOLD, l.x, l.y);
            }
            setAgNotCarryingGold(ag);
            return true;
        }
        return false;
    }

    /** world with gold, no obstacle */
    static WorldModel world4() throws Exception {
        WorldModel model = WorldModel.create(35, 35, 4);
        model.setId("Scenario 4");
        model.setDepot(5, 27);
        model.setAgPos(0, 1, 0);
        model.setAgPos(1, 20, 0);
        model.setAgPos(2, 3, 20);
        //model.setAgPos(3, 10, 20);
        model.add(WorldModel.GOLD, 20, 13);
        model.add(WorldModel.GOLD, 15, 20);
        model.add(WorldModel.GOLD, 1, 1);
        model.add(WorldModel.GOLD, 3, 5);
        model.add(WorldModel.GOLD, 24, 24);
        model.add(WorldModel.GOLD, 20, 20);
        model.add(WorldModel.GOLD, 20, 21);
        model.add(WorldModel.GOLD, 20, 22);
        model.add(WorldModel.GOLD, 20, 23);
        model.add(WorldModel.GOLD, 20, 24);
        model.add(WorldModel.GOLD, 19, 20);
        model.add(WorldModel.GOLD, 19, 21);
        model.add(WorldModel.GOLD, 34, 34);
        model.setInitialNbGolds(model.countObjects(WorldModel.GOLD));
        return model;
    }

}
