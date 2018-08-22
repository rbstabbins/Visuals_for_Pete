
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

float spectrumScale = 10;

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
  fft = new FFT(in.bufferSize(), in.sampleRate() );
  fft.logAverages( 22, 1);
}

void draw() {
  background(0);
  stroke(255);
  float centerFrequency = 0;
  // draw the waveforms so we can see what we are monitoring
  //waveform locations - top 25% of window - so max amplitude needs to be 12.5% of height
  int ampli = round(0.125 * height) ;
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, ampli + in.left.get(i)*ampli, i+1, ampli + in.left.get(i+1)*ampli );
    line( i, (ampli + 2*ampli) + in.right.get(i)*ampli, i+1, (ampli + 2*ampli) + in.right.get(i+1)*ampli );
  }
  
  //draw the fft of the input
  fft.forward(in.mix);
  // int ampli = round(0.125 * height) ;
  for(int i = 0; i < fft.avgSize(); i++)
        {
      centerFrequency = fft.getAverageCenterFrequency(i);
      // how wide is this average in Hz?
      float averageWidth = fft.getAverageBandWidth(i);   
      
      // we calculate the lowest and highest frequencies
      // contained in this average using the center frequency
      // and bandwidth of this average.
      float lowFreq  = centerFrequency - averageWidth/2;
      float highFreq = centerFrequency + averageWidth/2;
      
      // freqToIndex converts a frequency in Hz to a spectrum band index
      // that can be passed to getBand. in this case, we simply use the 
      // index as coordinates for the rectangle we draw to represent
      // the average.
      int xl = (int)fft.freqToIndex(lowFreq);
      int xr = (int)fft.freqToIndex(highFreq);
      
      // draw a rectangle for each average, multiply the value by spectrumScale so we can see it better
      rect( xl, height, xr, height - fft.getAvg(i)*spectrumScale );
    }
  
}