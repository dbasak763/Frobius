class Line
{
    float m, b;
    Line(float m, float b)
    {
        this.m = m;
        this.b = b;
    }
    //(x, y) is point on line, find slope and y-intercept
    void findEquationLine(PVector v, int x, int y)
    {
        float slope = calculateSlope(v);
        float y_intercept = y - slope * x;
        this.m = slope;
        this.b = y_intercept;
        
    }
    
}

//Line l1 = new Line(m, b);
//void intersect
//does line intersect with horizontal line segment x = ,with endpoints y1 and y2 
boolean intersectHorizontal(float x, Line l, float y1, float y2)
{
    float y = l.m * x + l.b;//
    if(y1 > y2)//swap two variables so that y1 < y2
    {
        float temp = y1;
        y1 = y2;
        y2 = temp;
    }
    if(y1 < y && y < y2)
    {
        return true; 
    }
    return false;
    
    
}

//Line l1 = new Line(m, b);
//void intersect
//does line intersect with vertical line segment y = ,with endpoints x1 and x2 

boolean intersectVertical(float y, Line l, float x1, float x2)
{
    float x = (l.b - y)/l.m;//
    if(x1 > x2)//swap two variables so that y1 < y2
    {
        float temp = x1;
        x1 = x2;
        x2 = temp;
    }
    if(x1 < x && x < x2)
    {
        return true; 
    }
    return false;
}

float calculateSlope(PVector netForce)
{
    return netForce.y / netForce.x;
}
