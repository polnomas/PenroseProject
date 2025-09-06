class CollisionChecker {
    ArrayList<ArrayList<ArrayList<Triangle>>> grid;
    int wGrid;
    int hGrid;
    ArrayList<Triangle> unMatched;
    CollisionChecker() {
        //discretiza el plano en casillas de l x l aprox
        this.wGrid = floor(w/l) + 1;
        this.hGrid = floor(h/l) + 1;
        // println("grid size", this.wGrid, this.hGrid);
        //Filas
        this.grid = new ArrayList<ArrayList<ArrayList<Triangle>>>(this.hGrid);
        for (int i = 0; i < this.hGrid; i++) {
            //Columnas
            this.grid.add(new ArrayList<ArrayList<Triangle>>(this.wGrid));
            for (int j = 0; j < this.wGrid; j++) {
                //En cada casilla va una lista de triangulos que la tocan
                this.grid.get(i).add(new ArrayList<Triangle>());
            }
        }
        this.unMatched = new ArrayList<Triangle>();
    }
    int[][] triangleGridRectangle(Triangle a) {
        //Discretiza las coordenadas del triangulo para ubicar en las casillas.
        return new int[][] {
            {
                max(floor(a.minX/l) - 1, 0),
                min(floor(a.maxX/l) + 1, this.wGrid - 1)
            },
            {
                max(floor(a.minY/l) - 1, 0),
                min(floor(a.maxY/l) + 1, this.hGrid - 1)
            }
        };
    }
    void linkTriangleToGrid(Triangle a, int[][] gridRectangle) {
        // println(gridRectangle[1][0], gridRectangle[1][1], gridRectangle[0][0], gridRectangle[0][1]);
        //Agrega al triangulo en las casillas que toca, emparejando aristas si hay match
        for (int i = gridRectangle[1][0]; i <= gridRectangle[1][1]; i++) {
            for (int j = gridRectangle[0][0]; j <= gridRectangle[0][1]; j++) {
                for (Triangle t : this.grid.get(i).get(j)) {
                    matchTriangles(a, t);
                    if (a.matched()) {
                        this.unMatched.remove(t);
                        return;
                    }
                }
                this.grid.get(i).get(j).add(a);
            }
        }
        this.unMatched.add(a);
    }
    void add(Triangle a) {
        //Calcula las casillas que toca
        int[][] rectangle = this.triangleGridRectangle(a);
        //Agrega al triangulo a las casillas que le corresponde
        this.linkTriangleToGrid(a, rectangle);
    }
    void drawUnmatched() {
        // println("Unmatched triangles:", this.unMatched.size());
        for (Triangle t : this.unMatched) {
            // println("Unmatched triangle at", t.position);
            t.drawUnmatched();
        }
    }
}
void matchTriangles(Triangle a, Triangle b) {
    //Si son del mismo tipo y son reflejo uno del otro
    if (a.type.equals(b.type) && a.reflected != b.reflected) {
        int aIndex;
        int bIndex;
        if (!a.reflected && b.reflected) {
            //Deben hacer match av0 y bv2
            aIndex = 0;
            bIndex = 2;
        }
        else {
            //Deben hacer match av2 y bv0
            aIndex = 2;
            bIndex = 0;
        }//No hay otro caso porque confirmamos que son reflejos
        //Si no coinciden, no se hace match
        if (!itsAMatch(a.edges[aIndex], b.edges[bIndex])) return;
        makeMatch(a.edges[aIndex], b.edges[bIndex]);
    }
    //En cualquier otro caso no se hace nada porque no forman tesela
}
boolean itsAMatch(HalfEdge a, HalfEdge b) {
    if (a.match == null && b.match == null) {
        //Deben coincidir ya sea entre vertices del mismo tipo u opuestos
        if ((eqVectors(a.v0, b.v0) && eqVectors(a.v1, b.v1)) || (eqVectors(a.v0, b.v1) && eqVectors(a.v1, b.v0))){
            return true;
        }
    }
    //Si ya tienen match, no pueden coincidir
    return false;
}
void makeMatch(HalfEdge a, HalfEdge b) {
    //Si alguno ya tiene match no deberían poder coincidir
    if (a.match != null || b.match != null) return;
    a.match = b;
    b.match = a;
}
boolean eqVectors(PVector a, PVector b) {
    return eqFloats(a.x, b.x) && eqFloats(a.y, b.y);
}
boolean eqFloats(float a, float b) {
    //Debe haber cierta tolerancia al error por cómo funcionan los float
    if (a >= b) return a - b <= tolerableError;
    return b - a <= tolerableError;
}