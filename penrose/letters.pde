String[][] letters;
HashMap<Character, Integer> charToIndex;;


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
}