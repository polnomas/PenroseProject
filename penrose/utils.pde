ArrayList<Triangle> getSuccs() {
    ArrayList<Triangle> aux = new ArrayList<Triangle>();
    for (Triangle t : triangles) {
        for (Triangle succ : t.succ()) {
            if (succ.nearWindow()) aux.add(succ);
        }
    }      
    return aux;
}

void generateTiling() {
    //searchStep
    ArrayList<Triangle> succs = getSuccs();
    while (!succs.isEmpty()) {
        triangles = succs;
        succs = getSuccs();
    }
    while (!triangles.isEmpty()) {
        Triangle current = triangles.remove(triangles.size() - 1);
        grid.add(current);
        Tile tile = current.generateTile();
        if (tile != null) tiles.add(tile);    
    }
}

void generateFrames() {
    for (int i = 0; i < 24*30; i++) {
        pg.beginDraw();
        pg.scale(height / 2, height / 2);
        pg.strokeWeight(1.5 / height);
        for (Tile t : tiles) {
            t.drawRainbow();
        }
        pg.endDraw();
        pg.save("frames/rainbow" + nf(i, 4) + ".png");
    }
}