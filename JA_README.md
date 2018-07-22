Bash Infinity
=============

[![チャットに参加する: https://gitter.im/niieani/bash-oo-framework](https://badges.gitter.im/niieani/bash-oo-framework.svg)](https://gitter.im/niieani/bash-oo-framework?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bash Infinityは**bash**でツールを書くための標準的なライブラリであり、模範的フレームワークです。  
C#やJava, JavaScriptの幾つかのコンセプトを導入しているにも関わらず、軽く、そしてモジュール単位で構成されています。  
また、Infinityフレームワークは手軽です: 既にあるスクリプトでも、その初めで読み込めば、エラーハンドリング等の機能を一つずつ選んで使う事ができます。

Bash Infinityは、bash scriptの可読性を最大限に引き上げ、繰り返されるコードを最小限に抑え、そしてよく書かれよくテストされたbash用の標準ライブラリの中心的レポジトリを作成する事を目的としています。

Bash Infinityは分かりづらい"bash syntax"を、より綺麗でよりモダンな文法に変えます。

免責事項: **bash 4**でテストしているため、全てのモジュールが古いバージョンで動くとは限りません。一方、[動かない部分を移植する](#bash3への移植)のは可能（且つ比較的簡単）です。


クイックスタート
==============

シングルファイルでのリリース&動的読み込みはv2.0ではまだ利用できません。
ローカルにフレームワークを落とすには、[こちら](#使い方)。

メインモジュール
==============

* 例外付きの自動的エラーハンドリングと視覚的なスタックトレース (`util/exception`)
* 関数に、$1や$2の代わりに名前付き引数を与える (`util/namedParameters`)
* 配列やmapを引数として渡す (`util/variable`)
* **try-catch** (`util/tryCatch`)
* **ユーザー定義例外**を作成 (`util/exception`)
* *require-js*風のスクリプト読み込みのための**import**キーワード (`oo-bootstrap`)
* 出力の可読性を上げるために、**色**と**powerline**への手軽なエイリアスを追加(`UI/Color`)
* しっかりと整形され色付けされた**ロギング**を*stderr*や他の任意の場所に出力する (`util/log`)
* **ユニットテスト**ライブラリ (`util/test`)
* 豊富な関数を揃えた、型システム用標準ライブラリ (`util/type`)
* **関数型プログラミング**のためのoperational chain (`util/type`)
* オブジェクト指向用の型システム (`util/class`)

全ての機能はモジュール単位で構成されているため、簡単に使いたい機能だけをimportすることができます。例えば、名前付き引数やtry-catchモジュールは別々のファイルに記述されています。

例外と`throw`とエラーハンドリング
=====================================

```
import util/exception
```

ハイライト機能の一つに、そのまま動作するエラーハンドリングがあります。もしスクリプトがエラーを起こしたら、自動的に終了してstackを呼び出します。

![example call stack](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/exception.png "Example Call Stack")

独自の例外を`trow`してエラーを引き起こすこともできます。

```bash
e="The hard disk is not connected properly!" throw
```

もしもどこで発生したのかわからなくてもcall stackが表示されるので、デバッグ時に役に立ちます。

*try & catch*で囲まれた**例外**は、**-o erroexit**オプションなしでも安全に実行できるようにします。

何か間違いがあった場合、例外の詳細なバックトレースが表示され、失敗したコマンドがハイライトされます。スクリプトの実行が一時停止し、そのまま続けるか、強制終了させるかの選択をすることができます。
反対に、一部のブロックが失敗することを望んでいる場合、それを`try`ブロックで覆い`catch`内でそのエラーを処理することができます。

