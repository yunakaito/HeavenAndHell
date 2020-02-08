//hah_barcode.pde

//最大文字数(文字の最大値を決めておき、それより少ない文字列はspaceで埋める)
final int n = 5;
//バーコードの大きさ(×2,×4...,×nなど)
final int scale = 2;
//色定義
final color white = color(254, 252, 252), black = color(15, 15, 15);
//ウィンドウサイズ定義
final int w = 320*scale, h = 150*scale;

// 任意の表示テキストを入力(スラッシュで区切る)
final String[] text = {
 "t/e/s/t",
 "T/E/S/T/!",
 "T/H/I/S",
 "I/S",
 "T/E/space/S/T"
};

//イージング度合い
final float easing = 0.2;

//表示するバーコードのカウント
int textCount = 1;
//バーコードがアニメーション中かどうか
boolean isMoveBarcode = false;
//パターン一覧用の変数
Table code_pattern;

void settings() {
 size(w, h);
 noSmooth();
}

void setup() {
 noStroke();
 code_pattern = loadTable("code_pattern.csv");
}

void draw() {
 background(white);
 drawBarcode(text[(textCount-1) % text.length], text[(textCount) % text.length]);
}

//キーを押すとアニメーションします
void keyPressed() {
 textCount++;
 isMoveBarcode = !isMoveBarcode;
}


//現パターンと、変化後のパターン用の変数
float[] patterns;
float[] patterns_next;
float count;

//バーコード
void drawBarcode(String t, String tNext) {

  //アニメーション待機時
  if (!isMoveBarcode) {
    patterns = generatePattern(t);
    patterns_next = generatePattern(tNext);

    count = 0;
    isMoveBarcode = !isMoveBarcode;
  }

  //バーコードの長さ、高さを計算
  float barcodeWidth = 0;
  float barcodeHeight = 30*scale;
  for (int i = 0; i < patterns.length; i++) {
    barcodeWidth += patterns[i]*scale;
  }

  pushMatrix();
  //中央揃え
  translate(w/2 - barcodeWidth/2, h/2-barcodeHeight/2);
  //実際の描画
  for (int i = 0; i < patterns.length; i++) {
    //【追加】patterns[i]の値にイージングアニメーションを追加します
    patterns[i] = patterns[i] + (patterns_next[i] - patterns[i])*(easing);
    if (i % 2 == 0) {
      fill(black);
      rect(count*scale, 0, patterns[i]*scale, barcodeHeight);
      count += patterns[i];
    } else {
      count += patterns[i];
    }
  }

  popMatrix();
  count = 0;
}

float[] generatePattern(String str) {
  //チェックディジット計算
  int checkdigit = int(code_pattern.getString(104, 0)) * 1;
  for (int i = 0; i < decomposeText(str).length; i++) {
    checkdigit += int(code_pattern.findRow(decomposeText(str)[i], 1).getString(0)) * (i+1);
  }
  checkdigit %= 103;

  //スタートコードの追加
  String p = code_pattern.getString(104, 2);
  //具体値の追加
  for (int i = 0; i < decomposeText(str).length; i++) {
    p += code_pattern.findRow(decomposeText(str)[i], 1).getString(2);
  }
  //チェックディジットの追加
  p += code_pattern.findRow(str(checkdigit), 0).getString(2);
  //ストップコードの追加
  p += code_pattern.getString(106, 2);

  //float化して配列に格納
  float[] code =  new float [n*6 + 6 + 6 + 7];
  for (int i = 0; i < code.length; i++) {
    // 文字列の数字は、"0"が数値48に該当するので注意！！！
    code[i] = p.charAt(i) - 48;
  }
  return code;
}


String[] decomposeText(String str) {
  //配列の初期化(n文字分の配列確保, 文字がないとこはスペースで保管)
  String[] moji;
  moji = new String[n];
  for (int i = 0; i < moji.length; i++) {
    moji[i] = "space";
  }

  //入力テキスト読み出し(スラッシュで分解し、１文字づつ入れていく)
  String[] t0 = str.split("/", 0);
  for (int j = 0; j < t0.length; j++) {
    moji[j] = t0[j];
  }
  return moji;
}
