/*
 * microc.flex
 *
 * Esqueleto do analisador lexico (scanner) para a linguagem Micro C.
 * Disciplina: Compiladores I - FACOM
 *
 * Este arquivo NAO esta completo. Partes do reconhecimento de tokens
 * foram implementadas apenas como EXEMPLO, para orienta-lo(a) sobre o
 * padrao a seguir. As demais estao marcadas com "TODO(aluno)" e devem
 * ser completadas por voce.
 *
 * Compilacao:
 *      flex microc.flex
 *      gcc lex.yy.c -o lexer
 *
 * Uso:
 *      ./lexer test.mc
 */

%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

/* ---------------------------------------------------------------------
 * 1. VOCABULARIO DE TOKENS (equivalente a tokens.h)
 * ------------------------------------------------------------------- */

typedef enum {
    /* Tokens fundamentais */
    UNDEF,          /* token indefinido (usado para reportar erros) */
    ID,             /* identificador                                */
    END_OF_FILE,    /* fim de arquivo                                */

    /* Constantes literais */
    INTEGERCONST,
    CHARCONST,
    STRINGCONST,

    /* Operadores aritmeticos */
    PLUS, MINUS, MUL, DIV, MOD,

    /* Operadores relacionais e logicos */
    EQ, NEQ, LT, GT, LEQ, GEQ, AND, OR, NOT,

    /* Simbolos de atribuicao e pontuacao */
    ASSIGN, SEMICOLON, COMMA, LPAREN, RPAREN,
    LBRACE, RBRACE, LBRACKET, RBRACKET,

    /* Palavras reservadas */
    MAIN, IF, ELSE, FOR, RETURN, INT, CHAR, PRINT
} TokenType;

/* Nomes dos tokens, usados apenas pelo main() de teste abaixo para
 * imprimir o tipo de cada token de forma legivel. Mantenha esta lista
 * na MESMA ORDEM do enum TokenType. */
static const char *nome_token[] = {
    "UNDEF", "ID", "END_OF_FILE",
    "INTEGERCONST", "CHARCONST", "STRINGCONST",
    "PLUS", "MINUS", "MUL", "DIV", "MOD",
    "EQ", "NEQ", "LT", "GT", "LEQ", "GEQ", "AND", "OR", "NOT",
    "ASSIGN", "SEMICOLON", "COMMA", "LPAREN", "RPAREN",
    "LBRACE", "RBRACE", "LBRACKET", "RBRACKET",
    "MAIN", "IF", "ELSE", "FOR", "RETURN", "INT", "CHAR", "PRINT"
};

/* Valor semantico do token corrente. */
typedef struct {
    char *symbol;      /* lexema para ID, INTEGERCONST, CHARCONST, STRINGCONST */
    char *error_msg;   /* mensagem de erro, usada apenas quando tipo == UNDEF   */
} YYSTYPE;

YYSTYPE microc_yylval;
#define TAM_BUFFER 1024

/* Linha atual do arquivo-fonte sendo processado. Deve ser incrementada
 * toda vez que uma quebra de linha for consumida pelo scanner (seja em
 * codigo "normal", dentro de comentarios ou dentro de strings). */
int linha_atual = 1;

char buffer_string[TAM_BUFFER];
int pos_buffer = 0;

void clear_string_buffer() {
    int i ;
    for (i = 0; i < TAM_BUFFER - 1; i++){
        buffer_string[i] = '\0';
    }
}

/* funcoes para calcular hash usando o meotodo tradicional da miltiplicacao
note que p é um numero arbitrário e tam é o tamanho da tabela hash que se deseja
criar. Para melhor funcionamento, adotou-se p = 10 fixo e o tamanho da tabela muda.
tam = 256 para tabela de identificadores */

#define P 10
#define TAM 256

