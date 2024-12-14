%{
#include<iostream>
#include<cstdlib>
#include<cstring>
#include<vector>
#include<cmath>
#include "1905086_SymbolTable.h"

using namespace std;

int yyparse(void);
int yylex(void);

extern FILE *yyin;
int line_count=1,error = 0;

vector<symbol_info*> decl,argl;  // Declared variable list
vector<pair<string, string>> params; 


FILE* logout, *errOut, *ptree;

symbol_table st(11);

void printErr(string errCmd) {
	fprintf(errOut, "Line# %d: %s\n", line_count, errCmd.c_str());
	error++;
}

void takeString(symbol_info* sym, string line){
	sym->setRule(line);
	fprintf(logout, line.c_str());
}

void printTree(symbol_info* sym, int depth) {
	sym->setVisited(true);
	for (int i=0; i<depth; i++) fprintf(ptree, " "); // # spaces = depth

	if (sym->get_terminal() == false) {
		fprintf(ptree, "%s 	<Line: %d-%d>\n", sym->get_rule().c_str(), sym->get_startline(), sym->get_endline());
	}
	else {
		fprintf(ptree, "%s : %s	<Line: %d>\n", sym->get_type().c_str(), sym->get_name().c_str(), sym->get_startline());
	}

	for (symbol_info* child: sym->get_children()) {
		if (child->get_visited() == false) printTree(child, depth+1);
	}
	delete sym;
}

void yyerror(char *s)
{
	//write your code
}
void define_func1(symbol_info* &fd, string type){
			symbol_info* sym = st.LookUp(fd->get_name());
			if(sym != NULL){
				if(sym->func_type == 1){
					if(sym->get_returntype()!= type){
						string print = "Conflicting types for '"+fd->get_name()+"'";
						printErr(print);
					}
					else if(sym->get_num_of_params() > params.size()){
						string print = "Too few parameters to function '"+fd->get_name()+"'";
						printErr(print);	
						
					}
					else if(sym->get_num_of_params() < params.size()){
						string print = "Too many parameters to function '"+fd->get_name()+"'";
						printErr(print);	
						
					}
					else{ 
						 vector<symbol_info*> lists = sym->get_params();
						 for(int i = 0; i < params.size(); i++){
							//cout<<lists[i]->get_name()<<"     "<<lists[i]->get_type()<<endl;
							if(params[i].second != lists[i]->get_type() && lists[i]->get_type() != ""){
								string print = "Type mismatch for parameter "+to_string(i+1)+" '"+fd->get_name()+"'";
						        printErr(print);	
								
							}
							else if(params[i].first != lists[i]->get_name() && lists[i]->get_name() != ""){
								string print = "Name mismatch for parameter "+to_string(i+1)+" '"+fd->get_name()+"'";
						        printErr(print);	
								
							}	
					    }
				    }
					sym->setParamList(params);
					sym->func_type = 2;
				}
				else if(sym->func_type == 2){
					string print = "Redefinition of function '"+fd->get_name()+"'";
				    printErr(print);
					
				}
				else {
					string print = "'"+fd->get_name()+ "' redeclared as different kind of symbol";
				    printErr(print);	
				}
			}
			else{
				st.Insert(fd->get_name(), "Function");
				for(auto x: params){
				string a,b;
				tie(a,b) = x;
				st.LookUp(fd->get_name())->addParam(new symbol_info(a, b));
			}
			    st.LookUp(fd->get_name())->func_type = 2;
			    st.LookUp(fd->get_name())->setReturnType(type);
			}
	//cout<<"check----"<<endl;
}
void define_func2(symbol_info* &fd, string type){
			symbol_info* sym = st.LookUp(fd->get_name());
			if(sym != NULL){
				if(sym->func_type == 1){
					if(sym->get_returntype()!= type){
						string print = "Conflicting types for '"+fd->get_name()+"'";
						printErr(print);
					}
					else if(sym->get_num_of_params() > params.size()){
						string print = "Too few parameters to function '"+fd->get_name()+"'";
						printErr(print);	
					}
					sym->setParamList(params);
					sym->func_type = 2;
				}
				else if(sym->func_type == 2){
					string print = "Redeclaration of function '"+fd->get_name()+"'";
				    printErr(print);
				}

			}
			else{
				st.Insert(fd->get_name(), "Function");
				st.LookUp(fd->get_name())->func_type = 2;
			    st.LookUp(fd->get_name())->setReturnType(type);
			}

}
void insertFunctionParam(){
	for(auto x: params){
				string a,b;
				tie(a,b) = x;
				bool y = st.Insert(a, b);
			}
}
void funcCall(symbol_info* &funcID) {
	symbol_info* prevFunc = st.LookUp(funcID->get_name());
	//cout<<"in function call "<<funcID->get_name()<<endl;

	if (prevFunc == NULL) {
		string print = "Undeclared function '"+funcID->get_name()+"'";
		printErr(print);
	}
	else if (prevFunc->func_type!=1 && prevFunc->func_type!=2) {
		string print = "'"+funcID->get_name()+"' is not a function";
		printErr(print);
		funcID->setReturnType(prevFunc->get_returntype());
	}
	else if (prevFunc->func_type!=2) {
		string print = "Undefined function '"+funcID->get_name()+"'";
		printErr(print);
		funcID->setReturnType(prevFunc->get_returntype());
	}

	else if(prevFunc->get_num_of_params() > argl.size()){
		string print = "Too few arguments to function '"+funcID->get_name()+"'";
		printErr(print);
		funcID->setReturnType(prevFunc->get_returntype());
	}
	else if(prevFunc->get_num_of_params() < argl.size()){
		string print = "Too many arguments to function '"+funcID->get_name()+"'";
		printErr(print);	
		funcID->setReturnType(prevFunc->get_returntype());
	}
	else{
	vector<symbol_info*> paramList = prevFunc->get_params();
	for(int i = 0; i < argl.size(); i++){
		//cout<<"param: "<<paramList[i]->get_type()<<endl;
		symbol_info* check = st.LookUp(argl[i]->get_name());
		if(check != NULL) {
			// cout<<check->get_type()<<endl;
			if(paramList[i]->get_type() != check->get_type()&& paramList[i]->get_type() != ""){
			string print = "Type mismatch for argument " + to_string(i+1) +" of '"+funcID->get_name()+"'";
			printErr(print);
		    }
		}
		else {
			//cout<<argl[i]->get_name()<<endl;
			if(paramList[i]->get_type() != argl[i]->get_type()&& paramList[i]->get_type() != ""){
			string print = "Type mismatch for argument " + to_string(i+1) +" of '"+funcID->get_name()+"'";
			printErr(print);
		    }
			//break;
		}
	}
	funcID->setReturnType(prevFunc->get_returntype());
	}
}

%}

