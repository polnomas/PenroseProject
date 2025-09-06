class HalfEdge {
    PVector v0, v1;
    Polygon owner;
    HalfEdge match;
    float m, n; // y = mx + n
    boolean vertical;
    HalfEdge(PVector v0, PVector v1, Polygon owner) {
        this.v0 = v0.copy();
        this.v1 = v1.copy();
        this.owner = owner;
        this.match = null;
        if (eqFloats(v0.x, v1.x)) {
            this.vertical = true;
            this.m = Float.POSITIVE_INFINITY;
            this.n = Float.POSITIVE_INFINITY;
            return;
        }
        this.vertical = false;
        this.m = (this.v0.y - this.v1.y) / (this.v0.x - this.v1.x);
        this.n = this.v0.y - this.m * this.v0.x;
    }
    void drawStructure() {
        stroke(125, 125, 125);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    void drawTiling() {
        stroke(255);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    void drawUnmatched() {
        stroke(255, 0, 0);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    boolean onHERange(PVector a) {
        float minX = min(this.v0.x, this.v1.x) - tolerableError;
        float maxX = max(this.v0.x, this.v1.x) + tolerableError;
        float minY = min(this.v0.y, this.v1.y) - tolerableError;
        float maxY = max(this.v0.y, this.v1.y) + tolerableError;
        boolean onX =  minX <= a.x && a.x <= maxX;
        boolean onY =  minY <= a.y && a.y <= maxY;
        return onX && onY;
    }
    boolean onTheLine(PVector a) {
        return (eqFloats(a.y, this.m * a.x + this.n));
    }
    boolean belongs(PVector a) {
        return this.onHERange(a) && this.onTheLine(a);
    }
}
class Polygon {
    PVector position;
    int rotation;
    PVector[] vertices;
    HalfEdge[] edges;
    String type;
    Polygon (PVector position, int rotation, String type) {
        this.position = position.copy();
        this.rotation = rotation;
        this.type = type;
        //Si no es un triángulo es una tesela
        this.vertices = new PVector["acute".equals(type) || "obtuse".equals(type) ? 3 : 4];
        this.edges = new HalfEdge["acute".equals(type) || "obtuse".equals(type) ? 3 : 4];
    }
    //Dibuja el esqueleto con un color claro (triángulos base)
    void drawStructure() {
        for (HalfEdge e : this.edges) {
            e.drawStructure();
        }
    }
    void drawUnmatched() {
        for (HalfEdge e : this.edges) {
            e.drawUnmatched();
        }
    }
}
class Triangle extends Polygon{
    boolean reflected;
    int phiPowerOfLargest;
    float minX;
    float maxX;
    float minY;
    float maxY;
    boolean expandedToTile;
    float centerDistance;
    Triangle(PVector position, int rotation, String type, boolean reflected, int phiPowerOfLargest) {
        super(position, rotation, type);
        this.phiPowerOfLargest = phiPowerOfLargest;
        this.reflected = reflected;
        this.calculateTriangle();
        //Calcula coordenadas extremas para cuadrilatero que lo encierra
        float xValues[] = new float[3];
        float yValues[] = new float[3];
        int i = 0;
        for (PVector v : this.vertices) {
            xValues[i] = v.x;
            yValues[i] = v.y;
            i++;
        }
        this.minX = min(xValues);
        this.maxX = max(xValues);
        this.minY = min(yValues);
        this.maxY = max(yValues);
        this.expandedToTile = false;
        this.centerDistance = PVector.sub(new PVector(minX + maxX, minY + maxY).mult(0.5), new PVector(w/2, h/2)).mag();
    }
    //Calcula los vertices del nuevo triangulo
    void calculateTriangle() {
        //Angulo en su vértice 0
        int baseAngle = "acute".equals(this.type) ? 1 : 3;
        //Si es obtuso se dibuja usando su lado más corto
        int realPower = "obtuse".equals(this.type) ? this.phiPowerOfLargest - 1 : this.phiPowerOfLargest;
        //El vértice 0 se corresponde con la ubicación del triángulo
        this.vertices[0] = this.position.copy();
        //Se crean los vértices y aristas
        for (int i = 1; i < 3; i++) {
            this.vertices[i] = notableRotations[(20 + baseAngle * (2 * i - 3) + this.rotation) % 20].copy().mult(phiPowers[realPower]);
            this.vertices[i].add(this.position);
            this.edges[i - 1] = new HalfEdge(this.vertices[i - 1], this.vertices[i], this);
        }
        //La última va a quedar vacía así que se agrega manualmente
        this.edges[2] = new HalfEdge(this.vertices[2], this.vertices[0], this);
    }
    //Genera los sucesores del triángulo, la siguiente gerneración.
    ArrayList<Triangle> succ() {
        ArrayList<Triangle> succs = new ArrayList<Triangle>();
        //Si la potencia es 1 el lado pequeño es l, el tamaño objetivo, no hay que seguir expandiendo.
        if (this.phiPowerOfLargest == 1) return succs;
        if ("obtuse".equals(this.type)) {
            int accVertex = !this.reflected ? 1 : 2;
            int accRotation = !this.reflected ? 6 : 14;
            int obtPosRotation = !this.reflected ? 1 : 19;
            int obtRotation = !this.reflected ? 8 : 12;
            succs.add(
                new Triangle(this.vertices[accVertex],
                (accRotation + this.rotation) % 20,
                "acute",
                !this.reflected,
                this.phiPowerOfLargest - 1
                )
            );
            succs.add(
                new Triangle(PVector.add(this.vertices[0], notableRotations[(obtPosRotation + this.rotation) % 20].copy().mult(phiPowers[this.phiPowerOfLargest - 2])),
                (obtRotation + this.rotation) % 20,
                "obtuse",
                this.reflected,
                this.phiPowerOfLargest - 1
                )
            );
        }
        else {
            int obtPosRotation = !this.reflected ? 1 : 19;
            int obtRotation = !this.reflected ? 14 : 6;
            int accsVertex = !this.reflected ? 2 : 1;
            int acc0Rotation = !this.reflected ? 12 : 8;
            int acc1Rotation = !this.reflected ? 14 : 6;
            succs.add(
                new Triangle(
                    PVector.add(this.vertices[0], notableRotations[(obtPosRotation + this.rotation) % 20].copy().mult(phiPowers[this.phiPowerOfLargest - 2])),
                    (obtRotation + this.rotation) % 20,
                    "obtuse",
                    this.reflected,
                    this.phiPowerOfLargest - 1
                )
            );
            succs.add(
                new Triangle(
                    this.vertices[accsVertex],
                    (acc0Rotation + this.rotation) % 20,
                    "acute",
                    !this.reflected,
                    this.phiPowerOfLargest - 1
                )
            );
            succs.add(
                new Triangle(
                    this.vertices[accsVertex],
                    (acc1Rotation + this.rotation) % 20,
                    "acute",
                    this.reflected,
                    this.phiPowerOfLargest - 1
                )
            );
        }
        return succs;
    }
    //Revisa si algun vertice está dentro de la ventana
    boolean inWindow() {
        for (PVector v : this.vertices) {
            if ((v.x >= 0 && v.x <= w) && (v.y >= 0 && v.y <= h)) return true;
        }
        return false;
    }
    //Revisa si algun vertice de la ventana esta dentro del triangulo
    boolean windowIn() {
        for (PVector v : new PVector[] {new PVector(0, 0), new PVector(w, 0), new PVector(0, h), new PVector(w, h)}) {
            if ((v.x >= this.minX && v.x <= this.maxX) && (v.y >= this.minY && v.y <= this.maxY)) return true;
        }
        return false;
    }
    boolean intersectsWindow() {
        for (HalfEdge e : this.edges) {
            if (edgesIntersect(e, new HalfEdge(new PVector(0, 0), new PVector(w, 0), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(w, 0), new PVector(w, h), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(w, h), new PVector(0, h), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(0, h), new PVector(0, 0), null))) return true;
        }
        return false;
    }
    //Revisa si la ventana y el triangulo estan suficientemente cerca
    boolean nearWindow() {
        return this.inWindow() || this.windowIn() || this.intersectsWindow();
    }
    void countMatches() {
        int matches = 0;
        for (HalfEdge e : this.edges) {
            if (e.match != null) matches++;
        }
    }
    boolean matched() {
        if (!this.reflected && this.edges[0].match == null) return false;
        if (this.reflected && this.edges[2].match == null) return false;
        return true;
    }
    Tile generateTile() {
        if (!this.matched()) return null;
        if (this.expandedToTile) return null;
        this.expandedToTile = true;
        PVector tilePos = this.position;
        int tileRot;
        if ("acute".equals(this.type)) tileRot = !this.reflected ? (this.rotation + 19) % 20 : (this.rotation + 1) % 20;
        else tileRot = !this.reflected ? (this.rotation + 17) % 20 : (this.rotation + 3) % 20;
        String tileType = "acute".equals(this.type) ? "kite" : "dart";
        return new Tile(tilePos, tileRot, tileType);
    }
}
//Insertion Sort in place básico
void sortTriangles(ArrayList<Triangle> triangles) {
    int n = triangles.size();
    for (int i = 1 ; i < n; i++) {
        Triangle key = triangles.get(i);
        int j = i - 1;
        while (j >= 0 && - triangles.get(j).centerDistance > - key.centerDistance) {
            triangles.set(j + 1, triangles.get(j));
            j = j - 1;
        }
        triangles.set(j + 1, key);
    }
}
boolean edgesIntersect(HalfEdge a, HalfEdge b) {
    if (a.vertical && b.vertical) {
        if (!eqFloats(a.v0.x, b.v0.x)) return false;
        boolean aInB = (a.v0.y - min(b.v0.y, b.v1.y) >= tolerableError && (max(b.v0.y, b.v1.y) - a.v0.y >= tolerableError));
        boolean bInA = (b.v0.y - min(a.v0.y, a.v1.y) >= tolerableError && (max(a.v0.y, a.v1.y) - b.v0.y >= tolerableError));
        return aInB || bInA;
    }
    if (a.vertical || b.vertical) {
        HalfEdge vertical = a.vertical ? a : b;
        HalfEdge nonVertical = a.vertical ? b : a;
        float iX = vertical.v0.x;
        float iY = nonVertical.m * iX + nonVertical.n;
        boolean onVertical = iY - min(vertical.v0.y, vertical.v1.y) >= tolerableError && (max(vertical.v0.y, vertical.v1.y) - iY >= tolerableError);
        boolean onNonVertical = iX - min(nonVertical.v0.x, nonVertical.v1.x) >= tolerableError && (max(nonVertical.v0.x, nonVertical.v1.x) - iX >= tolerableError);
        return onVertical && onNonVertical;
    }
    if (eqFloats(a.m, b.m)) return a.belongs(b.v0) || a.belongs(b.v1) || b.belongs(a.v0) || b.belongs(a.v1);
    float iX = (a.n - b.n) / (b.m - a.m);
    float iY = a.m * iX + a.n;
    PVector intersection = new PVector(iX, iY);
    return a.onHERange(intersection) && b.onHERange(intersection);
}