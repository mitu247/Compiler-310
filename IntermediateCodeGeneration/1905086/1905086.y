%{
#include<bits/stdc++.h>
#include "1905086_SymbolTable.h"
using namespace std;

int yyparse(void);
int yylex(void);

extern FILE *yyin;
int line_count=1,error = 0;
int offset = 0;
int n_label = 1;
string funcReturnType = "none";
bool flag = false;
int rL;

vector<symbol_info*> decl,argl; 
vector<pair<string, string>> params; 
vector<symbol_info*> globalVarList;
vector<symbol_info*> parameterList;


FILE* logout, *errOut, *ptree, *asmOut;

symbol_table st(11);
symbol_table st_new(11);

void ParseTree(symbol_info*);

void printErr(string errCmd) {
	//fprintf(errOut, "Line# %d: %s\n", line_count, errCmd.c_str());
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
	// else if (prevFunc->func_type!=2) {
	// 	string print = "Undefined function '"+funcID->get_name()+"'";
	// 	printErr(print);
	// 	funcID->setReturnType(prevFunc->get_returntype());
	// }
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
void new_line(){
    fprintf(asmOut, "new_line proc\n\tpush ax\n\tpush dx\n\tmov ah, 2\n\tmov dl, cr\n\tint 21h\n\tmov ah, 2\n\tmov dl, lf\n\tint 21h\n\tpop dx\n\tpop ax\n\tret\nnew_line endp\n");
}
void output() {
    fprintf(asmOut, "print_output proc  ;print what is in ax\n");
    fprintf(asmOut, "\tpush ax\n\tpush bx\n\tpush cx\n\tpush dx\n\tpush si\n\tlea si,number\n\tmov bx,10\n\tadd si,4\n\tcmp ax,0\n\tjnge negate\n\tprint:\n\txor dx,dx\n\tdiv bx\n\tmov [si],dl\n\tadd [si],'0'\n\tdec si\n\tcmp ax,0\n\tjne print\n\tinc si\n\tlea dx,si\n\tmov ah,9\n\tint 21h\n\tpop si\n\tpop dx\n\tpop cx\n\tpop bx\n\tpop ax\n\tret\n\tnegate:\n\tpush ax\n\tmov ah, 2\n\tmov dl,'-'\n\tint 21h\n");
    fprintf(asmOut, "\tpop ax\n\tneg ax\n\tjmp print\n");
    fprintf(asmOut, "print_output endp\n");
	fprintf(asmOut, "end main\n");
}
void PrintCode(symbol_info* node){
    fprintf(asmOut, ".MODEL SMALL\n.STACK 100h\n.DATA\n\tCR EQU 0DH\n\tLF EQU 0AH\n\tnumber DB \"00000$\"\n");
	for(int i = 0; i<globalVarList.size(); i++){
		if(globalVarList[i]->isAnArray() == false){
			fprintf(asmOut, "\t%s DW 1 DUP (0000H)\n",globalVarList[i]->get_name().c_str());
			st_new.Insert(globalVarList[i]->get_name(), "ID");
			st_new.LookUp(globalVarList[i]->get_name())->setGlobal(true);
		}
		else{
			int sz = stoi(globalVarList[i]->getArraySize());
			fprintf(asmOut,"\t%s DW %d DUP (?)\n",globalVarList[i]->get_name().c_str(),sz);
			st_new.Insert(globalVarList[i]->get_name(), "ID");
			st_new.LookUp(globalVarList[i]->get_name())->setArraySize(globalVarList[i]->getArraySize());
			st_new.LookUp(globalVarList[i]->get_name())->setGlobal(true);
		}
		
	}
	fprintf(asmOut,".CODE\n");
    ParseTree(node);
	new_line();
	output();
}
void ParseTree(symbol_info* node) {
	//cout << node->getNodeString() << endl;
	if (node->getNodeString() == "start"){
		ParseTree(node->get_children()[0]);
	}
	else if(node->getNodeString() == "program"){
		vector<symbol_info*> child = node->get_children();
		if (child.size() == 1){
			ParseTree(child[0]);	
		}
		if (child.size() == 2){
			ParseTree(child[0]);
			ParseTree(child[1]);
		}
	}
	else if(node->getNodeString() == "unit"){
		vector<symbol_info*> child = node->get_children();
			ParseTree(child[0]);
	}
	else if(node->getNodeString() == "var_declaration"){
		vector<symbol_info*> child = node->get_children();
		ParseTree(child[1]);      
	}
	else if(node->getNodeString() == "declaration_list"){
		vector<symbol_info*> child = node->get_children();
		if (child[0]->getNodeString() == "declaration_list")
			ParseTree(child[0]);

		if((child.size() == 1) || (child.size() == 3)){
			int i = (child.size() == 1) ? 0 : 2;
			if(child[i]->getGlobal() == false){
				offset+=2; 
				fprintf(asmOut, "\tSUB SP, 2\n");
				st_new.Insert(child[i]->get_name(), "ID");
				st_new.LookUp(child[i]->get_name())->setOffset(offset);
				st_new.LookUp(child[i]->get_name())->setGlobal(false);
			}
		}

		else if(child.size() == 4 || child.size() == 6){
			int i = (child.size() == 4) ? 0: 2;

			if(child[i]->getGlobal() == false){
				int a_size = stoi(child[i]->getArraySize());
				offset += 2;
				fprintf(asmOut,"\tSUB SP, %d\n",2*a_size);
				st_new.Insert(child[i]->get_name(), "ID");
				st_new.LookUp(child[i]->get_name())->setOffset(offset);
				st_new.LookUp(child[i]->get_name())->setArraySize(child[i]->getArraySize());
				st_new.LookUp(child[i]->get_name())->setGlobal(false);
			}
		}
	}
	else if(node->getNodeString() == "func_declaration"){
		vector<symbol_info*>child = node->get_children();
		if(child.size() == 6) ParseTree(child[3]);
	}
	else if(node->getNodeString() == "func_definition"){
		vector<symbol_info*> child = node->get_children();
		funcReturnType = child[0]->get_name();

		if (child[1]->get_name() == "main") {
			fprintf(asmOut, "main proc\n");
			fprintf(asmOut, "\tMOV AX, @DATA\n\tMOV DS, AX\n\tPUSH BP\n\tMOV BP, SP\n");
		}
		else {
			fprintf(asmOut, "%s proc\n", child[1]->get_name().c_str());
			fprintf(asmOut, "\tPUSH BP\n\tMOV BP, SP\n");
		}
		if(child.size() == 6){ //function_definition
			rL = n_label;
			n_label+=1;
			ParseTree(child[3]);//param_lits
			ParseTree(child[5]);//cmp_statement
			fprintf(asmOut, "L%d:\n", rL);
			//n_label += 1;
			fprintf(asmOut,"\tADD SP, %d\n",offset);
	        fprintf(asmOut,"\tPOP BP\n");
			if (child[1]->get_name() == "main") fprintf(asmOut, "\tMOV AX, 4CH\n\tINT 21H\n");
			(parameterList.size() == 0) ? fprintf(asmOut, "\tRET\n") : fprintf(asmOut, "\tRET %d\n", 2*parameterList.size());
			//fprintf(asmOut,"JMP L%d",label+1);
			parameterList.clear();
			funcReturnType = "none";
			offset = 0;
		}
		else if(child.size() == 5){
			rL = n_label;
			n_label+=1;
			ParseTree(child[4]);
			fprintf(asmOut, "L%d:\n", rL);
			//n_label += 1;
			fprintf(asmOut,"\tADD SP, %d\n",offset);
	        fprintf(asmOut,"\tPOP BP\n");
			if (child[1]->get_name() == "main") fprintf(asmOut, "\tMOV AX, 4CH\n\tINT 21H\n");
			fprintf(asmOut, "\tRET\n");
			offset = 0;
			funcReturnType = "none";
			
		}
		fprintf(asmOut, "%s ENDP\n", child[1]->get_name().c_str());
		
	}
	else if(node->getNodeString() == "parameter_list"){
		vector<symbol_info*> child = node->get_children();
		ParseTree(child[0]);
		if(child.size() == 2){
			parameterList.push_back(child[1]);
		}
		if(child.size() == 4){
			parameterList.push_back(child[3]);
		}
		
	}
	else if(node->getNodeString() == "compound_statement"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3) {
			 st_new.enter_scope();
             ParseTree(child[1]);//statement
			 //fprintf(asmOut, "L%d:\n",n_label);
			 //POP BP 
			 st_new.exit_scope();//rcurl
		}
		else {
			st_new.enter_scope();
			//fprintf(asmOut, "L%d:\n",n_label);
			st_new.exit_scope();
		}
		
	}
	else if(node->getNodeString() == "statements"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 2){
			ParseTree(child[0]);
			ParseTree(child[1]);
		} else{
			ParseTree(child[0]);
		}	
	}
	else if(node->getNodeString() == "statement"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 1){ 
			ParseTree(child[0]);
		}
		else if(child.size() == 3){

			ParseTree(child[1]); 
			// "RETURN"
			if (funcReturnType != "none") {
				fprintf(asmOut, "\tPOP AX\n");
			}
			fprintf(asmOut,"\tJMP L%d\n",rL);
		}
		else if(child.size() == 7){//for
			if(child[2]->getNodeString() == "expression_statement"){
				flag = false;
				ParseTree(child[2]);
				fprintf(asmOut, "L%d:\n",n_label);
				int l1 = n_label;
				n_label+=1;
			    ParseTree(child[3]);
				int label = n_label;
				fprintf(asmOut, "L%d:\n",n_label);//condition_check
				if(flag){
						flag = false;
					}
				else{
						fprintf(asmOut, "\tPOP AX\n");
					}
				fprintf(asmOut, "\tCMP AX, 0\n");
				fprintf(asmOut, "\tJNE L%d\n",n_label+1);//statement
				fprintf(asmOut, "\tJMP L%d\n", n_label+2);//out
				n_label+=3;
				fprintf(asmOut, "L%d:\n",n_label);
				n_label+=1;
			    ParseTree(child[4]);
				fprintf(asmOut, "\tJMP L%d\n",l1);//lw
				fprintf(asmOut, "L%d:\n",label+1);
			    ParseTree(child[6]);
				fprintf(asmOut, "\tJMP L%d\n", label+3);
				fprintf(asmOut, "L%d:\n",label+2);
				n_label+=1;
			}
			else{
				ParseTree(child[2]);
				fprintf(asmOut, "L%d:\n", n_label);
				n_label+=1;
				int label = n_label;
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut, "\tCMP AX, 0\n");
				fprintf(asmOut, "\tJNE L%d\n",n_label);
				fprintf(asmOut, "\tJMP L%d\n", n_label+1);
				fprintf(asmOut, "L%d:\n", n_label);
				n_label+=3;
			    ParseTree(child[4]);
				fprintf(asmOut, "\tJMP L%d\n",label+2);
				fprintf(asmOut, "L%d:\n", label+1);
				n_label+=1;
			    ParseTree(child[6]);
				fprintf(asmOut, "\tJMP L%d\n",label+2);
				fprintf(asmOut, "L%d:\n", label+2);
				n_label+=1;
			}
		}
		else if(child.size() == 5){
			if(child[2]->getNodeString() == "expression"){
				if(child[0]->get_name() == "if"){
					ParseTree(child[2]);
					fprintf(asmOut, "L%d:\n", n_label);
				    n_label+=1;
					int label = n_label;
					fprintf(asmOut, "\tPOP AX\n");
					fprintf(asmOut, "\tCMP AX, 0\n");
					fprintf(asmOut, "\tJNE L%d\n",n_label);
					fprintf(asmOut, "\tJMP L%d\n", n_label+1);
					fprintf(asmOut, "L%d:\n", n_label);
					n_label+=2;
					ParseTree(child[4]);
					fprintf(asmOut, "\tJMP L%d\n",label+1);
					fprintf(asmOut,"L%d:\n", label+1);
					n_label+=1;
				}
				else{//while
					flag = false;
					fprintf(asmOut, "L%d:\n",n_label);
				    int l1 = n_label;
				    n_label+=1;
					ParseTree(child[2]);
					int label = n_label;
					fprintf(asmOut, "L%d:\n",n_label);
					if(flag){
						flag = false;
					}
					else{
						fprintf(asmOut, "\tPOP AX\n");
					}
					fprintf(asmOut, "\tCMP AX, 0\n");
					fprintf(asmOut, "\tJNE L%d\n",n_label+1);
					fprintf(asmOut, "\tJMP L%d\n", n_label+2);
					n_label+=3;
					fprintf(asmOut, "L%d:\n",label+1);
					ParseTree(child[4]);
					fprintf(asmOut, "\tJMP L%d\n",l1);
					fprintf(asmOut, "L%d:\n", label+2);
					n_label+=1;
				}
			}
			else{ // println
				symbol_info* foundSym = st_new.LookUp(child[2]->get_name());
				fprintf(asmOut, "L%d:\n", n_label);
				n_label += 1;
				if(foundSym->getGlobal())fprintf(asmOut,"\tMOV AX, %s\n",foundSym->get_name().c_str());
				else
					fprintf(asmOut,"\tMOV AX, [BP-%d]\n",foundSym->get_offset());
				fprintf(asmOut,"\tCALL print_output\n\tCALL new_line\n");
			}
		}
	}
	else if(node->getNodeString() == "expression_statement"){
		vector<symbol_info*> child = node->get_children();
		if(child.size()==2){
		fprintf(asmOut, "L%d:\n",n_label);
		n_label+=1;	
		ParseTree(child[0]);
		} 
	}
	else if(node->getNodeString() == "variable"){
		vector<symbol_info*> child = node->get_children();
		if (child.size() == 1) {
			// single variable , not array
			symbol_info* var = st_new.LookUp(child[0]->get_name());

			if (node->getOp() != "assign"){
				// variables are not in main function
				for (int i=0; i<parameterList.size(); i++) {
					symbol_info* si = parameterList[i];
					if (si->get_name() == child[0]->get_name()) // so the var is in the parameter list
					{
						int localOffset = (i*2)+4;
						fprintf(asmOut, "\tMOV AX, [BP+%d]\n", localOffset);
						fprintf(asmOut, "\tPUSH AX\n");
						return;
					}
				}
				if (var->getGlobal()) {
					fprintf(asmOut, "\tMOV AX, %s\n", var->get_name().c_str());
					fprintf(asmOut, "\tPUSH AX\n");
				}
				else {
					fprintf(asmOut, "\tMOV AX, [BP-%d]\n", var->get_offset());
					fprintf(asmOut, "\tPUSH AX\n");
				}
				
			}
			else { 
				// variables are not in main function
				for (int i=0; i<parameterList.size(); i++) {
					symbol_info* si = parameterList[i];
					if (si->get_name() == child[0]->get_name()) // so the var is in the parameter list
					{
						int localOffset = (i*2)+4;
						fprintf(asmOut, "\tPOP AX\n");
						fprintf(asmOut, "\tMOV [BP+%d], AX\n", localOffset);
						return;
					}
				}
				if (var->getGlobal()) {
					fprintf(asmOut, "\tPOP AX\n");
					fprintf(asmOut, "\tMOV %s, AX\n", var->get_name().c_str());}
				else {
					fprintf(asmOut, "\tPOP AX\n");
					fprintf(asmOut, "\tMOV [BP-%d], AX\n", var->get_offset());
				}
				
			}
		}
		if(child.size() == 4) {
			symbol_info* var = st_new.LookUp(child[0]->get_name());
			//ParseTree(child[1]);
			ParseTree(child[2]);
			if(var->getGlobal() == false){
			int st_offset = var->get_offset();
			fprintf(asmOut,"\tPOP AX;array tried but failed\n");
			fprintf(asmOut,"\tMOV BX, 2\n");
			fprintf(asmOut,"\tCWD\n");
			fprintf(asmOut,"\tMUL BX\n");
			fprintf(asmOut,"\tADD AX, %d\n",st_offset);
			fprintf(asmOut,"\tMOV DI, AX\n");
			fprintf(asmOut,"\tPOP AX\n");
			fprintf(asmOut,"\tPUSH BP\n");
			fprintf(asmOut, "\tSUB BP, DI\n");
			if(node->getOp() == "assign"){
			    fprintf(asmOut, "\tMOV [BP], AX\n");
			}
			else{
				fprintf(asmOut, "\tMOV AX, [BP]\n");
			}    
            fprintf(asmOut, "\tPOP BP\n");
			}
		}
	}
	else if(node->getNodeString() == "expression"){
		vector<symbol_info*> child = node->get_children();
		if(child[0]->getNodeString() == "variable"){
			ParseTree(child[2]);
			child[0]->setOp("assign"); 
			ParseTree(child[0]);
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "logic_expression"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3){
			ParseTree(child[0]);
			ParseTree(child[2]);
			fprintf(asmOut, "\tPOP BX\n");
			fprintf(asmOut, "\tPOP AX\n");
			fprintf(asmOut, "\tCMP AX, 0\n");///change
			if(child[1]->get_name() == "||"){
				fprintf(asmOut, "\tJNE L%d\n",n_label);
				fprintf(asmOut, "\tJMP L%d\n",n_label+1);
				fprintf(asmOut, "L%d:\n", n_label);
				fprintf(asmOut, "\tMOV AX, 1\n");
				fprintf(asmOut, "\tPUSH AX\n");
				fprintf(asmOut, "\tJMP L%d\n", n_label+3);
				fprintf(asmOut, "L%d:\n", n_label+1);
				fprintf(asmOut, "\tCMP BX, 0\n");///change
				fprintf(asmOut, "\tJNE L%d\n",n_label);
				fprintf(asmOut, "L%d:\n", n_label+2);
				fprintf(asmOut, "\tMOV AX, 0\n");
				fprintf(asmOut, "\tPUSH AX\n");
				n_label+=3;
				fprintf(asmOut, "L%d:\n", n_label);
				n_label+=1;
			}
			else if(child[1]->get_name() == "&&"){
				fprintf(asmOut, "\tJNE L%d\n",n_label);//change
				fprintf(asmOut, "\tJMP L%d\n",n_label+1);
				fprintf(asmOut, "L%d:\n", n_label);
				fprintf(asmOut, "\tCMP BX, 0\n");
				fprintf(asmOut, "\tJNE L%d\n",n_label+2); //change
				fprintf(asmOut, "L%d:\n", n_label+1);
				fprintf(asmOut, "\tMOV AX, 0\n");
				fprintf(asmOut, "\tPUSH AX\n");
				fprintf(asmOut, "\tJMP L%d\n", n_label+3);
				fprintf(asmOut, "L%d:\n", n_label+2);
				fprintf(asmOut, "\tMOV AX, 1\n");
				fprintf(asmOut, "\tPUSH AX\n");
				n_label+=3;
				fprintf(asmOut, "L%d:\n", n_label);
				n_label += 1;
			}
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "rel_expression"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3){
			ParseTree(child[0]);
			ParseTree(child[2]);
			fprintf(asmOut,"\tPOP BX\n");
			fprintf(asmOut,"\tPOP AX\n");
			fprintf(asmOut, "\tCMP AX, BX\n");
                
			if(child[1]->get_name() == "<=") {
				fprintf(asmOut, "\tJLE L%d\n", n_label);
			}
			else if(child[1]->get_name() == "<") {
				fprintf(asmOut, "\tJL L%d\n", n_label);
			}
			else if (child[1]->get_name() == ">") {
				fprintf(asmOut, "\tJG L%d\n", n_label);
			}
			else if (child[1]->get_name() == ">=") {
				fprintf(asmOut, "\tJGE L%d\n", n_label);
			}
			else if (child[1]->get_name() == "==") {
				fprintf(asmOut, "\tJE L%d\n", n_label);
			}
			else if (child[1]->get_name() == "!=") {
				fprintf(asmOut, "\tJNE L%d\n", n_label);
			}
			fprintf(asmOut, "\tJMP L%d\n", n_label+1);
			fprintf(asmOut, "L%d:\n", n_label);
			fprintf(asmOut, "\tMOV AX, 1\n");
			fprintf(asmOut, "\tPUSH AX\n");
			fprintf(asmOut, "\tJMP L%d\n", n_label+2);
			fprintf(asmOut, "L%d:\n", n_label+1);
			fprintf(asmOut, "\tMOV AX, 0\n");
			fprintf(asmOut, "\tPUSH AX\n");
			n_label += 2;
			fprintf(asmOut, "L%d:\n", n_label);
			n_label += 1;
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "simple_expression"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3){
			ParseTree(child[0]);
			ParseTree(child[2]); 
			if (child[1]->get_name() == "+") {
				fprintf(asmOut, "\tPOP BX\n");
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut, "\tADD AX, BX\n");
				fprintf(asmOut, "\tPUSH AX\n");
			}
			else{
				fprintf(asmOut, "\tPOP BX\n");
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut, "\tSUB AX, BX\n");
				fprintf(asmOut, "\tPUSH AX\n");
			}
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "term"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3){
			ParseTree(child[0]);
			ParseTree(child[2]);
			if(child[1]->get_name() == "*"){
				fprintf(asmOut, "\tPOP BX\n");
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut,"\tCWD\n");
				fprintf(asmOut,"\tMUL BX\n");
				fprintf(asmOut, "\tPUSH AX\n");
			}
			else if(child[1]->get_name() == "/"){
				fprintf(asmOut, "\tPOP BX\n");
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut,"\tCWD\n");
			    fprintf(asmOut,"\tDIV BX\n");
				fprintf(asmOut, "\tPUSH AX\n");
			}
			else if(child[1]->get_name() == "%"){
				fprintf(asmOut, "\tPOP BX\n");
				fprintf(asmOut, "\tPOP AX\n");
				fprintf(asmOut, "\tCWD\n");
			    fprintf(asmOut,"\tDIV BX\n");
				fprintf(asmOut, "\tMOV AX,DX\n");
				fprintf(asmOut, "\tPUSH AX\n"); 
			}
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "unary_expression"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 2){
			ParseTree(child[1]);
			 if (child[0]->get_name() == "-") {
                fprintf(asmOut, "\tPOP AX\n");
                fprintf(asmOut, "\tNEG AX\n");
                fprintf(asmOut, "\tPUSH AX\n");
            }
            else if(child[0]->get_name() == "!") {
                fprintf(asmOut, "\tPOP AX\n");
                fprintf(asmOut, "\tNOT AX\n");
                fprintf(asmOut, "\tPUSH AX\n");
            }
		}
		else {
			ParseTree(child[0]);
		}
	}
	else if(node->getNodeString() == "factor"){
		vector<symbol_info*> child = node->get_children();
		if (child.size() == 1) {
			if(child[0]->getNodeString() == "variable"){
				ParseTree(child[0]);
			}
			else {
				fprintf(asmOut, "\tMOV AX, %s\n", child[0]->get_name().c_str());
				fprintf(asmOut, "\tPUSH AX\n");
			}
		}
		else if(child.size() == 3){
			ParseTree(child[1]);
		}
		else if(child.size() == 4){
			ParseTree(child[2]);
			fprintf(asmOut, "\tCALL %s\n",child[0]->get_name().c_str());
			fprintf(asmOut, "\tPUSH AX\n");
		}
		else if(child.size() == 2){
		ParseTree(child[0]); // accessing the variable
		if (child[1]->get_name() == "++") {
            fprintf(asmOut, "\tINC AX\n");
            fprintf(asmOut, "\tPUSH AX\n");
			flag = true;
        }
        else if (child[1]->get_name() == "--") {
            fprintf(asmOut, "\tDEC AX\n");
            fprintf(asmOut, "\tPUSH AX\n");
			flag = true;
        }
		child[0]->setOp("assign");
		ParseTree(child[0]);
		fprintf(asmOut, "\tPOP AX\n");   //problem
		
		}
	}
	else if(node->getNodeString() == "argument_list"){
		vector<symbol_info*> child = node->get_children();
		ParseTree(child[0]);
	}
	else if(node->getNodeString() == "arguments"){
		vector<symbol_info*> child = node->get_children();
		if(child.size() == 3){
			ParseTree(child[2]);
			ParseTree(child[0]);
		}
		else {
			ParseTree(child[0]);
		}
	}
}
void optimizeAsmCode() {
    ifstream unOptasmCode("code.asm");

    ofstream optasmCode("optimized_code.asm", ios::out);
    vector<string> lineCodes;
    string singleLine;

    while(getline(unOptasmCode, singleLine)) {
        lineCodes.push_back(singleLine);
    }

    // optimizing
    for (int i=0; i<lineCodes.size(); i++) {
        if (i+1 > lineCodes.size() || lineCodes[i].size()<4 || lineCodes[i+1].size()<4) {}
        // not cwd or others 
        else if ((lineCodes[i].substr(1, 3) == "MOV") && (lineCodes[i+1].substr(1, 3) == "MOV")) {
            string reg1 = lineCodes[i].substr(4);
            string reg2 = lineCodes[i+1].substr(4);

            int deleteIdx1 = reg1.find(",");
            int deleteIdx2 = reg1.find(",");

            if (reg1.substr(1, deleteIdx1-1) == reg2.substr(deleteIdx2+2)) {
                if (reg1.substr(deleteIdx1+2) == reg2.substr(1, deleteIdx2-1)) {
                    optasmCode << "\t; redundant MOV removed" << endl;
                    i++; continue;
                }
            }
        }
        else if ((lineCodes[i].substr(1, 4)=="PUSH") && (lineCodes[i+1].substr(1, 3)=="POP"))
        {
            string reg1 = lineCodes[i].substr(5); // get registers
            string reg2 = lineCodes[i+1].substr(4);

            if (reg1.substr(1) == reg2.substr(1)) {
                optasmCode << "\t; unused push pop removed" << endl;
                i++;
                continue;
            }
        }
        optasmCode << lineCodes[i] << endl;
    }
}

