void setup() {
    size(1200, 800);
    initLetters();
    initValues();
    initColors();
    frameRate(60);
    boolean next = true;
    while (next && !show) {
        if ("triangules".equals(status)) {
            // println("a");
            searchStep();
            // saveFrame("frames/triangles_#####.png");
        }
        else if ("tiles".equals(status)) {
            // println("b");
            matchStep();
            // saveFrame("frames/tiles_#####.png");
        }
        else if ("style".equals(status)) {
            // println("c");
            styleStep();
            if (tiles.isEmpty()) {
                next = false;
            }
            // saveFrame("frames/styled_#####.png");
        }
    }
    // iterations = 0;
}
void draw() {
    // scale(height, height);
    // strokeWeight(1.5 / height);
    // translate(600, 400);
    scale(height / 2, height / 2);
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
    // saveFrame("frames/test_#####.png");
    // fill(255);
    // rect(disp.x, disp.y, squareSize, squareSize);
    // rect(0, 0, w, h);
}
