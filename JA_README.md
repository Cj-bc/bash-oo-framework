Bash Infinity
=============

[![チャットに参加する: https://gitter.im/niieani/bash-oo-framework](https://badges.gitter.im/niieani/bash-oo-framework.svg)](https://gitter.im/niieani/bash-oo-framework?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Bash Infinityは**bash**でツールを書くための標準的なライブラリであり、模範的フレームワークです。  
C#やJava, JavaScriptの幾つかのコンセプトを導入しているにも関わらず、軽く、そしてモジュール単位で構成されています。  
また、Infinityフレームワークは手軽です: 既にあるスクリプトでも、その初めで読み込めば、エラーハンドリング等の機能を一つずつ選んで使う事ができます。

Bash Infinityは、bash scriptの可読性を最大限に引き上げ、繰り返されるコードを最小限に抑え、そしてよく書かれよくテストされたbash用の標準ライブラリの中心的レポジトリを作成する事を目的としています。

Bash Infinityは分かりづらい"bash syntax"を、より綺麗でよりモダンな文法に変えます。

免責事項: **bash 4**でテストしているため、全てのモジュールが古いバージョンで動くとは限りません。一方、[動かない部分を移植する](#bash 3対応について)のは可能（且つ比較的簡単）です。


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
* オブジェクト指向用の**型システム** (`util/class`)

全ての機能はモジュール単位で構成されているため、簡単に使いたい機能だけをimportすることができます。例えば、名前付き引数やtry-catchモジュールは別々のファイルに記述されています。

例外と`throw`とエラーハンドリング
=====================================

```
import util/exception
```

ハイライト機能の一つに、単体で動作するエラーハンドリングがあります。もしスクリプトがエラーを起こしたら、自動的に終了してstackを呼び出します。

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
    [reference] table   # reference はbash4.3以上でのみ動きます
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
    # ここでのみ*を使ってるぜ:
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
このモジュールはとても軽量で、bash 3でもbash 4でも動きます(referencceを除く - bash >=4.3)。もしこれだけを切り離して使いたければ、`/lib/system/02_named_parameters.sh`を取り出して使ってください。


注： 2-10までの引数には、`[string[4]]`の様な配列のエイリアスがあります。もしそれ以上の引数が必要な場合、上記の例にあるように`l=LENGTH [string[]]`といった形になります。若しくは、自分でエイリアスを作ることもできます :)


`import`
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

?    ## 捕捉した例外を表示する一番簡単な方法は
    Exception::PrintException "${__EXCEPTION__[@]}"
}
```

`try`ブロック内でもしなんらかのコマンドが失敗した時（例: 返り値が0以外）、`catch`ブロックが自動的に実行されます。
`try`ブロックの中括弧は必ずしも必要ではありませんが、`catch`は複数行である場合は中括弧が必要になります。


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
Log "Play me some Jazz, will ya? $(UI.Powerline.Saxophone)"

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

  # 連鎖した使い方です。詳しくは下を参照してください:
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


標準ライブラリ
=============

```
import util/type
```

一般的な作業をより簡潔に・読みやすくするために、string型や配列などの基本的な型とその操作を提供するライブラリがあります。

三つの方法で標準ライブラリを使用することができます。

### 1. ハンドル作成定義で変数を作成する

もしoo-frameworkのハンドル作成定義で変数を作成したなら、以下のようにすることで標準ライブラリのメゾットを使用できます: `$var:yourVariable someMethod someParameter`

使用可能なハンドル作成定義:

* string
* integer
* array
* map
* boolean

bash本体はboolean値を持つ変数をサポートしていないため、boolean型の変数はハンドル作成定義を使用して定義・変更する必要のある特殊なケースです。

例:

```bash
# string型の変数someStringを作成
string someString="My 123 Joe is 99 Mark"

# 正規表現にマッチした結果を保存
array matchGroups=$($var:someString getMatchGroups '([0-9]+) [a-zA-Z]+')

? # グループ1の
? $var:matchGroups every 2 1

? ## group 0, match 1
? $var:someString match '([0-9]+) [a-zA-Z]+' 0 1

# getterを呼びます。ここでようやく値が出力されます。
 $var:someString
 ```

### 2. `var:`を使ってmethodを使う

ハンドルを使って変数を作らなかった場合、`var:`methodを使用してアクセスすることもできます。

例:

```bash
# string型の変数someStringを作成
declare someString="My 123 Joe is 99 Mark"

# 正規表現にマッチした結果を保存
declare -a matchGroups=$(var: someString getMatchGroups '([0-9]+) [a-zA-Z]+')

? # list all metches in group 1:
var: matchGroups every 2 1

? ## group 0, match 1
var: someString match '([0-9]+) [a-zA-Z]+' 0 1

# getterを呼びます。ここでようやく値が出力されます。
var: someString
```

### 3. 変数の定義をパイプを使ってmethodに直接渡す

最後に、パイプを使って変数定義を使いたいmethodに渡すこともできます。

例:

```bash
# string型の変数someStringを作成
declare someString="My 123 Joe is 99 Mark"

# 正規表現にマッチした結果を保存
declare -a matchGroups=$(@get someString | string.getMatchGroups '([0-9]+) [a-zA-Z]+')

? # lists all matches in group 1:
@get matchGroups | array.every 2 1

? ## group 0, match 1
@get someString | string.match '([0-9]+) [a-zA-Z]+' 0 1

# 値の出力
echo "$someString"
```

## 標準ライブラリに追加する

次のように定義することで、カスタムmethodを標準ライブラリに追加することができます。

```bash
string.makeCool() {
  @resolve:this ## パイプ処理を追加したい場合必要です
  local outValue="cool value: $this"
  @return outValue
}

string someString="nice"
$var:someString makeCool
# "cool value: nice"と出力される
```

詳しくは`classを定義する`を参照してください。

Functional/operational chains with the Standard Library and custom classes
==========================================================================

```
import util/type
```

? Bash Infinityの型システムでは、C#やJava, JavaScript(JQueryのモナドライクなスタイルを考えてください)のようにメゾットをつなげたり、あるコマンドから他のコマンドへ出力をパイプしたりすることができます。

```bash
declare -a someArray=( 'one' 'two' )

var: someArray : \
  { map 'echo "${index} - $(var: item)"' } \
  { forEach 'var: item toUpper' }

# 上記のコマンドは以下の配列を定義します:
# ( '0 - ONE' '1 - TWO' )
```

次の連鎖で使用可能なメゾットは、その前に実行されたメゾットの戻り値の方によります。

自分でクラスを作成する
======================

クラスの作成はいたってシンプルで、殆どの最近の言語と同じように直感的にできます。

クラス定義:

* **class:YourName()** - クラスの定義

クラス定義の中で使われるキーワード:

* **method ClassName.FunctionName()** - *$this* にアクセスできるメゾットを定義するときに使えます。
* **public SomeType yourProperty** - パブリックなプロパティを作成します。(全ての型のクラスで使用可能です)
* **private SomeType _yourProperty** - 上記と同じですが、クラス内のメゾットからのみアクセスができます。
* **$this** - This変数はメゾットの中で使用可能で、現在の型にアクセスするために使用できます。
* **this** - $var:thisへのエイリアスで、メゾットを実行したりオブジェクトのプロパティを取得するのに使用します。
* 今後追加予定: **extends SomeClass** - 元のクラスからの継承

クラスが定義された後、`Type::Initialize NameOfYourType`を呼び出す必要があります。クラスをシングルトンにしたい場合は、`Type::InitializeStatic NameOfYourStaticType`を呼び出してください。

自分でクラスを定義する例:

```bash
import util/namedParameters util/class

class:Human() {
  public string name
  public integer height
  public array eaten

  Human.__getter__() {
    echo "I'm a human called $(this name), $(this height) cm tall."
  }

  Human.Example() {
    [array]     someArray
    [integer]   someNumber
    [...rest]   arrayOfOtherParams

    echo "Testing $(var: someArray toString) and $someNumber"
    echo "Stuff: ${arrayOfOtherParams[*]}"

    # はじめに渡された配列を返します
    @return someArray
  }

  Human.Eat() {
    [string] food

    this eaten push "$food"

    # 値が代入された文字列を返します:
    @return:value "$this just ate $food, which is the same as $1"
  }

  Human.WhatDidHeEat() {
    this eaten toString
  }

  # 静的メゾットにするには`::`を使用します
  Human::PlaySomeJazz() {
    echo "$(UI.Powerline.Saxophone)"
  }
}

# クラスのイニシャライズに必要
Type::Initialize Human

class:SingletonExample() {
  private integer YoMamaNumber = 150

  SingletonExample.PrintYoMama() {
    echo "Number is: $(this YoMamaNumber)!"
  }
}

# 静的イニシャライズに必要
Type::InitializeStatic SingletonExample
```

ここから、`Human`と`SingletonExample`クラスを使用できます:

```bash
# Human型のオブジェクト'Mark'を作成
Human Mark

# string.= (setter)の呼び出し
$var:Mark name = 'Mark'

# integer.= (setter)の呼び出し
$var:Mark height = 180

# 'corn'を配列Mark.eatenに追加し、出力を吐き出す
$var:Mark Eat 'corn'

# 'blueberries'を配列Mark.eatenに追加し、出力を大文字にして吐き出す
$var:Mark : { Eat 'blueberries' } { toUpper }

# getterを実行
$var:Mark

# invoke the method on the static instance of SingletonExample
# SingletonExampleの静的インスタンスにあるメゾットを実行する
SingletonExample PrintYoMama
```

ユニットテストを書く
====================

```
import util/test
```

![unit tests](https://raw.githubusercontent.com/niieani/bash-oo-framework/master/docs/unit.png "フレームワーク自身のユニットテスト")

[Bats](https://github.com/sstephenson/bats)のように、Bashスクリプトや他のUNIXプログラムをテストするためにユニットテストモジュールを使用できます。
テストケースは標準的なシェルコマンドから構成されます。テストケースを走らせる際、Infinity Frameworkは、BatsのようにBashのerrexitオプション(set -e)を使用します。それぞれのテストはサブシェルで実行され、他のテストケースから独立しています。Batsから引用すると:

? > テストケース内のすべてのコマンドが終了コード0(成功)で終了したら、テストは通ります。このように、それぞれの行は成功を期待されます。

より発展的なテストをする必要がある場合やbash 4以外のシェルでテストを実行する必要がある場合、Batsを使用することを推奨します。

使用例:

```bash
it 'should make a number and change its value'
try
    integer aNumber=10
    aNumber = 12
    test (($aNumber == 12))
expectPass

it "should make basic operations on two arrays"
try
    array Letters
    array Letters2

    $var:Letters push "Hello Bobby"
    $var:Letters push "Hello Maria"

    $var:Letters contains "Hello Bobby"
    $var:Letters contains "Hello Maria"

    $var:Letters2 push "Hello Midori,
                        Best regards!"

    $var:Letters2 concatAdd $var:Letters

    $var:Letters2 contains "Hello Bobby"
expectPass
```

これがBashだなんて信じられます!? ;-)

発展的なロギング
================

```
import util/log
```

ここでは、Infinity Frameworkで提供される発展的なロギングの使用方法の例をみてみましょう。

ロギングするすべてのファイルの中で、ロギングスコープ(namespace)を設定することができます。
設定しなかった場合、namespaceは拡張子を除いたファイル名になります。
ファイル名は衝突することがあるため、namespaceを設定した方が良いです。
スコープのおかげで、何を/どのように記録したいかを正確に指定できます。

```bash
namespace myApp

? ## "myApp"の出力をSTDERRに設定する
Log::AddOutput myApp STDERR

## 何か試してみましょう:
Log "logging to stderr"
```

上のコードは、単純に"logging to stderr"をSTDERRに吐き出します。
みてわかる通り、"STDERR"と呼ばれるロガーの出力を使いました。自分でロガーを作成して使うことも可能です。

```bash
## カスタムロガーの作成:
myLoggingDelegate() {
    echo "Hurray: $*"
}

## 登録する必要があります:
Log::RegisterLogger MYLOGGER myLoggingDelegate
```

さて、特定の関数からのログのみが、先ほど作成したカスタムロガーに出力されるように設定します:

```bash
## *myApp内のmyFunctionのログを全てMYLOGGERに流したい*
Log::AddOutput myApp/myFunction MYLOGGER

## 関数を定義:
myFunction() {
    echo "Hey, I am a function!"
    Log "logging from myFunction"
}

## 実行:
myFunction
```

上記のコードは以下のように出力するはずです:

```
Hey, I am a function!
Hurray: logging from myFunction
```

見ての通り、私たちの関数からのログは自動的に、以前登録されていたSTDERRより明確に規定されたMYLOGGERに返されます。
両方のロガーに出力したい場合は、特定のフィルターを外すことができます:

```bash
Log::DisableFilter myApp
```

この状態で`myFunction`を実行すると、このようになるはずです:

```
Hey, I am a function!
Hurray: logging from myFunction
logging from myFunction
```

もっと具体的に、 *subject*を指定してロガーを切り替えたり、そのsubjectの出力を停止したりできます:

```bash
## これまでのコードと同じファイルなので、まずはリセットします
Log::ResetAllOutputsAndFilters

Log::AddOutput myApp/myFunction MYLOGGER

myFunction() {
    echo "Hey, I am a function!"
    Log "logging from myFunction"
    subject="unimportant" Log "message from myFunction"
}
```

そして、subjectに対処するよう、先ほどのカスタムロガーを少し変えましょう:

```bash
myLoggingDelegate() {
    echo "Hurray: $subject $*"
}
```

この状態で`myFunction`を実行すると、このようになるはずです:

```
Hey, I am a function!
Hurray:  logging from myFunction
Hurray: unimportant message from myFunction
```

`myApp`ファイル内の`myFunction`の中の、`unimportant`subjectがついたメッセージをフィルタする(もしくはリダイレクトする)には以下のようにします:

```bash
Log::AddOutput myApp/myFunction/unimportant VOID
```

`myApp`内の全ての`unimportant`subjectがついたメッセージをフィルタするには:

```bash
Log::AddOutput myApp/unimportant VOID
```

もしくは、あらゆる箇所の`unimportant`subjectをフィルタするには以下のようにします:

```bash
Log::AddOutput unimportant VOID
```

この状態で`myFunction`を実行すると、このようになるはずです:

```
Hey, I am a function!
Hurray: logging from myFunction
```

使い方
=====

1. このレポジトリをcloneもしくはダウンロードしてください。必要なのは **/lib/** ディレクトリのみです。
2. そのディレクトリのすぐ外(訳注: 先ほどの`/lib`と同じ階層)にファイルを作成し、先頭に以下を追加してください。

    ```shell
    #!/usr/bin/env bash
    source "$( cd "${BASH_SOURCE[0]%/*}" && pwd )/lib/oo-bootstrap.sh"
    ```

3. もちろん、上記のソースコードも書き換えれば**/lib/**の名称を変えることもできます。
4. 何もない状態では、import機能のみが使用可能です。
   型システムなどのその他の機能を使いたいのであれば、以下のようにして各moduleをimportする必要があります:

   ```shell
   # 型システムのロード
   import util/log util/exception util/tryCatch util/namedParameters

   # 基礎的な型の標準ライブラリと型システムのロード
   import util/class
   ```

5. ユニットテストを使うには`import lib/types/util/test`とします。
   テスト内で初めてエラーが出たとき、テスト全体が失敗します。

6. `util/exception`や`util/tryCatch`を使うときは`set -o errexit`や`set -e`を使用しないでください。
   - エラーハンドリングはフレームワーク自体で行うため、それらは不要です。

Contributing
=============

気軽にforkして、新しいmoduleや変更をしてPull Requestを送ってください。
新しく加えたいと思っている機能:

* 全ての重要なメゾットへのユニットテスト
* bash3対応(できれば、バージョン毎に正しいファイルをimportする動的port)
? * 一つのファイルにまとまったボイルプレートを生成するwebジェネレーター(moduleを選ぶオプション付き)
* 主要な型(arrays, maps, strings, integers)の標準ライブラリへの関数の追加
* 使いやすい標準クラスの追加も歓迎します

bash 3対応について
==================

? **bash 3**に移植する際の主な課題は、型システムで使われる連想配列のpolyfillを作成することです(おそらく、連想配列のキーをそれぞれのインデックスに使うことで実現します)。そのほかの課題として、グローバル定義(`declare -g`)を削除することが挙げられます。

謝辞
====

もし関数が他のライブラリやwebページから得られたものならば、私はコード内のコメントにいつも書いています。

さらに、Bash Infinityのv1を作るにあたりオブジェクト指向のbashライブラリからいくつかの発想を得ました:

* https://github.com/tomas/skull/
* https://github.com/domachine/oobash/
* https://github.com/metal3d/Baboosh/
* http://sourceforge.net/p/oobash/
* http://lab.madscience.nl/oo.sh.txt
* http://unix.stackexchange.com/questions/4495/object-oriented-shell-for-nix
* http://hipersayanx.blogspot.sk/2012/12/object-oriented-programming-in-bash.html

その他bashの参考:

* http://wiki.bash-hackers.org
* http://kvz.io/blog/2013/11/21/bash-best-practices/
* http://www.davidpashley.com/articles/writing-robust-shell-scripts/
* http://qntm.org/bash


---

翻訳者(translator): @Cj-bc
素人翻訳ですので、誤りが多々ある可能性がございます。
訂正等あればよろしくお願いします。

As I'm not a pro, there might be some mistakes.
Please fix if you found any mistakes.
