float backgroundColor;
int backgroundSaturation;
int backgroundBrightness;
float lettersColor;
int lettersSaturation;
int lettersBrightness;
float arc1Color, arc2Color;
int arc1Saturation, arc2Saturation, arc1Brightness, arc2Brightness;

void initColors() {
    colorMode(HSB, 360, 100, 100);
    //Fondo
    backgroundColor = random(360);
    backgroundSaturation = 20;
    backgroundBrightness = 85;
    //Letras
    lettersColor = backgroundColor;
    lettersSaturation = 80;
    lettersBrightness = 80;
    arc1Color = backgroundColor + 90;
    arc2Color = backgroundColor - 18;
    arc1Saturation = backgroundSaturation;
    arc2Saturation = lettersSaturation - 30;
    arc1Brightness = backgroundBrightness;
    arc2Brightness = lettersBrightness + 20;
}