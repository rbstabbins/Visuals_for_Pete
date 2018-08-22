void gauss_noise_colour(int[] r_stats,int[] g_stats, int[] b_stats) {  
  for (int i = 0; i < width*height; i++) {
      r_pot[i] = int(r_stats[1]*randomGaussian() + r_stats[0]);
      g_pot[i] = int(g_stats[1]*randomGaussian() + g_stats[0]);
      b_pot[i] = int(b_stats[1]*randomGaussian() + b_stats[0]);
  }
}