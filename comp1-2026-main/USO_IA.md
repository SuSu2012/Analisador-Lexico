## USO_IA.md

Ferramenta: Claude (Claude Code)
Trecho/arquivo afetado: microc.l (geral) e arquivos de teste em tests/
Finalidade: esclarecer dúvidas pontuais sobre expressões regulares e a linguagem flex (regras de quoting, casamento mais longo, estados exclusivos, `yyless`, `yymore`, `<<EOF>>`) e sobre conceitos gerais de análise léxica, durante a implementação do trabalho.
O que fiz com a resposta: entendi a explicação e escrevi/ajustei o código eu mesmo(a) com base nela.

Ferramenta: Claude (Claude Code)
Trecho/arquivo afetado: microc.l
Finalidade: pedi para revisar trechos que eu já tinha escrito, buscando bugs e inconsistências (tabela de identificadores, tratamento de STRINGCONST/CHARCONST, operadores compostos, tratamento de inteiros negativos).
O que fiz com a resposta: a IA apontou os problemas encontrados; procurei compreender e aplicar as correções.

Ferramenta: Claude (Claude Code)
Trecho/arquivo afetado: tests/teste_completo.mc, tests/teste_eof_comentario.mc, tests/teste_eof_string.mc
Finalidade: pedi para criar arquivos de teste adicionais que cobrissem o maior número possível de casos exigidos pelo enunciado (tokens, palavras reservadas, operadores, erros léxicos etc.).
O que fiz com a resposta: usei os arquivos gerados como parte da minha bateria de testes, executando o scanner contra eles para validar o comportamento.
