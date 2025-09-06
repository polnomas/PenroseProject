import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class penrose extends PApplet {

public void setup() {
    
    initValues();
    initLetters();
    frameRate(60);
    // iterations = 0;
}
public void draw() {
    // scale(height, height);
    // strokeWeight(1.5 / height);
    // translate(600, 400);
    scale(height, height);
    strokeWeight(1.5f / height);
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
    public void drawStructure() {
        stroke(125, 125, 125);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    public void drawTiling() {
        stroke(255);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    public void drawUnmatched() {
        stroke(255, 0, 0);
        line(v0.x, v0.y, v1.x, v1.y);
    }
    public boolean onHERange(PVector a) {
        float minX = min(this.v0.x, this.v1.x) - tolerableError;
        float maxX = max(this.v0.x, this.v1.x) + tolerableError;
        float minY = min(this.v0.y, this.v1.y) - tolerableError;
        float maxY = max(this.v0.y, this.v1.y) + tolerableError;
        boolean onX =  minX <= a.x && a.x <= maxX;
        boolean onY =  minY <= a.y && a.y <= maxY;
        return onX && onY;
    }
    public boolean onTheLine(PVector a) {
        return (eqFloats(a.y, this.m * a.x + this.n));
    }
    public boolean belongs(PVector a) {
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
    public void drawStructure() {
        for (HalfEdge e : this.edges) {
            e.drawStructure();
        }
    }
    public void drawUnmatched() {
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
        this.centerDistance = PVector.sub(new PVector(minX + maxX, minY + maxY).mult(0.5f), new PVector(w/2, h/2)).mag();
    }
    //Calcula los vertices del nuevo triangulo
    public void calculateTriangle() {
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
    public ArrayList<Triangle> succ() {
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
    public boolean inWindow() {
        for (PVector v : this.vertices) {
            if ((v.x >= 0 && v.x <= w) && (v.y >= 0 && v.y <= h)) return true;
        }
        return false;
    }
    //Revisa si algun vertice de la ventana esta dentro del triangulo
    public boolean windowIn() {
        for (PVector v : new PVector[] {new PVector(0, 0), new PVector(w, 0), new PVector(0, h), new PVector(w, h)}) {
            if ((v.x >= this.minX && v.x <= this.maxX) && (v.y >= this.minY && v.y <= this.maxY)) return true;
        }
        return false;
    }
    public boolean intersectsWindow() {
        for (HalfEdge e : this.edges) {
            if (edgesIntersect(e, new HalfEdge(new PVector(0, 0), new PVector(w, 0), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(w, 0), new PVector(w, h), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(w, h), new PVector(0, h), null))) return true;
            if (edgesIntersect(e, new HalfEdge(new PVector(0, h), new PVector(0, 0), null))) return true;
        }
        return false;
    }
    //Revisa si la ventana y el triangulo estan suficientemente cerca
    public boolean nearWindow() {
        return this.inWindow() || this.windowIn() || this.intersectsWindow();
    }
    public void countMatches() {
        int matches = 0;
        for (HalfEdge e : this.edges) {
            if (e.match != null) matches++;
        }
    }
    public boolean matched() {
        if (!this.reflected && this.edges[0].match == null) return false;
        if (this.reflected && this.edges[2].match == null) return false;
        return true;
    }
    public Tile generateTile() {
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
public void sortTriangles(ArrayList<Triangle> triangles) {
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
public boolean edgesIntersect(HalfEdge a, HalfEdge b) {
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
String word;
String[][] letters;
HashMap<Character, Integer> charToIndex;
LetterGrid mask;

class LetterGrid {
    int letterAmount, letterHeight, letterWidth, gridHeight, gridWidth;
    float boxWidth, boxHeight;
    int offsetX, offsetY;
    boolean[][] bitMap;
    LetterGrid() {
        word = word.toUpperCase();
        this.letterAmount = word.length();
        this.letterWidth = letters[0][0].length();
        this.letterHeight = letters[0].length;
        this.gridWidth = this.letterWidth * (this.letterAmount + 2) + (this.letterAmount - 1);
        this.gridHeight = round(2 * this.gridWidth / 3);
        this.boxWidth = w / this.gridWidth;
        this.boxHeight = h / this.gridHeight;
        this.offsetX = this.letterWidth;
        this.offsetY = floor((this.gridHeight - this.letterHeight) / 2);
        int wordRectangle[][] = {
            {this.offsetX, this.offsetX + this.letterWidth * this.letterAmount + (this.letterAmount - 1)},
            {this.offsetY, this.offsetY + this.letterHeight}
        };
        println(wordRectangle[0][0], wordRectangle[0][1], wordRectangle[1][0], wordRectangle[1][1]);
        String[] wordMap = new String[this.letterHeight];
        char[] charArray = word.toCharArray();
        for (int i = 0; i < this.letterHeight; i++) {
            wordMap[i] = "";
            for (int j = 0; j < charArray.length; j++) {
                wordMap[i] += letters[charToIndex.get(charArray[j])][i];
                wordMap[i] += j == charArray.length - 1 ? "" : "0";
            }
        }
        println(wordMap.length, wordMap[0].length());
        this.bitMap = new boolean[this.gridHeight][this.gridWidth];
        for (int i = 0; i < this.gridHeight; i++) {
            for (int j = 0; j < this.gridWidth; j++) {
                if (wordRectangle[0][0] <= j && j < wordRectangle[0][1] && wordRectangle[1][0] <= i && i < wordRectangle[1][1]) {
                    this.bitMap[i][j] = wordMap[i - this.offsetY].charAt(j - this.offsetX) == '1';
                }
                else {
                    this.bitMap[i][j] = false;
                }
            }
        }
        for (boolean[] row : this.bitMap) {
            for (boolean b : row) {
                print(b ? "# " : "  ");
            }
            print('\n');
        }
    }
    public boolean itsLetter(Tile tile) {
       int x = floor(tile.centroid.x / this.boxWidth);
       int y = floor(tile.centroid.y / this.boxHeight);
       if (x < 0 || x >= this.gridWidth || y < 0 || y >= this.gridHeight) return false;
       return this.bitMap[y][x];
    }
}

public void initLetters() {
    letters = new String[27][];
    letters[0] = new String[] {
        "1111",
        "1001",
        "1111",
        "1001",
        "1001"
    };
    letters[1] = new String[] {
        "1110",
        "1001",
        "1110",
        "1001",
        "1110"
    };
    letters[2] = new String[] {
        "1111",
        "1000",
        "1000",
        "1000",
        "1111"
    };
    letters[3] = new String[] {
        "1110",
        "1001",
        "1001",
        "1001",
        "1110"
    };
    letters[4] = new String[] {
        "1111",
        "1000",
        "1110",
        "1000",
        "1111"
    };
    letters[5] = new String[] {
        "1111",
        "1000",
        "1110",
        "1000",
        "1000"
    };
    letters[6] = new String[] {
        "0111",
        "1000",
        "1010",
        "1001",
        "1111"
    };
    letters[7] = new String[] {
        "1001",
        "1001",
        "1111",
        "1001",
        "1001"
    };
    letters[8] = new String[] {
        "1111",
        "0110",
        "0110",
        "0110",
        "1111"
    };
    letters[9] = new String[] {
        "1111",
        "0100",
        "0100",
        "0101",
        "0011"
    };
    letters[10] = new String[] {
        "1001",
        "1011",
        "1100",
        "1010",
        "1001"
    };
    letters[11] = new String[] {
        "1100",
        "1100",
        "1100",
        "1100",
        "1111"
    };
    letters[12] = new String[] {
        "1001",
        "1111",
        "1001",
        "1001",
        "1001"
    };
    letters[13] = new String[] {
        "1001",
        "1001",
        "1101",
        "1011",
        "1001"
    };
    letters[14] = new String[] {
        "1111",
        "1001",
        "1001",
        "1001",
        "1111"
    };
    letters[15] = new String[] {
        "1111",
        "1001",
        "1111",
        "1000",
        "1000"
    };
    letters[16] = new String[] {
        "0111",
        "1001",
        "1001",
        "1111",
        "0001"
    };
    letters[17] = new String[] {
        "1111",
        "1001",
        "1111",
        "1010",
        "1001"
    };
    letters[18] = new String[] {
        "0111",
        "1000",
        "1111",
        "0001",
        "1110"
    };
    letters[19] = new String[] {
        "1111",
        "0110",
        "0110",
        "0110",
        "0110"
    };
    letters[20] = new String[] {
        "1001",
        "1001",
        "1001",
        "1001",
        "1111"
    };
    letters[21] = new String[] {
        "1001",
        "1001",
        "1010",
        "1100",
        "1000"
    };
    letters[22] = new String[] {
        "1001",
        "1001",
        "1001",
        "1111",
        "1001"
    };
    letters[23] = new String[] {
        "1001",
        "0110",
        "0110",
        "0110",
        "1001"
    };
    letters[24] = new String[] {
        "1001",
        "1001",
        "1001",
        "0110",
        "0110"
    };
    letters[25] = new String[] {
        "1111",
        "0010",
        "0100",
        "1000",
        "1111"
    };
    charToIndex = new HashMap<Character, Integer>();
    for (int i = 0; i < 26; i++) {
        charToIndex.put((char)('A' + i), i);
    }
    word = "IVAN";
    mask = new LetterGrid();
}
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
    public int[][] triangleGridRectangle(Triangle a) {
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
    public void linkTriangleToGrid(Triangle a, int[][] gridRectangle) {
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
    public void add(Triangle a) {
        //Calcula las casillas que toca
        int[][] rectangle = this.triangleGridRectangle(a);
        //Agrega al triangulo a las casillas que le corresponde
        this.linkTriangleToGrid(a, rectangle);
    }
    public void drawUnmatched() {
        // println("Unmatched triangles:", this.unMatched.size());
        for (Triangle t : this.unMatched) {
            // println("Unmatched triangle at", t.position);
            t.drawUnmatched();
        }
    }
}
public void matchTriangles(Triangle a, Triangle b) {
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
public boolean itsAMatch(HalfEdge a, HalfEdge b) {
    if (a.match == null && b.match == null) {
        //Deben coincidir ya sea entre vertices del mismo tipo u opuestos
        if ((eqVectors(a.v0, b.v0) && eqVectors(a.v1, b.v1)) || (eqVectors(a.v0, b.v1) && eqVectors(a.v1, b.v0))){
            return true;
        }
    }
    //Si ya tienen match, no pueden coincidir
    return false;
}
public void makeMatch(HalfEdge a, HalfEdge b) {
    //Si alguno ya tiene match no deberían poder coincidir
    if (a.match != null || b.match != null) return;
    a.match = b;
    b.match = a;
}
public boolean eqVectors(PVector a, PVector b) {
    return eqFloats(a.x, b.x) && eqFloats(a.y, b.y);
}
public boolean eqFloats(float a, float b) {
    //Debe haber cierta tolerancia al error por cómo funcionan los float
    if (a >= b) return a - b <= tolerableError;
    return b - a <= tolerableError;
}
public void searchStep() {
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
public void matchStep() {
    if (triangles.isEmpty()) {
        // noLoop();
        println("Kites:", kites, "Darts:", darts);
        status = "style";
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
public void styleStep() {
    if (tiles.isEmpty()) {
        noLoop();
        // println("Kites:", kites, "Darts:", darts);
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
class Tile extends Polygon{
    float centerDistance;
    PVector centroid;
    Tile(PVector position, int rotation, String type) {
        super(position, rotation, type);
        this.calculateTile();
        this.calculateCenterDistance();
        if ("kite".equals(type)) kites++;
        else darts++;
    }
    public void calculateTile() {
        this.vertices[0] = this.position.copy();
        for (int i = 1; i < 4; i++) {
            if ("kite".equals(this.type)) this.vertices[i] = PVector.add(this.vertices[0], notableRotations[(16 + 2 * i + this.rotation) % 20].copy().mult(phiPowers[1]));
            else this.vertices[i] = PVector.add(this.vertices[0], notableRotations[(8 + 6 * i + this.rotation) % 20]);
            this.edges[i - 1] = new HalfEdge(this.vertices[i - 1], this.vertices[i], this);
        }
        this.edges[3] = new HalfEdge(this.vertices[3], this.vertices[0], this);
    }
    public void calculateCenterDistance() {
        PVector avgVertex = new PVector(0, 0);
        for (PVector v : this.vertices) {
            avgVertex.add(v);
        }
        avgVertex.div(this.vertices.length);
        this.centroid = avgVertex.copy();
        avgVertex.sub(new PVector(w/2, h/2));
        this.centerDistance = avgVertex.mag();
    }
    public void drawTiling() {
        for (HalfEdge e : this.edges) {
            e.drawTiling();
        }
    }
    public boolean intraMargin() {
        for (PVector v : this.vertices) {
            boolean onX = (v.x - margin >= tolerableError && w - margin - v.x >= tolerableError);
            boolean onY = (v.y - margin >= tolerableError && h - margin - v.y >= tolerableError);
            return onX && onY;
        }
        return false;
    }
    public void drawStyled() {
        if (mask.itsLetter(this)) {
            this.drawTiling();
        }
    }
}
float l, phi, tolerableError, squareSize, w, h;
float[] phiPowers, phiInversePowers;
PVector[] notableRotations;
ArrayList<Triangle> triangles;
ArrayList<Tile> tiles;
PVector disp;
String status;
CollisionChecker grid;
int iterations;
int kites, darts;
float margin;
ArrayList<Tile> styledTiles;
public void initValues() {
    randomSeed(1);
    //La relacion es 2:3 pero se podría cambiar
    w = 1.5f;
    h = 1;
    //Tamaño del lado más corto en las teselas objetivo
    l = 0.03444f;
    phi = (1 + sqrt(5)) / 2;
    margin = phi * l;
    tolerableError = 1e-5f;
    //La ventana estará dentro de un cuadrado más grande y podría ubicarse dentro de cualquier punto dentro de él
    squareSize = pow(phi, 4) * h;
    //Rotaciones precalculadas para optimizar
    notableRotations = new PVector[20];
    notableRotations[0] = new PVector(l, 0);
    for (int i = 1; i < 20; i++) {
        notableRotations[i] = notableRotations[0].copy().rotate((TWO_PI/20) * i);
    }
    //Elegimos un triángulo semilla al azar copn las mismas probabilidades
    String firstTriangleType = random(1) < 0.5f ? "acute" : "obtuse";
    //Este angulo sirve para calcular la ubicaciones de la ventana
    float angle = "acute".equals(firstTriangleType) ? (TWO_PI/5) : (TWO_PI/10);
    //Calculamos cuántas potencias de phi veces debe multiplicarse l para generar un triangulo que encierre al cuadrado
    int d = round(log((squareSize/l) * ((2/tan(angle)) + 1)) / log(phi)) + 1;
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
    triangles.add(new Triangle(tPos, 0, firstTriangleType, random(1) < 0.5f, d));
    //El primer paso es el de generar triangulos
    status = "triangules";
    //Estructuras para la etapa de generación de teselas
    tiles = new ArrayList<Tile>();
    grid = new CollisionChecker();
    kites = 0;
    darts = 0;
    styledTiles = new ArrayList<Tile>();
}
  public void settings() {  size(1200, 800); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "penrose" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
