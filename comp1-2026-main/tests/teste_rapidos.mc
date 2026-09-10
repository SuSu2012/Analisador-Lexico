// 1. Testando palavras reservadas puras
int main() {
    int x;
    char letra;

    if (x == 0) {
        print(x);
    } else {
        return 1;
    }
}

// 2. Testando IDs misturados (para garantir que ele nao confunda)
int main2;
char char_valido;

// 3. Testando constantes de caractere corretas
'a'
'1'
'+'

// 4. Testando constantes de caractere com ERRO (nao fechadas)
'x
'

// Constantes de Caractere (CHARCONST)
char c1 = 'a';
char c2 = '\n';
char c3 = '\t';
char c4 = '\\';
char c5 = '\'';

// Erro de caractere nao fechado
char err1 = 'x;

// Subtracao vs Inteiros (MINUS / INTEGERCONST)
int x = 5;
int y = x - 2;
int z = a-10;
int w = -30;

// Constantes de String (STRINGCONST)

// 1. Strings validas (comum, vazia e com escapes)
string s1 = "Texto simples";
string s2 = "";
string s3 = "Com \"aspas\", \\barra\\, \t tab e \n nova linha";

// 2. Erro: String nao terminada (quebra de linha sem escape)
string err_str1 = "String sem fechar
int proxima_linha = 10;

// 3. Teste de String Longa (verifica protecao de buffer)
string long_str = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA";