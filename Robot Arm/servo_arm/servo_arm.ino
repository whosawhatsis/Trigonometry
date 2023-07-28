#include <Arduino.h>

//Calibrated angle offsets for each servo:
#define BASE_OFFSET 0.0f
#define SHOULDER_OFFSET 1.0f
#define ELBOW_OFFSET 1.0f

//Lengths:
#define BICEP 50
#define FOREARM 50

#define SQUARESIZE 65

//Servo hardware abstraction:
#define BASE_PIN 0
#define SHOULDER_PIN 1
#define ELBOW_PIN 2
#define USE_PCA9685_SERVO_EXPANDER //used by ServoEasing.hpp
#include "ServoEasing.hpp"
class aServo {
  ServoEasing thisServo;
  public:
    aServo() {
      thisServo = ServoEasing(PCA9685_DEFAULT_ADDRESS);
    }
    void go(float angle) {
      thisServo.setEaseTo(angle);
    }
    void setup(int pin, float offset) {
      thisServo.setEasingType(EASE_CUBIC_IN_OUT);
      thisServo.setSpeed(500);
      thisServo.attach(pin);
      go(90);
    }
};
void syncServos() {
  //Add a delay here for libraries without a wait function
  synchronizeAllServosStartAndWaitForAllServosToStop();
}
//End servo hardware abstraction

float r2d(float r) {return r * 180 / PI;}
float d2r(float d) {return d * PI / 180;}

aServo base;
aServo shoulder;
aServo elbow;

void cartesian(float x, float y, float z) {
  float r = sqrt(pow(x, 2) + pow(y, 2) + pow(z, 2));
  float theta = r2d(atan2(y, x));
  float phi = r2d(acos(z / r));

  Serial.print("r = ");
  Serial.println(r);
  Serial.print("theta = ");
  Serial.println(theta);
  Serial.print("phi = ");
  Serial.println(phi);

  //law of cosines, C = acos((a^2 + b^2 - c^2) / 2ab)
  float elbow_a = acos((pow(BICEP, 2) + pow(FOREARM, 2) - pow(r, 2)) / (2 * BICEP * FOREARM));
  //law of sines, A = asin(a sin(B) / b)
  float shoulder_a_adjust = r2d(asin(FOREARM * sin(elbow_a) / r));
  elbow_a = r2d(elbow_a) - 180;

  Serial.print("elbow = ");
  Serial.println(elbow_a);

  if(theta < 0) {
    theta += 180;
    phi *= -1;
    elbow_a *= -1;
    shoulder_a_adjust *= -1;
  }

  base.go(theta);
  shoulder.go(90 - phi + shoulder_a_adjust);
  elbow.go(90 - elbow_a);
  syncServos();
}

void setup() {
  Serial.begin(9600);
  base.setup(BASE_PIN, BASE_OFFSET);
  shoulder.setup(SHOULDER_PIN, SHOULDER_OFFSET);
  elbow.setup(ELBOW_PIN, ELBOW_OFFSET);
  delay(500);
}

void loop() {
  for(int i = -SQUARESIZE; i <= SQUARESIZE; i += 2) {
      cartesian(i, -SQUARESIZE, -30);
  }
  for(int i = -SQUARESIZE; i <= SQUARESIZE; i += 2) {
      cartesian(SQUARESIZE, i, -30);
  }
  for(int i = -SQUARESIZE; i <= SQUARESIZE; i += 2) {
      cartesian(-i, SQUARESIZE, -30);
  }
  for(int i = -SQUARESIZE; i <= SQUARESIZE; i += 2) {
      cartesian(-SQUARESIZE, -i, -30);
  }
}
