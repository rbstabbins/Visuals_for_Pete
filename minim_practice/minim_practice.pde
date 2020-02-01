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


void setup() {
  size(512, 480);  //Window size set according to buffer size

  minim = new Minim(this);  //initiate the minim object

  //Setup Audio input
  in = minim.getLineIn(2, 2*width);  //Attach the minim object to the laptop microphone
  //Print info on the audio input
  println("Type is: " + in.type() );
  println("Buffer Size is: " + in.bufferSize() );
  println("Sample Rate is: " + in.sampleRate() );

  //Setup FFT
  //Make time domain buffer the same size as the Audio In buffer
  // and match sample rates.
  fft = new FFT(in.bufferSize(), in.sampleRate()/4 );
}

void draw() {
  background(0);
  stroke(255);

  // draw the waveforms so we can see what we are monitoring
  //waveform locations - top 25% of window - so max amplitude needs to be 12.5% of height
  int ampli = round(0.125 * height) ;
  for (int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, ampli + in.left.get(i)*ampli, i+1, ampli + in.left.get(i+1)*ampli );
    line( i, (ampli + 2*ampli) + in.right.get(i)*ampli, i+1, (ampli + 2*ampli) + in.right.get(i+1)*ampli );
  }

  //draw the fft of the input
  fft.forward(in.mix);
  // int ampli = round(0.125 * height) ;
  for (int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i, height, i, height - fft.getBand(i)*8 );
  }
}