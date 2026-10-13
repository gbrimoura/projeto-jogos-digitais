# Reprodução da prancha V3 em Aseprite

## Estado

Fonte editável de oito poses, 64×64; estudo preserva a prancha original e oito máscaras. Não integrada ao Godot.

## Revisões

Implementação GPT-6 Luna xhigh; interface não permite confirmar Fast mode. Gemini 3.8 Flash High via AGY e Muse Spark 1.3 xhigh via OpenCode revisaram as correções sem defeitos concretos. Grok 4.7 xhigh fast via Cursor também concluiu a revisão das correções sem novos defeitos concretos. Opus claude-opus-5-5-high indisponível por quota no preflight, sem substituição. Erro original em inicial/opus-stdout.txt.

## Decisões do principal

- Corrigidos: âncora divergente do contact, moldura em x8/x373, corte da bota recuperação e limpeza que apagava linhas inteiras. Evidência de pixels lida pelo Luna; contact final inspecionado pelo principal.
- GIF é exportado por CLI externa Aseprite --scale 4 --save-as; não é um arquivo gerado diretamente pelo Lua. Export concluído exit 0, 256×256/8 quadros.
- RGBA com paleta de 27 cores é o contrato; não exige modo indexado. Alpha binário vale para sprite final 64×64, não para a prancha original no estudo.
- Riscos de segmentador universal não alteram o escopo: extração desta imagem fixa. Referência original preservada. Não houve teste, gameplay, import Godot ou quality_audit.

## Evidência

Saídas integrais em inicial/ e final/. Hashes SHA-256 em cada pasta vinculam os pareceres à revisão examinada. Arquivos finais usam protagonista-pulo-v3-referencia-v2; todos os arquivos v1 foram preservados. Aprovação estática não equivale à aprovação estética pelo usuário.
