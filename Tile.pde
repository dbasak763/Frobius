

class Tile
{    
    ArrayList<Point> pointList; // tracks the points currentl;y in the tile, as points move, this needs to be computed every iteration 
    
    Tile()
    {
         pointList = new ArrayList<Point> ();
    }
    
    void addPoint(Point p)
    {
         pointList.add(p);
    }
    
    void removePoint(Point p)
    {
         pointList.remove(p); 
    }
    
    void clearPointList (){
      pointList.clear();
    }
 
}
