# Logic Expression Compiler

## Experiment Contents

​	The input is a logical expression containing a number, and the output is the boolean value after calculation and the number of comparisons skipped due to short-circuit operations. The output format is "Output: [true or false], [number of times]". Note that the evaluation of the logical expression conforms to the short-circuit algorithm. Among them, the operater "!" counts the number of logical operations, and "==" or "!=" are only used for non-boolean numeric comparisons.

## Lexical Analysis

​		Flex is an open source lexical analyzer. The compiler converts the pattern input by the developer into a state transition diagram, and generates the corresponding implementation code, which is stored in the .yy, c files.

| token | symbol                | meaning    |
| ----------- | ------------------- | -------- |
| dight       | [0-9]\|\[1-9][0-9]* | number     |
| LT          | <                   | less than    |
| GT          | >                   | greater than  |
| LE          | <=                  | less or equal to |
| GE          | >=                  | greater or equal to |
| EQ          | ==                  | equal to     |
| NE          | !=                  | not equal to   |
| AND         | &&                  | and     |
| OR          | \|\|                | or     |
| NOT         | !                   | not    |
| LP          | (                   | left parentheses  |
| RP          | )                   | right parentheses   |
| newline     | \n\r                | line-termination |
| whitespace  | \t\f\v              | whitespace   |

## Grammar Analysis

#### Bison

​		bison 和 flex 配合使用，它可以将用户提供的语法规则转化成一个语法分析器，读取用户提供的语法的产生式，生成一个 C 语言格式的 LALR(1) 动作表，并将其包含进一个名为 yyparse 的 C 函数，这个函数的作用就是利用这个动作表来解析 token stream ，而这个 token stream 是由 flex 生成的词法分析器扫描源程序得到。

​		bison 里面 ”:” 代表一个 “->” ，同一个非终结符的不同产生式用 “|” 隔开，用 ”;” 结束表示一个非终结符产生式的结束；每条产生式的后面花括号内是一段 C 代码、这些代码将在该产生式被应用时执行，这些代码被称为 action ，产生式的中间以及 C 代码内部可以插入注释（稍后再详细解释本文件中的这些代码）；产生式右边是 ε 时，不需要写任何符号，一般用一个注释 /* empty */ 代替。	

​		bison 会将 Productions 段里的第一个产生式的左边的非终结符（本文件中为 Program ）当作语法的起始符号，同时，为了保证起始符号不位于任何产生式的右边， bison 会自动生成增广文法，而将这个新增的符号当作解析的起始符号。

#### Grammatical precedence and associativity

​		在.y文件中定义了这些运算符token的优先级和结合律，在代码中，先出现的声明优先级越低，同时声明的token具有相同的优先级。规则如下：

| Priority(top-down） | simbol        | Associativity |
| ------------------ | ----------- | ------ |
| 1                  | OR          | Left |
| 2                  | AND         | Left |
| 3                  | LT GT LE GE | Left |
| 4                  | EQ NE       | Left |
| 5                  | NOT         | Right  |
| 6                  | LP RP       | Left |

#### Grammar Design

​		根据逻辑表达式的形式，总结出如下的文法：

● Program => Exp

● Exp => NOT Exp 

​				| Exp AND Exp

​				| Exp OR Exp

​				| Exp LT Exp

​				| Exp LE Exp

​				| Exp GT Exp

​				| Exp GE Exp

​				| Exp EQ Exp

​				| Exp NE Exp

​				| LP Exp Rp

​				| VALUE

​		Program是文法的开始符号，经过bison编译后会自动生成对应的增广文法Program’。

#### 短路次数统计

​		短路次数仅与AND和OR两个运算符有关。首先在.y文件中，定义一个全局变量来统计短路次数：

```c
int short_cut = 0;	// record the number of shortcuts 
```

​		对于AND，如果第一个表达式的结果为False，则进行短路，short_cut值自增1，返回为True；对于OR，如果第一个表达式的结果为True，则进行短路，short_cut值自增1，返回为True。其他情况不考虑短路操作，短路操作对应的部分代码如下：

```c
	| Exp AND Exp {			// AND operation
		if ( $1 == 0 ) {	// 第一个操作数为False进行短路
			short_cut++;
			$$ = 0;
		}
		else
		{
			if ($3 == 1) { $$ = 1; }
			else { $$ = 0; }
		}
	}
	| Exp OR Exp {  	// OR operation
		if ($1 == 1) {	// 第一个操作数为True进行短路
			short_cut++;
			$$ = 1;
		}
		else {
			if ($3 == 0) { $$ = 0; }
			else { $$ = 1; }
		}
	}
```

#### Error Handling

​		该程序所接受的所有输入符号如下：

```c
%token LT 	// <
%token GT	// >
%token LE	// <=
%token GE	// >=
%token EQ	// ==
%token NE	// !=
%token AND	// &&
%token OR	// ||
%token NOT	// !
%token LP	// (
%token RP	// )
digit	[0-9]|[1-9][0-9]*	// Numbers
whitespace [ \t\f\v]		// Whitespace
newline [\r\n]  		// Newline
```

​		当输入的字符不在上述列表中时，程序输出错误信息，并显示第一个输入错误的字符内容。当有多个错误时，只会显示第一个错误，检测到错误就立即停止运行。代码如下：

```c
/* 报错,非正确字符 */
.	{
	// 输入遇到非指定字符,显示出错,则不再继续分析
	printf("Error! Wrong token '%s'.\n", yytext);
	exit(0);
}
```

## compilation and Runtime output

#### Compile outputs

​	Compile files:

![image](https://user-images.githubusercontent.com/51059802/141681513-23490951-2a6d-4ee0-baf3-efb18b47e51a.png)


​	Compile succeeds, generates files listed below：

![image](https://user-images.githubusercontent.com/51059802/141681523-6cef240e-f386-424b-8f52-474f81df7880.png)

#### 运行结果

​		测试程序输出：

![image](https://user-images.githubusercontent.com/51059802/141681534-02133267-d6d4-4a26-863b-588194d1402b.png)
![image](https://user-images.githubusercontent.com/51059802/141681543-4c243239-63b0-4802-b207-c26f251f450b.png)
![image](https://user-images.githubusercontent.com/51059802/141681548-466a0752-c626-4720-a66b-bc988123adf8.png)

​		下面测试一些不合法的文法：

![image](https://user-images.githubusercontent.com/51059802/141681564-b0f92f78-0a4b-4700-8b13-c61cb7f88a74.png)

​		程序达到预期效果。
