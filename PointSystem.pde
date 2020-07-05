
//create spirals
ArrayList<PointSystem> spirals = new ArrayList<PointSystem>();
//add a spiral when mouse is clicked

class PointSystem
{
   
    //points in Point System
    ArrayList<Point> points;
    
    
    //grid system imagined within box that is used to implement 
    //the AR force compute algorithm of points within proximal tiles
    Tile[][] gridTiles;
    int numGridRows, numGridColumns;
    float tileSideLen;
    
    //the top_Left_X and top_Left_Y in the parameters for Spiral() are the top left corner of the rectBox
    float top_left_X, top_left_Y, bottom_right_X, bottom_right_Y;//box region that user picks on image 
    float current_X, current_Y; //tracks the current position in spiral drawing, starts with center of box
        
    int distanceX, distanceY; // x and y _displacement between initial spiral arrangement of points

    PointSystem (float topLeft_X, float topLeft_Y, float bottomRight_X, float bottomRight_Y)
    {       
      //currentX and currentY are initially set to the x- and y- locations 
       //of the center of the spiral maze.
       println ("Bounding box: " + topLeft_X + " " + topLeft_Y  + " " +  bottomRight_X + " " + bottomRight_Y + baseimg.width + baseimg.height);
       
       //box region that user picks on image 
       top_left_X = topLeft_X;
       top_left_Y = topLeft_Y;
       bottom_right_X =  bottomRight_X;
       bottom_right_Y = bottomRight_Y;
       
       
       current_X = (topLeft_X + bottomRight_X)/2;
       current_Y = (topLeft_Y + bottomRight_Y)/2;
       

       //distanceXbetweenInitialSpiralArms = 100; // in initial spiral arrangement of points in Point system
       int max_num_spiral_half_twists = (int) sqrt (numParticles);
       distanceX = max (10, (int) ((bottomRight_X - topLeft_X)/max_num_spiral_half_twists));

       //proportions of width and height of spiral must match that of image
       //can't multiply n by (baseimg.height/baseimg.width)
       distanceY = (int) ((distanceX * (bottomRight_Y - topLeft_Y)) / (bottomRight_X - topLeft_X));


       points = new ArrayList<Point>();
       Point p = new Point(current_X, current_Y,  this);
       points.add(p);
       
       //place the points in an initial arrangement inside the box - we are doing spiral 
       createSpiral();
       
       intitalizeGridSystem();

       
    }
    
    //grid system that is used to implement the AR force ccompute algorithm 
    //if the radius of influenc[e is changed, recompute the grids for this point system
    
   //initalize a grid system withon box.
    void intitalizeGridSystem(){
      
       tileSideLen = D_attraction*2; //compute new tile side length
       numGridRows =  ceil((bottom_right_Y - top_left_Y)/tileSideLen);
       numGridColumns = ceil((bottom_right_X -  top_left_X)/tileSideLen);
 
       println(" Init grid [" + numGridRows + "," + numGridColumns + "]"); 
       
       gridTiles = new Tile[numGridRows][numGridColumns];
       for (int i = 0; i < numGridRows; i++){
         for (int j = 0; j < numGridColumns; j++){
           gridTiles[i][j] = new Tile();
         }
       }
       
       //map points into tiles
       for(Point p: points){
          InsertPointIntoTileItisOn(p);
       }

    }
    
    //map a given x,y to a tile in grid system
    void InsertPointIntoTileItisOn(Point p) {
        int i = (int) ((p.y - top_left_Y) / tileSideLen);
        int j = (int) ((p.x - top_left_X)/ tileSideLen);
        
        if ((i >=  numGridRows) || (j >= numGridColumns)) {
        println ("Temp error check in grid triggered" + i + " "  + j); //<>//
        println ("Base image dims:" + baseimg.width + "," + baseimg.height);
        }
        
        gridTiles[i][j].addPoint(p);
    }
    
    //Display spiral lines and points to image screen
    void display()
    {
        if (display_points){
          for(Point p: points)
          {
            ellipse(p.x, p.y, 3.0, 3.0);
          } 
        }
        
       if (display_lines) {
         beginShape();
         for(Point p: points)
         {
           vertex(p.x, p.y);
           
         }
         endShape();
       }
       
    }
    
   // compute the AR force  between 2 points based on distance
   // core of the AR function is here
   PVector computeAR_forceBetweenTwoPoints(Point p1, Point p2)
   {
    float force_mag = 0.0;
    
    float displacement_x = p2.x - p1.x;
    float displacement_y = p2.y - p1.y;
                       
    PVector displ = new PVector(displacement_x, displacement_y);
    float d = displ.mag();

    // only compute if d  is less than d_attraction
    if(d < D_attraction){
       // Compute attract or repel force
       if(d > D_repulsion){ //points attract if d > D_repulsion
             // breaking attraction into 2 parts, between d_replusion and somwhere between d_repulsion, d_attractiion
             float d_a = (D_repulsion + D_attraction)/2.0;
             
             if (d < d_a) {
              force_mag = 3.0*(D_repulsion -d); //attraction force
             }
             else {
              force_mag =  -1.0/(d*d) + 1.0/(d_a*d_a) + 3*(D_repulsion - d_a) ;
             }
       }
       else {  //points repel if d  < D_repulio        
             force_mag = 5.0*(D_repulsion -d);
       }
    }
    PVector force = displ.normalize().mult(force_mag);
    return (force); //convert force to vector
   
  }
   