%union {
	symbol_info* si;
}

%token <si> IF ELSE FOR WHILE INT FLOAT VOID RETURN PRINTLN LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON 
%token <si> CONST_INT CONST_FLOAT ID ASSIGNOP NOT INCOP DECOP LOGICOP RELOP ADDOP MULOP

%type <si> start program unit func_declaration func_definition var_declaration parameter_list compound_statement type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%%

start : program
	{
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "start : program\n");
			printTree($$, 0);
	}
	;

program : program unit {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setTerminal(false);
			$$->setChild(2, $1, $2);
			takeString($$, "program : program unit\n");
		}
	| unit {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "program : unit\n");
	}
	;
	
unit : var_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : var_declaration\n");
		}
     | func_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());

			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : func_declaration\n");
	 }
     | func_definition {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : func_definition\n");
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			//----------------------change----------------------------------//
			if(st.Insert($2->get_name(), "Function")){
				for(auto x: params){
				st.LookUp($2->get_name())->addParam(new symbol_info(x.first, x.second));
			    }
			    st.LookUp($2->get_name())->func_type = 1;
			    st.LookUp($2->get_name())->setReturnType($1->get_name());
			}
			else{
				string print = "Redeclaration of function '"+$2->get_name()+"'";
				printErr(print);
			}
			//----------------------change----------------------------------//


			$$->setStartEndline($1->get_startline() , $6->get_endline());
			$$->setChild(6, $1, $2, $3, $4, $5, $6);
			$$->setTerminal(false);
			takeString($$, "func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON\n");
			params.clear();   //-----------------------------------parameter clearing-----------------------//
		}	
		| type_specifier ID LPAREN RPAREN SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			if(st.Insert($2->get_name(), "Function")){
				st.LookUp($2->get_name())->func_type = 1;
			    st.LookUp($2->get_name())->setReturnType($1->get_name());
			}
			else{
				string print = "Redeclaration of function '"+$2->get_name()+"'";
				printErr(print);
			}
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON\n");
		}
		;
		 
