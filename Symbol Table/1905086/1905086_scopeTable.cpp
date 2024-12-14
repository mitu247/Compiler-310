#include "1905086_symbolInfo.cpp"
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

        // sym->set_name(n_obj.get_name());
        // sym->set_type(n_obj.get_type());
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
            cout<<"<"<<ptr->get_name()<<","<<ptr->get_type()<<"> ";
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
        for(int i = 0; i <= num_buckets; i++) delete linkers[i];
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
        if(chain_search(linkers[hashVal], symbol_info(name))== false){
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
            cout << "	" << i << "--> ";
            display(linkers[i]);
            cout<<endl;
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