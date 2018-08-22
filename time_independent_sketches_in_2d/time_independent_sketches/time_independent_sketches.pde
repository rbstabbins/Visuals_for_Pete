//Square background, with Albers Homage to a Square darkest gold
//Gaussian Noise
  
  int h = 512;
  int w = 512;
  
  int[] r_pot = new int[w*h];
  int[] g_pot = new int[w*h];
  int[] b_pot = new int[w*h];
  int[] r_stats = { 186, 5 };
  int[] g_stats = { 134, 5 };
  int[] b_stats = { 38, 5 };
  
void setup() {
  size(512,512);
  //Make random array for all pixels
  perlin_noise_colour(r_stats,g_stats, b_stats);
  
}

void draw() {
  background(186, 134, 38);
  perlin_noise_colour(r_stats,g_stats, b_stats);
  loadPixels();
  for (int i = 0; i < width*height; i++) {
    //int r = r_pot[i];
    //int g = g_pot[i];
    //int b = b_pot[i];
   pixels[i] = color(r_pot[i], g_pot[i], b_pot[i]); 
  }
  updatePixels();
}