func_definition : type_specifier ID LPAREN parameter_list RPAREN {define_func1($2,$1->get_name());} compound_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(6, $1, $2, $3, $4, $5, $7);
			$$->setTerminal(false);
			takeString($$, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			params.clear();
		}
		| type_specifier ID LPAREN RPAREN {define_func2($2,$1->get_name());} compound_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $6->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $6);
			$$->setTerminal(false);
			takeString($$, "func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $4->get_endline());

			//-----------------------------------change--------------------------------//
			for(auto x: params){
				string a,b;
				tie(a,b) = x;
				if(a == $4->get_name()){
				    string print = "Redefinition of parameter '"+a+"'";
					printErr(print);	
				}
			}
			//-------------------------------change-----------------------------------//
			if($3->get_name() == "void"){
					string print = "parameter of '"+$4->get_name()+"' declared void";
					printErr(print);
				}
			params.push_back({$4->get_name(),$3->get_name()});     //params add
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			takeString($$, "parameter_list  : parameter_list COMMA type_specifier ID\n");
        }
		| parameter_list COMMA type_specifier {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			if($3->get_name() == "void"){
					string print = "parameter declared void";
					printErr(print);
			}
			params.push_back({"",$3->get_name()});     //params add
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "parameter_list  : parameter_list COMMA type_specifier\n");
		}
 		| type_specifier ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			if($1->get_name() == "void"){
					string print = "parameter of '"+$2->get_name()+"' declared void";
					printErr(print);
			}
			params.push_back({$2->get_name(),$1->get_name()});    //params add
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "parameter_list  : type_specifier ID\n");
		}
		| type_specifier {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			if($1->get_name() == "void"){
					string print = "parameter declared void";
					printErr(print);
			}
			params.push_back({"", $1->get_name()});       //params add
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "parameter_list  : type_specifier\n");
		}
 		;

 		
compound_statement : LCURL {st.enter_scope();insertFunctionParam();} statements RCURL {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(3, $1, $3, $4);
			$$->setTerminal(false);
			takeString($$, "compound_statement : LCURL statements RCURL\n");
			st.printAllScope();
			st.exit_scope();
			}
 		    | LCURL {st.enter_scope();} RCURL {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(2, $1, $3);
			$$->setTerminal(false);
			takeString($$, "compound_statement : LCURL RCURL\n");
			st.printAllScope();
			st.exit_scope();
			}
 		    ;
 		    
var_declaration : type_specifier declaration_list SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			for(symbol_info* temp : decl){
				if($1->get_name()=="void"){
					string print = "Variable or field '"+temp->get_name()+"' declared void";
					printErr(print);
				}
				else{
					if(st.Insert(temp->get_name(), $1->get_name()) == false){
						symbol_info* foundSym = st.LookUp(temp->get_name());
						if($1->get_name() != foundSym->get_type()){
							//cout<<st.LookUp(temp->get_name())->get_type()<<endl;
							string print = "Conflicting types for '"+temp->get_name()+"'";
							printErr(print);
						}
						else{
							string print = "Redeclaration of variable '"+temp->get_name()+"'";
							printErr(print);
						}
					}
					else{
						symbol_info* foundSym = st.LookUp(temp->get_name());
						foundSym->setArraySize(temp->getArraySize());
					}
				}
			}
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "var_declaration : type_specifier declaration_list SEMICOLON\n");
			decl.clear();
            }
 		 ;
 		 
type_specifier	: INT { 
	        $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
	        takeString($$, "type_specifier	: INT\n"); 
	        }
 		| FLOAT {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
	        takeString($$, "type_specifier	: FLOAT\n");
		}
 		| VOID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
	        takeString($$, "type_specifier	: VOID\n");
		}
 		;
 		
declaration_list : declaration_list COMMA ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			decl.push_back($3);
			takeString($$, "declaration_list : declaration_list COMMA ID\n");
            }
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $6->get_endline());
			$$->setChild(6, $1, $2, $3, $4, $5, $6);
			$$->setTerminal(false);
			$3->setArraySize($5->get_name());
			decl.push_back($3);
			takeString($$, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");
		  }
 		  | ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			decl.push_back($1);
			takeString($$, "declaration_list : ID\n");
		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			$1->setArraySize($3->get_name());
			decl.push_back($1);
			takeString($$, "declaration_list : ID LSQUARE CONST_INT RSQUARE\n");
		  }
 		  ;
 		  
statements : statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statements : statement\n");
}
	   | statements statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "statements : statements statement\n");

	   }
	   ;
	   
statement : var_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : var_declaration\n");
}
	  | expression_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : expression_statement\n");
	  }
	  | compound_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : compound_statement\n");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(7, $1, $2, $3, $4, $5, $6, $7);
			$$->setTerminal(false);
			takeString($$, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : IF LPAREN expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(7, $1, $2, $3, $4, $5, $6, $7);
			$$->setTerminal(false);
			takeString($$, "statement : IF LPAREN expression RPAREN statement ELSE statement\n");
	  }
	  | WHILE LPAREN expression RPAREN statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : WHILE LPAREN expression RPAREN statement\n");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
	  }
	  | RETURN expression SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "statement : RETURN expression SEMICOLON\n");
	  }
	  ;
	  
expression_statement : SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "expression_statement : SEMICOLON\n");
}		
			| expression SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "expression_statement : expression SEMICOLON\n");
			}
			;
	  
