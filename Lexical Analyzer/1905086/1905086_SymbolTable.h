#ifndef ST_HEADER
#define ST_HEADER

#include<bits/stdc++.h>
#include<string>
using namespace std;

class symbol_info{
    private:
    string name;
    string type;
    public:
    symbol_info* next;
    symbol_info(){
        this->name = "";
        this->type = "";
    }
    symbol_info(string name, string type = " "){
      this->name = name;
      this->type = type;
    }
    //setter
    void set_name(string name){
        this->name = name;
    }
    void set_type(string type){
        this->type = type;
    }
    //getter
    string get_name(){
        return this->name;
    }
    string get_type(){
        return this->type;
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
    
    void display(symbol_info* head){
        symbol_info* ptr = head;
        while(ptr != NULL){
            //cout<<"<"<<ptr->get_name()<<","<<ptr->get_type()<<"> ";
            fprintf(logout, "<%s,%s> ", ptr->get_name().c_str(), ptr->get_type().c_str());
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
            delete curr;
            temp = temp->next;
            curr = temp;
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
            chain_append(linkers[hashVal],symbol_info(name,type));
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
        //cout<<"	ScopeTable# "<<scopeTableNo<<" created"<<endl;
    }
    ~symbol_table(){
        scope_table* temp = current_scope;
    
        while(temp != NULL){
            current_scope = current_scope->getPscope();
            //cout<<"	ScopeTable# " << temp->getSTNo() << " removed" << endl;
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
        //cout<<"	ScopeTable# "<<scopeTableNo<<" created"<<endl;
    }
    void exit_scope(){
        int scopeTableID;
        if(current_scope == root_scope) {
            //cout<<"	ScopeTable# 1 cannot be removed" << endl;
            return;
        }
        scope_table* temp = current_scope;
        scopeTableID = temp->getSTNo();
        current_scope = current_scope->getPscope();
        delete temp;
        //cout<<"	ScopeTable# " << scopeTableID << " removed" << endl;
    }
    bool Insert(std::string name, std::string type){
        if(current_scope->insert(name, type)){
            //cout<<"	Inserted in ScopeTable# "<<current_scope->getSTNo()<<" at position "<<current_scope->getIndex()<<", "<<current_scope->getPosition()<<endl;
        }
        else{
            //cout<<"	'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
            return false;
        }
        return true;
    }
    bool Remove(std::string name){
        if(current_scope->deletion(name)){
            //cout<<"	Deleted '"<<name<< "' from ScopeTable# "<<scopeTableNo<<" at position "<<current_scope->getIndex()<<", "<<current_scope->getPosition()<<endl;
        }
        else{
            //cout<<"	Not found in the current ScopeTable"<<endl;
        }
        return true;
    }
    symbol_info* LookUp(std::string name){
        scope_table* temp = current_scope;
        symbol_info* found = NULL;
        while(temp != NULL){
            found = temp->look_up(name);
            if(found != NULL) {
                //cout<<"	'" << name << "' found in ScopeTable# " << temp->getSTNo() << " at position " << temp->getIndex() << ", " << temp->getPosition() << endl;
                break;
            }
            temp = temp->getPscope(); 
        }

        if (found == NULL) {
            //cout<<"	'" << name << "' not found in any of the ScopeTables" << endl;
        }
        return found;
    }
    void printCurrentScope(){
        //cout<<"	ScopeTable# " << current_scope->getSTNo() << endl;
        current_scope->print();
    }
    void printAllScope(){
        scope_table* temp = current_scope;
        while(temp != NULL){
            //cout<<"	ScopeTable# " << temp->getSTNo() << endl;
            fprintf(logout,"	ScopeTable# %d\n",temp->getSTNo());
            temp->print();
            temp = temp->getPscope();
        }
    }
};

#endif