%}

%union {
	symbol_info* si;
}

%token <si> IF ELSE FOR WHILE INT FLOAT VOID RETURN PRINTLN LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON 
%token <si> CONST_INT CONST_FLOAT ID ASSIGNOP NOT INCOP DECOP LOGICOP RELOP ADDOP MULOP

%type <si> start program unit func_declaration func_definition var_declaration parameter_list compound_statement type_specifier declaration_list statements statement expression_statement variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%

start : program
	{
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("start");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "start : program\n");
			PrintCode($$);
			printTree($$, 0);
	}
	;

program : program unit {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("program");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setTerminal(false);
			$$->setChild(2, $1, $2);
			takeString($$, "program : program unit\n");
		}
	| unit {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("program");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "program : unit\n");
	}
	;
	
unit : var_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unit");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : var_declaration\n");
		}
     | func_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unit");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : func_declaration\n");
	 }
     | func_definition {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unit");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			$$->setChild(1, $1);
			takeString($$, "unit : func_definition\n");
	 }
     ;
     
func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("func_declaration");

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
			$$->setNodeString("func_declaration");

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
			$$->setNodeString("func_definition");
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(6, $1, $2, $3, $4, $5, $7);
			$$->setTerminal(false);
			takeString($$, "func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement\n");
			params.clear();
		}
		| type_specifier ID LPAREN RPAREN {define_func2($2,$1->get_name());} compound_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("func_definition");
			$$->setStartEndline($1->get_startline() , $6->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $6);
			$$->setTerminal(false);
			takeString($$, "func_definition : type_specifier ID LPAREN RPAREN compound_statement\n");
		}
 		;				


