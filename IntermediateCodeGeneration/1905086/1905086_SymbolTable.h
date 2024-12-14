#ifndef ST_HEADER
#define ST_HEADER

#include<bits/stdc++.h>
#include<string>
#include <cstdarg>

using namespace std;
extern FILE* logout;

class symbol_info{
    private:
    vector<symbol_info*> children;
    vector<symbol_info*> param_list;
    string name;
    string type;
    string returnType;
    string rule;
    string arraySize;
    string nodeString;
    bool terminal;
    bool visited;
    int startline;
    int endline;
    int offset;
    bool global;
    string op;
    public:

    int func_type;
    symbol_info* next;
    symbol_info(){
        this->name = "";
        this->type = "";
        this->visited = false;
        func_type = 0;
        arraySize = "";
    }
    symbol_info(string name, string type = " "){
      this->name = name;
      this->type = type;
      this->visited = false;
      offset = 0;
      arraySize = "";
    }
    //setter
    void setNodeString(string node){
        this->nodeString = node;
    }
    string getNodeString(){
        return this->nodeString;
    }
    void setGlobal(bool value){
        this->global = value;
    }
    bool getGlobal(){
        return this->global;
    }
    void setType(string type) {
        this->type = type;
    }
    void setTerminal(bool terminal){
        this->terminal = terminal;
    }
    void setStartEndline(int line1,int line2){
        this->startline = line1;
        this->endline = line2;
    }
    void setRule(string line){
        this->rule = line;
    }
    void setReturnType(string returnType){
        this->returnType = returnType;
    }
    void setVisited(bool visited) {
        this->visited = visited;
    }
    void setOffset(int offset){
        this->offset = offset;
    }
    void setChild(int numOfChild, ...) {
        va_list valist;
        int i;
        va_start(valist, numOfChild); //initialize valist for num number of arguments

        for (i = 0; i < numOfChild; i++) { //access all the arguments assigned to valist
            symbol_info* sym = va_arg(valist, symbol_info*);
            // printf("%s\n", sym->get_name().c_str());
            this->children.push_back(sym);
        }
        va_end(valist); 
    }
    void addParam(symbol_info* sym){
        param_list.push_back(sym);
    }
    void setParamList(vector<pair<string,string>> params){
        this->param_list.clear();
        for(auto x: params){
				string a,b;
				tie(a,b) = x;
				addParam(new symbol_info(a, b));
			}
    }
    void setArraySize(string size) {
        arraySize = size;
    }

    //getter
    string get_name(){
        return this->name;
    }
    string get_type(){
        return this->type;
    }
    bool get_terminal(){
        return this->terminal;
    }
    int get_startline(){
        return this->startline;
    }
    int get_endline(){
        return this->endline;
    }
    int get_offset(){
        return this->offset; 
    }
    string get_returntype(){
        return this->returnType;
    }

    string get_rule() {
        int len = rule.size();
        rule[len-1] = '\0';
        // Replacing the last "\n"
        return this->rule;
    }
    bool get_visited() {
        return this->visited;
    }
    
    vector<symbol_info*> get_children() {
        return this->children;
    }
    vector<symbol_info*> get_params(){
        return this->param_list;
    }
    int get_num_of_params(){
        return this->param_list.size();
    }
    string getArraySize() {
        return arraySize;
    }
    // Checkers
    bool isAnArray() {
        return (arraySize.size() == 0 ? false : true);
    }

    void setOp(string op) {
        this->op = op;
    }

    string getOp() {
        return this->op;
    }
};

class scope_table{
    private:
    int num_buckets;
    symbol_info** linkers;
    scope_table* parentScope;
    int listSize, hashVal, tableID;
    void chain_append(symbol_info *&head,symbol_info n_obj){
        symbol_info* sym = new symbol_info(n_obj.get_name(), n_obj.get_type());
        sym->next = NULL;
        listSize = 1;
        symbol_info* temp = head;
        if(head == NULL){
            head = sym;
        }
        else{
            listSize++;
           while(temp->next!=NULL){
            temp = temp->next;
            listSize++;
           }
           temp->next = sym;
        }
    }
    bool chain_delete(symbol_info *&head, symbol_info n_obj){
        symbol_info* temp = head;
        symbol_info* prev = NULL;
        listSize = 1;
        if(temp != NULL && temp->get_name() == n_obj.get_name()){
            head = temp->next;
            delete temp;
            return true;
        }
        else{
            while (temp != NULL && temp->get_name() != n_obj.get_name())
            {
                prev = temp;
                temp = temp->next;
                listSize++;
            }
            if(temp == NULL){
                return false;
            }
            prev->next = temp->next;
            delete temp;
        }
        return true;
    }
    bool chain_search(symbol_info* head, symbol_info n_obj ){
        if(head == NULL) return false;
         symbol_info* temp = head;
         listSize = 1;
         while(temp!=NULL && temp->get_name() != n_obj.get_name())
         {
            listSize++;
            temp = temp->next;
         }
         if(temp == NULL) return false;
         else return true;
    }

    const char* toUpper(string test) {
        for (int i=0; i<test.size(); i++) 
            test[i] = toupper(test[i]);
        return test.c_str();
    }
    
