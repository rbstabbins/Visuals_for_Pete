// Test environment for mapping sound input to spatial noise
// patterns.
// 1. Get input sound
// 2. Get Spectrum of input sound
// 3. Generate Noise image
// 4. Get FFT of noise image
// 5. Scale frequencies of noise according to sound spectrum

import ddf.minim.*;

Minim minim;
AudioInput in;


void setup() {
  size(512, 480);
  
  minim = new Minim(this);
  in = minim.getLineIn();
  println("Type is: " + in.type() );
  println("Buffer Size is: " + in.bufferSize() );
  println("Sample Rate is: " + in.sampleRate() );
  
}

void draw() {
    background(0);
  stroke(255);
  
  // draw the waveforms so we can see what we are monitoring
  for(int i = 0; i < in.bufferSize() - 1; i++)
  {
    line( i, 50 + in.left.get(i)*50, i+1, 50 + in.left.get(i+1)*50 );
    line( i, 150 + in.right.get(i)*50, i+1, 150 + in.right.get(i+1)*50 );
  }
}