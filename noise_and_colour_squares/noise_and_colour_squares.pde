//NOISE AND SQUARES
//NOISE
//Log-Normal Noise Pattern (to look like stars)
//Beat Detect reloads noise pattern
//Time in between reloads sees the noise grow
//SQUARES
//Square intensity from frequency bin
//Square Stroke inverse with number of bins above certain threshold

//Debugging Window Also

// TODO - Add background noise
// TODO - Change spectra to log scale, with good resolution for notes
// TODO - Test note identification/detection
// TODO - add some kind of delay to signal chain

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

//Colours
color[] peak_cols = new color[3];
int[] peaks = new int[3];

//EQ
float[] EQ;
float[] debug_EQ;
float[] main_EQ;
int n_eq;
float lo_cut_freq = 120.0; //Hz
int lo_cut_ind;
int side;
int i_d;

//---------------------------------------------------------------
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
  
  //Debug Window tracking
  fft_debug = new FFT(in.bufferSize(), in.sampleRate() );
  fft_debug.logAverages( 5, 11 );
  println(fft_debug.avgSize());
  fft_debug_buffer = new float[fft_debug.avgSize()];
  fft_debug_buffer_next = new float[fft_debug.avgSize()];
  
  //Colours
  colorMode(HSB, in.sampleRate()/2, 1.0, 1.0);
  
  //EQ
  n_eq = round(in.sampleRate())/2;
  EQ = new float[n_eq];
  println(n_eq);  
  debug_EQ = new float[fft_debug.avgSize()];  
  main_EQ = new float[fft.specSize()];
  
  //wide parabola, centered at n_eq/2 
  for (int i = 0; i < n_eq; i++) {     
     EQ[i] = 1.0-((pow(i-(n_eq/2),2))/pow(n_eq/2,2));
     if (EQ[i] < 0.0) { EQ[i] = 0.0; } 
     //Get much better EQ system in future     
     //println(EQ[i]);
  }
      
  //Debug EQ
    //Map EQ range to debug fft domain
    float rescale = 129.0;
  for (int i = 0; i < n_eq; i++) {
     i_d = fft_debug.freqToIndex(i);
     rescale = fft_debug.getAverageCenterFrequency(i_d)/i;
     i_d = floor(i_d/rescale);
     if (i_d >= fft_debug.avgSize())  { i_d = fft_debug.avgSize() - 1; }
     debug_EQ[i_d] = EQ[i];
  }
  
  //Full EQ
    for (int i = 0; i < n_eq; i++) {
     i_d = fft.freqToIndex(i);
     //todo insert better averaging over this
     main_EQ[i_d] = EQ[i];
  }
  
  
}
//---------------------------------------------------------------
void draw() {
  background(0);

  //Get Spectrum
  fft_debug.forward(in.mix);
  fft.forward(in.mix);

  debug_window(); //<>//
  
  peak_cols = get_colours();
  
  ////Noise Pattern
  ////Squares
  //for (int i = 2; i >= 0; i--) {
    for (int i = 0; i < 3; i++) {
        rectMode(CENTER);
        colorMode(RGB, 255, 255, 255);
        fill(peak_cols[i]);
        strokeWeight(100*fft.getBand(i));
        side = fft.specSize() - peaks[i];
        side = round(map(side, 0, fft.specSize(), 0, height/2));  
        println(side);
        //rect( width/2, height/2, side, side);
      }  
}
//---------------------------------------------------------------