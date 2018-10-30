int[] get_colours() {  
  
  // Get 3 Peaks from spectrum  
  float max_a = 1.0;
  
  for(int i = 0; i < fft.specSize(); i++) {
      a = fft.getBand(i) * main_EQ[i];
      if (a >= max_a) { max_a = a;}
      if (a >= fft.getBand(peaks[0])) {        
        peaks[2] = peaks[1];
        peaks[1] = peaks[0];
        peaks[0] = i;     
        }
  }
  
  //colorMode(mode, max1, max2, max3)
  float max_freq = fft.indexToFreq(fft.specSize()) /10;
  colorMode(HSB, max_freq, 1.0, max_a);
  //println(peaks);
  // Map Peak indices to frequencies
  float[] freqs = new float[3];
  for (int p = 0; p < 3; p++) {   
    colorMode(HSB, max_freq, 1.0, max_a);
    freqs[p] = fft.indexToFreq(peaks[p]); 
    //Map freqs to colours
    //print(freqs[p]+", ");
    //print(0.5+", ");
    //println(fft.getBand(peaks[0]));
    peak_cols[p] = color(freqs[p], 0.5, fft.getBand(peaks[0]));
    //println("Hue : "+hue(peak_cols[p]));
    //println("Saturation : "+saturation(peak_cols[p]));
    //println("Brightness : "+brightness(peak_cols[p]));
    //colorMode(RGB,255,255,255);
    //println("Red : "+red(peak_cols[p]));
    //println("Green : "+green(peak_cols[p]));
    //println("Blue : "+blue(peak_cols[p]));
  }
  
  //print(peak_cols[0]+", ");
  //print(peak_cols[1]+", ");
  //println(peak_cols[2]);
  
  return peak_cols;
}