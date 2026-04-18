#include <ESP8266WiFi.h>
#include <FirebaseESP8266.h>
#include <FastLED.h>

// ==========================================
// USER CONFIGURATION (ENTER YOUR DETAILS)
// ==========================================
#define WIFI_SSID "YOUR_WIFI_SSID"
#define WIFI_PASSWORD "YOUR_WIFI_PASSWORD"
#define FIREBASE_HOST "YOUR_FIREBASE_DATABASE_URL"
#define FIREBASE_AUTH "YOUR_FIREBASE_DATABASE_SECRET"

// ==========================================
// HARDWARE CONFIGURATION
// ==========================================
#define LED_PIN     4     // D4 on Wemos D1 Mini / NodeMCU
#define NUM_LEDS    60    
#define LED_TYPE    WS2812B
#define COLOR_ORDER GRB

CRGB leds[NUM_LEDS];
FirebaseData fbdo;

// State Variables
bool isPowered = false;
int globalBrightness = 255;
String currentMode = "pixel";
String activeAnimation = "solid custom";
String colorMode = "multi";
long activeColorHex = 0x00FFCC;

unsigned long sendDataPrevMillis = 0;

void setup() {
  Serial.begin(115200);
  FastLED.addLeds<LED_TYPE, LED_PIN, COLOR_ORDER>(leds, NUM_LEDS).setCorrection(TypicalLEDStrip);
  FastLED.setBrightness(255);

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println("\nConnected to Wi-Fi!");

  Firebase.begin(FIREBASE_HOST, FIREBASE_AUTH);
  Firebase.reconnectWiFi(true);
}

void loop() {
  if (Firebase.ready() && (millis() - sendDataPrevMillis > 500 || sendDataPrevMillis == 0)) {
    sendDataPrevMillis = millis();
    
    if(Firebase.getBool(fbdo, "/aurora/state/isPowered")) isPowered = fbdo.boolData();
    if(Firebase.getInt(fbdo, "/aurora/state/brightness")) globalBrightness = map(fbdo.intData(), 0, 100, 0, 255);
    if(Firebase.getString(fbdo, "/aurora/state/mode")) currentMode = fbdo.stringData();
    if(Firebase.getString(fbdo, "/aurora/state/activeAnimation")) activeAnimation = fbdo.stringData();
    if(Firebase.getString(fbdo, "/aurora/state/colorMode")) colorMode = fbdo.stringData();
    if(Firebase.getInt(fbdo, "/aurora/state/activeColorHex")) activeColorHex = fbdo.intData();
  }

  if (!isPowered) {
    FastLED.clear();
    FastLED.show();
    return;
  }

  FastLED.setBrightness(globalBrightness);
  activeAnimation.toLowerCase();

  // HIGH LEVEL FASTLED ENGINE
  if (activeAnimation == "solid custom") {
    CRGB color = CRGB(activeColorHex);
    if(colorMode == "multi") fill_rainbow(leds, NUM_LEDS, millis() / 20, 7);
    else fill_solid(leds, NUM_LEDS, color);
  } 
  else if (activeAnimation == "meteor shower") {
    fadeToBlackBy(leds, NUM_LEDS, 40);
    int pos = beatsin16(20, 0, NUM_LEDS - 1);
    leds[pos] += (colorMode == "multi") ? CHSV(millis() / 10, 255, 255) : CRGB(activeColorHex);
  }
  else if (activeAnimation == "aurora borealis") {
    for (int i = 0; i < NUM_LEDS; i++) {
      uint8_t index = inoise8(i * 20, millis() / 5);
      leds[i] = ColorFromPalette(OceanColors_p, index, 255, LINEARBLEND);
    }
  }
  else if (activeAnimation == "cyber sweep") {
    fadeToBlackBy(leds, NUM_LEDS, 20);
    int pos = beatsin16(30, 0, NUM_LEDS - 1);
    leds[pos] = CRGB(0, 255, 200); 
    if(pos > 0) leds[pos-1] = CRGB(0, 100, 80);
    if(pos < NUM_LEDS-1) leds[pos+1] = CRGB(0, 100, 80);
  }
  else if (activeAnimation == "matrix rain") {
    fadeToBlackBy(leds, NUM_LEDS, 60);
    if (random8() < 50) leds[random16(NUM_LEDS)] = CRGB::White;
    for(int i=0; i<NUM_LEDS; i++) {
        leds[i] %= 200; 
        if(leds[i].r < 20 && leds[i].g > 50) leds[i] = CRGB(0, 255, 0); 
    }
  }
  else {
    fill_rainbow(leds, NUM_LEDS, millis() / 10, 5);
  }

  FastLED.show();
  delay(10); 
}
