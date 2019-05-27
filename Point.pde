  class PointAnna {
  float x,y;
  int cluster;
  
  PointAnna(float xax, float yax){
    x= xax;
    y= yax;
  }
 
   void display(){ //trial
   
    stroke(170);
    strokeWeight(0.2);
    //line(width/2,height/2,x,y);
    stroke(0);
    fill(0,150);
    ellipse(x,y,3,3);
  }
  
  public float getX()
  {
    return x;
  }
   public float getY()
  {
    return y;
  }
  
  
}
