void perlin_noise_colour(int[] r_stats,int[] g_stats, int[] b_stats) {  
  for (int i = 0; i < width*height; i++) {
      float rn = random(0.0,1.0);
      float gn = random(0.0,1.0);
      float bn = random(0.0,1.0);
      r_pot[i] = int(2*r_stats[1]*(noise(rn)-0.5) + r_stats[0]) ;;
      g_pot[i] = int(2*g_stats[1]*(noise(gn)-0.5) + g_stats[0]) ;;
      b_pot[i] = int(2*b_stats[1]*(noise(bn)-0.5) + b_stats[0]) ;
    }
  }