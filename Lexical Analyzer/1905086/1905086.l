%option noyywrap

%{
#include<stdio.h>
#include<stdlib.h>
#include<fstream>
#include<string>
using namespace std;

int line_count=1,ll = 0,error = 0;
string token_str, logout_str, comment;
int multi = 0;

FILE *logout;
FILE *tokenout;

#include "1905086_SymbolTable.h"

symbol_table st(10);

char getChar(string teststring) {
	if(teststring[0] == '\\') {
		if(teststring[1] == '0') {
			return (char) 0;
		} 
		else if(teststring[1] == 'a') {
			return (char) 7;
		} 
		else if(teststring[1] == 'b') {
			return (char) 8;
		}
		else if(teststring[1] == 't') {
			return (char) 9;
		}
		else if(teststring[1] == 'n') {
			return (char) 10;
		}
	    else if(teststring[1] == 'v') {
			return (char) 11;
		} 
		else if(teststring[1] == 'f') {
			return (char) 12;
		}
		else if(teststring[1] == 'r') {
			return (char) 13;
		}
		else if(teststring[1] == '\\') {
			return (char) 92;
		}
		else if(teststring[1] == '\"') {
			return (char) 34;
		}
		else if(teststring[1] == '\'') {
			return (char) 39;
		} 
	}
	return teststring[0];
}

%}

