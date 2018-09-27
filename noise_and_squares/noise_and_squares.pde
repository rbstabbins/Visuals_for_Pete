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

float[] fft_debug_buffer;
float[] fft_debug_buffer_next;
int debug_buffer_count = 0;
int debug_buffer_size = 5;

void setup() {
  fullScreen();
  //size(740,380);

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
  fft_debug = new FFT(in.bufferSize(), in.sampleRate() );
  fft_debug.linAverages( debug_width );
  
  fft_debug_buffer = new float[debug_width];
  fft_debug_buffer_next = new float[debug_width];
}

void draw() {
  background(0);

  //Get Spectrum
  fft_debug.forward(in.mix);
  fft.forward(in.mix);

  debug_window();
  
  //Noise Pattern
  //Squares
    for(int i = 0; i < fft.specSize(); i++)
  {
    // draw some rectangles based on the band and amplitude
    rectMode(CENTER);
    stroke(round(fft.getBand(i)*128));
    strokeWeight(100*fft.getBand(i));
    rect( width/2, height/2, fft.specSize()-i, fft.specSize()-i );
  }
  
  
}