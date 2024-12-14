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