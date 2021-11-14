%{
	#include <stdio.h>
	#include "mytool.tab.h"
%}

digit	[0-9]|[1-9][0-9]*
whitespace [ \t\f\v]
newline [\r\n]

%%
 /* 忽略空格 */
{whitespace}	{ ; }

 /* end of input */
{newline}	{ return 0; }

 /* 
 atoi函数将str指向的字符串转换成一个整数 
 strdup函数复制字符串
 */
{digit} {
yylval.value = atoi(strdup(yytext));
return VALUE; 
}

[<] 	{
return LT;
}

[>]	{
return GT;
}

"<="	{
return LE;	
}

">="	{
return GE;
}

"=="	{
return EQ;
}

"!="	{
return NE;
}

"&&"	{
return AND;
}

"||"	{
return OR;
}

[!]	{
return NOT;
}

[(]	{
return LP;
}

[)]	{
return RP;
}

 /* 报错,非正确字符 */
.	{
	// 输入遇到非指定字符,显示出错,则不再继续分析
	printf("Error! Wrong token '%s'.\n", yytext);
	exit(0);
}
%%

int yywrap(void)
{
	return 1;
}
