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
float[] debug_EQ;
float[] main_EQ;
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
  fft = new FFT(in.bufferSize(), in.sampleRate() ); // Initiate the Fourier Transform operator, to match the sampling settings of the audio input
     
  max_a = 0.1; // set the maximum band amplitude
}
//---------------------------------------------------------------
void draw(){
  // set background  
  background(0);  // set to black
  
  // get spectum of input audio  
  fft.forward(in.mix);
    
  // loop through fft channels
  // at each channel, draw a square, with side-length scaled to the
  // the channel number.   
  for (int i = fft.specSize(); i > 0 ; i=i-2) {  // start at biggest
        rectMode(CENTER);  // draw the square from the centre
        float a = fft.getBand(i);  // get this band amplitude
        if (a >= max_a) {  // update max amplitude
            max_a = a;
            println(max_a);
          }
        fill(0); // set interior of square to black
        // set the square line shade according to the amplitude, wrt max_a, mapped to 8-bit
        stroke(map(a, 0, max_a, 0, 255)); 
        strokeWeight(1); // set line width to 1 pixel
        side = i;  // set the side of the square to the index number
        side = round(map(side, 0, fft.specSize(), (3*height/4)*0.1, 3*height/4)); // map the square size to 3/2 of the height
        //println(side);
        rect( width/2, height/2, side, side); // draw the rectangle
      }
      
   // TODO add key to reset the amplitude
}