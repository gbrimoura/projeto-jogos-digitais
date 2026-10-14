# Histórico — margem da shape query

Antes da correção, snapshots do script, plano, spec e hashes da implementação revisada estão em pre-correcao/. O hash prévio também está preservado sem alteração em pareceres/estado-implementacao-sha256.json.

A revisão apontou que margin=0.08 expandia a consulta além do círculo visual de 140 px. A correção delimitada usa margin=0.0 para alinhar a shape query à borda desenhada. Nenhum outro contrato de runtime foi alterado.
