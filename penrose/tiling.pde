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
    void calculateTile() {
        this.vertices[0] = this.position.copy();
        for (int i = 1; i < 4; i++) {
            if ("kite".equals(this.type)) this.vertices[i] = PVector.add(this.vertices[0], notableRotations[(16 + 2 * i + this.rotation) % 20].copy().mult(phiPowers[1]));
            else this.vertices[i] = PVector.add(this.vertices[0], notableRotations[(8 + 6 * i + this.rotation) % 20]);
            this.edges[i - 1] = new HalfEdge(this.vertices[i - 1], this.vertices[i], this);
        }
        this.edges[3] = new HalfEdge(this.vertices[3], this.vertices[0], this);
    }
    void calculateCenterDistance() {
        PVector avgVertex = new PVector(0, 0);
        for (PVector v : this.vertices) {
            avgVertex.add(v);
        }
        avgVertex.div(this.vertices.length);
        this.centroid = avgVertex.copy();
        avgVertex.sub(new PVector(w/2, h/2));
        this.centerDistance = avgVertex.mag();
    }
    void drawTiling() {
        for (HalfEdge e : this.edges) {
            e.drawTiling();
        }
    }
    boolean intraMargin() {
        for (PVector v : this.vertices) {
            boolean onX = (v.x - margin >= tolerableError && w - margin - v.x >= tolerableError);
            boolean onY = (v.y - margin >= tolerableError && h - margin - v.y >= tolerableError);
            return onX && onY;
        }
        return false;
    }
    void drawStyled() {
        if (mask.itsLetter(this)) {
            this.drawTiling();
        }
    }
}