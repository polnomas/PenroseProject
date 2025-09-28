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