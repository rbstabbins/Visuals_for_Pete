// Test environment for mapping sound input to spatial noise
// patterns.
// 1. Get input sound
// 2. Get Spectrum of input sound
// 3. Generate Noise image
// 4. Get FFT of noise image
// 5. Scale frequencies of noise according to sound spectrum

import ddf.minim.*;
import ddf.minim.analysis.*;

Minim       minim;  //Minim library object, used for audio analysis
AudioInput  in; //Audio input object
FFT         fft; //FFT object
BeatDetect  beat; //beat detection object

float max_lvl = 0;

void setup() {
  fullScreen();
  //size(, 1024);  //Window size set according to buffer size
  
  minim = new Minim(this);  //initiate the minim object
  
  //Setup Audio input
  in = minim.getLineIn(2);  //Attach the minim object to the laptop microphone
  //Print info on the audio input
  println("Type is: " + in.type() );
  println("Buffer Size is: " + in.bufferSize() );
  println("Sample Rate is: " + in.sampleRate() );
  
  //Setup FFT
  //Make time domain buffer the same size as the Audio In buffer
  // and match sample rates.
  fft = new FFT(in.bufferSize(), in.sampleRate() );
  beat = new BeatDetect();
}

void draw() {
  background(0);
  //stroke(255);
  
  // draw the waveforms so we can see what we are monitoring
  //waveform locations - top 25% of window - so max amplitude needs to be 12.5% of height
  //int ampli = round(0.125 * height) ;
  //for(int i = 0; i < in.bufferSize() - 1; i++)
  //{
  //  line( i, ampli + in.left.get(i)*ampli, i+1, ampli + in.left.get(i+1)*ampli );
  //  line( i, (ampli + 2*ampli) + in.right.get(i)*ampli, i+1, (ampli + 2*ampli) + in.right.get(i+1)*ampli );
  //}
  
  //draw the fft of the input
  fft.forward(in.mix);
  beat.detect(in.mix);
  if (beat.isOnset()) background(255);
  if (beat.isHat()) background(0,255,0);
  if (beat.isSnare()) background(0,0,255);
  for(int i = 0; i < fft.specSize(); i++)
  {
    // draw some rectangles based on the band and amplitude
    rectMode(CENTER);
    stroke(round(fft.getBand(i)*128));
    rect( width/2, height/2, fft.specSize()-i, fft.specSize()-i );
  }
  
}