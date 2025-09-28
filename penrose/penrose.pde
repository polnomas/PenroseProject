void setup() {
    size(1200, 800);
    initLetters();
    initValues();
    initColors();
    frameRate(60);
    if (!show) {
        generateTiling();
        scale(height / 2, height / 2);
        strokeWeight(1.5 / height);
        // for (Tile t : tiles) {
        //     t.drawStyled();
        // }
        // noLoop();
    }
    // iterations = 0;
}
void draw() {
    scale(height / 2, height / 2);
    strokeWeight(1.5 / height);
    for (Tile t : tiles) {
        t.drawRainbow();
    }
}
