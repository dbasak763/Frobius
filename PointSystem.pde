
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
    
    float begin_X, begin_Y, end_X, end_Y; //tracks the center of spiral and end point of spiral 
    float current_X, current_Y; //tracks the current position in spiral drawing, starts with center of box
        
    int distanceX, distanceY; // x and y _displacement between initial spiral arrangement of points

    PointSystem (float topLeft_X, float topLeft_Y, float bottomRight_X, float bottomRight_Y)
    {       
             
       //box region that user picks on image, the box includes the 4 points, we do not have to substract 1 from anything as in 0 + L -1 for something tha is L long
       //Therefore, width of box = bottomRight_X - topLeft_X + 1; height of box = bottomRight_Y - topLeft_Y + 1; 
       top_left_X = topLeft_X;
       top_left_Y = topLeft_Y;
       bottom_right_X =  bottomRight_X;
       bottom_right_Y = bottomRight_Y;
       
       points = new ArrayList<Point>();

       
       println ("Bounding box: " + top_left_X + " " + top_left_Y  + " " +  bottom_right_X + " " + bottom_right_Y + "Base image" + baseimg.width + "(W) " + baseimg.height + "(H)");

  
       //place the points in an initial arrangement inside the box - we are doing spiral 
       //createSpiral();
       createCircle();
       
       println("Before Initialize Grid System!");
       
       intitalizeGridSystem();

       
    }
    
    //grid system that is used to implement the AR force ccompute algorithm 
    //if the radius of influence is changed, recompute the grids for this point system
    
   //initalize a grid system withon box.
    void intitalizeGridSystem(){
      
       tileSideLen = R1 + kmax*D; //compute new tile side length, we use  attrcation radius + d_max
       println("tileSideLen: " + tileSideLen);
       numGridRows =  ceil((bottom_right_Y - top_left_Y + 1)/tileSideLen); //box width divided by tileside
       numGridColumns = ceil((bottom_right_X -  top_left_X + 1)/tileSideLen); //box height divided by tileside
 
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
    
    //map a given x,y to a tile in grid system //<>//
    void InsertPointIntoTileItisOn(Point p) {
        int i = (int) ((p.y - top_left_Y) / tileSideLen);
        int j = (int) ((p.x - top_left_X)/ tileSideLen);
        
        if ((i >=  numGridRows) || (j >= numGridColumns)) {
        println ("Temp error check in grid triggered" + i + " "  + j); //<>// //<>// //<>//
        println ("Base image dims:" + baseimg.width + "," + baseimg.height);
        }
        
        gridTiles[i][j].addPoint(p);
    }
    
    //Display spiral lines and points to image screen
    void display()
    {        
        if (display_points){
          fill(0);   // black points
          for(Point p: points)
          {
             ellipse(p.x, p.y, 2.0, 2.0);
          } 
        }
       

       if (display_lines) {
         noFill();
         stroke (0);
         beginShape();
         for(Point p: points)
         {
           vertex(p.x, p.y);
           
         }
         vertex(points.get(0).x, points.get(0).y);
         endShape();
       }
       
       if (stepmode) {
         noFill();
         stroke (255, 0, 0);  // Use 'redValue' in new fill;
         for(Point p: points)
         {
           line(p.x, p.y, p.next_x, p.next_y);
           
         }
       }
       
    }
    
   //computes the AR force between point and left line segment from p2
   PVector computeAR_forceOnFirstPointFromLineSegmentFromSecondPoint(Point p1, Point p2)
   {
    
    //find the left line segment neighbor of p2. From p2 index, subtract 1, to get index of left neighbor
    
    Point p2neighbor;
    PVector ARforce = new PVector(0.0, 0.0);
    float d; //d is distance from p1 to closestpoint on p2 -> p2neighbor line segment
        
    if(p2.myindexingloballist == 0) p2neighbor = points.get(points.size() - 1); //if points  form closed loop
    else p2neighbor = points.get(p2.myindexingloballist - 1);
    
    if (p1 == p2  || p1 == p2neighbor) {
      println("Error: computeAR_forceOnFirstPointFromLineSegmentFromSecondPoint - same point not expected");
      p1.printPointDetails();
      p2.printPointDetails();
      p2neighbor.printPointDetails();
      exit();
    }
    
    if (debug) println("p1: " + p1.x + ", " + p1.y + " p2: " + p2.x + ", " + p2.y + " p2neighbor: " + p2neighbor.x + ", " + p2neighbor.y);

    //find intersection point from p1 to line segment p2 -> p2neighbor
    Point closest_point = findClosestPointFromPointToLineSegment(p1, p2, p2neighbor);
    
    d = dist(p1.x, p1.y, closest_point.x, closest_point.y); //why is d = 0
    

    float delta_p1 = delta[(int)(p1.x - imgTopLeftCorner_X)][(int)p1.y];
    float delta_closest_point = delta[(int)(closest_point.x - imgTopLeftCorner_X)][(int)closest_point.y];
    
    // if |pi - xij| < min(delta(pi), delta(xij)) * R1 return fij
    if(!(d < (min(delta_p1, delta_closest_point) * R1)))
    {
          if (debug) println("computeAR_forceOnFirstPointFromLineSegmentFromSecondPoint:: delta: " + delta_p1 + " delta_closest_point: " + delta_closest_point + " R1:" + R1 + " d: " + d);

          return new PVector(0.0, 0.0);
    }
        
    //so normal vector direction is from closest point on line segment -> p1
    
    ARforce.set(p1.y - closest_point.y, p1.x - closest_point.x);  //is this 0 vector
    ARforce.normalize();
 
    //ARforce has magnitude lj_potential, + is repulsion, - is attraction
    if (debug) println("ARforce: " + ARforce + " delta: " + delta_p1 + " D: " + D + " d: " + d);
     
    ARforce.mult(lj_potential(d/(delta_p1))); //check why ARforce is 0 before
    return ARforce;
  }
  
  
  //line segment is p2 -> p2neighbor, find closest point from p1 to line segment, 
  //it is normal line intersection if point is next to line segment, otherwise, it will be boundary point
  
  //Tried to avoid  instability by avoiding division by unbounded values
  // Still seeing where intersection point (should be on extended line segment is sometimes coming out as not ????
  Point findClosestPointFromPointToLineSegment(Point p1, Point p2, Point p2neighbor)
  {
          
      float rise, run, d, x_intersect, y_intersect;
    
      
      rise = p2neighbor.y - p2.y;  //Determine rise and run of line segment 
      run = p2neighbor.x - p2.x;
      
      //compute distance squared between p2 and p2neighbor
      
      float rise_sq = rise * rise;
      float run_sq =  run*run;
      float rise_run = rise * run;
      float d_squared = rise_sq + run_sq ;
      d = sqrt(d_squared);
      float rise_run_by_dsquared = rise_run/d_squared;
      float run_sq_by_dsquared = run_sq/d_squared;
      float rise_sq_by_dsquared = rise_sq/d_squared;
      

      x_intersect = (rise_run_by_dsquared * (p1.y - p2.y) + run_sq_by_dsquared * p1.x + rise_sq_by_dsquared * p2.x) ;//this calculation avoids unbounded values in intermediate calculations
      y_intersect = (run_sq_by_dsquared * p2.y + rise_sq_by_dsquared * p1.y + rise_run_by_dsquared * (p1.x-p2.x));

      float d_from_p2 = dist(p2.x, p2.y, x_intersect, y_intersect); //d from p_intersect to p2
      float d_from_p2neighbor = dist(p2neighbor.x, p2neighbor.y, x_intersect, y_intersect);


      //confirm x_intersect, y_intersect are on line segment
      float chek1 = (x_intersect - p2neighbor.x)*(y_intersect - p2.y);
      float chek2 = (x_intersect - p2.x)*(y_intersect - p2neighbor.y);
      
      if (abs(chek1 - chek2) > 0.01) { // .01 seems to be ok, but do hit this check more if 0.001 or smaller is used
              if (debug1) print("p1: " + p1.x + ", " + p1.y + " p2: " + p2.x + ", " + p2.y + " p2neighbor: " + p2neighbor.x + ", " + p2neighbor.y + " rise" + rise + " run" + run + " x_intersect: " + x_intersect + " y_intersect: " + y_intersect + " d_from_p2:" + d_from_p2 + " d_from_p2neighbor: " + d_from_p2neighbor );
      }
      
      //d from p_intersect to p2neighbor
      if(d_from_p2 < d && d_from_p2neighbor < d)//point is within line segment
      {
           if (debug)println (" return intersect");
           return new Point(x_intersect, y_intersect, this);
      }
      else //points is not within line segment
      {
           if(d_from_p2 > d_from_p2neighbor) 
           {
               if (debug)println (" return p2neighbor");

               return p2neighbor; 
           }
           else{
             if (debug)println (" return p2");

             return p2;
           }
        
      }
      
  }
  
  
  //LJ-Potential Function, + is repulsion, - is attraction
  
  //    r           0.1   0.5   1   1.122     2.5        10
  // sigma_lj / r    10     2   1   0.891     0.4        0.1
  //    w          10^12  4032  0   -0.25   -0.004       0
  float lj_potential(float r)
  {
 
    if (debug) println("lj_potential: r: " + r);
    
    if(r < 0.5)  r = 0.5;  // bounding the largest replusion that lj potential

    float sigma_LJ = R0; //sigma_LJ is R0 from LJ formula
    
    //for small distance, ratio is large, returns +, repulsion
    //for large distance, ratio is small, returns -, attraction
    
    float ratio = sigma_LJ/r;
    if (debug) println("lj_potential(): ratio: " + ratio);

      
    float ratio_pow_6 = pow(ratio, 6);
    float ratio_pow_12 = ratio_pow_6*ratio_pow_6;
    
    return (ratio_pow_12 - ratio_pow_6);
  
  }


   
   // given two tiles find the forces between points in them, 
   // for a point, only consider the left line segment from another point as its right segment will get considered when you pick the neighbor tile where the right neighbor is
   void computeAROnPointsBetweenTwoTiles(Tile tile, Tile neighbor_tile){
       
       //println("Tile tile: " + tile);
       
       PVector force;

       for(int i = 0; i < tile.pointList.size(); i++)
       {

           Point p1 = tile.pointList.get(i);

           for(int j = 0; j < neighbor_tile.pointList.size(); j++)
           {

                       if((tile == neighbor_tile) && (i == j)) continue;   //same point on same tile, ignore
                              
                        //get p2 and compute the interaction with p1 and the left line segment from p2
                       Point p2 = neighbor_tile.pointList.get(j);
                                            
                       //.........(i - 1), i, (i+1), .....(points within i - n_min and i + n_min are not used for force computations)

                       
                      int index_p1 = p1.myindexingloballist;
                      int  index_p2 = p2.myindexingloballist;
                      boolean skip_flag = false;
                      float wrapped_index;
                       
                       //to handle for wrap around cases we use mods and have a flag which keeps track of whether a point can be used as line segment
                       
                       for(int k = index_p1 - n_min; k < index_p1; k++) //from point p1's index, get the indices to its left that we do not want to consider
                       {
                           wrapped_index = (k + points.size())% points.size(); // handle wrap around case
                           if (index_p2 == wrapped_index) skip_flag = true;
                       }
                       
                       if (!skip_flag) { // if decision to skip p2 is not already made, check the indices to its right that we do not want to consider
                         for(int k = index_p1 + n_min; k > index_p1; k--)
                         {
                             wrapped_index = k % points.size();
                             if (index_p2 == wrapped_index) skip_flag = true;
                         }
                       }
                       
                       if (skip_flag) continue;
                                     
                        //if not neigboring line segments within n_min, compute force between point and line segments
                       force = computeAR_forceOnFirstPointFromLineSegmentFromSecondPoint(p1, p2);
                       if(Float.isNaN(force.x) || Float.isNaN(force.y)) {
                         println("force in computeARForces is NaN");
                         exit();
                       }
                       
                       p1.netForce.add(force);  //accumulate AR force for point, we can use netforce to accumulate since we are doing AR force computation first                     
           }
       }
   }
   
   
   
   
   // while computing AR foces, lets consider a tile and its neighbors
   void computeARforces() {
 
       Tile tile, neighbor_tile;

       //Apply the AR type forces which are determined by other points
       // visit the tiles from top left to bottom right each row at a time
       // and consider self, and neigbors to the right, and three below it

       for (int tile_i = 0; tile_i < numGridRows; tile_i++){
         for (int tile_j = 0; tile_j < numGridColumns; tile_j++){
           
           tile = gridTiles[tile_i][tile_j];
           
           //compute AR forces between points within this tile
           //computeAROnPointsBetweenTwoTiles(tile, tile);
           
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
           //left tile
           if(tile_j != 0)
           {
                 neighbor_tile = gridTiles[tile_i][tile_j - 1]; 
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);

           }
           //topleft tile
           if(tile_i != 0 && tile_j != 0)
           {
                 neighbor_tile = gridTiles[tile_i - 1][tile_j - 1]; 
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           //top tile
           if(tile_i != 0)
           {
                 neighbor_tile = gridTiles[tile_i - 1][tile_j]; 
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           
           //topright tile
           if(tile_i != 0 && tile_j != (numGridColumns - 1))
           {
                 neighbor_tile = gridTiles[tile_i - 1][tile_j + 1]; 
                 computeAROnPointsBetweenTwoTiles(tile, neighbor_tile);
           }
           
         }
       }
         
    }
    //at sample point pi, for line segment pi -> pi+1
    //dmax = kmax * D * (delta(pi) + delta(pi+1)) / 2
    //dmin = kmin * D * (delta(pi) + delta(pi+1)) / 2
    //go through line segments pi->pi+1 and add/del points for maintaining an optimal distribution of points
    //
    void resample()
    {
        
        Point p, p_left, p_right;
        //since line segments form closed loop, boundary points are considered
        for(int i = 0; i < points.size(); i++)
        {
            //check boundary cases when getting neighbors
            if(i == 0) {
                p_left = points.get(points.size() - 1);
            } 
            else 
            {
                p_left = points.get(i - 1);
            }
            if(i == points.size() - 1) {
                p_right = points.get(0);
            } 
            else 
            {
                p_right = points.get(i + 1);
            }
            
            p = points.get(i);
            
            //if dist(p, p_right) > dmax, insert intermediate point
            float delta_p_i = delta[(int)(p.x - imgTopLeftCorner_X)][(int)p.y];
            float delta_p_right = delta[(int)(p_right.x - imgTopLeftCorner_X)][(int)p_right.y];
            float delta_p_left = delta[(int)(p_left.x - imgTopLeftCorner_X)][(int)p_left.y];
            
            float d_max = kmax * D * (delta_p_i + delta_p_right) / 2;
            float d_min_left = kmin * D * (delta_p_i + delta_p_left) / 2;
            float d_min_right = kmax * D * (delta_p_i + delta_p_right) / 2;
            
            float dist_to_left_point = dist(p_left.x, p_left.y, p.x, p.y);
            float dist_to_right_point = dist(p.x, p.y, p_right.x, p_right.y);
            
            if( dist_to_right_point > d_max){                      
                 
                 Point p_interim = new Point ((p.x + p_right.x)/2, (p.y + p_right.y)/2, this) ;
                 points.add(i + 1, p_interim);
            }
            

            
            //if( dist(p_left, p) < dmin && dist(p, p_right) < dmin), remove intermediate point
            if((dist_to_left_point < d_min_left)     &&    (dist_to_right_point < d_min_right)){  
                points.remove(i);     
                i -= 1; // to ensure that we dont skip the point i+1 in the loop that has now become i 
            }
        }
      
    }
    
    void fairing()
    {
         int p_index, p_index_left, p_index_right;
         Point p, p_left, p_right;
         
         float delta_p, delta_p_left, delta_p_right, denom, weighted_average_x, weighted_average_y;
         
         PVector fairing_vec = new PVector(0, 0);
         
         for(int i = 0; i < points.size(); i++)
         {
             p = points.get(i);
             p_left = points.get(((points.size() + i - 1) % points.size()));
             p_right = points.get((i + 1) % points.size());
             
             delta_p_left = delta[(int)(p_left.x - imgTopLeftCorner_X)][(int)(p_left.y)];
             delta_p_right = delta[(int)(p_right.x - imgTopLeftCorner_X)][(int)(p_right.y)];
             
             
             denom = delta_p_left + delta_p_right; 
             
             weighted_average_x = (p_left.x * delta_p_right + p_right.x * delta_p_left) / denom;
             weighted_average_y = (p_left.y * delta_p_right + p_right.y * delta_p_left) / denom;
                          
             fairing_vec.set(weighted_average_x - p.x, weighted_average_y - p.y);
             fairing_vec.mult(f_f[(int)(p.x - imgTopLeftCorner_X)][(int)(p.y)]);
             
             p.netForce.add(fairing_vec);  
             
         }
      
    }
    
    
    float dist(float x1, float y1, float x2, float y2)
    {
       float x_diff = x2 - x1;
       float y_diff = y2 - y1;
        return sqrt(x_diff * x_diff + y_diff * y_diff); 
    }
    
    //iterate through points and modify attraction force A_i
    void updateARforces_w_anisotropy()
    {
         for(Point p : points)
         {
           
             if (p.netForce.mag() == 0.0) continue;
            
             //get x and y location on image for point p
            int x = (int) (p.x - imgTopLeftCorner_X);    int y = (int) p.y;
             p.netForce.mult(f_a[x][y]);  // this is the only point when we are sure that all the AR forces on a point have been computed and accumulated, so apply f_a scaling

             PVector temp = p.netForce.copy(); //later for printing the old value if later netforce turns out NaN

             if(Float.isNaN(p.netForce.x) || Float.isNaN(p.netForce.y))
             {
                   println("updateARforces_w_anisotropy(): p.netForce before anisotropy " + p.netForce);
             }
             
             PVector gradient = gradient_vector(p);
             
             if (gradient.mag() == 0.0) continue;
             
             
             float dot = gradient.dot(p.netForce);
             gradient.normalize();
             gradient.mult(dot);
             
             p.netForce.add(gradient);


             if(Float.isNaN(gradient.x) || Float.isNaN(gradient.y))
             {
               println("updateARforces_w_anisotropy(): vec is NaN"); 
               exit();
               
             }                          
             
             
             if(Float.isNaN(p.netForce.x) || Float.isNaN(p.netForce.y))
             { 
                     println("updateARforces_w_anisotropy(): p.netForce After anisotropy " + p.netForce + " befor anisotropy " + temp + " gradient " + gradient );
             }
             //else if (debug) println("updateARforces_w_anisotropy(): p.netForce After anisotropy: " + p.netForce);
         }
    }
    

    //given a point on baseimg, find gradient_vector
    PVector gradient_vector(Point p)
    {
        //get x and y location for point p
        int x = (int) (p.x - imgTopLeftCorner_X);    int y = (int) p.y;
        
        //use top and right pixels of pixel under point p to compute partial derivatives, (x, y-1) and (x + 1, y)
        
        //using adjacent pixel derivatives to compute gradient vector: top pixel is 0, right pixel is 2
        
        float partial_deriv_x = adjPixelsDerivatives[x][y][0];   //top pixel
        float partial_deriv_y = adjPixelsDerivatives[x][y][2];   //right pixel

        return new PVector(partial_deriv_x, partial_deriv_y);
      
    }
     
    void computeNetForceandNewPositionofPoints()
    {
      // apply AR forces
      //println("Compute Net Forces and New Positions Of Points");
      if (has_attractionrepulsion) 
      {
           computeARforces();     
           updateARforces_w_anisotropy();
      }
      
      //apply forces which do not depend on other points
      for(Point p: points){
          //doing anisotropy based of image                        
           if (has_attractionrepulsion){} //p.AdjustandAddARForce();   //adjust the AR force based on gradient of image pixel at point location p1 and  accumulate force in point p1

          //if(coeff_friction > 0.0) p.apply_friction(); //since p.velocity is set to 0 before iteration, friction will compute to 0
          if(has_brownianmotion) 
          {
              p.apply_brownianmotion();
          }
          
       }
       
       
       //compute new positions of points
        for(Point p: points){
          
          p.apply_transformation();
          
        }
        
      
    }
    //reset things to get ready for next iteration
    void getReadyForNextIteration()
    {
         // cleat the points lists in tiles from last iteration and insert updated points
         for (int tile_i = 0; tile_i < numGridRows; tile_i++){
             for (int tile_j = 0; tile_j < numGridColumns; tile_j++){
                gridTiles[tile_i][tile_j].clearPointList();
             }
         }
        //coumpute fairing forces 
        if (has_fairing) fairing();
        
        
        //before next iteration, resample points 
        resample(); 
         
        for(int i = 0; i < points.size(); i++){
          
          Point p = points.get(i);
          
          //set the next position of point
          p.x = p.next_x;  
          p.y = p.next_y;
          
          //map next location of point to tiles
          InsertPointIntoTileItisOn(p);
          // also reset the netforce and velocity on a point for next iteration

          p.netForce.set(0.0,0.0);
          p.velocity.set(0.0,0.0);
          
          //recompute point's index in global list at start of every iteration to efficiently get the index of point
   
          p.myindexingloballist = i;
          //p.printPointDetails();
        }
           
      
    }
    
   //creates a circle inscribed in pointsystem bounding box with radius r = min(pointsystem.width, pointsystem.height) / 2
   //get  estimate of points, num_points = 2 * pi * r / D;
   //float theta = 0.0
   //float magnitude = ;
   //PVector vec = new PVector(magnitude, 0);
   //for num_points
   //vec.rotate(2 * pi / num_points);
   //vec.rotate(D / r);
   
   void createCircle()
   {
        float theta = 0.0;
        //circle is inscribed in pointsystem bounding box with center at (boxwidth / 2, boxheight / 2)
        float radius = min(bottom_right_X - top_left_X, bottom_right_Y - top_left_Y) / 4;
        //at start, vec points in x_direction
        PVector vec = new PVector(radius, 0);
        
        int estim_num_of_points = (int) (2 * PI * radius / D);
        
        
        
        for(int i = 0; i < estim_num_of_points; i++)
        {
            vec.rotate(2 * PI / estim_num_of_points);
            float p_x, p_y;
            p_x = vec.x + (top_left_X + bottom_right_X) / 2;
            p_y = vec.y + (top_left_Y + bottom_right_Y) / 2;
            points.add(new Point(p_x, p_y, this));
        }
        
     
   }
   
   
 
   //creates an initial spiral arrangment of points 
   void createSpiral()
   {
       // for an initial spiral arrangement of points in Point system
       int max_num_spiral_half_twists = (int) sqrt (numParticles);
       distanceX = max (10, (int) ((bottom_right_X - top_left_X + 1)/max_num_spiral_half_twists));

       //proportions of width and height of spiral must match that of image
       //can't multiply n by (baseimg.height/baseimg.width)
       distanceY = (int) ((distanceX * (bottom_right_Y - top_left_Y + 1)) / (bottom_right_X - top_left_X + 1));
       
       current_X = (top_left_X + bottom_right_X)/2; //currentX and currentY are set to the x and y locations 
       current_Y = (top_left_Y + bottom_right_Y)/2; //of the center of the initial spiral maze.
       
       Point p = new Point(current_X, current_Y,  this);
       points.add(p);
     
      int n = 1;
      //begin_X = current_X;   begin_Y = current_Y;     
      //proceed in a right, up, left, down manner, [R, U, L, D]
      while(true)
      {
          if (moveR(n) == false) break; //hit an edge of the bounding box - stop
          if (moveU(n) == false) break; //hit an edge of the bounding box - stop
          n++;
          if (moveL(n) == false) break; //hit an edge of the bounding box - stop
          if (moveD(n) == false) break; //hit an edge of the bounding box - stop
          n++;
      }
      
      //end_X = current_X;   end_Y = current_Y;
      println("Number of points created :" + points.size());
      
   }
   
//disp
   
    //helper methods to draw the initial spriral
    boolean moveL(int num)
     {
       for(int i = 0; i<num; i++){
         if((current_X - distanceX) >= top_left_X)
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
         if((current_X + distanceX) <= bottom_right_X)
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
         if((current_Y - distanceY) >= top_left_Y)
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
         if((current_Y + distanceY) <= bottom_right_Y)
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
