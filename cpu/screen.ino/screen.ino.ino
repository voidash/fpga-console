#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

#define SCREEN_WIDTH 128 // OLED display width, in pixels
#define SCREEN_HEIGHT 64 // OLED display height, in pixels

// Declaration for an SSD1306 display connected to I2C (SDA, SCL pins)
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, -1);


void setup() {
  Serial.begin(115200);

  if(!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) { // Address 0x3D for 128x64
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  delay(2000);
  display.clearDisplay();

  display.setTextSize(1);
  display.setTextColor(WHITE);
  display.setCursor(0, 0);
  // Display static text
  display.println("Hello, nepal!");
  display.display(); 
}

void loop() {
if (Serial.available()) {
    String message = Serial.readStringUntil('\n');
    message.trim();

    // Check the message type and parameters
    if (message.startsWith("rect")) {
      // Parse the rectangle parameters
      int fi = message.indexOf(' ');
      // int x = message.substring(5, fi).toInt();
      int si = message.indexOf(' ', fi) + 1;
      int x = message.substring(si, message.indexOf(' ',si)).toInt();
      int ti = message.indexOf(' ',si) +1;
      int y = message.substring(ti, message.indexOf(' ', ti)).toInt();
      int ji = message.indexOf(' ',ti)+1;
      int w = message.substring(ji, message.indexOf(' ', ji)).toInt();
      int h = message.substring(message.lastIndexOf(' ')).toInt();

      Serial.println(x);
      Serial.println(y);
      Serial.println(w);
      Serial.println(h);

      // Draw the rectangle
      display.drawRect(x, y, w, h,WHITE);
    }
    else if (message.startsWith("circ")) {
      // Parse the circle parameters
      int fi = message.indexOf(' ');
      // int x = message.substring(5, fi).toInt();
      int si = message.indexOf(' ', fi) + 1;
      int x = message.substring(si, message.indexOf(' ',si)).toInt();
      int ti = message.indexOf(' ',si) +1;
      int y = message.substring(ti, message.indexOf(' ', ti)).toInt();
      int r = message.substring(message.lastIndexOf(' ')).toInt();

      Serial.println(x);
      Serial.println(y);
      Serial.println(r);
      // Draw the circle
      display.drawCircle(x, y, r,WHITE);
    }
    else if (message == "clear") {
      // Clear the screen
      display.clearDisplay();
    }
  }
  
 
  display.display();
}