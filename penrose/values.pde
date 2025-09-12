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
boolean show;
float[] notableAngles;
void initValues() {
    randomSeed(seedFromWord());
    //La relacion es 2:3 pero se podría cambiar
    // w = 1.5;
    // h = 1;
    //Tamaño del lado más corto en las teselas objetivo
    // l = 0.03444;
    // margin = phi * l;
    margin = 0;
    tolerableError = 1e-5;
    //La ventana estará dentro de un cuadrado más grande y podría ubicarse dentro de cualquier punto dentro de él
    squareSize = pow(phi, 4) * h;
    //Rotaciones precalculadas para optimizar
    notableRotations = new PVector[20];
    notableRotations[0] = new PVector(l, 0);
    notableAngles = new float[20];
    notableAngles[0] = 0;
    for (int i = 1; i < 20; i++) {
        notableRotations[i] = notableRotations[0].copy().rotate((TWO_PI/20) * i);
        notableAngles[i] = (TWO_PI/20) * i;
    }
    //Elegimos un triángulo semilla al azar copn las mismas probabilidades
    String firstTriangleType = random(1) < 0.5 ? "acute" : "obtuse";
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
    triangles.add(new Triangle(tPos, 0, firstTriangleType, random(1) < 0.5, d));
    //El primer paso es el de generar triangulos
    status = "triangules";
    //Estructuras para la etapa de generación de teselas
    tiles = new ArrayList<Tile>();
    grid = new CollisionChecker();
    kites = 0;
    darts = 0;
    styledTiles = new ArrayList<Tile>();
    show = false;
}