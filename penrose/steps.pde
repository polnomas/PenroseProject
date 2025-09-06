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
        return;
    }
    //Se ingresan los sucesores a la estructura principal para repetir
    triangles = aux;
    //Los dibujamos para mostrar el proceso
    background(0);
    for (Triangle t : triangles) {
        t.drawStructure();
    }
}
void matchStep() {
    if (triangles.isEmpty()) {
        noLoop();
        println("Kites:", kites, "Darts:", darts);
        return;
    }
    Triangle current = triangles.remove(triangles.size() - 1);
    grid.add(current);
    Tile tile = current.generateTile();
    if (tile != null) tiles.add(tile);
    background(0);
    for (Triangle t : triangles) {
        t.drawStructure();
    }
    for (Tile t : tiles) {
        t.drawTiling();
    }
    grid.drawUnmatched();
}