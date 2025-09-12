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
    boolean itsLetter(Tile tile) {
        // for (PVector v : tile.vertices) {
        //     int x = floor(v.x / this.boxWidth);
        //     int y = floor(v.y / this.boxHeight);
        //     if (x < 0 || x >= this.gridWidth || y < 0 || y >= this.gridHeight) continue;
        //     if (this.bitMap[y][x]) return true;
        // }
        // return false;
        int x = floor(tile.centroid.x / this.boxWidth);
        int y = floor(tile.centroid.y / this.boxHeight);
        if (x < 0 || x >= this.gridWidth || y < 0 || y >= this.gridHeight) return false;
        return this.bitMap[y][x];
    }
}

void initLetters() {
    letters = new String[29][];
    letters[0] = new String[] { //A
        "00111100",
        "01111110",
        "01100110",
        "01000010",
        "11000011",
        "11111111",
        "11111111",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011"
    };
    letters[1] = new String[] {//B
        "11111000",
        "11111110",
        "11000111",
        "11000011",
        "11000011",
        "11000110",
        "11111100",
        "11000110",
        "11000011",
        "11000011",
        "11000111",
        "11111110",
        "11111000"
    };
    letters[2] = new String[] {//C
        "01111110",
        "11111111",
        "11110111",
        "11100011",
        "11000001",
        "11000000",
        "11000000",
        "11000000",
        "11000001",
        "11100011",
        "11110111",
        "11111111",
        "01111110"
    };
    letters[3] = new String[] {//D
        "11111100",
        "11111110",
        "11000111",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000111",
        "11111110",
        "11111100"
    };
    letters[4] = new String[] {//E
        "11111111",
        "11111110",
        "11000000",
        "11000000",
        "11000000",
        "11111110",
        "11111111",
        "11111110",
        "11000000",
        "11000000",
        "11000000",
        "11111110",
        "11111111"
    };
    letters[5] = new String[] {//F
        "11111111",
        "11111111",
        "11100000",
        "11100000",
        "11100000",
        "11111111",
        "11111111",
        "11111111",
        "11100000",
        "11100000",
        "11100000",
        "11100000",
        "11100000"
    };
    letters[6] = new String[] {//G
        "01111110",
        "11111111",
        "11100011",
        "11000000",
        "11000000",
        "11000110",
        "11000111",
        "11000011",
        "11000011",
        "11000011",
        "11100111",
        "11111111",
        "01111110"
    };
    letters[7] = new String[] {//H
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11111111",
        "11111111",
        "11111111",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011"
    };
    letters[8] = new String[] {//I
        "00011000",
        "00011000",
        "00000000",
        "00111100",
        "00111100",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "11111111",
        "11111111"
    };
    letters[9] = new String[] {//J
        "00111111",
        "00011110",
        "00001100",
        "00001100",
        "00001100",
        "00001100",
        "00001100",
        "00001100",
        "00001100",
        "10001100",
        "11011100",
        "11111000",
        "01110000"
    };
    letters[10] = new String[] {//K
        "11000011",
        "11000011",
        "11000111",
        "11000110",
        "11011110",
        "11111100",
        "11111000",
        "11111100",
        "11011110",
        "11000111",
        "11000111",
        "11000011",
        "11000011"
    };
    letters[11] = new String[] {//L
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000000",
        "11000011",
        "11111111",
        "11111111"
    };
    letters[12] = new String[] {//M
        "11000011",
        "11000011",
        "11100111",
        "11100111",
        "11111111",
        "11011011",
        "11011011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
    };
    letters[13] = new String[] {//N
        "11000011",
        "11000011",
        "11100011",
        "11100011",
        "11110011",
        "11010011",
        "11011011",
        "11001011",
        "11001111",
        "11000111",
        "11000111",
        "11000011",
        "11000011"
    };
    letters[14] = new String[] {//O
        "01111110",
        "11111111",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11111111",
        "01111110"
    };
    letters[15] = new String[] {//P
        "11111110",
        "11111111",
        "11111111",
        "11000011",
        "11000011",
        "11000011",
        "11111111",
        "11111110",
        "11111100",
        "11000000",
        "11000000",
        "11000000",
        "11000000"
    };
    letters[16] = new String[] {//Q
        "11111110",
        "11111110",
        "11000110",
        "11000110",
        "11000110",
        "11000110",
        "11000110",
        "11000110",
        "11000110",
        "11001110",
        "11111110",
        "11111111",
        "00000011"
    };
    letters[17] = new String[] {//R
        "11111100",
        "11111110",
        "11000111",
        "11000011",
        "11000011",
        "11000111",
        "11111110",
        "11111100",
        "11110000",
        "11011000",
        "11001100",
        "11000110",
        "11000011"
    };
    letters[18] = new String[] {//S
        "00111111",
        "01111111",
        "11100000",
        "11000000",
        "11100000",
        "11111110",
        "11111111",
        "01111111",
        "00000111",
        "00000011",
        "00000111",
        "11111110",
        "11111100"
    };
    letters[19] = new String[] {//T
        "11111111",
        "11111111",
        "10011001",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
    };
    letters[20] = new String[] {//U
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11100111",
        "11111111",
        "11111111",
        "01111110"
    };
    letters[21] = new String[] {//V
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11100111",
        "11100111",
        "11100111",
        "11111111",
        "01111110",
        "00111100",
        "00111100"
    };
    letters[22] = new String[] {//W
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11000011",
        "11011011",
        "11011011",
        "11111111",
        "11100111",
        "11100111",
        "11000011",
        "11000011"
    };
    letters[23] = new String[] {//X
        "11000011",
        "11100111",
        "11100111",
        "01100110",
        "01111110",
        "00111100",
        "00111100",
        "00111100",
        "01111110",
        "01100110",
        "11100111",
        "11100111",
        "11000011"
    };
    letters[24] = new String[] {//Y
        "11000011",
        "11000011",
        "11000011",
        "01100110",
        "01100110",
        "00111100",
        "00111100",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000",
        "00011000"
    };
    letters[25] = new String[] {//Z
        "11111111",
        "11111111",
        "10000011",
        "00000111",
        "00001111",
        "00011110",
        "00111100",
        "01111000",
        "11110000",
        "11100000",
        "11000001",
        "11111111",
        "11111111"
    };
    letters[26] = new String[] {//Ñ
        "00111100",
        "00111100",
        "00000000",
        "11000011",
        "11000011",
        "11100011",
        "11110011",
        "11111011",
        "11111111",
        "11011111",
        "11001111",
        "11000111",
        "11000011"
    };
    letters[27] = new String[] {//espacio
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000",
        "00000000"
    };
    letters[28] = new String[] {//Á
        "00001100",
        "00011000",
        "00110000",
        "00000000",
        "00111100",
        "01111110",
        "11100111",
        "11100111",
        "11111111",
        "11111111",
        "11100111",
        "11100111",
        "11100111"
    };
    int trueCount = 0;
    for (String[] letter : letters) {
        for (String row : letter) {
            for (char c : row.toCharArray()) {
                if (c == '1') trueCount++;
            }
        }
    }
    println("avg:", trueCount / 26);
    charToIndex = new HashMap<Character, Integer>();
    for (int i = 0; i < 26; i++) {
        charToIndex.put((char)('A' + i), i);
    }
    charToIndex.put('Ñ', 26);
    charToIndex.put(' ', 27);
    charToIndex.put('Á', 28);
    phi = (1 + sqrt(5)) / 2;
    w = 1.5;
    h = 1;
    word = "POL";
    mask = new LetterGrid();
    float letterArea = mask.boxWidth * mask.boxHeight;

    float kitesPerLetter = 24;
    
    float letterW = mask.letterWidth * mask.boxWidth;
    println("letterW:", letterW);
    l = sqrt((2 * letterW * letterW) / (kitesPerLetter * sqrt(20 * phi + 15)));
    println("Letter l:", l);
    println("Box size:", mask.boxWidth, mask.boxHeight);
    println("Grid size:", mask.gridWidth, mask.gridHeight);
}