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

関数の名前付き引数
====================

```
import util/namedParameters
```

どのようなプログラミング言語であれ、可読性向上のために意味のある名前を変数につけるのはいいことです。
Bashの場合、関数のパラメータ変数を避けることを意味します。
関数内で、引数にアクセスするために可読性の悪い`$1`,`$2`等を使う代わりに、次のように書くことができます。

```bash
testPassingParams() {

    [string] hello
    [string[4]] anArrayWithFourElements
    l=2 [string[]] anotherArrayWithTwo
    [string] anotherSingle
    [reference] table   # references はbash4.3以上でのみ動きます
    [...rest] anArrayOfVariedSize

    test "$hello" = "$1" && echo correct
    #
    test "${anArrayWithFourElements[0]}" = "$2" && echo correct
    test "${anArrayWithFourElements[1]}" = "$3" && echo correct
    test "${anArrayWithFourElements[2]}" = "$4" && echo correct
    # etc...
    #
    test "${anotherArrayWithTwo[0]}" = "$6" && echo correct
    test "${anotherArrayWithTwo[1]}" = "$7" && echo correct
    #
    test "$anotherSingle" = "$8" && echo correct
    #
    test "${table[test]}" = "works"
    table[inside]="adding a new value"
    #
    # I'm using * just in this example:
    test "${anArrayOfVariedSize[*]}" = "${*:10}" && echo correct
}

fourElements=( a1 a2 "a3 with spaces" a4 )
twoElements=( b1 b2 )

declare -A assocArray
assocArray[test]="works"

testPassingParams "first" "${fourElements[@]}" "${twoElements[@]}" "single with spaces" assocArray "and more... " "even more..."

test "${assocArray[inside]}" = "adding a new value"
```

システムによって、以下のように割り当てられます。
 * **$1**は**$hello**に代入されます。
 * **$anArrayWithFourElements**は、$2から$5の値をもつ配列の引数になります。
 * **$anotherArrayWithTwo**は$6と$7の値を持った配列になります。
 * **$8**は**$anotherSingle**に代入されます。
 * **$table**は9番目の引数として渡された名前を持つ変数への参照になります。
 * **$anArrayOfVariedSize**は、それ以降のすべてのパラメーターの、bashの配列になります。

言い換えれば、引数をそれらの名前で呼ぶことができる(可読性を向上させる)だけでなく、配列を簡単に渡す(bash4.3以上なら、さらに変数の参照を渡す)ことができます！それに加えて、マップされた変数は全てローカル変数です。
このモジュールはとても軽量で、bash 3でもbash 4でも動きます(riferencceを除く - bash >=4.3)。もしこれだけを切り離して使いたければ、`/lib/system/02_named_parameters.sh`を取り出して使ってください。


注： 2-10までの引数には、```[string[4]]```の様な配列のエイリアスがあります。もしそれ以上の引数が必要な場合、上記の例にあるように```l=LENGTH [string[]]```といった形になります。若しくは、自分でエイリアスを作ることもできます :)


```import```
=============

ブートストラップの後、ライブラリや自前のファイルを読み込むために`import`コマンドを使うことができます。
`import`コマンドは、そのファイルが一度だけ読み込まれることを保証します。`import`しているファイルからの相対パスか、フレームワークのあるディレクトリからの相対パスか、絶対パスを使用することができます。`.sh`はあってもなくても構いません。
ファイルの代わりにディレクトリへのパスを指定することで、ディレクトリの中身を全て読み込むこともできます。


`try & catch`でエラーハンドリング
====================================

```bash
import util/tryCatch
import util/exception # Exception::PrintException使用時のみ必要
```

使用例:

```bash
try {
    # something...
    cp ~/test ~/test2
    # something more...
} catch {
    echo "The hard disk is not connected properly!"
    echo "Caught Exception:$(UI.Color.Red) $__BACKTRACE_COMMAND__ $(UI.Color.Default)"
    echo "File: $__BACKTRACE_SOURCE__, Line: $__BACKTRACE_LINE__"

    ## printing a caught exception couldn't be simpler, as it's stored in "${__EXCEPTION__[@]}"
    Exception::PrintException "${__EXCEPTION__[@]}"
}
```

```try```ブロック内でもしなんらかのコマンドが失敗した時（例: 返り値が0以外）、```catch```ブロックが自動的に実行されます。
```try```ブロックの中括弧は必ずしも必要ではありませんが、```catch```は複数行である場合は中括弧が必要になります。


注: `try`はサブシェル内で実行されるため、内部で変数を定義することはできません。


基礎的なロギング、色、パワーラインの絵文字を使う
===================================================

```
import util/log
```

```bash
# 色を使う
echo "$(UI.Color.Blue)I'm blue...$(UI.Color.Default)"

# 名前空間を定義してこのファイルの基礎的なロギングを可能にする
namespace myApp
# ログ関数に、名前空間'myApp'内のもの全てをDEBUGというログハンドラーに流すように設定する
Log::AddOutput myApp DEBUG

# ここから、DEBUG出力のセットを使って書くことができる
Log "Play me some Jazz, will ya?${UI.Powerline.Saxphone}"

# エラーメッセージをSTDERRにリダイレクトする
Log::AddOutput error STDERR
subject=error Log "Something bad happened."

# 出力をリセットする
Log::ResetAllOutputsAndFilters

# 直接StdErr出力に書き出すこともできます
Console::WriteStdErr "This will be printed to STDERR, no matter what."
```

色やPowerline絵文字は、それらをサポートしていないシステムでは自動的に適宜置き換えられます
Powerline絵文字を見るためには、powerlineのパッチ済みフォントを使う必要があります。

利用可能な色と絵文字のリストは、[lib/UI/Color.sh](https://github.com/niieani/bash-oo-framework/blob/master/lib/UI/Color.sh)を参照してください。
ForkしてもっとContributeしてください！

より発展的なロギングについては以下の[発展的ロギング](#発展的なロギング)を参照してください。


パラメータに配列、マップ、オブジェクトを渡す
=============================================

```
import util/variable
```

? variableユーティリティは、`@get`コマンドを使用して、配列と連想配列（ここでは`maps`と呼ばれます）の完全なダンプを提供します。

? `util/namedParameters`と併用することで、個別の引数として渡すことができるようになります。

? より記述しやすく値渡しで変数を渡すには、変数を`$ref:yourVariableName`と呼びます。

参照をサポートしているbash 4.3以上では、参照渡しが可能です。その場合、関数内で起きた変数への変更は、関数の外にも影響を及ぼします。参照渡しをするには、この方法を使ってください: `$ref:yourVariableName`

```bash
array someArray=( 'one' 'two' )
# $var:someArray メゾットのハンドラを作ることを除けば、
# 上記は次の書き方と同義です: declare -a someArray=( 'one' 'two' )

passingArraysInput() {
  [array] passedInArray

  # chained usage, see below for more details:
  $var:passedInArray : \
    { map 'echo "${index} - $(var: item)"' } \
    { forEach 'var: item toUpper' }

  $var:passedInArray push 'will work only for references'
}

echo 'passing by $var:'

## 二つの方法で配列のコピーを渡すことができます。(定義を使って渡す)
passingArraysInput "$(@get someArray)"
passingArraysInput $var:someArray

## まだ何も変わってません
$var:someArray toJSON

echo
echo 'passing by $ref:'

## bash4.3以降の場合、リファレンスが使えるため参照渡しができます。
## この方法で変数を渡すと、関数内でその変数に起きた変化は全てそのまま元の変数に影響します。
passingArraysInput $ref:someArray

## 変わっているはずです。
$var:someArray toJSON
```

