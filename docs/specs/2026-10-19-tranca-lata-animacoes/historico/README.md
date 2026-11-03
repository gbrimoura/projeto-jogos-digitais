# Histórico e baseline

A pasta base/ reproduz, preservando os caminhos relativos ao projeto, o conteúdo dos seis arquivos de runtime elegíveis para alteração na etapa posterior. sha256-before.json registra SHA-256 de origem e confirmações de igualdade das cópias. A captura inclui modificações locais preexistentes nos dois scripts, não uma versão limpa de Git.

historico/plano-r1/anteseditar/plano.md preserva integralmente a revisão R1 antes das emendas documentais R2. SHA-256: 43DA7A424DAA2AA04AD293A265D6D38464CA5D5722E2AFE752A43A19ECB7D1FB. Não é fonte de runtime e não deve ser sobrescrita.

historico/plano-r2/antescomplemento/ preserva plano.md, spec.md e registro.md no estado intermediário R2, antes do complemento Opus e da consolidação do plano R3 final. sha256-before.json contém os hashes verificados das três cópias.

plano.md e spec.md na raiz documental são o plano R3 final congelado em 19/10/2026; registro.md acompanha os handoffs de documentação e arte. Não sobrescrever os snapshots R1/R2.

Os arquivos são snapshots de referência; não editar nem substituir durante a integração. Plano e spec atuais são prospectivos. A implementação estacionária de 14/10 permanece no seu diretório original como histórico e não foi reescrita.
