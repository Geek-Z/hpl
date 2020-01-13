%{
#include <stdio.h>
#include <stdlib.h>
#define YYDEBUG 1
%}
%union{
    int int_value;
    double double_value;
}
%token <double_value>    DOUBLE_LITERAL
%token ADD SUB MUL DIV CR
%type <double_value> expression term primary_expression
%%
line_list                              /* 多行的规则*/
    : line			       /* 多行由一个单行组成*/
    | line_list line                   /* 或由多行+一个单行组成*/
    ;
line                                   /* 单行的规则*/
    : expression CR                    /* 单行由 一个表达式 + 换行符 组成*/
    {
        printf(">>%lf\n", $1);
    }
    | error CR                         /* error 为yacc当中的特殊标记, 表示任何错误的匹配*/
    {
        yyclearin;                     /* 丢弃预读的记号*/
        yyerrok;                       /* 通知yacc程序已经从错误状态恢复了*/
    }
    ;
expression                             /* 表达式的规则*/
    : term                             /* 和项*/
    | expression ADD term              /* 表达式 + 和项*/
    {
        $$ = $1 + $3;
    }
    | expression SUB term              /* 表达式 - 和项*/
    {
        $$ = $1 - $3;
    }
    ;
term                                   /* 和项的规则*/
    : primary_expression               /* 一元表达式*/
    | term MUL primary_expression      /* 和项 * 一元表达式*/
    {
        $$ = $1 * $3;
    }
    | term DIV primary_expression      /* 和项 / 一元表达式*/
    {
        $$ = $1 / $3;
    }
    ;
primary_expression                     /* 一元表达式的规则*/
    : DOUBLE_LITERAL                   /* 实数的字面常量*/
    ;
%%

int yyerror(char const *str)
{
    extern char *yytext;
    fprintf(stderr, "parser error near %s\n", yytext);
    return 0;
}
int main(void)
{
    extern int yyparser(void);
    extern FILE *yyin;
    yyin = stdin;
    if(yyparse()) {
        fprintf(stderr, "Error ! Error ! Error !\n");
        exit(1);
    }
}
