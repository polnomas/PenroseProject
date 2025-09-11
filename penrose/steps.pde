void searchStep() {
    ArrayList<Triangle> aux = new ArrayList<Triangle>();
    //Generamos recursivamente a los sucesores
    for (Triangle t : triangles) {
        for (Triangle succ : t.succ()) {
            //Agregamos solo los triangulos cercanos a la ventana para optimizar
            //Los demas no se veran, no valen la pena
            if (succ.nearWindow()) aux.add(succ);
        }
    }
    //Si no hay sucesores no se puede dividir mas y se pasa a la etapa de generacion de teselas
    if (aux.isEmpty()) {
        status = "tiles";
        frameRate(60);
        sortTriangles(triangles);
        background(0);
        for (Triangle t : triangles) {
            t.drawStructure();
        }
        return;
    }
    //Se ingresan los sucesores a la estructura principal para repetir
    triangles = aux;
    //Los dibujamos para mostrar el proceso
    if (show) {
        background(0);
        for (Triangle t : triangles) {
            t.drawStructure();
        }
    }
}
void matchStep() {
    if (triangles.isEmpty()) {
        // noLoop();
        println("Kites:", kites, "Darts:", darts);
        status = "style";
        for (Tile t : tiles) {
            t.drawTiling();
        }
        return;
    }
    Triangle current = triangles.remove(triangles.size() - 1);
    grid.add(current);
    Tile tile = current.generateTile();
    if (tile != null) tiles.add(tile);
    if (show) {
        background(0);
        for (Triangle t : triangles) {
            t.drawStructure();
        }
        for (Tile t : tiles) {
        t.drawTiling();
        }
        grid.drawUnmatched();
    }
}
void styleStep() {
    if (tiles.isEmpty()) {
        println("Finished");
        noLoop();
        // println("Kites:", kites, "Darts:", darts);
        saveFrame("jaime.png");
        for (Tile t : styledTiles) {
            t.drawStyled();
        }
        return;
    }
    Tile current = tiles.remove(tiles.size() - 1);
    if (current.intraMargin()) styledTiles.add(current);
    background(0);
    for (Tile t : tiles) {
        t.drawTiling();
    }
    for (Tile t : styledTiles) {
        t.drawStyled();
    }
}