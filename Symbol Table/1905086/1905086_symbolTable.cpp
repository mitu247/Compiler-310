#include "1905086_scopeTable.cpp"

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
        cout<<"	ScopeTable# "<<scopeTableNo<<" created"<<endl;
    }
    ~symbol_table(){
        scope_table* temp = current_scope;
    
        while(temp != NULL){
            current_scope = current_scope->getPscope();
            cout<<"	ScopeTable# " << temp->getSTNo() << " removed" << endl;
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
        cout<<"	ScopeTable# "<<scopeTableNo<<" created"<<endl;
    }
    void exit_scope(){
        int scopeTableID;
        if(current_scope == root_scope) {
            cout<<"	ScopeTable# 1 cannot be removed" << endl;
            return;
        }
        scope_table* temp = current_scope;
        scopeTableID = temp->getSTNo();
        current_scope = current_scope->getPscope();
        delete temp;
        cout<<"	ScopeTable# " << scopeTableID << " removed" << endl;
    }
    bool Insert(std::string name, std::string type){
        if(current_scope->insert(name, type)){
            cout<<"	Inserted in ScopeTable# "<<current_scope->getSTNo()<<" at position "<<current_scope->getIndex()<<", "<<current_scope->getPosition()<<endl;
        }
        else{
            cout<<"	'"<<name<<"'"<<" already exists in the current ScopeTable"<<endl;
            return false;
        }
        return true;
    }
    bool Remove(std::string name){
        if(current_scope->deletion(name)){
            cout<<"	Deleted '"<<name<< "' from ScopeTable# "<<scopeTableNo<<" at position "<<current_scope->getIndex()<<", "<<current_scope->getPosition()<<endl;
        }
        else{
            cout<<"	Not found in the current ScopeTable"<<endl;
        }
        return true;
    }
    symbol_info* LookUp(std::string name){
        scope_table* temp = current_scope;
        symbol_info* found = NULL;
        while(temp != NULL){
            found = temp->look_up(name);
            if(found != NULL) {
                cout<<"	'" << name << "' found in ScopeTable# " << temp->getSTNo() << " at position " << temp->getIndex() << ", " << temp->getPosition() << endl;
                break;
            }
            temp = temp->getPscope(); 
        }

        if (found == NULL) {
            cout<<"	'" << name << "' not found in any of the ScopeTables" << endl;
        }
        return found;
    }
    void printCurrentScope(){
        cout<<"	ScopeTable# " << current_scope->getSTNo() << endl;
        current_scope->print();
    }
    void printAllScope(){
        scope_table* temp = current_scope;
        while(temp != NULL){
            cout<<"	ScopeTable# " << temp->getSTNo() << endl;
            temp->print();
            temp = temp->getPscope();
        }
    }
};