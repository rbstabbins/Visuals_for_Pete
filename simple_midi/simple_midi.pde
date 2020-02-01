// Simple Midi test for Korg Nano Kontrol
// Listen for MIDI messages and print to console

// draw a bar for each midi dial

import themidibus.*; // Import midibus library

MidiBus myBus; // The MidiBus object

//float cc0 = 0.0; // Slider 1
//float cc1 = 0.0; // Slider 2
//float cc2 = 0.0; // Slider 3
//float cc3 = 0.0; // Slider 4
//float cc4 = 0.0; // Slider 5
//float cc5 = 0.0; // Slider 6
//float cc6 = 0.0; // Slider 7
//float cc7 = 0.0; // Slider 8
//float cc16 = 0.0; // Dial 1
//float cc17 = 0.0; // Dial 2
//float cc18 = 0.0; // Dial 3
//float cc19 = 0.0; // Dial 4
//float cc20 = 0.0; // Dial 5
//float cc21 = 0.0; // Dial 6
//float cc22 = 0.0; // Dial 7
//float cc23 = 0.0; // Dial 8
float w; 
float [] cc  = new float[16];

void setup() {
  
  // basic window
  size(400,400);
  background(0);
  
  MidiBus.list(); // List all available buses
   
  myBus = new MidiBus(this, 1, -1); // Attaches midi bus to channel 1 for input, and leaves off output
    
}

void draw() {
  
  // listen for changes only
  rectMode(CORNERS);
  w = width / 16;
  for (int i = 0; i < 16 ; i=i+1) {
      fill(255);
      rect( i * w, 0, (i+1) * w, map(cc[i], 0, 127, 0, height)); // draw the rectangle
  }
  
}

void controllerChange(int channel, int number, int value) {
   //Recieve Controller change
  println();
  println("Controller Change:");
  println("----------");
  println("Channel:"+channel);
  println("Number:"+number);
  println("Value:"+value);
  
  //if (number == 16) {
  //  cc1 = value;
  //}  
  
  cc[number] = value;
  
  //switch(number) {
  //  case 0:
  //    cc0 = value;
  //    break;
  //  case 1:
  //    cc1 = value;
  //    break;
  //  case 2:
  //    cc2 = value;
  //    break;
  //  case 3:
  //    cc3 = value;
  //    break;
  //  case 4:
  //    cc4 = value;
  //    break;
  //  case 5:
  //    cc5 = value;
  //    break;
  //  case 6:
  //    cc6 = value;
  //    break;
  //  case 7:
  //    cc7 = value;
  //    break;
  //  case 16:
  //    cc16 = value;
  //    break;
  //  case 17:
  //    cc17 = value;
  //    break;
  //  case 18:
  //    cc18 = value;
  //    break;
  //  case 19:
  //    cc19 = value;
  //    break;
  //  case 20:
  //    cc20 = value;
  //    break;
  //  case 21:
  //    cc21 = value;
  //    break;
  //  case 22:
  //    cc22 = value;
  //    break;
  //  case 23:
  //    cc23 = value;
  //    break;
  //}
}