unsigned long retorna_hash(char *texto, int p) {
    double A = 0.6180339887; // [(raiz de 5) - 1]/2 aproximado
    int x = 0;
    char *ptr = texto;
    double m;
    while (*ptr != '\0'){
        x = x + (*ptr);
        ptr++;
    }
    m = pow(2, p);
    return floor(m * (x * A - floor(x * A)));
}

unsigned int retorna_pos(unsigned long val, int tam){
    return val % tam;
}

typedef struct NoIdentificador {
    char *identificador;
    int tipo;
    struct NoIdentificador *proximo;
} NoIdentificador;

/* declaracao dos vetores para as tab hash */
NoIdentificador *identificadores[TAM];

NoIdentificador* busca_tabela_id(char *texto, int tipo, int hash_pos){
    NoIdentificador *ptr = identificadores[hash_pos];
    int ind = 0;
    while (ptr != NULL){
        if ((strcmp(texto, ptr->identificador) == 0) && ptr->tipo == tipo) {
            return ptr;
        }
        ptr = ptr->proximo;
        ind++;
    }
    return NULL;
}

NoIdentificador* inserir_tabela_id(char *texto, int tipo, int hash_pos) {
    NoIdentificador *ptr = identificadores[hash_pos];
    NoIdentificador *ptr_ant = NULL;
    NoIdentificador *novo = calloc(1, sizeof(NoIdentificador));
    while (ptr != NULL) {
        ptr_ant = ptr;
        ptr = ptr->proximo;
    }
    if (ptr_ant == NULL) {
        identificadores[hash_pos] = novo;
    }
    novo->identificador = strdup(texto);
    novo->tipo = tipo;
    novo->proximo = NULL;
    if (ptr_ant != NULL){
        ptr_ant->proximo = novo;
    }
    ptr = novo;

    return novo;
}

/* Funcao auxiliar para preencher microc_yylval.symbol com uma copia do
 * texto reconhecido (yytext). Sinta-se livre para usar/adaptar. */
static void guarda_lexema(char *texto, int tipo) {
    unsigned long hash_val = retorna_hash(texto, P);
    unsigned int hash_pos = retorna_pos(hash_val, TAM);
    NoIdentificador *novo = busca_tabela_id(texto, tipo, hash_pos);
    if (novo == NULL) {
        novo = inserir_tabela_id(texto, tipo, hash_pos);
    }
    if (novo != NULL) {
        microc_yylval.symbol = novo->identificador;
    }
}
%}

/* -----------------------------------------------------------------------
 * 2. SECAO DE DEFINICOES
 * ------------------------------------------------------------------- */

DIGIT       [0-9]
LETRA       [a-zA-Z_]
ALFANUM     [a-zA-Z0-9_]

%x COMMENT
%x STRING

%%

 /* -----------------------------------------------------------------------
  * 3. SECAO DE REGRAS
  * --------------------------------------------------------------------- */

 /* --- Fim de arquivo -----------------------------------------------------
  * Tratada explicitamente (em vez de depender do retorno automatico 0
  * do flex), pois o token UNDEF tambem vale 0 no enum TokenType -- se
  * dependessemos do comportamento padrao, um erro lexico seria
  * confundido com o fim do arquivo pelo main() de teste abaixo. */
<INITIAL><<EOF>>             { return END_OF_FILE; }

 /* --- Espacos em branco e quebras de linha ---------------------------- */
\n                  { linha_atual++; }
[ \t\r]+            { /* ignora espacos em branco */ }

 /* --- Comentarios ------------------------------------------------------
  * Estes ja estao implementados como exemplo de uso de estados (%x) e
  * de tratamento de erro via EOF dentro de um estado especial. */
"//".*              { /* comentario de linha: ignora ate o fim da linha */ }
<COMMENT><<EOF>>    {
                        microc_yylval.error_msg = "EOF em comentario";
                        BEGIN(INITIAL);
                        return UNDEF;
                    }
"/*"                { BEGIN(COMMENT); }
<COMMENT>"*/"       { BEGIN(INITIAL); }
<COMMENT>\n         { linha_atual++; }

