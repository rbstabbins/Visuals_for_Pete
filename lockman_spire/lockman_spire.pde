// Lockman Spire Animation
//
// Import the Lockman Spire image, and segment
// the red and blue colours into bins that correspond
// to EQ channels.
// Use the MacBeth target to verify the colour mapping.
//
// As the EQ channel are excited, scale the image segments
// accordingly.
//
// Insert previous infrastructure of midi and minim etc,
// perhaps in a neater way now as well.
//
// Roger Stabbins
// 09/02/2020

import ddf.minim.*;
import ddf.minim.analysis.*;
import themidibus.*; // Import midibus library
import java.util.*; // java tools

MidiBus myBus; // The MidiBus object

Minim    minim;  // Minim library object
AudioInput  in;  //  Audio object that performs the listening
FFT  fft;  // Primary fourier transform object

int n_bands; // number of bands

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

// Midi
String[] in_list;
int n_ins;
int[] cc = new int[127];

// Image

PImage raw_img;  // image object
PImage cop_img;  // duplicate for editing each time
int x_0;  // top left x co-ord
int y_0;  // top left y co-ord
color col_list[]; // array of all colours in image
FloatList hue_list; // list of all hues in image 
//int hue_hist[];  // histogram of hues
float bin_list[]; // vector of limits of hue bins
float bin_step; // hue bin intervals
IntList mask_list[]; // array of IntLists that will store pixel indices

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
  // reduce sampleRate to improve response speed
  fft = new FFT(in.bufferSize(), in.sampleRate()/4 ); // Initiate the Fourier Transform operator, to match the sampling settings of the audio input  
  // set logarithmic binning
  fft.logAverages(15,8); // set the fft object to compute average bins, with a minimum bandwidth of 15Hz, with logarithmically increasing bandwidth, and including 3 channels per octave.
  
  // get number of bands in logarithmic binning
  fft.forward(in.mix);
  n_bands = fft.avgSize();
  
  // find the Korg Nanokontrol midi controller and attach to MidiBus
  
  String midi_target = "SLIDER/KNOB";  // the name of the korg midi controller    
  in_list = MidiBus.availableInputs() ; // string list of available devices
  n_ins = in_list.length;  // number of available devices
  int midi_index; // index of the korg device  
  // search through list and return index of Korg device
  boolean found = false;
  for ( midi_index = 0; midi_index < n_ins; midi_index++) {   
    println(in_list[midi_index]);
    if ( in_list[midi_index].equals(midi_target) ) {
      found = true;
      break; }    
  }
  if (found == false) { println("Error: MIDI TARGET NOT FOUND"); } 
 
  myBus = new MidiBus(this, midi_index, -1); // Attaches midi bus to found Korg channel for input, and leaves off output
  
  max_l = 50.0; // set the low freq maximum band amplitude
  max_m = 50.0; // set the mid freq maximum band amplitude
  max_h = 50.0; // set the high freq maximum band amplitude
  
  low = 6.0 ; // set the initial low bin amplitude
  mid = 6.0 ; // set the initial mid bin amplitude 
  high = 6.0 ;  // set the initial high bin amplitude
  
  // to do - scale these
  l_m_x = n_bands / 3; // Set the Low - Mid Cross-over Index
  m_h_x = 2* n_bands / 3; // Set the Mid - High Cross-over Index
    
  for (int i =0 ; i < 127; i++) { cc[i] = 1; }      
  
  // Import image
  raw_img = loadImage("lockman_spire.jpg");
  //raw_img = loadImage("macbeth.png"); // DEBUG with MACBETH
  //raw_img = loadImage("spec_sweep.png"); // DEBUG with sweep
  raw_img.resize(0, int(height*0.9)); // resize the image to fit the frame, with a 10% border
  
  // set corner co-ords
   y_0 = ( height / 2 ) - ( raw_img.height / 2 );
   x_0 = ( width / 2 ) - ( raw_img.width / 2 );
  
  col_list = new color[raw_img.width * raw_img.height]; // colour object 
  hue_list = new FloatList(); // list of hue values
  // switch colour mode to HSV, with H in range of 0 - nbands
  colorMode(HSB,n_bands,255,255);  
  
  // get list of colour present in image in hex
  raw_img.loadPixels(); // load the pixels
  // Loop through every pixel column
  for (int x = 0; x < raw_img.width; x++) {
    // Loop through every pixel row
    for (int y = 0; y < raw_img.height; y++) {
         int loc = x + y * raw_img.width;
         col_list[loc] = raw_img.pixels[loc];
         // get hue
         hue_list.appendUnique(hue(col_list[loc])); // get the hue for the colour
    }
  }
  
  // sort hue_list
  hue_list.sort();
  //// make histogram of hue_list, with number of bins set to number of channels
  //hue_hist = new int[n_bands];
  
  // set up bin intervals
  print("Max Hue");
  println(hue_list.max());
  print("Min Hue");
  println(hue_list.min());
  
  print("nbands : ");
  println(n_bands);
  
  bin_step = ( hue_list.max() - hue_list.min() ) / ( n_bands - 1 ) ;   
  bin_list = new float[n_bands];
  for (int i = 0; i < n_bands; i++) { bin_list[i] = i*bin_step; }
  // this produces a list of the hue bins to use    
  
  //println( bin_list);
  
  // the mapping process is going to take, for each band, all 
  // all pixels with hue values within the bin range, and adjust
  // either the brightness or saturation, or perhaps both, and 
  // scale according to the band amplitude.
  // So it would be much faster to pre-make the pixel location
  // lists / maps at this early stage.
  
  // store locations of hues satisfying bins in int array
  // make stack of these int arrays - an n_bands long array of n_pixels arrays
  
  mask_list = new IntList[n_bands]; // Array of lists of indices for hues
  
  for (int i = 0; i < n_bands; i++) { mask_list[i] = new IntList(); } 
  
  for (int x = 0; x < raw_img.width; x++) {    
    for (int y = 0; y < raw_img.height; y++) {
         int loc = x + y * raw_img.width;
         float this_hue = hue(raw_img.pixels[loc]);         
         // do some comparison of this hue to bin_lo_lims values
         // just brute force it for now
         for (int i = 0; i < n_bands; i++) {
           if ( bin_list[i] <= this_hue && this_hue < bin_list[i]+bin_step ) {               
               mask_list[i].append(loc);
           }
         }  
    }
  }
  
  // check the mask lists worked
  //for (int i = 0; i < n_bands-1; i++) { println(mask_list[i]); } 
  
}
//---------------------------------------------------------------
void draw(){
  // set background  
  background(0);  // set to black

  
  // get spectum of input audio  
  fft.forward(in.mix);
  
  // map max range values
  
  max_l = map(cc[16], 0, 127, 0.1, 50.0);
  if (max_l == 0.0) { max_l = 0.1; } // clip max_a to avoid infinities when mapping  
  
  max_m = map(cc[17], 0, 127, 0.1, 50.0);
  if (max_m == 0.0) { max_m = 0.1; } // clip max_a to avoid infinities when mapping
  
  max_h = map(cc[18], 0, 127, 0.1, 50.0);
  if (max_h == 0.0) { max_h = 0.1; } // clip max_a to avoid infinities when mapping
  
  // map bin amplitudes
          
  low = map(cc[0], 0, 127, 0.0, max_l);
  if (low == 0.0) { low = 0.1; } // clip max_a to avoid infinities when mapping  
  
  mid = map(cc[1], 0, 127, 0.0, max_m);
  if (mid == 0.0) { mid = 0.1; } // clip max_a to avoid infinities when mapping
  
  high = map(cc[2], 0, 127, 0.0, max_h);
  if (high == 0.0) { high = 0.1; } // clip max_a to avoid infinities when mapping
  //max_a = 10.0; 
  // print the current EQ state
  
  //print("EQ:  LOW:  "+low);
  //print("     MID:  "+mid);
  //println("    HIGH:  "+high);
  
  // loop through fft channels
  // at each channel, draw the Lockman Spire thresholded band of that layer, 
  // with transparency set according to amplitude.  
  // the highest index is the highest frequency (for log mode - opposite for linear)
    
  //raw_img.loadPixels();
  cop_img = raw_img.copy();
  cop_img.loadPixels();
  
  for (int i = 0; i < n_bands ; i=i+1) {  // cycle through frequency bands
  
    // get amplitude
    float a = fft.getAvg(i);  // get this band amplitude 
    
    // print hue
    //print("This Hue: ");
    //println(bin_list[i]);
    
    //color band_col = color(bin_list[i], 255, 255); 
    //print(i);
    //print("    Red : ");
    //print(red(band_col));
    //print("    Green : ");
    //print(green(band_col));
    //print("    Blue : ");
    //println(blue(band_col));
    
    // error in this scaling
    
     // choose the EQ bin depending on the index of the band
    // and set the band scaling, max_a
    if ( i < l_m_x) { max_a = low; }
    if ( l_m_x <= i && i < m_h_x) { max_a = mid; }
    if ( m_h_x <= i) { max_a = high; }
    
    //println(i+" max_a : "+max_a+"   this a :"+a);
    
    float this_scale = map(a, 0, max_a, 0.0, 1.0) ;
    if ( this_scale > 1.0 ) { this_scale = 1.0; }
    if ( this_scale < 0.0 ) { this_scale = 0.0; }
    //println("This scale : "+this_scale);
            
    // brute force method - for each band, scroll through the pixel index list, and set brightness accordingly
    // load mask_list into array temporarily
    
    // turns out the brute force method requires too much power!
    // so need to come up with a more memory efficient method.
    // maybe matrix pop and stacking will be of some use.
    
    // Actually it was just the continual reprinting of the list that 
    // was causing the crashing
  
    //IntList this_list = mask_list[i];
    int[] this_arr = mask_list[i].array(); 
    for (int j = 0; j < this_arr.length -1; j++) {
        colorMode(HSB,n_bands,255,255);  
        float this_lvl = brightness(cop_img.pixels[this_arr[j]]);
        float this_hue = hue(cop_img.pixels[this_arr[j]]);
        float this_sat = saturation(cop_img.pixels[this_arr[j]]);
        float new_lvl =  this_lvl * this_scale;
        cop_img.pixels[this_arr[j]] = color(this_hue, this_sat, new_lvl);
    }
    
  }
  
  // draw the new image
  cop_img.updatePixels();
  
  image(cop_img,x_0,y_0, raw_img.width, raw_img.height);
}

void controllerChange(int channel, int number, int value) {
   //Recieve Controller change to [value] in CC [number] control  
    cc[number] = value;
}