parameter_list  : parameter_list COMMA type_specifier ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("parameter_list");

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
			$$->setNodeString("parameter_list");
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
			$$->setNodeString("parameter_list");

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
			$$->setNodeString("parameter_list");
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
			$$->setNodeString("compound_statement");
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(3, $1, $3, $4);
			$$->setTerminal(false);
			takeString($$, "compound_statement : LCURL statements RCURL\n");
			st.printAllScope();
			st.exit_scope();
			}
 		    | LCURL {st.enter_scope();} RCURL {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("compound_statement");
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
			$$->setNodeString("var_declaration");

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
						if(st.getScopeTableNo() == 1)
						{
							globalVarList.push_back(foundSym);
						}
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
			$$->setNodeString("type_specifier");
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
			if(st.getScopeTableNo() == 1){
				$3->setGlobal(true);
			}
			else{
				$3->setGlobal(false);
			}
			$$->setNodeString("declaration_list");
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			decl.push_back($3);
			takeString($$, "declaration_list : declaration_list COMMA ID\n");
            }
 		  | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("declaration_list");
			$$->setStartEndline($1->get_startline() , $6->get_endline());
			$3->setArraySize($5->get_name());
			if(st.getScopeTableNo() == 1){
				$3->setGlobal(true);
			}
			else{
				$3->setGlobal(false);
			}
			$$->setChild(6, $1, $2, $3, $4, $5, $6);
			$$->setTerminal(false);
			decl.push_back($3);
			takeString($$, "declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE\n");
		  }
 		  | ID {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("declaration_list");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setTerminal(false);
			if(st.getScopeTableNo() == 1){
				$1->setGlobal(true);
			}
			else{
				$1->setGlobal(false);
			}
			$$->setChild(1, $1);
			decl.push_back($1);
			takeString($$, "declaration_list : ID\n");
		  }
 		  | ID LSQUARE CONST_INT RSQUARE {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("declaration_list");
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$1->setArraySize($3->get_name());
			if(st.getScopeTableNo() == 1){
				$1->setGlobal(true);
			}
			else{
				$1->setGlobal(false);
			}
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			$1->setArraySize($3->get_name());
			decl.push_back($1);
			takeString($$, "declaration_list : ID LSQUARE CONST_INT RSQUARE\n");
		  }
 		  ;
 		  
