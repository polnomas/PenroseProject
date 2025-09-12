color mainColor;
color negativeColor;

void initColors() {
    colorMode(HSB, 360, 100, 100);
    mainColor = color(random(360), 35, 90);
    negativeColor = color((hue(mainColor) + 50) % 360, 90, 35);
    // negativeColor = color(hue(mainColor), 90, 35);
}