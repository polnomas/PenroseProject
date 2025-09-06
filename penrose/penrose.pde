void setup() {
    size(1200, 800);
    initValues();
    initLetters();
    frameRate(60);
    // iterations = 0;
}
void draw() {
    // scale(height, height);
    // strokeWeight(1.5 / height);
    // translate(600, 400);
    scale(height, height);
    strokeWeight(1.5 / height);
    if ("triangules".equals(status)) {
        searchStep();
        // saveFrame("frames/triangles_#####.png");
    }
    else if ("tiles".equals(status)) {
        matchStep();
        // saveFrame("frames/tiles_#####.png");
    }
    else if ("style".equals(status)) {
        styleStep();
        // saveFrame("frames/styled_#####.png");
    }
    saveFrame("frames/test_#####.png");
    // fill(255);
    // rect(disp.x, disp.y, squareSize, squareSize);
    // rect(0, 0, w, h);
}
