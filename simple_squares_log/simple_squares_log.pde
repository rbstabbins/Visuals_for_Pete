// The Simple Squares Animation
//
// Concentric Squares, each of equal line thickness - 1 pix,
// Largest square brightness maps to Lowest frequency
// of audio input, and smallest square to highest frequency.
//
// Effect is that the square brightnesses map to the instantaneous
// spectral power distribution of the audio.
//
// Audio listening performed with the minim library.
// Will also apply windowing to the spectrum prior to the transform
//
// Logarithmic binning of bands
// Also apply spectrum scaling
//
// Roger Stabbins
// 19/01/2020

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim    minim;  // Minim library object
AudioInput  in;  //  Audio object that performs the listening
FFT  fft;  // Primary fourier transform object
FFT  fft_debug;  // FFT Debug object

// [19/01/2020] will add debug later, for now continue with main 
// project.

float[] fft_buffer;
float[] fft_buffer_next;
int buffer_count = 0;
int buffer_size = 5;

//EQ
float[] EQ;
float[] main_EQ;
float mid_cut;
float lo_boost;
float poly_grad;
int n_eq;
float lo_cut_freq = 120.0; //Hz
int lo_cut_ind;
int side;
int i_d;
float max_a;

//---------------------------------------------------------------
void setup(){
  
  //*** set graphic dimensions***
  fullScreen(); // FULL SCREEN
  //size(740, 380); // WINDOW
  
  //***Audio input setup***
  minim = new Minim(this);  // Initiate the minim object
  // TODO investigate alternative routings (whats playing -> input)
  in = minim.getLineIn(2);  // Attach the laptop microphone to mnm
  
  //***Fourier Transform (eq) setup***
  
  // check buffer size and sample rate
  print("Input Buffer Size: ");
  println(in.bufferSize());
  print("Input Sample Rate: ");
  println(in.sampleRate());
  
  // set arrays for storing data stream
  // NEW FIND - reduce  sampleRate to improve response speed
  fft = new FFT(in.bufferSize(), in.sampleRate()/4 ); // Initiate the Fourier Transform operator, to match the sampling settings of the audio input  
  // set logarithmic binning
  fft.logAverages(20,2); // set the fft object to compute average bins, with a minimum bandwidth of 10Hz, with logarithmically increasing bandwidth, and including 8 channels per octave.
  
  max_a = 6.0; // set the maximum band amplitude
  
  ////EQ
  //EQ = new float[fft.avgSize()];
  
  //// Quadratic "smile" EQ parameters
  //mid_cut = 0.8;  // value of middle of range minima
  //lo_boost = 1.2; // value of edge freq boosts (i.e. y-intercept)
  //poly_grad = 4.0 * (lo_boost - mid_cut) / pow(fft.avgSize(),2); // scale factor required
  
  // for (int i = 0; i < fft.avgSize(); i++) {     
  //   EQ[i] = poly_grad*pow(i - fft.avgSize()/2,2) + mid_cut;
  //   if (EQ[i] < 0.0) { EQ[i] = 0.0; } 
  //   //Get much better EQ system in future     
  //   println(EQ[i]);
  //}
}
//---------------------------------------------------------------
void draw(){
  // set background  
  background(0);  // set to black
  
  // get spectum of input audio  
  fft.forward(in.mix);
  
  //print("Number of channels: ");
  //println(fft.specSize());
  //println();
  //print("Average Size: ");
  //println(fft.avgSize());
  
  int n_bands = fft.avgSize();
    
  // loop through fft channels
  // at each channel, draw a square, with side-length scaled to the
  // the channel number.   
  // Note in comparison to the linear mode, the highest index is the highest frequency
  for (int i = 0; i < n_bands ; i=i+1) {  // start at biggest
        rectMode(CENTER);  // draw the square from the centre
        float a = fft.getAvg(i);  // get this band amplitude
        if (a >= max_a) {  // update max amplitude
            max_a = a;
            //println(max_a);
          }
        fill(0); // set interior of square to black
        // set the square line shade according to the amplitude, wrt max_a, mapped to 8-bit
        stroke(map(a, 0, max_a, 0, 255)); 
        strokeWeight(1); // set line width to 1 pixel
        side = n_bands - i;  // set the side of the square to the index number
        //println(side);
        side = round(map(side, 0, n_bands,  (3*height/4)*0.1, 3*height/4)); // map the square size to 3/2 of the height        
        rect( width/2, height/2, side, side); // draw the rectangle
      }
      
   // TODO add key to reset the amplitude
}