<COMMENT>.          { /* consome qualquer outro caractere dentro do comentario */ }

 /* Fechamento de comentario sem abertura correspondente. */
"*/"                {
                        microc_yylval.error_msg = "Comentario nao iniciado";
                        return UNDEF;
                    }

 /* --- Palavras reservadas e identificadores ----------------------------
  * TODO(aluno): atualmente TODA sequencia de letras/underscore e
  * devolvida como ID. Voce deve comparar o lexema reconhecido com cada
  * palavra reservada da linguagem (main, if, else, for, return, int,
  * char, print) e devolver o token especifico quando houver
  * correspondencia. Use strcmp(), conforme discutido em aula, ou uma
  * tabela hash caso queira ir alem do exigido. Nao esqueca de chamar
  * guarda_lexema() (ou equivalente) quando o token for de fato ID. */
{LETRA}{ALFANUM}*   {
                        if (strcmp(yytext, "main") == 0) return MAIN;
                        else if (strcmp(yytext, "if") == 0) return IF;
                        else if (strcmp(yytext, "else") == 0) return ELSE;
                        else if (strcmp(yytext, "for") == 0) return FOR;
                        else if (strcmp(yytext, "return") == 0) return RETURN;
                        else if (strcmp(yytext, "int") == 0) return INT;
                        else if (strcmp(yytext, "char") == 0) return CHAR;
                        else if (strcmp(yytext, "print") == 0) return PRINT;
                        else{
                            guarda_lexema(yytext, ID);
                            return ID;
                        }
                    }

 /* --- Constantes inteiras -----------------------------------------------
  * TODO(aluno): o padrao formal para um inteiro em Micro C e um ou mais
  * digitos, opcionalmente precedidos de um sinal de menos (numeros
  * negativos). A regra abaixo trata apenas inteiros sem sinal; use a
  * tecnica de lookahead discutida em aula (veja o operador MINUS mais
  * abaixo) para decidir quando um '-' faz parte do numero e quando ele
  * e, na verdade, o operador de subtracao. */
{DIGIT}+            {
                        guarda_lexema(yytext, INTEGERCONST);
                        return INTEGERCONST;
                    }

 /* --- Constantes de caractere --------------------------------------------
  * TODO(aluno): reconhecer o padrao 'x' (aspas simples, um caractere,
  * aspas simples) e devolver CHARCONST. Trate tambem o caso de erro em
  * que as aspas simples nao sao fechadas corretamente (token UNDEF). */
 /* Aqui procura a aspa simples (\'), seguida por qualquer caracter (.) e termina com aspas (\') */
\'.\'               {
                        guarda_lexema(yytext, CHARCONST);
                        return CHARCONST;
                    }
 /* Aqui procura a aspa simples (\'), procura os carcteres ([]) exceto (^\n e ') os que estão na lista */
\'[^'\n]*           {
                        microc_yylval.error_msg = "Constante de caractere nao fechada";
                        return UNDEF;
                    }

 /* --- Constantes de string -------------------------------------------
  * TODO(aluno): reconhecer o padrao "[^"\n]*" (uma ou mais aspas
  * duplas delimitando o conteudo da string) e devolver STRINGCONST.
  * Voce deve tratar os seguintes erros (veja o enunciado, Secao 4.1):
  *   - EOF antes do fechamento da string ("EOF em string")
  *   - quebra de linha nao escapada dentro da string
  *     ("String nao terminada")
  *   - caractere nulo dentro da string
  *     ("String contem caractere nulo")
  * Alem disso, converta as sequencias de escape (\n, \t, \\, \", \0)
  * para os caracteres correspondentes antes de armazenar o lexema. */


\"                  {
                        BEGIN(STRING);
                        pos_buffer = 0;
                    }

<STRING>\"          { 
                        BEGIN(INITIAL);
                        buffer_string[pos_buffer] = '\0';
                        guarda_lexema(buffer_string, STRINGCONST);
                        clear_string_buffer();
                        return STRINGCONST;
                    }