%x CHARLIT_STATE
%x STRING1
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
			fprintf(tokenout,"<IF, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else" {
			fprintf(tokenout,"<ELSE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ELSE> Lexeme %s found\n",line_count,yytext);
		}
"for" {
			fprintf(tokenout,"<FOR, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FOR> Lexeme %s found\n",line_count,yytext);
		}
		
"do" {
			fprintf(tokenout,"<DO, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DO> Lexeme %s found\n",line_count,yytext);
		}

"while"	{
			fprintf(tokenout,"<WHILE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <WHILE> Lexeme %s found\n",line_count,yytext);
		}
		
"break"	{
			fprintf(tokenout,"<BREAK, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BREAK> Lexeme %s found\n",line_count,yytext);
		}
"int" {
			fprintf(tokenout,"<INT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INT> Lexeme %s found\n",line_count,yytext);
		}
		
"char" {
			fprintf(tokenout,"<CHAR, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CHAR> Lexeme %s found\n",line_count,yytext);
		}        
"float" {
			fprintf(tokenout,"<FLOAT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
		
"double" {
			fprintf(tokenout,"<DOUBLE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}
"void" {
			fprintf(tokenout,"<VOID, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <VOID> Lexeme %s found\n",line_count,yytext);
		}
		
"return" {
			fprintf(tokenout,"<RETURN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RETURN> Lexeme %s found\n",line_count,yytext);
		}

"switch" {
			fprintf(tokenout,"<SWITCH, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
		
"case" {
			fprintf(tokenout,"<CASE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CASE> Lexeme %s found\n",line_count,yytext);
		}

"default" {
			fprintf(tokenout,"<DEFAULT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
		
"continue" {
			fprintf(tokenout,"<CONTINUE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CONTINUE> Lexeme %s found\n",line_count,yytext);
		} 		 
{DIGIT}+ {
			fprintf(tokenout,"<CONST_INT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CONST_INT> Lexeme %s found\n",line_count,yytext);
}
{NUMBER} {
			fprintf(tokenout,"<CONST_FLOAT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
}
{ID} {
	        int check = (int)st.Insert(string(yytext), "ID");
			fprintf(tokenout,"<ID, %s>\n",yytext);
			if(check == 1){
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				st.printAllScope();
			}
			else if(check == 0){
				fprintf(logout,"Line# %d: Token <ID> Lexeme %s found\n",line_count,yytext);
				fprintf(logout,"	%s already exists in the current ScopeTable\n",yytext);	
			}
}
{TOO_MANY_DECIMAL_POINTS} {
			fprintf(logout, "Error at line# %d: TOO_MANY_DECIMAL_POINTS %s\n", line_count, yytext);	
			error++;
}
{ILLFORMED_NUMBER} {
			fprintf(logout, "Error at line# %d: ILLFORMED_NUMBER %s\n", line_count, yytext);	
			error++;
}
{INVALID_ID_SUFFIX_NUM_PREFIX} {
			fprintf(logout, "Error at line# %d: INVALID_ID_SUFFIX_NUM_PREFIX %s\n", line_count, yytext);	
			error++;
}
"+" |
"-" {
			fprintf(tokenout,"<ADDOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ADDOP> Lexeme %s found\n",line_count,yytext);
}
"*" |
"/" |
"%" {
            fprintf(tokenout,"<MULOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <MULOP> Lexeme %s found\n",line_count,yytext);
}
"++" |
"--" {
            fprintf(tokenout,"<INCOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <INCOP> Lexeme %s found\n",line_count,yytext);
}
"<" |
"<=" |
">" |
">=" |
"==" |
"!=" {
            fprintf(tokenout,"<RELOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RELOP> Lexeme %s found\n",line_count,yytext);
}

"=" {
            fprintf(tokenout,"<ASSIGNOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
}

"&&" |
"||" {
            fprintf(tokenout,"<LOGICOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LOGICOP> Lexeme %s found\n",line_count,yytext);
}

"&" |
"|" |
"^" |
"<<" |
">>" {
            fprintf(tokenout,"<BITOP, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <BITOP> Lexeme %s found\n",line_count,yytext);
}

"!" {
            fprintf(tokenout,"<NOT, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <NOT> Lexeme %s found\n",line_count,yytext);
}
"(" {
            fprintf(tokenout,"<LPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LPAREN> Lexeme %s found\n",line_count,yytext);
}
")" {
            fprintf(tokenout,"<RPAREN, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RPAREN> Lexeme %s found\n",line_count,yytext);
}
"{" {
            fprintf(tokenout,"<LCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LCURL> Lexeme %s found\n",line_count,yytext);
			st.enter_scope();
}
"}" {
            fprintf(tokenout,"<RCURL, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RCURL> Lexeme %s found\n",line_count,yytext);
			st.exit_scope();
}
"[" {
            fprintf(tokenout,"<LSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <LSQUARE> Lexeme %s found\n",line_count,yytext);
}
"]" {
            fprintf(tokenout,"<RSQUARE, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <RSQUARE> Lexeme %s found\n",line_count,yytext);
}
"," {
            fprintf(tokenout,"<COMMA, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <COMMA> Lexeme %s found\n",line_count,yytext);
}
";" {
            fprintf(tokenout,"<SEMICOLON, %s>\n",yytext);
			fprintf(logout,"Line# %d: Token <SEMICOLON> Lexeme %s found\n",line_count,yytext);
}

\' {
			BEGIN CHARLIT_STATE;
			token_str.clear();
}

<CHARLIT_STATE>\' {
			int length = token_str.size();
			//fprintf(logout, "Found char %s, -> size %d\n", token_str.c_str(), length);
			if ((token_str[0] == '\\' && length>2) || (token_str[0] != '\\' && length>=2)) {
				error++;
				fprintf(logout, "Error at line# %d: MULTICHAR_CONST_CHAR \'%s\'\n", line_count, token_str.c_str());
			}
			else if (length == 0) {
				error++;
				fprintf(logout, "Error at line# %d: EMPTY_CONST_CHAR \'\'\n", line_count);
			}
			else if ((token_str[0] == '\\' && length == 2) || (token_str[0] != '\\' && length == 1)) {
				fprintf(tokenout, "<CONST_CHAR, %c>\n", getChar(token_str));
				fprintf(logout,"Line# %d: Token <CONST_CHAR> Lexeme %c found\n",line_count,getChar(token_str));
			}

			BEGIN INITIAL;
}

<CHARLIT_STATE>\\' {token_str.append("\\'");}
<CHARLIT_STATE>\\\" { token_str.append("\\\""); }
<CHARLIT_STATE>\\\\ { token_str.append("\\\\"); }
<CHARLIT_STATE>\\n { token_str.append("\\n"); }
<CHARLIT_STATE>\\t {  token_str.append("\\t"); }
<CHARLIT_STATE>\\a {  token_str.append("\\a"); }
<CHARLIT_STATE>\\f {  token_str.append("\\f"); }
<CHARLIT_STATE>\\r {  token_str.append("\\r"); }
<CHARLIT_STATE>\\b {  token_str.append("\\b"); }
<CHARLIT_STATE>\\v {  token_str.append("\\v"); }
<CHARLIT_STATE>\\0 {  token_str.append("\\0"); }

<CHARLIT_STATE>\n {
			error++;
			fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR \'%s\n", line_count, token_str.c_str());
			line_count++;
			token_str.clear();
			BEGIN INITIAL;
}

<CHARLIT_STATE><<EOF>> {
			error++;
			fprintf(logout, "Error at line# %d: UNFINISHED_CONST_CHAR \'%s\n", line_count, token_str.c_str());
			BEGIN INITIAL;
}

<CHARLIT_STATE>. {  token_str.append(string(yytext));}

\" {
			token_str.clear();
			logout_str.clear();
			logout_str = "\"";
			ll = 0;
			BEGIN STRING1;
}
<STRING1>\\t {logout_str.append("\\t"); token_str.append("\t");}
<STRING1>\\n {logout_str.append("\\n"); token_str.append("\n");}
<STRING1>\\a {logout_str.append("\\a"); token_str.append("\a");}
<STRING1>\\v {logout_str.append("\\v"); token_str.append("\v");}
<STRING1>\\b {logout_str.append("\\b"); token_str.append("\b");}
<STRING1>\\f {logout_str.append("\\f"); token_str.append("\f");}
<STRING1>\\r {logout_str.append("\\r"); token_str.append("\r");}
<STRING1>\\0 {logout_str.append("\\0"); token_str.append("\0");}
<STRING1>\\\\ {logout_str.append("\\\\"); token_str.append("\\");}
<STRING1>\\\" {logout_str.append("\\\""); token_str.append("\"");}
<STRING1>\\' {logout_str.append("\\'"); token_str.append("\'");}
<STRING1>\" {
			logout_str.append("\"");
			if(multi==1){
			fprintf(tokenout,"<MULTI LINE STRING, %s>\n", token_str.c_str());
            fprintf(logout,"Line# %d: Token <MULTI LINE STRING> Lexeme %s found\n",line_count, logout_str.c_str());
			}
			else{
			fprintf(tokenout,"<SINGLE LINE STRING, %s>\n", token_str.c_str());
            fprintf(logout,"Line# %d: Token <SINGLE LINE STRING> Lexeme %s found\n",line_count, logout_str.c_str());
			}	
			multi = 0;
			token_str.clear();
			logout_str.clear();	
			line_count = line_count + ll;
			BEGIN INITIAL;	
}
<STRING1>\\\n { ll++;multi=1; logout_str.append("\\\n"); }
<STRING1>\n |
<STRING1><<EOF>> { 
		if(yytext[0]=='\n') ll++;
		fprintf(logout, "Error at line# %d: UNFINISHED_STRING %s\n", line_count, logout_str.c_str());	
		line_count = line_count + ll;
		logout_str.clear();
		token_str.clear();
		error++;
		BEGIN INITIAL;
}
<STRING1>. {
			logout_str.append(yytext);
			token_str.append(yytext);
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
        fprintf(logout,"Line# %d: Token <SINGLE LINE COMMENT> Lexeme %s found\n",line_count, comment.c_str());
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
        fprintf(logout,"Line# %d: Token <MULTI LINE COMMENT> Lexeme %s found\n",line_count, comment.c_str());
		line_count += ll;
		BEGIN INITIAL;
	}
<COMMENT2>. {comment.append(yytext);}
<COMMENT2><<EOF>> { 
		error++;	
		line_count += ll;
		fprintf(logout, "Error at line# %d: UNFINISHED_COMMENT %s\n", line_count, comment.c_str());	
		BEGIN INITIAL;
	}
. {
	fprintf(logout, "Error at line# %d: UNRECOGNIZED_CHAR %c\n", line_count, yytext[0]);	
	error++;

}

%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1905086_log.txt","w");
	tokenout= fopen("1905086_token.txt","w");

	yyin= fin;
	yylex();
	fclose(yyin);

	st.printAllScope();

	fprintf(logout, "Total lines: %d\n", line_count);	
	fprintf(logout, "Total errors: %d\n", error);	

	fclose(tokenout);
	fclose(logout);
	return 0;
}
