%{

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include "Structures/Stack.c"

#define AFFECTATION 3
#define VARIABLE 2
char* concat(const char *s1, const char *s2);
int yylex();
void yyerror (char *s) {
	fprintf (stderr, "%s\n", s);	
	exit(2);
}
typedef struct liste_noeud liste_noeud;
struct liste_noeud{
	char* type;
	char* valeur;
	GNode* noeud;
};

GHashTable* table_symbole;
struct stack *pt;

tree_node_linked_t* listeNoeuds;
node_t* i;
%}
%union{
    char* chaine; 
	GNode* noeud;
};

%token<chaine> IDENTIFICATEUR INT VOID CONSTANTE
%type<noeud> type affectation declaration liste_declarateurs instruction declarateur  liste_fonctions fonction liste_instructions variable expression programme 
%type<chaine> binary_op liste_expressions 

%token FOR WHILE IF ELSE SWITCH CASE DEFAULT
%token BREAK RETURN PLUS MOINS MUL DIV LSHIFT RSHIFT LT GT
%token GEQ LEQ EQ NEQ NOT EXTERN
%left PLUS MOINS
%left MUL DIV
%left LSHIFT RSHIFT
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
		liste_fonctions fonction {$$ = $2;}
|               fonction
;
declaration	:	
		type liste_declarateurs ';'     {
				
				
				}
		
;
liste_declarateurs	:	
		liste_declarateurs ',' declarateur 		{
				$$ = concat(concat($1,","),$3);
		}
	|	declarateur {
				$$ = $1;
	}
declarateur	:	
		IDENTIFICATEUR						{$$ = $1;}
	|	declarateur '[' CONSTANTE ']'
;
fonction	:	
		type IDENTIFICATEUR '(' liste_parms ')' '{' liste_declarations liste_instructions '}' {$$ = $8;}
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
		liste_instructions instruction { $$ = $2;}
	|
;
instruction	:	
		iteration
	|	selection
	|	saut
	|	affectation ';' {$$ = $1;}
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
		variable '=' expression {	
				liste_noeud* l = g_hash_table_lookup(table_symbole,(char*)g_node_nth_child($1, 0)->data);
				if(l != NULL){
					$$ = g_node_new((void*)AFFECTATION);
					g_node_append_data($$,$1);
					g_node_append($$,$3);
				}
				else{
					l = malloc(sizeof(liste_noeud));
					l->valeur=$3;
					l->type = "int";
					if(g_hash_table_insert(table_symbole, g_node_nth_child($1,0)->data, l)){
						$$ = g_node_new((void*)AFFECTATION);
						g_node_append($$,$1);
						g_node_append($$,$3);
					}
				}

		}
;
bloc	:	
		'{' liste_declarations liste_instructions '}'
;
appel	:	
		IDENTIFICATEUR '(' liste_expressions ')' ';'
;
variable	:	
		IDENTIFICATEUR 				{ $$ = g_node_new((void*)VARIABLE);
										g_node_append_data($$, $1); }
	|	variable '[' expression ']' { $$=$1; }
;

expression	:	
		'(' expression ')' 	{$$ = $2;}	
	|	expression binary_op expression %prec OP {$$ = concat(concat($1,$2),$3);}
	|	MOINS expression {$$ = concat("-",$2);}
	|	CONSTANTE {$$ = $1;}
	|	variable {$$ = $1;}
	|	IDENTIFICATEUR '(' liste_expressions ')' {$$ = concat(concat($1," "),$3);}
;

liste_expressions :      // pour accepter epsilon ou une liste d'expressions
	| expression        {$$ = $1;}
    | liste_expressions ',' expression  { $$ = concat(concat($1,","),$3); }
    

condition	:	
		NOT '(' condition ')'
	|	condition binary_rel condition %prec REL
	|	'(' condition ')'
	|	expression binary_comp expression
;
binary_op	:	
		PLUS 	{$$ = "+";}
	|   MOINS{$$ = "-";}
	|	MUL{$$ = "*";}
	|	DIV{$$ = "/";}
	|   LSHIFT{$$ = "<<";}
	|   RSHIFT{$$ = ">>";}
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


char* concat(const char *s1, const char *s2)
{
    char *result = malloc(strlen(s1) + strlen(s2) + 1); // +1 for the null-terminator
    // in real code you would check for errors in malloc here
    strcpy(result, s1);
    strcat(result, s2);
    return result;
}

int main (){


		listeNoeuds = (tree_node_linked_t*)malloc(sizeof(tree_node_linked_t));
		pt = newStack(10000);
		i = makeTab();
		stack_push(pt,i);
		yyparse();

		printf("Success.\n");

		return 0;
}