    void display(symbol_info* head){
        symbol_info* ptr = head;
        while(ptr != NULL){
            //cout<<"<"<<ptr->get_name()<<","<<ptr->get_type()<<"> ";
            if (ptr->isAnArray())
                fprintf(logout, "<%s, ARRAY, %s> ", ptr->get_name().c_str(), toUpper(ptr->get_type()));
            else if (ptr->func_type==1 || ptr->func_type==2)
                fprintf(logout, "<%s, FUNCTION, %s> ", ptr->get_name().c_str(), toUpper(ptr->get_returntype()));
            else
                fprintf(logout, "<%s, %s> ", ptr->get_name().c_str(), toUpper(ptr->get_type()));
            ptr = ptr->next;
        }
    }

    int sdbm_hash(string str) {

        int hash = 0;
        int len = str.length();

        for (int i = 0; i < len; i++)
        {
            hash = ((str[i]) + (hash << 6) + (hash << 16) - hash) % num_buckets;
        }
        return hash;
    }
    
public:
    scope_table(int num_buckets){
        this->num_buckets = num_buckets;
        linkers = new symbol_info* [num_buckets+1];
        parentScope = NULL;
        for(int i = 0; i <= num_buckets; i++) linkers[i] = NULL;
    }
    ~scope_table(){
        for(int i = 0; i <= num_buckets; i++) {
            symbol_info* temp = linkers[i];
            symbol_info* curr = temp;
            while(temp != NULL){
            curr = temp;
            temp = temp->next;
            delete curr;
           }
        }
        delete [] linkers;
    }
    scope_table* getPscope(){
        return parentScope;
    }
    void setPscope(scope_table* ptr){
        parentScope = ptr;
    }
    void setScopeTableID(int tId){
        this->tableID = tId;
    }
    bool insert(string name, string type){
        int hash = sdbm_hash(name);
        hashVal = hash%num_buckets + 1;
        if(chain_search(linkers[hashVal], symbol_info(name)) == false){
            // cout<<"before chain append"<<endl;
            chain_append(linkers[hashVal],symbol_info(name,type));
           // cout<<"after chain append"<<endl;
            return true;
        }
        else{
            return false;
        }
    }
    bool deletion(string name){
        int hash = sdbm_hash(name);
        hashVal = hash%num_buckets + 1;
        if(chain_delete(linkers[hashVal],symbol_info(name)) == true){
            return true;
        }
        else{
            return false;
        }
    }
    symbol_info* look_up(string name){
        int hash = sdbm_hash(name);
        listSize = 1;
        hashVal = hash%num_buckets + 1;
        symbol_info* temp = linkers[hashVal];
        while(temp!=NULL && temp->get_name() != name){
            temp = temp->next;
            listSize++;
        }
        return temp;
    }
    void print(){
        for(int i = 1; i <= num_buckets; i++){
            //cout << "	" << i << "--> ";
            if (linkers[i]) {
                fprintf(logout, "	%d--> ", i);
                display(linkers[i]);
                fprintf(logout, "\n");
            }
        }
    }
    int getIndex(){
        return hashVal;
    }
    int getPosition(){
        return listSize;
    }
    int getSTNo() {
        return tableID;
    }
};


class symbol_table{
    private:
    scope_table* current_scope;
    scope_table* root_scope;
    int scopeTableNo, bucketSize;

    public:
    symbol_table(int num_buckets){
        this->bucketSize = num_buckets;
        scopeTableNo = 1;
        scope_table* st = new scope_table(bucketSize);
        st->setScopeTableID(scopeTableNo);
        root_scope = st;
        current_scope = st;
        root_scope->setPscope(NULL);
        current_scope->setPscope(NULL);
    }
    ~symbol_table(){
        scope_table* temp = current_scope;
    
        while(temp != NULL){
            current_scope = current_scope->getPscope();
            delete temp;
            temp = current_scope;
        }
    }
    void enter_scope(){
        scopeTableNo = scopeTableNo + 1;
        scope_table* st = new scope_table(bucketSize);
        st->setScopeTableID(scopeTableNo);
        st->setPscope(current_scope);
        current_scope = st;
    }
    void exit_scope(){
        int scopeTableID;
        if(current_scope == root_scope) {
            return;
        }
        scope_table* temp = current_scope;
        scopeTableID = temp->getSTNo();
        current_scope = current_scope->getPscope();
        delete temp;
    }
    bool Insert(std::string name, std::string type){
        if(current_scope->insert(name, type)){
        }
        else{
            return false;
        }
        return true;
    }
    bool Remove(std::string name){
        if(current_scope->deletion(name)){

        }
        else{
            return false;
        }
        return true;
    }
    symbol_info* LookUp(std::string name){
        scope_table* temp = current_scope;
        symbol_info* found = NULL;
        while(temp != NULL){
            found = temp->look_up(name);
            if(found != NULL) {
                break;
            }
            temp = temp->getPscope(); 
        }

        if (found == NULL) {
        }
        return found;
    }
    void printCurrentScope(){
        current_scope->print();
    }
    void printAllScope(){
        scope_table* temp = current_scope;
        while(temp != NULL){
            fprintf(logout,"	ScopeTable# %d\n",temp->getSTNo());
            temp->print();
            temp = temp->getPscope();
        }
    }
    int getScopeTableNo(){
        return scopeTableNo;
    }
};

#endif