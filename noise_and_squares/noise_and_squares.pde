//NOISE AND SQUARES
//NOISE
//Log-Normal Noise Pattern (to look like stars)
//Beat Detect reloads noise pattern
//Time in between reloads sees the noise grow
//SQUARES
//Square intensity from frequency bin
//Square Stroke inverse with number of bins above certain threshold

//Debugging Window Also

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim       minim;  //Minim library object, used for audio analysis
AudioInput  in; //Audio input object
FFT         fft; //FFT object
FFT         fft_debug; //FFT Debug object

//Debug Window Locations
int[] debug1_xy = new int[4];
int[] debug2_xy = new int[4];
int[] debug3_xy = new int[4];
int debug_height = 0;
int debug_width = 0;

float[] fft_buffer;
float[] fft_buffer_next;
int buffer_count = 0;
int buffer_size = 5;

float[] fft_debug_buffer;
float[] fft_debug_buffer_next;
int debug_buffer_count = 0;
int debug_buffer_size = 5;

float a;

color[] peak_cols = new color[3];

void setup() {
  //fullScreen();
  size(740,380);

  //Debug Info
  debug_width = width/5;    
  debug_height = 3*height/4;        
  debug1_xy[0] = 0;
  debug2_xy[0] = 0;
  debug3_xy[0] = 0;
  debug1_xy[1] = height/4;
  debug2_xy[1] = 2*height/4;
  debug3_xy[1] = 3*height/4;
  debug1_xy[2] = width/5;
  debug2_xy[2] = width/5;
  debug3_xy[2] = width/5;
  debug1_xy[3] = height/2;
  debug2_xy[3] = 3*height/4;
  debug3_xy[3] = height;

  //Audio Listening
  minim = new Minim(this);  //initiate the minim object
  
  in = minim.getLineIn(2);  //Attach to laptop microphone
  fft = new FFT(in.bufferSize(), in.sampleRate() );
  fft_buffer = new float[in.bufferSize()];  
  fft_buffer_next = new float[in.bufferSize()];
  
  fft_debug = new FFT(in.bufferSize(), in.sampleRate() );
  fft_debug.linAverages( debug_width );
  
  fft_debug_buffer = new float[debug_width];
  fft_debug_buffer_next = new float[debug_width];
  colorMode(HSB, in.sampleRate()/2, 1.0, 1.0);
}

void draw() {
  background(0);

  //Get Spectrum
  fft_debug.forward(in.mix);
  fft.forward(in.mix);

  debug_window();
  
  peak_cols = get_colours();
  
  //Noise Pattern
  //Squares
      for(int i = 0; i < fft.specSize(); i++)
      {        
        fft_buffer_next[i] = fft_buffer_next[i] + fft.getBand(i);       
      }
    if (buffer_count == buffer_size) {
      fft_buffer = fft_buffer_next;
      //println(fft_debug_buffer_next);
      fft_buffer_next = new float[in.bufferSize()];
      buffer_count = 0;
  }
  else {   buffer_count++; }
    //float max_a = 1.0;
    //for(int i = 0; i < fft.specSize(); i++)
    //  {
    //    // draw some rectangles based on the band and amplitude
    //    rectMode(CENTER);
    //    a = fft.getBand(i);
    //    if (a >= max_a) { max_a = a;}
    //    //a = map(a, 0.0,max_a, 0,256); 
    //    //colorMode(HSB, 1000, 1.0, max_a);
    //    stroke(peak_cols[0]);
    //    //strokeWeight(100*fft.getBand(i));
    //    rect( width/2, height/2, fft.specSize()-i, fft.specSize()-i );
    //  }
  //for (int i = 0; i < 3; i++) {
  //      rectMode(CENTER);
  //      colorMode(HSB, 1000, 1.0, 10.0);
  //      stroke(peak_cols[i]);
  //      //strokeWeight(100*fft.getBand(i));
  //      rect( width/2, height/2, fft.specSize()*i, fft.specSize()*i );
  //    }
  
}