variable : ID {
			symbol_info *sym = st.LookUp($1->get_name());
			if(sym==NULL){
				string print = "Undeclared variable '"+$1->get_name()+"'";
				printErr(print);
			}
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "variable : ID\n");
            }		
	 | ID LSQUARE expression RSQUARE {
			symbol_info *sym = st.LookUp($1->get_name());
			if(sym != NULL){ 
				if(!sym->isAnArray()){
					string print = "'"+$1->get_name()+"'"+" is not an array";
					printErr(print);
				}
				
				if($3->get_type()!="int"){
					string print = "Array subscript is not an integer";
					printErr(print);
				}
			}else{
				string print = "Undeclared variable '"+$1->get_name()+"'";
				printErr(print);
			}

			$$ = new symbol_info($1->get_name(), sym->get_type()); // <----------------------- change [to check and catch int=float assignment error]
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			takeString($$, "variable : ID LSQUARE expression RSQUARE\n");
	 }
	 ;
	 
 expression : logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "expression : logic_expression\n");
 }
	   | variable ASSIGNOP logic_expression {
			if ($3->get_returntype() == "void") {
				string print = "Void cannot be used in expression";
				printErr(print);
			}
			else {
				if ($1->get_type()=="int" && $3->get_type()=="float") {
					string print = "Warning: possible loss of data in assignment of FLOAT to INT";
					printErr(print);
				}
			}

			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($3->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "expression : variable ASSIGNOP logic_expression\n");
	   }
	   ;
			
logic_expression : rel_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "logic_expression : rel_expression\n");
}
		 | rel_expression LOGICOP rel_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "logic_expression : rel_expression LOGICOP rel_expression\n");
		 }	
		 ;
			
rel_expression	: simple_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "rel_expression	: simple_expression\n");
         }
		| simple_expression RELOP simple_expression	{
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "rel_expression	: simple_expression RELOP simple_expression\n");
		}
		;
				
simple_expression : term {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "simple_expression : term\n");
           }
		  | simple_expression ADDOP term {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($3->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "simple_expression : simple_expression ADDOP term\n");
		  }
		  ;
					
term :	unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "term :	unary_expression\n");
}
     |  term MULOP unary_expression {
			if ($1->get_returntype() == "void" || $3->get_returntype() == "void") {
				string print = "Void cannot be used in expression";
				printErr(print);
			}
			else {
				if ($3->get_name() == "0" && ($2->get_name() == "%" || $2->get_name() == "/")) {
						string print = "Warning: division by zero";
						printErr(print);
				}
				else if($2->get_name() == "%" && ($1->get_type()!="int" || $3->get_type()!="int")){
							string print = "Operands of modulus must be integers";
							printErr(print);
				}
			}
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($2->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "term  : term MULOP unary_expression\n");
	 }
     ;

unary_expression : ADDOP unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setReturnType($2->get_returntype());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "unary_expression : ADDOP unary_expression\n");
          }
		 | NOT unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setReturnType($2->get_returntype());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "unary_expression : NOT unary_expression\n");
		 }
		 | factor {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "unary_expression : factor\n");
		 }
		 ;
	
factor	: variable {
	        $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: variable\n");
}
	| ID LPAREN argument_list RPAREN {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			funcCall($1); // Function call related errors check
			$$->setReturnType($1->get_returntype());
			argl.clear();
			takeString($$, "factor	: ID LPAREN argument_list RPAREN\n");
	}
	| LPAREN expression RPAREN {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "factor	: LPAREN expression RPAREN\n");
	}
	| CONST_INT {
		    $$ = new symbol_info($1->get_name(), "int");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: CONST_INT\n");
	}
	| CONST_FLOAT {
		    $$ = new symbol_info($1->get_name(), "float");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: CONST_FLOAT\n");
	}
	| variable INCOP {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "factor	: variable INCOP\n");
	}
	| variable DECOP {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "factor	: variable DECOP\n");
	}
	;
	
argument_list : arguments {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "argument_list : arguments\n");
}
			  |
			  ;
	
arguments : arguments COMMA logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			argl.push_back($3);
			takeString($$, "arguments : arguments COMMA logic_expression\n");
}
	      | logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			argl.push_back($1);
			takeString($$, "arguments : logic_expression\n");
		  }
	      ;
 

%%
int main(int argc,char *argv[])
{
	FILE *fin = fopen(argv[1], "r");
	if(fin==NULL)
	{
		printf("Cannot Open Input File.\n");
		exit(1);
	}
	if (argc != 2) {
		printf("Please enter input file name.");
	}
	
	logout = fopen("log.txt","w");
	errOut= fopen("error.txt","w");
	ptree = fopen("parseTree.txt", "w");

	yyin = fin;
	yyparse();

	fclose(errOut);
	fclose(ptree);
	fclose(yyin);
	
	fprintf(logout, "Total Lines: %d\n",line_count);
	fprintf(logout, "Total Errors: %d\n", error);

	fclose(logout);

	return 0;
}

