
class Point 
{
   float x, y;
   float next_x, next_y; // temporarily stores  the next (x,y) where point will move to based on net force, used to help step through each iteration
   float constrained_next_x, constrained_next_y; // temporarily stores the next (x,y) where point is contrained to move to based on not crossing line segments
   PVector netForce;
   PVector BRForce;
   PVector ARForce;
   PVector FairingForce;
   PVector velocity;
   int myindexingloballist; //point's index in global list, temporary variable that is recomputed at start of every iteration to efficiently get the index of point, 
   boolean just_added;
   
   PointSystem parentps; //tracks the parent point system to which this point belongs to get the bounding box within which point should be constrained
   
   Point(float px, float py, PointSystem parent)
   {
      x = next_x = constrained_next_x = px;
      y = next_y = constrained_next_y = py;
      
      just_added = true;
      
      //mass = 1.0;

      parentps = parent;
      
      netForce = new PVector(0.0, 0.0);
      velocity = new PVector(0.0, 0.0);
      BRForce = new PVector(0.0, 0.0);
      ARForce = new PVector(0.0, 0.0);
      FairingForce = new PVector(0.0, 0.0);
      
   }
   
  /* Commented since we are resetting velocity between iterations, so this function is useless
   void apply_friction()
   {
      PVector force = PVector.mult(velocity, -coeff_friction);
      netForce.add(force);
   }
   
   */
   
   void apply_brownianmotion()
   {
           
      int x_index = (int)(this.x - imgTopLeftCorner_X);
      int y_index = (int)this.y;
      
      //random offset vector has magnitude and direction, where magnitude and direction have mean 0, variance sigma
      BRForce.set(randomGaussian(), randomGaussian());
      
      BRForce.mult(f_b[x_index][y_index] * delta[x_index][y_index] * D);
   }
   
   void apply_transformation()
   {      
      if(Float.isNaN(this.x) || Float.isNaN(this.y))
      {
          println();
          println("apply_transformation: current postion of point is NaN, exiting" );
          printPointDetails();
          exit();
      }
      
      netForce.add(BRForce);
      netForce.add(ARForce);
      netForce.add(FairingForce);

      if(Float.isNaN(netForce.x) || Float.isNaN(netForce.y)) {
         println("netForce is NaN");
         exit();
      }
      

      if (debug1){
        if (netForce.mag() > 20 || ARForce.mag() > 10 || BRForce.mag() > 10 || FairingForce.mag() > 10 ) 
          println("Point [" + myindexingloballist + "] large forces: net: " + netForce.mag() + " AR: " + ARForce.mag() + " BR: " + BRForce.mag() + " Fairing: " + FairingForce.mag());
      }
          
      velocity.add(PVector.mult(netForce, unit_of_time)); // v = F/m * unit time  ; 

       
      //translate point and constrain to screen
            
      next_x = x + velocity.x;
      next_y = y + velocity.y;
      
      

      next_x = constrain(next_x, parentps.top_left_X, parentps.bottom_right_X); //contrain the point within the bounding box of the point system
      next_y = constrain(next_y, parentps.top_left_Y, parentps.bottom_right_Y); //contrain the point within the bounding box of the point system

      //check if path from curr pos to next pos will cross line segments from last iteration and stop short of it,
      // this still does not guarantee that lines will not cross, since movements from this iteration may cross one another
      if (constrainMoves) {
        ContrainMoveToNotCrossLineSegments(); // contrained x, y is in (constrained_next_x, constrained_next_y)
      }
   }

  void printPointDetails(){
   println ("Point [" + myindexingloballist + "] at curr location ( " + x + " , " + y + ")" + "at new location ( " + next_x + " , " + next_y + ")"); 
  }
  
  
//check if path from curr pos to next pos will cross line segments from last iteration and stop short of it,
// this still does not guarantee that lines will not cross, since movements from this iteration may cross one another
  void ContrainMoveToNotCrossLineSegments()
  {
      float x2minusx1 = next_x - x;
      float y2minusy1 = next_y - y;
      float try_x, try_y;  

      if ((next_x - x) >= 1)
      {
          //(y-y1)/(x-x1) = (y2-y1)/(x2-x1) - given slope is same, or 
                 
          for (try_x = x; try_x <= next_x; try_x +=1.0)
          {
            try_y = y + (y2minusy1/x2minusx1 ) * (try_x - x);
            //println ("(x,y): " + x + "," + y + "  ; (next_x, next_y): " + next_x + "," + next_y + " + (con_next_x, con_next_y): " + constrained_next_x + "," + constrained_next_y); 

            int i = (int) constrain(round(try_x), parentps.top_left_X, parentps.bottom_right_X); 
            int j = (int) constrain(round(try_y), parentps.top_left_Y, parentps.bottom_right_Y);
            
            if (lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != -MAX_INT &&
                lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != myindexingloballist){
                return;
            }
            else {
              constrained_next_x = try_x;
              constrained_next_y = try_y;
            }
          }
      }
      else if ((x - next_x) >= 1)
      {
          //(y-y1)/(x-x1) = (y2-y1)/(x2-x1) - given slope is same, or 
                 
          for (try_x = x; try_x >= next_x; try_x -=1.0)
          {
            try_y = y + (y2minusy1/x2minusx1 ) * (try_x - x);
            //println ("(x,y): " + x + "," + y + "  ; (next_x, next_y): " + next_x + "," + next_y + " + (con_next_x, con_next_y): " + constrained_next_x + "," + constrained_next_y); 

            int i = (int) constrain(round(try_x), parentps.top_left_X, parentps.bottom_right_X); 
            int j = (int) constrain(round(try_y), parentps.top_left_Y, parentps.bottom_right_Y);
            
            if (lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != -MAX_INT &&
                lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != myindexingloballist){
                return;
            }
            else {
              constrained_next_x = try_x;
              constrained_next_y = try_y;
            }
          }
      }
      else  if ((next_y -y) >= 1)
      {
          // (x-x1)/(y-y1) = (x2-x1)/(y2-y1) - given slope is same, or 
          
          for (try_y = y; try_y <= next_y; try_y +=1.0)
          {
            try_x = x + (x2minusx1/y2minusy1) * (try_y - y);
            
            int i = (int) constrain(round(try_x), parentps.top_left_X, parentps.bottom_right_X); 
            int j = (int) constrain(round(try_y), parentps.top_left_Y, parentps.bottom_right_Y);
            
            if (lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != -MAX_INT &&
                lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != myindexingloballist){
                return;
            }
            else {
              constrained_next_x = try_x;
              constrained_next_y = try_y;
            }
          }
      }
      else if ((y - next_y) >= 1)
      {
          // (x-x1)/(y-y1) = (x2-x1)/(y2-y1) - given slope is same, or 
          
          for (try_y = y; try_y >= next_y; try_y -=1.0)
          {
            try_x = x + (x2minusx1/y2minusy1) * (try_y - y);
            
            int i = (int) constrain(round(try_x), parentps.top_left_X, parentps.bottom_right_X); 
            int j = (int) constrain(round(try_y), parentps.top_left_Y, parentps.bottom_right_Y);
            
            if (lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != -MAX_INT &&
                lineSegmentsMappedOnImage[i-imgTopLeftCorner_X ][j] != myindexingloballist){
                return;
            }
            else {
              constrained_next_x = try_x;
              constrained_next_y = try_y;
            }
          }
      }
      else
      {
        // point did not move
      }
  }
    
}
