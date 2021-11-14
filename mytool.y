/*
源程序包括：
	声明
	%%
	翻译规则
	%%
	辅助性C语言例程
*/
%{
	#include <stdio.h>
	int yylex(void);  
	void yyerror(char const *);    
	int err = 0;
	int short_cut = 0;	// 记录短路次数  
%}

// %define parse.error verbose

%union
{
	int value;
}

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

// 规定优先级别和结合左右顺序
// 自上而下优先级升高
%left OR
%left AND
%left LT GT LE GE
%left EQ NE
%right NOT	// !为右结合
%left LP RP

%token<value> VALUE
%type<value> Exp

%%
Program : Exp {
	char* res;
	if ( $1 == 0 ) { res = "false"; }
	else { res = "true"; }

	printf("Output: %s, %d\n ", res, short_cut);
}

Exp : NOT Exp {
	if ($2 == 0) { $$ = 1; }
	else { $$ = 0; }
	}
	| Exp AND Exp {
		if ( $1 == 0) {
			short_cut++;
			$$ = 0;
		}
		else
		{
			if ($3 == 1) { $$ = 1; }
			else { $$ = 0; }
		}
	}
	| Exp OR Exp {
		if ($1 == 1) {
			short_cut++;
			$$ = 1;
		}
		else {
			if ($3 == 0) { $$ = 0; }
			else { $$ = 1; }
		}
	}
	| Exp LT Exp {
		if ($1 < $3) { $$ = 1; }
		else {$$ = 0;}
	}
	| Exp GT Exp {
		if ($1 > $3) { $$ = 1; }
		else { $$ = 0; }
	}
	| Exp LE Exp {
		if ($1 <= $3) { $$ = 1; }
		else { $$ = 0; }	
	}
	| Exp GE Exp {
		if ($1 >= $3) { $$ = 1; }
		else { $$ = 0; }
	}
	| Exp EQ Exp {
		if ($1 == $3) { $$ = 1; }
		else { $$ = 0; }
	}
	| Exp NE Exp {
		if ($1 != $3) { $$ = 1; }
		else { $$ = 0; }
	}
	| LP Exp RP {
		$$ = $2;
	}
	| VALUE {
		$$ = $1;
	}
%%

int main(int argc, char* argv[])
{
	yyparse();
	return 0;
}

void yyerror(char const *msg)
{  
	if(err) return; // 如果已经报错，则程序直接退出
	fprintf(stderr, "%s\n", msg);  
}  
