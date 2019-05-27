
class Attractor {
  // position
  float x=0, y=0; 

  // radius of impact
  float radius = 200;
  // strength: positive for attraction, negative for repulsion
  float strength = 1;  
  // parameter that influences the form of the function
  float ramp = 0.5;    //// 0.01 - 0.99


  Attractor(float theX, float theY) {
    x = theX;
    y = theY;
  }


  void attract(Node theNode) {
    // calculate distance
    float dx = x - theNode.x;
    float dy = y - theNode.y;
    float d = mag(dx, dy);

    if (d > 0 && d < radius) {
      // calculate force
      float s = pow(d / radius, 1 / ramp);
      float f = s * 9 * strength * (1 / (s + 1) + ((s - 3) / 4)) / d;

      // apply force to node velocity
      // swapping of dx and dy makes the twirl
      theNode.velocity.x += dy * f;
      theNode.velocity.y -= dx * f;
    }
  }

}
