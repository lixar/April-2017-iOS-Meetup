#include "elapsedMillis.h"
#include "thermistor-library.h"

const unsigned int THERMISTOR_PUBLISH_INTERVAL = 1000;
const unsigned int THERMISTOR_RESISTANCE = 10000;
const int THERMISTOR_PIN = A0;
Thermistor thermistor = Thermistor(THERMISTOR_PIN, THERMISTOR_RESISTANCE);
elapsedMillis thermistorPublishElapsed;

void setup() {
  pinMode(THERMISTOR_PIN, INPUT);
  thermistor.begin();
}

void loop() {
  if (thermistorPublishElapsed > THERMISTOR_PUBLISH_INTERVAL) {
    publishTemperatureChange();
    thermistorPublishElapsed = 0;
  }
}


//Publish
void publishTemperatureChange() {
  Particle.publish("temperature_changed", formattedTemperature(), 60, PRIVATE);
}


//Helpers
String formattedTemperature() {
  return String(thermistor.getTempC(), 2);
}