statements : statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statements");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statements : statement\n");
}
	   | statements statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statements");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "statements : statements statement\n");

	   }
	   ;
	   
statement : var_declaration {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : var_declaration\n");
}
	  | expression_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : expression_statement\n");
	  }
	  | compound_statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "statement : compound_statement\n");
	  }
	  | FOR LPAREN expression_statement expression_statement expression RPAREN statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(7, $1, $2, $3, $4, $5, $6, $7);
			$$->setTerminal(false);
			takeString($$, "statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : IF LPAREN expression RPAREN statement\n");
	  }
	  | IF LPAREN expression RPAREN statement ELSE statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $7->get_endline());
			$$->setChild(7, $1, $2, $3, $4, $5, $6, $7);
			$$->setTerminal(false);
			takeString($$, "statement : IF LPAREN expression RPAREN statement ELSE statement\n");
	  }
	  | WHILE LPAREN expression RPAREN statement {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : WHILE LPAREN expression RPAREN statement\n");
	  }
	  | PRINTLN LPAREN ID RPAREN SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $5->get_endline());
			$$->setChild(5, $1, $2, $3, $4, $5);
			$$->setTerminal(false);
			takeString($$, "statement : PRINTLN LPAREN ID RPAREN SEMICOLON\n");
	  }
	  | RETURN expression SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("statement");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "statement : RETURN expression SEMICOLON\n");
	  }
	  ;
	  
