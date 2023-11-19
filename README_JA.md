# sakura_blizzard

## デモ
サンプルコードを実行した時に表示される画面と類似の画面を、以下のサンプルアプリからも確認することができます。
サンプルアプリではフロントレイヤとバックレイヤの両方を使用しており、子ウィジェットであるテキストウィジェットがその中間にあります。
[サンプルアプリ](https://sakurablizzard.web.app/)

## 概要
Flutterの桜の花びらに関する3Dエフェクトです。
桜以外にも、雪、雨、画像などを落下させられます。
このパッケージは[simple_3d_renderer](https://pub.dev/packages/simple_3d_renderer)とその関連パッケージを用いて作成されており、simple_3d_rendererの簡単な使用例でもあります。
デフォルト以外のオブジェクトを使用したい場合、ElementsFlowViewを利用することで、
あらゆる[Sp3dObj](https://pub.dev/packages/simple_3d)を落下アニメーションさせることができます。

![桜の花びらのサンプル](https://raw.githubusercontent.com/MasahideMori-SimpleAppli/simple_3d_images/main/SakuraBlizzard/sakura_blizzard_sakura_sample.png)

![キューブのサンプル](https://raw.githubusercontent.com/MasahideMori-SimpleAppli/simple_3d_images/main/SakuraBlizzard/sakura_blizzard_cube_sample.png)

## 使い方
Exampleタブをチェックしてください。

## サポート
もし何らかの理由で有償のサポートが必要な場合は私の会社に問い合わせてください。  
このパッケージは私が個人で開発していますが、会社経由でサポートできる場合があります。  
[合同会社シンプルアプリ](https://simpleappli.com/index.html)

## バージョン管理について
それぞれ、Cの部分が変更されます。  
ただし、バージョン1.0.0未満は以下のルールに関係無くファイル構造が変化する場合があります。  
- 変数の追加など、以前のファイルの読み込み時に問題が起こったり、ファイルの構造が変わるような変更
  - C.X.X
- メソッドの追加など
  - X.C.X
- 軽微な変更やバグ修正
  - X.X.C

## ライセンス
このソフトウェアはMITライセンスの元配布されます。LICENSEファイルの内容をご覧ください。

## 著作権表示
The “Dart” name and “Flutter” name are trademarks of Google LLC.  
*The developer of this package is not Google LLC.