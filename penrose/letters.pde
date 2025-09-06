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
       int x = floor(tile.centroid.x / this.boxWidth);
       int y = floor(tile.centroid.y / this.boxHeight);
       if (x < 0 || x >= this.gridWidth || y < 0 || y >= this.gridHeight) return false;
       return this.bitMap[y][x];
    }
}

void initLetters() {
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