void perlin_noise_colour(int[] r_stats,int[] g_stats, int[] b_stats) {  
  for (int i = 0; i < width*height; i++) {
      float n = random(0.005,0.030);
      r_pot[i] = int(r_stats[1]*noise(n) + r_stats[0]);
      g_pot[i] = int(g_stats[1]*noise(n) + g_stats[0]);
      b_pot[i] = int(b_stats[1]*noise(n) + b_stats[0]);
  }
}