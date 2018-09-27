void debug_window() {
    //***************************************************************************
  //Debug Window
  stroke(255);
  strokeWeight(1);
  fill(0);
  rectMode(CORNER);
  rect(debug1_xy[0], debug1_xy[1], debug1_xy[2], debug1_xy[3]);
  rect(debug2_xy[0], debug2_xy[1], debug2_xy[2], debug2_xy[3]);
  rect(debug3_xy[0], debug3_xy[1], debug3_xy[2], debug3_xy[3]);

  //Put Spectrum in debug1  
  float max_a = 1.0;
  for (int i=0; i < fft_debug.avgSize(); i++) {    
    float a = fft_debug.getAvg(i);
    fft_debug_buffer_next[i] = fft_debug_buffer_next[i] + a;
    if (a >= max_a) { max_a = a;}
    a = map(a, 0.0,max_a,0,debug_height/3);    
    fill(0);
    point( i, debug1_xy[3]-a );    
  }
  //Put Frequency Differential of spectrum in debug2
  float max_dadf = 1.0;
  for (int i=1; i < fft_debug.avgSize(); i++) {    
    float dadf = fft_debug.getAvg(i-1) - fft_debug.getAvg(i);
    if (abs(dadf) >= max_dadf) { max_dadf = abs(dadf);}
    dadf = map(dadf, -max_dadf, max_dadf, -debug_height/6, debug_height/6);
    fill(0);
    point( i, debug2_xy[1]+debug_height/6-dadf);//, i, debug2_xy[3]-dadf );    
  }
    
  //Put Time Differential of spectrum in debug3
  if (debug_buffer_count == debug_buffer_size) {
      fft_debug_buffer = fft_debug_buffer_next;
      //println(fft_debug_buffer_next);
      fft_debug_buffer_next = new float[debug_width];
      debug_buffer_count = 0;
  }
  else {   debug_buffer_count++; }
  for (int i=0; i < fft_debug.avgSize(); i++) {        
    float max_dadt = 1.0;
    float dadt = (fft_debug_buffer[i]/debug_buffer_size) - fft_debug.getAvg(i);
    println(dadt);
    if (abs(dadt) >= max_dadt) { max_dadt = abs(dadt);}
    dadt = map(dadt, -max_dadt, max_dadt, -debug_height/6, debug_height/6);
    fill(0);
    point( i, debug3_xy[1]+debug_height/6-dadt);    
  }
}