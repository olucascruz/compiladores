%{

#define YYSTYPE double
#include <stdio.h>
#include <string.h>

extern FILE* yyin;
extern int yylineno;
extern char *yytext;

//int yyerror(char *s, int linha, char *mensagem );
//int yyerror(char *msg, int error_line_number, char *error_msg);

void yyerror(const char *s);
int yylex();
int yyparse();

int errors = 0;
char *teste;

%}

%token NUMBER EOL
%token PLUS MINUS DIVIDE TIMES
%token P_LEFT P_RIGHT NAN

%left NAN PLUS MINUS
%left TIMES DIVIDE
%left P_LEFT P_RIGHT

%define parse.error verbose
%locations

%%

STATEMENT:
	STATEMENT EXPRESSION EOL{ 
							if(errors == 0){
								$$ = $2; printf("Resultado: %f\n", $2);
							}
							}
	|
	;

EXPRESSION:
	NUMBER {$$ = $1;}
	|	EXPRESSION PLUS EXPRESSION {$$ = $1 + $3;}
	|	EXPRESSION MINUS EXPRESSION {$$ = $1 - $3;}
	|	EXPRESSION TIMES EXPRESSION {$$ = $1 * $3;}
	|	EXPRESSION DIVIDE EXPRESSION {
										if($3 == 0)
											yyerror("division by zero");
										else
											$$ = $1 / $3;
									}
	|	P_LEFT EXPRESSION P_RIGHT {$$ = $2;}
	|	EXPRESSION NAN EXPRESSION{yyerror("two operators sequements");}
	;



%%


int main(int argc, char *argv[])
{
	if (argc == 1)
    {
		yyparse();
    }

	if (argc == 2)
	{
    	yyin = fopen(argv[1], "r");
		
		printf("\nCompiling ... \n");
		
		yyparse();
	
		if ( errors == 0)
			printf("\nSuccess!\n");
	}

	return 0;
}


void yyerror(const char *s)
{
	if (strstr(s, "syntax error") != NULL) {
		printf("Error: Line %d: Syntax error near '%s'\n", yylineno, yytext);
	} else if (strstr(s, "invalid operands") != NULL) {
		printf("Error: Line %d: Invalid operands '%s'\n", yylineno, yytext);
	} else {
		printf("Error: Line %d: %s\n", yylineno, s);
	}
	errors++;
}