<STRING><<EOF>>     {
                        microc_yylval.error_msg = "EOF em string";
                        BEGIN(INITIAL);
                        clear_string_buffer();
                        return UNDEF;
                    }

<STRING>\n         {
                        microc_yylval.error_msg = "String nao terminada";
                        BEGIN(INITIAL);
                        clear_string_buffer();
                        linha_atual++;
                        return UNDEF;
                    }
<STRING>\0         {
                        microc_yylval.error_msg = "String contem caractere nulo";
                        BEGIN(INITIAL);
                        clear_string_buffer();
                        return UNDEF;
                    }         
<STRING>.           {
                        buffer_string[pos_buffer++] = yytext[0];
                    }


 /* --- Operadores relacionais e logicos ---------------------------------
  * O caso de '=' esta implementado como EXEMPLO do uso de lookahead
  * (yytext mostra o que foi casado; voce pode usar input()/unput() ou,
  * de forma mais simples em flex, escrever as duas alternativas como
  * regras separadas, deixando o proprio flex escolher o casamento mais
  * longo -- veja a explicacao na Secao 2 do enunciado). */
"=="                { return EQ; }
"="                 { return ASSIGN; }
"!="                { return NEQ; }
"!"                 { return NOT; }
"<="                { return LEQ; }
"<"                 { return LT; }
">="                { return GEQ; }
">"                 { return GT; }
"&&"                { return AND; }
"||"                { return OR; }

 /* --- Operadores aritmeticos e simbolos de pontuacao (ja prontos) ------ */
"+"                 { return PLUS; }
"-"                 { return MINUS; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"                 { return MOD; }
";"                 { return SEMICOLON; }
","                 { return COMMA; }
"("                 { return LPAREN; }
")"                 { return RPAREN; }
"{"                 { return LBRACE; }
"}"                 { return RBRACE; }
"["                 { return LBRACKET; }
"]"                 { return RBRACKET; }

 /* --- Caractere invalido -------------------------------------------------
  * Casa com qualquer caractere que nao tenha correspondido a nenhuma
  * regra anterior. Deve ser SEMPRE a ultima regra do arquivo. */
.                   {
                        microc_yylval.error_msg = strdup(yytext);
                        return UNDEF;
                    }

%%

/* -----------------------------------------------------------------------
 * 4. SUB-ROTINAS DO USUARIO
 * ------------------------------------------------------------------- */

/* yywrap: informa ao flex que, ao atingir o EOF, a leitura deve
 * simplesmente parar (nao ha um proximo arquivo a processar). */
int yywrap(void) {
    return 1;
}

/* main() de teste: le o arquivo passado como argumento e imprime, para
 * cada token reconhecido, seu tipo, lexema e linha -- no mesmo espirito
 * do utilitario "lexer" mencionado no enunciado (Secao 6). Este main()
 * e apenas uma ferramenta de depuracao para voce testar seu scanner de
 * forma isolada; ele NAO faz parte da interface formal entre o scanner
 * e o parser (isso sera tratado nos trabalhos seguintes). */
int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "Uso: %s <arquivo.mc>\n", argv[0]);
        return 1;
    }

    FILE *arquivo_fonte = fopen(argv[1], "r");
    if (!arquivo_fonte) {
        fprintf(stderr, "Erro: nao foi possivel abrir o arquivo '%s'\n", argv[1]);
        return 1;
    }
    yyin = arquivo_fonte;

    int tipo;
    while ((tipo = yylex()) != END_OF_FILE) {
        if (tipo == UNDEF) {
            fprintf(stderr, "ERRO LEXICO (linha %d): %s\n",
                    linha_atual, microc_yylval.error_msg);
            continue;
        }
        printf("Token: tipo = %-13s lexema = '%s'  linha = %d\n",
               nome_token[tipo], yytext, linha_atual);
    }

    fclose(arquivo_fonte);
    return 0;
}