   // given two tiles find the forces between points between them
   void computeAROnPointsBetweenTwoTiles(Tile tile, Tile neighbor_tile){
       PVector force;
       
       for(int i = 0; i < tile.pointList.size(); i++)
       {
           int k = (tile == neighbor_tile)? (i+1): 0; // if within same tile then special case of j index

           for(int j = k; j < neighbor_tile.pointList.size(); j++)
                   {
                       //get two points and interact with each other
                       Point p1 = tile.pointList.get(i);
                       Point p2 = neighbor_tile.pointList.get(j);
                       
                       //compute force between points
                       force = computeAR_forceBetweenTwoPoints(p1, p2);
                       
                       //add force to particles, since displacement is from p2 to p1 particles experience force in opposite directions
                       p1.netForce.add(force);
                       //print (p1.netForce.x + " AR " + p1.netForce.y);

                       p2.netForce.add(force.mult(-1));
                      
           }
       }
   }
   
   // while computign AR foces, lets consider a tile and its neighbors
   void computeARforces() {
 
       Tile tile, neighbor_tile;
       
       //Apply the AR type forces which are determined by other points
       // visit the tiles from top left to bottom right each row at a time
       // and consider self, and neigbors to the right, and three below it
       
       for (int tile_i = 0; tile_i < numGridRows; tile_i++){
         for (int tile_j = 0; tile_j < numGridColumns; tile_j++){
           
           tile = gridTiles[tile_i][tile_j];
           
           //compute AR forces between points within this tile
           computeAROnPointsBetweenTwoTiles(tile, tile);
           
           //determine AR forces with right tile, if it exists
           if(tile_j != (numGridColumns - 1))
           {
                neighbor_tile = gridTiles[tile_i][tile_j + 1];
                computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);

           }
           
           //determine AR forces with diagonal below right tile, if it exists
           if(tile_i != (numGridRows - 1) && tile_j != (numGridColumns - 1))
           {
                 neighbor_tile = gridTiles[tile_i + 1][tile_j + 1];
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           
           //determine AR forces with below tile, if it exists
           if(tile_i != (numGridRows - 1))
           {
                 neighbor_tile = gridTiles[tile_i + 1][tile_j];
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           
           //determine AR forces with diagonal below left tile, if it exists
           if(tile_i != (numGridRows - 1) && tile_j != 0)
           {
                 neighbor_tile = gridTiles[tile_i + 1][tile_j - 1];
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           
         }
       }
         
    }
     
    void computeNetForceandNewPositionofPoints()
    {
      // apply AR forces
      if (has_attractionrepulsion) computeARforces();
      
      //apply forces which do not depend on other points
      for(Point p: points){
          if(coeff_friction > 0.0) p.apply_friction();
          if(has_brownianmotion) p.apply_brownianmotion();
          //p.apply_constrain();
       }
       
       // cleat the points lists in tiles from last iteration and insert updated points
       for (int tile_i = 0; tile_i < numGridRows; tile_i++){
         for (int tile_j = 0; tile_j < numGridColumns; tile_j++){
            gridTiles[tile_i][tile_j].clearPointList();
         }
       }
       
       //compute new positions and map to tile
        for(Point p: points){
          p.apply_transformation();
          InsertPointIntoTileItisOn(p);
          // also reset the netforce on a point for next iteration
          p.netForce.set(0.0,0.0);
        }
        
      
    }
    
 
   //creates an initial spiral arrangment of points 
   void createSpiral()
   {
      int n = 1;
            
      while(true)
      {
          if (moveR(n) == false) break; //hit an edge of the bounding box - stop
          if (moveU(n) == false) break; //hit an edge of the bounding box - stop
          n++;
          if (moveL(n) == false) break; //hit an edge of the bounding box - stop
          if (moveD(n) == false) break; //hit an edge of the bounding box - stop
          n++;
      }
      println("Number of points created :" + points.size());
   }
   
    //helper methods to draw the initial spriral
    boolean moveL(int num)
     {
       for(int i = 0; i<num; i++){
         if((current_X - distanceX) > top_left_X)
         {
           current_X -= distanceX;
           Point p = new Point(current_X, current_Y, this);
           points.add(p);
           if (points.size() >= numParticles) return false;
         }
         else return false; // hit an edge of the bounding box
       }
       return true; // did not hit the edge of the bounding box yet
     }

     boolean moveR(int num)
     {
       for(int i = 0; i<num; i++) {
         if((current_X + distanceX) < bottom_right_X)
         {
           current_X += distanceX;
           Point p = new Point(current_X, current_Y, this);
           points.add(p);
           if (points.size() >= numParticles) return false;

         }
         else return false; // hit an edge of the bounding box
       }
       return true; // did not hit the edge of the bounding box yet
     }

     boolean moveU(int num)
     {
       for(int i = 0; i<num; i++){
         if((current_Y - distanceY) > top_left_Y)
         {
           current_Y -= distanceY;
           Point p = new Point(current_X, current_Y, this);
           points.add(p);
           if (points.size() >= numParticles) return false;
         }
         else return false; // hit an edge of the bounding box
       }
       return true; // did not hit the edge of the bounding box yet
     }

     boolean moveD(int num)
     {
       for(int i = 0; i<num; i++) {
         if((current_Y + distanceY) < bottom_right_Y)
         {
           current_Y += distanceY;
           Point p = new Point(current_X, current_Y, this);
           points.add(p);
           if (points.size() >= numParticles) return false;  
         }
         else return false; // hit an edge of the bounding box
       }
       return true; // did not hit the edge of the bounding box yet
     }

}
