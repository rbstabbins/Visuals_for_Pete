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
// Add Midi Control - first, to control the amplitude value
//                  - then to control EQ
//
// Roger Stabbins
// 27/01/2020

import ddf.minim.*;
import ddf.minim.analysis.*;
import themidibus.*; // Import midibus library

MidiBus myBus; // The MidiBus object

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

int n_bands; // number of bands

int side;

//EQ
float low;  // Low Frequency Val  
float mid;  // Mid Frequency Val
float high;  // High Frequency Val

float max_l;  // Low Frequency Maximum  
float max_m;  // Mid Frequency Maximum
float max_h;  // High Frequency Maximum

int l_m_x; // Low - Mid Cross-over Index
int m_h_x; // Mid - High Cross-over Index

float max_a; // master max level

int cc1;

// Midi
String[] in_list;
int n_ins;
int[] cc = new int[127];

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
  fft.logAverages(15,3); // set the fft object to compute average bins, with a minimum bandwidth of 10Hz, with logarithmically increasing bandwidth, and including 8 channels per octave.
  
  // get number of bands
  fft.forward(in.mix);
  n_bands = fft.avgSize();
  
  // find the Korg Nanokontrol midi controller and attach to MidiBus
  
  String midi_target = "SLIDER/KNOB";  // the name of the korg midi controller    
  in_list = MidiBus.availableInputs() ;
  n_ins = in_list.length;
  int midi_index;
  for ( midi_index = 0; midi_index < n_ins; midi_index++) {     
    if ( in_list[midi_index].equals(midi_target) ) {       
      break; }
    else { println("Error: "+midi_target+" not found"); }
  }
  
  myBus = new MidiBus(this, midi_index, -1); // Attaches midi bus to channel 1 for input, and leaves off output
  
  max_l = 50.0; // set the low freq maximum band amplitude
  max_m = 50.0; // set the mid freq maximum band amplitude
  max_h = 50.0; // set the high freq maximum band amplitude
  
  low = 6.0 ; 
  mid = 6.0 ; 
  high = 6.0 ; 
  
  l_m_x = n_bands / 3; // Low - Mid Cross-over Index
  m_h_x = 2* n_bands / 3; // Mid - High Cross-over Index
    
  for (int i =0 ; i < 127; i++) { cc[i] = 1; }      
}
//---------------------------------------------------------------
void draw(){
  // set background  
  background(0);  // set to black
  
  // get spectum of input audio  
  fft.forward(in.mix);
  
  // map max range values
  max_l = map(cc[16], 0, 127, 1.0, 60.0);
  if (max_l == 0.0) { max_l = 0.1; } // clip max_a to avoid infinities when mapping  
  
  max_m = map(cc[17], 0, 127, 1.0, 60.0);
  if (max_m == 0.0) { max_m = 0.1; } // clip max_a to avoid infinities when mapping
  
  max_h = map(cc[18], 0, 127, 1.0, 60.0);
  if (max_h == 0.0) { max_h = 0.1; } // clip max_a to avoid infinities when mapping
  
        
  low = map(cc[0], 0, 127, 0.0, max_l);
  if (low == 0.0) { low = 0.1; } // clip max_a to avoid infinities when mapping  
  
  mid = map(cc[1], 0, 127, 0.0, max_m);
  if (mid == 0.0) { mid = 0.1; } // clip max_a to avoid infinities when mapping
  
  high = map(cc[2], 0, 127, 0.0, max_h);
  if (high == 0.0) { high = 0.1; } // clip max_a to avoid infinities when mapping
  
  // print the current EQ state
  print("EQ:  LOW:  "+low);
  print("     MID:  "+mid);
  println("    HIGH:  "+high);
  
  // loop through fft channels
  // at each channel, draw a square, with side-length scaled to the
  // the channel number.   
  // Note in comparison to the linear mode, the highest index is the highest frequency
  for (int i = 0; i < n_bands ; i=i+1) {  // start at biggest
        rectMode(CENTER);  // draw the square from the centre        
        float a = fft.getAvg(i);  // get this band amplitude
        fill(0); // set interior of square to black
        
        if ( i < l_m_x) { max_a = low; }
        if ( l_m_x <= i && i < m_h_x) { max_a = mid; }
        if ( m_h_x <= i) { max_a = high; }
        
        // set the square line shade according to the amplitude, wrt max_a, mapped to 8-bit
        stroke(map(a, 0, max_a, 0, 255)); 
        strokeWeight(1); // set line width to 1 pixel
        side = n_bands - i;  // set the side of the square to the index number
        //println(side);
        side = round(map(side, 0, n_bands,  (3*height/4)*0.2, 3*height/4)); // map the square size to 3/2 of the height        
        rect( width/2, height/2, side, side); // draw the rectangle
        
      }
      
   // TODO add key to reset the amplitude
}

void controllerChange(int channel, int number, int value) {
   //Recieve Controller change
  //println();
  //println("Controller Change:");
  //println("----------");
  //println("Channel:"+channel);
  //println("Number:"+number);
  //println("Value:"+value);
  
  cc[number] = value;
  
}