expression_statement : SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("expression_statement");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "expression_statement : SEMICOLON\n");
}		
			| expression SEMICOLON {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("expression_statement");
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
			$$->setNodeString("variable");
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

			$$ = new symbol_info($1->get_name(), sym->get_type());
			$$->setNodeString("variable");
			$$->setStartEndline($1->get_startline() , $4->get_endline());
			$$->setChild(4, $1, $2, $3, $4);
			$$->setTerminal(false);
			takeString($$, "variable : ID LSQUARE expression RSQUARE\n");
	 }
	 ;
	 
 expression : logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("expression");
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
			$$->setNodeString("expression");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($3->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "expression : variable ASSIGNOP logic_expression\n");
	   }
	   ;
			
logic_expression : rel_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("logic_expression");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "logic_expression : rel_expression\n");
}
		 | rel_expression LOGICOP rel_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("logic_expression");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "logic_expression : rel_expression LOGICOP rel_expression\n");
		 }	
		 ;
			
rel_expression	: simple_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("rel_expression");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "rel_expression	: simple_expression\n");
         }
		| simple_expression RELOP simple_expression	{
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("rel_expression");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "rel_expression	: simple_expression RELOP simple_expression\n");
		}
		;
				
simple_expression : term {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("simple_expression");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "simple_expression : term\n");
           }
		  | simple_expression ADDOP term {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("simple_expression");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($3->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "simple_expression : simple_expression ADDOP term\n");
		  }
		  ;
					
