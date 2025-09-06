float l, phi, tolerableError, squareSize, w, h;
float[] phiPowers, phiInversePowers;
PVector[] notableRotations;
ArrayList<Triangle> triangles;
ArrayList<Triangle> matched;
PVector disp;
String status;
CollisionChecker grid;
int iterations;
class HalfEdge {
    PVector v0, v1;
    Polygon owner;
    HalfEdge match;

    HalfEdge(PVector v0, PVector v1, Polygon owner) {
        this.v0 = v0.copy();
        this.v1 = v1.copy();
        this.owner = owner;
        this.match = null;
    }
    void drawStructure() {
        stroke(125, 125, 125);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    void tileDraw() {
        stroke(255);
        if (this.match != null) return;
        line(v0.x, v0.y, v1.x, v1.y);
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
}
class Triangle extends Polygon{
    boolean reflected;
    int phiPowerOfLargest;
    float minX;
    float maxX;
    float minY;
    float maxY;
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
    //Revisa si la ventana y el triangulo estan suficientemente cerca
    boolean nearWindow() {
        return this.inWindow() || this.windowIn();
    }
    void countMatches() {
        int matches = 0;
        for (HalfEdge e : this.edges) {
            if (e.match != null) matches++;
        }
    }
    //Dibuja las teselas resultantes en un color más fuerte
    void tileDraw() {
        for (HalfEdge e : this.edges) {
            e.tileDraw();
        }
        this.countMatches();
    }
}
class CollisionChecker {
    ArrayList<ArrayList<ArrayList<Triangle>>> grid;
    int wGrid;
    int hGrid;
    CollisionChecker() {
        //discretiza el plano en casillas de l x l aprox
        this.wGrid = floor(w/l);
        this.hGrid = floor(h/l);
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
    }
    int[][] triangleGridRectangle(Triangle a) {
        //Discretiza las coordenadas del triangulo para ubicar en las casillas.
        return new int[][] {
            {
                max(floor(a.minX/l), 0),
                min(floor(a.maxX/l), this.wGrid - 1)
            },
            {
                max(floor(a.minY/l), 0),
                min(floor(a.maxY/l), this.hGrid - 1)
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
                }
                this.grid.get(i).get(j).add(a);
            }
        }
    }
    void add(Triangle a) {
        //Calcula las casillas que toca
        int[][] rectangle = this.triangleGridRectangle(a);
        //Agrega al triangulo a las casillas que le corresponde
        this.linkTriangleToGrid(a, rectangle);
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
void initValues() {
    //La relacion es 2:3 pero se podría cambiar
    w = 1.5;
    h = 1;
    //Tamaño del lado más corto en las teselas objetivo
    l = 0.03444;
    phi = (1 + sqrt(5)) / 2;
    tolerableError = 1e-6;
    //La ventana estará dentro de un cuadrado más grande y podría ubicarse dentro de cualquier punto dentro de él
    squareSize = pow(phi, 4) * h;
    //Rotaciones precalculadas para optimizar
    notableRotations = new PVector[20];
    notableRotations[0] = new PVector(l, 0);
    for (int i = 1; i < 20; i++) {
        notableRotations[i] = notableRotations[0].copy().rotate((TWO_PI/20) * i);
    }
    //Elegimos un triángulo semilla al azar copn las mismas probabilidades
    String firstTriangleType = random(1) < 0.5 ? "acute" : "obtuse";
    //Este angulo sirve para calcular la ubicaciones de la ventana
    float angle = "acute".equals(firstTriangleType) ? (TWO_PI/5) : (TWO_PI/10);
    //Calculamos cuántas potencias de phi veces debe multiplicarse l para generar un triangulo que encierre al cuadrado
    int d = round(log((squareSize/l) * ((2/tan(angle)) + 1)) / log(phi));
    //Ajuste segun el tipo de triángulo
    if ("acute".equals(firstTriangleType)) d++;
    //Potencias de phi precalculadas
    phiPowers = new float[d + 1];
    phiPowers[0] = 1;
    for (int i = 1; i <= d; i++) {
        phiPowers[i] = pow(phi, i);
    }
    //Desplazamiento de la ventana respecto al cuadrado que la encierra
    //La pondero por menos uno porque al final el origen esta en una esquina de la ventana, no del cuadrado
    disp = new PVector(random(squareSize - w), random(squareSize - h)).mult(-1);
    //La posicion del triangulo semilla es su posicion respecto al cuadrado menos la del cuadrado respecto de la ventan
    //Estamos desplazando el triángulo para que el punto de referencia sea el origen en la ventana
    PVector tPos = new PVector(-1 * squareSize * tan(angle) / 2, squareSize / 2).add(disp);
    //Arreglo de triangulos, son el esqueleto del teselado
    triangles = new ArrayList<Triangle>();
    //Agregamos la semilla
    triangles.add(new Triangle(tPos, 0, firstTriangleType, random(1) < 0.5, d));
    //El primer paso es el de generar triangulos
    status = "triangules";
    //Estructuras para la etapa de generación de teselas
    matched = new ArrayList<Triangle>();
    grid = new CollisionChecker();
}
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
        return;
    }
    Triangle current = triangles.remove(triangles.size() - 1);
    grid.add(current);
    matched.add(current);
    background(0);
    for (Triangle t : triangles) {
        t.drawStructure();
    }
    for (Triangle t : matched) {
        t.tileDraw();
    }
}
void setup() {
    size(1200, 800);
    initValues();
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
    // fill(255);
    // rect(disp.x, disp.y, squareSize, squareSize);
    // rect(0, 0, w, h);
}
