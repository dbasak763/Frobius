ArrayList<Point> points;

class Point 
{
   float x, y;
   float mass;
   PVector randDirection;
   PVector netForce;
   PVector velocity;
   int Max_Rebirth_Distance_X, Max_Rebirth_Distance_Y;
   
   PointSystem parentps; //tracks the parent point system to which this point belongs
   
   Point(float px, float py, PointSystem parent)
   {
      x = px;
      y = py;
      mass = 1.0;

      parentps = parent;
      
      Max_Rebirth_Distance_X = (int)(parentps.bottom_right_X - parentps.top_left_X);
      Max_Rebirth_Distance_Y = (int)(parentps.bottom_right_Y - parentps.top_left_Y);
      
      randDirection = new PVector(0, 0);
      netForce = new PVector(0, 0);
      velocity = new PVector(0, 0);
   }

   void apply_friction()
   {
      PVector force = PVector.mult(velocity, -coeff_friction);
      netForce.add(force);
   }
   
   void apply_brownianmotion()
   {
      float a = random(TWO_PI);
      float b = random(max_acceleration);//b is magnitude of acceleration
      
      PVector force = new PVector(b*cos(a), b*sin(a));
      netForce.add(force);
   }
   
   //TO FIX
   void apply_constrain()
   {
      if(x<=5) netForce.add(1, 0);
      else if(x>=495) netForce.add(-1, 0);
      if(y<=5) netForce.add(0, 1);
      else if(y>=495) netForce.add(0, -1);
   }
   
   void apply_transformation()
   {

      velocity.add(PVector.mult(netForce, unit_of_time/mass)); // v = F/m * unit time

      //translate point and constrain to screen
      
      x += velocity.x;
      y += velocity.y;

      x = constrain(x, parentps.top_left_X, parentps.bottom_right_X); //contrain the point within the bounding box of the point system
      y = constrain(y, parentps.top_left_Y, parentps.bottom_right_Y); //contrain the point within the bounding box of the point system
      
      
      //move point away from boundaries to prevent clustering, doesn't work properly
      if(x == parentps.top_left_X)
      {
          x += random(0, Max_Rebirth_Distance_X);
      }
      else if(x == parentps.bottom_right_X)
      {
          x -= random(0, Max_Rebirth_Distance_X);
      }
      
      if(y == parentps.top_left_Y)
      {
         y += random(0, Max_Rebirth_Distance_Y);
      }
      else if(y == parentps.bottom_right_Y)
      {
         y -= random(0, Max_Rebirth_Distance_Y); 
      }
      

   }
}
