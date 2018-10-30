int[] get_colours() {  
  
  // Get 3 Peaks from spectrum
  int[] peaks = new int[3];
  float max_a = 1.0;
  for(int i = 0; i < fft.specSize(); i++) {
      a = fft.getBand(i);
      if (a >= max_a) { max_a = a;}
      if (a >= fft.getBand(peaks[0])) {        
        peaks[2] = peaks[1];
        peaks[1] = peaks[0];
        peaks[0] = i;     
  }
  }
  colorMode(HSB, 1000, 1.0, max_a);
  //println(peaks);
  // Map Peak indices to frequencies
  float[] freqs = new float[3];
  for (int p = 0; p < 3; p++) {    
    freqs[p] = fft.indexToFreq(peaks[p]); 
    //Map freqs to colours
    peak_cols[p] = color(freqs[p], 0.5, fft.getBand(peaks[0]));
  }
  return peak_cols;
}