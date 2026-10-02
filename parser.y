%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void yyerror(const char *s);
int yylex();

typedef enum { V_NUM, V_BOOL, V_FUNC } ValType;
struct Node;
struct Env;

typedef struct {
    struct Node* params;
    struct Node* body;
    struct Env* closure; 
} FuncData;

typedef struct {
    ValType type;
    int num;
    FuncData* func;
} Value;

typedef struct Env {
    char* name;
    Value val;
    struct Env* parent; 
} Env;

typedef struct Node {
    int node_type; // 0:Lit, 1:ID, 2:Op, 3:If, 4:Fun, 5:Call, 6:Def
    int op; char* id; int val;  
    struct Node *child1, *child2, *child3, *next;
} Node;

Node* newNode(int type);
Value eval(Node* n, Env* env);
void type_error();

Env* global_env = NULL;

Env* find_var(char* name, Env* env) {
    Env* curr = env;
    while(curr) {
        if(curr->name && strcmp(curr->name, name) == 0) return curr;
        curr = curr->parent;
    }
    Env* g = global_env;
    while(g) {
        if(g->name && strcmp(g->name, name) == 0) return g;
        g = g->parent;
    }
    return NULL;
}

Env* add_binding(char* name, Value val, Env* parent) {
    Env* e = malloc(sizeof(Env));
    e->name = strdup(name);
    e->val = val;
    e->parent = parent;
    return e;
}
%}

%union {
    int num_val;
    int bool_val;
    char* id_name;
    struct Node* node_ptr;
}

%token <num_val> NUMBER
%token <bool_val> BOOL_VAL
%token <id_name> ID
%token PRINT_NUM PRINT_BOOL DEFINE IF FUN AND OR NOT MOD
%type <node_ptr> exp stmt stmt_list exp_list id_list fun_body

%%
program : stmt_list { 
            Node* curr = $1;
            while(curr) { eval(curr, NULL); curr = curr->next; }
        }
        ;

stmt_list : stmt { $$ = $1; }
          | stmt stmt_list { $1->next = $2; $$ = $1; }
          ;

stmt : exp 
     | '(' PRINT_NUM exp ')'  { $$ = newNode(2); $$->op = PRINT_NUM; $$->child1 = $3; }
     | '(' PRINT_BOOL exp ')' { $$ = newNode(2); $$->op = PRINT_BOOL; $$->child1 = $3; }
     | '(' DEFINE ID exp ')'  { $$ = newNode(6); $$->id = $3; $$->child1 = $4; }
     ;

exp : NUMBER    { $$ = newNode(0); $$->val = $1; $$->op = V_NUM; }
    | BOOL_VAL  { $$ = newNode(0); $$->val = $1; $$->op = V_BOOL; }
    | ID        { $$ = newNode(1); $$->id = $1; }
    | '(' '+' exp exp_list ')' { $$ = newNode(2); $$->op = '+'; $$->child1 = $3; $$->child2 = $4; }
    | '(' '-' exp exp ')'      { $$ = newNode(2); $$->op = '-'; $$->child1 = $3; $$->child2 = $4; }
    | '(' '*' exp exp_list ')' { $$ = newNode(2); $$->op = '*'; $$->child1 = $3; $$->child2 = $4; }
    | '(' '/' exp exp ')'      { $$ = newNode(2); $$->op = '/'; $$->child1 = $3; $$->child2 = $4; }
    | '(' MOD exp exp ')'      { $$ = newNode(2); $$->op = MOD; $$->child1 = $3; $$->child2 = $4; }
    | '(' '>' exp exp ')'      { $$ = newNode(2); $$->op = '>'; $$->child1 = $3; $$->child2 = $4; }
    | '(' '<' exp exp ')'      { $$ = newNode(2); $$->op = '<'; $$->child1 = $3; $$->child2 = $4; }
    | '(' '=' exp exp_list ')' { $$ = newNode(2); $$->op = '='; $$->child1 = $3; $$->child2 = $4; }
    | '(' AND exp exp_list ')' { $$ = newNode(2); $$->op = AND; $$->child1 = $3; $$->child2 = $4; }
    | '(' OR exp exp_list ')'  { $$ = newNode(2); $$->op = OR; $$->child1 = $3; $$->child2 = $4; }
    | '(' NOT exp ')'          { $$ = newNode(2); $$->op = NOT; $$->child1 = $3; }
    | '(' IF exp exp exp ')'   { $$ = newNode(3); $$->child1 = $3; $$->child2 = $4; $$->child3 = $5; }
    | '(' FUN '(' id_list ')' fun_body ')' { $$ = newNode(4); $$->child1 = $4; $$->child2 = $6; }
    | '(' exp exp_list ')'     { $$ = newNode(5); $$->child1 = $2; $$->child2 = $3; }
    | '(' exp ')'              { $$ = newNode(5); $$->child1 = $2; $$->child2 = NULL; }
    ;