term :	unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("term");
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
			$$->setNodeString("term");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "term  : term MULOP unary_expression\n");
	 }
     ;

unary_expression : ADDOP unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unary_expression");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setReturnType($2->get_returntype());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "unary_expression : ADDOP unary_expression\n");
          }
		 | NOT unary_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unary_expression");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setReturnType($2->get_returntype());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "unary_expression : NOT unary_expression\n");
		 }
		 | factor {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("unary_expression");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setReturnType($1->get_returntype());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "unary_expression : factor\n");
		 }
		 ;
	
factor	: variable {
	        $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: variable\n");
}
	| ID LPAREN argument_list RPAREN {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("factor");
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
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			takeString($$, "factor	: LPAREN expression RPAREN\n");
	}
	| CONST_INT {
		    $$ = new symbol_info($1->get_name(), "int");
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: CONST_INT\n");
	}
	| CONST_FLOAT {
		    $$ = new symbol_info($1->get_name(), "float");
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "factor	: CONST_FLOAT\n");
	}
	| variable INCOP {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "factor	: variable INCOP\n");
	}
	| variable DECOP {
		    $$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("factor");
			$$->setStartEndline($1->get_startline() , $2->get_endline());
			$$->setChild(2, $1, $2);
			$$->setTerminal(false);
			takeString($$, "factor	: variable DECOP\n");
	}
	;
	
argument_list : arguments {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("argument_list");
			$$->setStartEndline($1->get_startline() , $1->get_endline());
			$$->setChild(1, $1);
			$$->setTerminal(false);
			takeString($$, "argument_list : arguments\n");
}
			  |
			  ;
	
arguments : arguments COMMA logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("arguments");
			$$->setStartEndline($1->get_startline() , $3->get_endline());
			$$->setChild(3, $1, $2, $3);
			$$->setTerminal(false);
			argl.push_back($3);
			takeString($$, "arguments : arguments COMMA logic_expression\n");
}
	      | logic_expression {
			$$ = new symbol_info($1->get_name(), $1->get_type());
			$$->setNodeString("arguments");
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
	asmOut = fopen("code.asm", "w");
	ptree = fopen("parseTree.txt", "w");

	yyin = fin;
	yyparse();

	fclose(errOut);
	fclose(ptree);
	fclose(yyin);
	
	fprintf(logout, "Total Lines: %d\n",line_count);
	fprintf(logout, "Total Errors: %d\n", error);

	fclose(logout);
	fclose(asmOut);
	//optasmCode = fopen("optimized_code.asm", "w");
	optimizeAsmCode();
	return 0;
}

