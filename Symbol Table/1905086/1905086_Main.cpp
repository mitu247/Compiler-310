#include "1905086_symbolTable.cpp"
#include <regex>
#include <cstdio>

int main(){
    int cmd = 0;
    int bucket;
    
    freopen("sample_input.txt", "r", stdin);
    freopen("output.txt", "w", stdout);

    cin>> bucket;
    symbol_table ST(bucket);
    while(true){
        string s,xy;
        getline(cin, s);
        //cout<<s<<endl;
        stringstream ss(s);
        string str[100];
        int cnt = 0;
        while(getline(ss, xy , ' ')){
        str[cnt] = xy;
        cnt++;
        }
        str[cnt-1] = std::regex_replace(str[cnt-1], std::regex("\\r\\n|\\r|\\n"), "");

        if(str[0] == "I"){
            cout << "Cmd " << cmd << ": " << s << endl;
            if(cnt == 3){
            ST.Insert(str[1],str[2]);
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;
            }
        }
        else if (str[0]=="L"){
            cout << "Cmd " << cmd << ": " << s << endl;
            if(cnt == 2){
                ST.LookUp(str[1]);
            }
            else{
            cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;
           }
         }
        else if(str[0]=="P") {
            cout << "Cmd " << cmd << ": " << s << endl;
            if(cnt == 2){
                if (str[1] == "A") {
                ST.printAllScope();
                }
                else if(str[1] == "C") {
                ST.printCurrentScope();
                }
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;  
            }
        }

        else if (str[0]=="D") {
            cout << "Cmd " << cmd << ": " << s << endl;
            if(cnt == 2){
                ST.Remove(str[1]);
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;  
            }
        }
        else if (str[0]=="S") {
            cout << "Cmd " << cmd << ": " << s << endl; 
            if(cnt == 1){
                ST.enter_scope();
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;  
            }
        }
        else if (str[0]=="E") {
            cout << "Cmd " << cmd << ": " << s << endl; 
            if(cnt == 1){
                ST.exit_scope();
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;  
            }
        }
        else if (str[0]=="Q") {
            cout << "Cmd " << cmd << ": " << s << endl; 
            if(cnt == 1){
                break;
            }
            else{
                cout<<"	Number of parameters mismatch for the command "<<str[0]<<endl;  
            }
        } 
        cmd++;
    }

    return 0;
}