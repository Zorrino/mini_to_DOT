%{

#include <stdio.h>
#include <stdlib.h>
#include "Structures/Stack.c"
#include "Structures/tree.c"
int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
%}

%union{
    char* chaine; 
    int val;
};

%token<chaine> IDENTIFICATEUR
%token<chaine> INT
%token<chaine> VOID
%type<chaine> type

%token<val> CONSTANTE

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
%left BOR BAND
%left LAND LOR
%nonassoc THEN
%nonassoc ELSE
%left OP
%left REL
%start programme
%%
programme	:	
	|	liste_declarations liste_fonctions
;
liste_declarations	:	
		liste_declarations declaration 
	|	

liste_fonctions	:	
		liste_fonctions fonction
|               fonction
;
declaration	:	
		type liste_declarateurs ';'     {
				if (strcmp($1,"void")==0){
					yyerror("variable void");
				}
		}
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur
	|	declarateur
;
declarateur	:	
		IDENTIFICATEUR						{

											}
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}'
	|	EXTERN type IDENTIFICATEUR '(' liste_parms ')' ';'
;
type	:	
		VOID 	{$$ = strdup("void");}
	|	INT		{$$ = "int";}
;


liste_parms	:
		parm	
	|
		liste_parms ',' parm
    | 

;
parm	:	
		INT IDENTIFICATEUR
;
liste_instructions :	
		liste_instructions instruction
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation ';'
	|	bloc
	|	appel
;
iteration	:	
		FOR '(' affectation ';' condition ';' affectation ')' instruction
	|	WHILE '(' condition ')' instruction
;
selection	:	
		IF '(' condition ')' instruction %prec THEN
	|	IF '(' condition ')' instruction ELSE instruction
	|	SWITCH '(' expression ')' instruction
	|	CASE CONSTANTE ':' instruction
	|	DEFAULT ':' instruction
;
saut	:	
		BREAK ';'
	|	RETURN ';'
	|	RETURN expression ';'
;
affectation	:	
		variable '=' expression
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
		IDENTIFICATEUR 				{

									}
	|	variable '[' expression ']'
;
expression	:	
		'(' expression ')'
	|	expression binary_op expression %prec OP
	|	MOINS expression 
	|	CONSTANTE
	|	variable
	|	IDENTIFICATEUR '(' liste_expressions ')'
;

liste_expressions :      // pour accepter epsilon ou une liste d'expressions
	| expression                              // liste à un seul élément
    | liste_expressions ',' expression  // liste à n éléments
    

condition	:	
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:	
		PLUS
	|   MOINS
	|	MUL
	|	DIV
	|   LSHIFT
	|   RSHIFT
	|	BAND
	|	BOR
;
binary_rel	:	
		LAND
	|	LOR
;
binary_comp	:	
		LT
	|	GT
	|	GEQ
	|	LEQ
	|	EQ
	|	NEQ
;
%%

int main (){
		yyparse();
		printf("Success.\n");
		
		return 0;
}