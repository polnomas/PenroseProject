PGraphics pg;

void setup() {
    size(1920, 1280);
    initLetters();
    initValues();
    initColors();
    frameRate(24);
    if (!show) {
        generateTiling();
        scale(height / 2, height / 2);
        strokeWeight(1.5 / height);
        // for (Tile t : tiles) {
        //     t.drawStyled();
        // }
        // noLoop();
    }
    pg = createGraphics(width, height);
    generateFrames();
    noLoop();
    exit();
    // iterations = 0;
}
void draw() {
    scale(height / 2, height / 2);
    strokeWeight(1.5 / height);
    for (Tile t : tiles) {
        t.drawRainbow();
    }
    saveFrame("frames/rainbow-####.png");
    if (frameCount > 24*30) {
        exit();
    }
}
