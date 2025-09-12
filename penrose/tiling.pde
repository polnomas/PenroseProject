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
        color currentColor;
        color strokeColor;
        color arc1CurrentColor;
        color arc2CurrentColor;
        float arc1MinAngle;
        float arc1MaxAngle;
        float arc2MinAngle;
        float arc2MaxAngle;
        float arc1Radius;
        float arc2Radius;
        int arc1Center;
        int arc2Center;
        int factor = random(1) > 0.5 ? -1 : 1;
        int secondFactor = random(1) > 0.5 ? -1 : 1;
        if ("kite".equals(this.type)) {
            arc1Center = 0;
            arc2Center = 2;
            arc1Radius = l;
            arc2Radius = l / phi;
            arc1MinAngle = notableAngles[this.rotation] - notableAngles[2];
            arc1MaxAngle = notableAngles[this.rotation] + notableAngles[2];
            arc2MinAngle = notableAngles[this.rotation] + notableAngles[6];
            arc2MaxAngle = notableAngles[this.rotation] + notableAngles[14];
        }
        else {
            arc1Center = 2;
            arc2Center = 0;
            arc1Radius = l / phi;
            arc2Radius = l / pow(phi, 2);
            arc1MinAngle = notableAngles[this.rotation] + notableAngles[8];
            arc1MaxAngle = notableAngles[this.rotation] + notableAngles[12];
            arc2MinAngle = notableAngles[this.rotation] - notableAngles[6];
            arc2MaxAngle = notableAngles[this.rotation] + notableAngles[6];
        }
        if (mask.itsLetter(this)) {
            currentColor = color(lettersColor + factor * random(0, 36), lettersSaturation, lettersBrightness);
            strokeColor = color(lettersColor + factor * random(0, 36), lettersSaturation, lettersBrightness);
        }
        else {
            currentColor = color(backgroundColor + factor * random(0, 36), backgroundSaturation, backgroundBrightness);
            strokeColor = color(backgroundColor + factor * random(0, 36), backgroundSaturation, backgroundBrightness);
        }
        arc1CurrentColor = color(arc1Color + secondFactor * random(54), arc1Saturation, arc1Brightness);
        arc2CurrentColor = color(arc2Color + secondFactor * random(54), arc2Saturation, arc2Brightness);
        stroke(strokeColor);
        fill(currentColor);
        quad(
            this.vertices[0].x,
            this.vertices[0].y,
            this.vertices[1].x,
            this.vertices[1].y,
            this.vertices[2].x,
            this.vertices[2].y,
            this.vertices[3].x,
            this.vertices[3].y
        );
        stroke(arc1CurrentColor);
        noFill();
        strokeWeight(2.0 / height);
        arc(this.vertices[arc1Center].x, this.vertices[arc1Center].y, 2 * arc1Radius, 2 * arc1Radius, arc1MinAngle, arc1MaxAngle);
        stroke(arc2CurrentColor);
        arc(this.vertices[arc2Center].x, this.vertices[arc2Center].y, 2 * arc2Radius, 2 * arc2Radius, arc2MinAngle, arc2MaxAngle);
        strokeWeight(1.5 / height);
    }
}