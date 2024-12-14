%option noyywrap

%{
#include<stdio.h>
#include<stdlib.h>
#include<fstream>
#include<string>

using namespace std;


extern FILE *logout;
extern int line_count;
extern int error;
int ll = 0;
string comment;

#include "1905086_SymbolTable.h"
#include "y.tab.h"

extern YYSTYPE yylval;

extern symbol_table st;


%}
%x COMMENT1
%x COMMENT2

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
NUMBER {DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?
ID [a-zA-Z_][a-zA-Z0-9_]* 
NEWLINE \n
TOO_MANY_DECIMAL_POINTS {DIGIT}+\.{DIGIT}+\.({DIGIT}|\.)*
ILLFORMED_NUMBER ({DIGIT}+\.?{DIGIT}*|\.{DIGIT}+)[Ee][+-]?{DIGIT}*\.({DIGIT}+)?
INVALID_ID_SUFFIX_NUM_PREFIX {DIGIT}*(\.{DIGIT}+)?([Ee][+-]?{DIGIT}+)?{ID}*
%%
{WHITESPACE} {}
{NEWLINE} {line_count++;}

"if" {
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "IF");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return IF;
		}
		
"else" {
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "ELSE");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return ELSE;
		}
"for" {
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext); 
			yylval.si = new symbol_info(yytext, "FOR");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true); 
			return FOR;
}

"while"	{
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "WHILE");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
		    return WHILE;
		}

"int" {
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "INT");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return INT;
		}
       
"float" {
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "FLOAT");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return FLOAT;
		}

"void" {
			fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "VOID");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return VOID;
		}
		
"return" {
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "RETURN");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return RETURN;
		}	
"println" {
			fprintf(logout,"Line# %d: Token <PRINTLN> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "PRINTLN");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return PRINTLN;
		}	 
{DIGIT}+ {
			fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "CONST_INT");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
            return CONST_INT;
}
{NUMBER} {
			fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
            yylval.si = new symbol_info(yytext, "CONST_FLOAT");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);            
			return CONST_FLOAT;
}
{ID} {
			fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
            yylval.si = new symbol_info(yytext, "ID");
			yylval.si->setNodeString("ID");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);            
			return ID;
}

"+" |
"-" {
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
            yylval.si = new symbol_info(yytext, "ADDOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);            
			return ADDOP;
}
"*" |
"/" |
"%" {
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
            yylval.si = new symbol_info(yytext, "MULOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);            
			return MULOP;
}
"++" {
	       fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
		    yylval.si = new symbol_info(yytext, "INCOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
		   return INCOP;
} 
"--" {
		   fprintf(logout,"Line# %d: Token <DECOP> Lexeme %s found\n",line_count,yytext);
		    yylval.si = new symbol_info(yytext, "DECOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
		   return DECOP;
}
"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "RELOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
            return RELOP;
}

"=" {
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "ASSIGNOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return ASSIGNOP;
}

"&&" |
"||" {
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "LOGICOP");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return LOGICOP;
}

"!" {
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "NOT");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return NOT;
}
"(" {
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "LPAREN");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return LPAREN;
}
")" {
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "RPAREN");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return RPAREN;
}
"{" {
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "LCURL");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return LCURL;
}
"}" {
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "RCURL");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return RCURL;
}
"[" {
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "LSQUARE");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return LSQUARE;
}
"]" {
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "RSQUARE");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return RSQUARE;
}
"," {
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "COMMA");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return COMMA;
}
";" {
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			yylval.si = new symbol_info(yytext, "SEMICOLON");
			yylval.si->setStartEndline(line_count, line_count);
			yylval.si->setTerminal(true);
			return SEMICOLON;
}
\/\/ {
	BEGIN COMMENT1;
	ll = 1;
	comment.clear();
	comment.append("//");	
}
<COMMENT1>\\\n { ll++; comment.append("\\\n");}
<COMMENT1>\\ { comment.append("\\");}
<COMMENT1>\n |
<COMMENT1><<EOF>> {
        //fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",line_count, comment.c_str());
		line_count = line_count + ll;
		BEGIN INITIAL;
}
<COMMENT1>. {comment.append(yytext);}
\/\* {
	BEGIN COMMENT2;
	ll = 0;
	comment.clear();
	comment.append("/*");
} 
<COMMENT2>\n {ll++; comment.append("\n");} 
<COMMENT2>\*\/ { 
		comment.append("*/");
        //fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_count, comment.c_str());
		line_count += ll;
		BEGIN INITIAL;
	}
<COMMENT2>. {comment.append(yytext);}
<COMMENT2><<EOF>> { 
		error++;	
		line_count += ll;
		//fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, comment.c_str());	
		BEGIN INITIAL;
	}

%%
