// =========================================================================
// Teste completo do scanner Micro C
// Cobre todas as categorias de tokens e erros exigidas pelo enunciado,
// EXCETO o caso de "\0" (escape ou byte nulo cru) dentro de STRINGCONST/
// CHARCONST, que ainda tem uma limitacao conhecida (o valor e truncado
// pelo strdup/strcmp, que param no primeiro byte nulo). Os dois casos de
// EOF exatamente no fim do arquivo (comentario e string sem fechar) estao
// em arquivos separados: teste_eof_comentario.mc e teste_eof_string.mc.
// =========================================================================

// --- 1. Palavras reservadas -------------------------------------------
int main() {
    char letra;
    for (letra = 'a'; letra != 'z'; letra = letra) {
        print(letra);
    }
    return 0;
}

// --- 2. Identificadores, inclusive prefixos parecidos com reservadas ---
int main2;
int ifx;
int forest;
int returned;
char character;
char print_valor;

// --- 3. Tabela de identificadores (reaproveitamento do mesmo lexema) ---
int contador;
contador = contador + 1;
contador = contador + contador;

// --- 4. Constantes inteiras ---------------------------------------------
int a1 = 0;
int a2 = 7;
int a3 = 12345;
int a4 = 999999999999999999;

// --- 5. Inteiros negativos vs. operador de subtracao ---------------------
int b1 = -5;                 // sinal: um unico INTEGERCONST "-5"
int b2 = 5 - 3;               // subtracao: INT, MINUS, INT
int b3 = 5-3;                 // subtracao sem espacos: mesmo resultado
int b4 = a1 - 10;             // ID seguido de subtracao
int b5 = (a2) - 5;            // depois de ")" tambem e subtracao
int b6 = f(-5);               // dentro de parenteses de chamada: sinal
int b7 = vetor[3] - 1;        // depois de "]" tambem e subtracao
int b8 = vetor[-1];           // depois de "[" e sinal
int b9 = -5 - 3;              // sinal seguido de subtracao
int b10 = 5 - -3;             // subtracao seguida de sinal (com espaco antes do segundo -)
if (a2 == -5) { }             // depois de operador relacional e sinal
if (a2 != -1) { }
if (a2 <= -1) { }
if (a2 >= -1) { }
if (a2 < -1) { }
if (a2 > -1) { }

// --- 6. Constantes de caractere (com e sem escape) -----------------------
char c1 = 'a';
char c2 = '5';
char c3 = '+';
char c4 = '\n';
char c5 = '\t';
char c6 = '\\';
char c7 = '\'';
char c_err = 'x;              // erro: constante de caractere nao fechada

// --- 7. Constantes de string (com e sem escape, sem usar \0) -------------
char s1 = "Texto simples";
char s2 = "";
char s3 = "Com \"aspas\" e \\barra\\ e \t tab e \n nova linha";
char s4 = "String sem fechar
int depois_do_erro = 1;       // confirma que a linha volta a contar certo

// --- 8. Comentarios -------------------------------------------------------
// comentario de linha simples
/* comentario de bloco em uma linha */
/* comentario de bloco
   que se estende
   por varias linhas */
int depois_do_comentario = 2;
*/                             // erro: comentario nao iniciado

// --- 9. Operadores compostos com prefixo compartilhado -------------------
int o1 = a2 == a3;
int o2 = a2 != a3;
int o3 = a2 <= a3;
int o4 = a2 < a3;
int o5 = a2 >= a3;
int o6 = a2 > a3;
int o7 = a2 && a3;
int o8 = a2 || a3;
int o9 = !a2;
int o10 = a2 = a3;

// --- 10. Operadores aritmeticos e pontuacao -------------------------------
int p1 = a2 + a3;
int p2 = a2 * a3;
int p3 = a2 / a3;
int p4 = a2 % a3;
int arr[10];
arr[0] = 1;

// --- 11. Caractere invalido (nao pertence a nenhum token) -----------------
int q1 = 5 @ 3;
int q2 = 5 # 3;