exp_list : exp { $$ = $1; }
         | exp exp_list { $1->next = $2; $$ = $1; }
         ;

id_list : /* empty */ { $$ = NULL; }
        | ID id_list  { $$ = newNode(1); $$->id = $1; $$->next = $2; }
        ;

fun_body : exp { $$ = $1; }
         | stmt fun_body { $$ = $1; $1->next = $2; }
         ;
%%

Node* newNode(int type) { Node* n = calloc(1, sizeof(Node)); n->node_type = type; return n; }
void type_error() { printf("Type error!\n"); exit(0); }

Value eval(Node* n, Env* env) {
    Value res = {0}; if(!n) return res;
    switch(n->node_type) {
        case 0: res.type = (n->op == V_NUM ? V_NUM : V_BOOL); res.num = n->val; return res;
        case 1: { // Variable lookup
            Env* e = find_var(n->id, env);
            if(!e) exit(0); return e->val;
        }
        case 2: { // Operators
            Value v1 = eval(n->child1, env);
            switch(n->op) {
                case PRINT_NUM:  if(v1.type!=V_NUM) type_error(); printf("%d\n",v1.num); return res;
                case PRINT_BOOL: if(v1.type!=V_BOOL) type_error(); printf("%s\n",v1.num?"#t":"#f"); return res;
                case NOT:        if(v1.type!=V_BOOL) type_error(); res.type=V_BOOL; res.num=!v1.num; return res;
                case '+':
                case '*':
                case '-':
                case '/':
                case MOD:
                case '>':
                case '<':
                case '=': {
                    if(v1.type != V_NUM) type_error();
                    int acc = v1.num; Node* c = n->child2;
                    if(n->op=='+' || n->op=='*') {
                        while(c) { Value v2=eval(c,env); if(v2.type!=V_NUM) type_error(); acc=(n->op=='+')?acc+v2.num:acc*v2.num; c=c->next; }
                        res.type=V_NUM; res.num=acc;
                    } else if(n->op=='=') {
                        int eq=1; while(c) { Value v2=eval(c,env); if(v2.type!=V_NUM) type_error(); if(acc!=v2.num) eq=0; c=c->next; }
                        res.type=V_BOOL; res.num=eq;
                    } else {
                        Value v2=eval(c,env); if(v2.type!=V_NUM) type_error();
                        if(n->op=='-') acc-=v2.num; else if(n->op=='/') acc/=v2.num; else if(n->op==MOD) acc%=v2.num;
                        else if(n->op=='>') { res.type=V_BOOL; res.num=(acc>v2.num); return res; }
                        else if(n->op=='<') { res.type=V_BOOL; res.num=(acc<v2.num); return res; }
                        res.type=V_NUM; res.num=acc;
                    }
                    return res;
                }
                case AND:
                case OR: {
                    if(v1.type!=V_BOOL) type_error();
                    int acc = v1.num; Node* c = n->child2;
                    while(c) { Value v2=eval(c,env); if(v2.type!=V_BOOL) type_error(); acc=(n->op==AND)?acc&&v2.num:acc||v2.num; c=c->next; }
                    res.type=V_BOOL; res.num=acc; return res;
                }
            }
            return res;
        }
        case 3: { // IF
            Value test = eval(n->child1, env); if(test.type!=V_BOOL) type_error();
            return (test.num) ? eval(n->child2, env) : eval(n->child3, env);
        }
        case 4: { // Create Function (Closure)
            res.type=V_FUNC; res.func=malloc(sizeof(FuncData));
            res.func->params=n->child1; res.func->body=n->child2; res.func->closure=env;
            return res;
        }
        case 5: { // CALL / Recursion
            Value fv = eval(n->child1, env); if(fv.type!=V_FUNC) type_error();
            FuncData* f = fv.func; Env* new_env = f->closure;
            Node* p = f->params; Node* a = n->child2;
            while(p && a) { new_env = add_binding(p->id, eval(a, env), new_env); p=p->next; a=a->next; }
            Node* b = f->body; Value last;
            while(b) {
                if(b->node_type == 6) { new_env = add_binding(b->id, eval(b->child1, new_env), new_env); }
                else { last = eval(b, new_env); }
                b = b->next;
            }
            return last;
        }
        case 6: { // DEFINE
            global_env = add_binding(n->id, eval(n->child1, env), global_env);
            return res;
        }
    }
    return res;
}

void yyerror(const char *s) { printf("syntax error\n"); exit(0); }

int main(int argc, char** argv) {
    extern FILE* yyin; if(argc > 1) yyin = fopen(argv[1], "r");
    yyparse(); return 0;
}