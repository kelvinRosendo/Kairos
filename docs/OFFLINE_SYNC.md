# Funcionamento offline e servidor doméstico

Decisão de produto registrada em 30/09/2026. Estado: planejado, não implementado.

## Experiência desejada

O usuário deve consultar registros já baixados e criar, editar, confirmar, reabrir ou cancelar lançamentos sem depender da disponibilidade do servidor. O aplicativo salva localmente e envia as operações quando conseguir acessar a API novamente. Fechar o app ou reiniciar o celular não pode apagar essa fila.

Salvar localmente e sincronizar são estados diferentes, mostrados claramente: “Salvo no celular”, “Sincronizando”, “Sincronizado” e “Precisa de atenção”. Sem conexão, mostrar a última atualização e a quantidade de operações pendentes.

## Desenho inicial

- Banco local SQLite no Android, com migrations; biblioteca Dart a escolher na implementação conforme compatibilidade do projeto.
- Gravar a alteração e a operação pendente na mesma transação local, antes de informar sucesso.
- Separar o estado confirmado pelo servidor das alterações locais pendentes, evitando que uma atualização remota apague um rascunho local.
- Cada lançamento tem UUID estável. Cada operação de criação, edição ou mudança de estado tem outro UUID estável, preservado nas tentativas.
- Sincronizar em ordem por lançamento, respeitando dependências; uma confirmação de um registro criado offline precisa ocorrer depois da criação.
- O backend reconhece operações já aplicadas e devolve seu resultado sem repetir o efeito. Persistir o registro de operação e a mudança financeira atomicamente.
- A chave atual de criação ajuda, mas não substitui um protocolo de sincronização para todas as alterações.
- Só concluir a operação local após confirmação do servidor. Timeout pode significar que ele já gravou: reenviar com a mesma chave.
- Falhas temporárias usam espera progressiva e novas tentativas. Erros de validação permanecem visíveis para correção, sem repetição infinita.
- Buscar alterações remotas com cursor emitido pelo servidor e preservar cancelamentos. Não usar exclusivamente relógio do celular para ordenação ou detecção de mudanças.
- Versionar registros no backend. Enviar a versão original na edição; se outro dispositivo alterou o mesmo registro, preservar ambos os conteúdos e solicitar resolução. Não sobrescrever silenciosamente valores financeiros.

## Quando sincronizar

Tentar ao abrir/retomar o app, depois de uma operação quando a API estiver acessível, ao detectar recuperação de conexão e mediante ação manual. Ter Wi-Fi ou internet não garante acesso ao servidor doméstico.

Sincronização com o app fechado é uma evolução separada, sujeita às restrições de tarefas em segundo plano do Android. A primeira entrega não promete execução imediata em segundo plano.

## Saldos offline

Manter os cálculos oficiais no backend. Na primeira entrega offline, mostrar o último resumo confirmado com data/hora e aviso de que ele ainda não inclui as alterações pendentes. Não apresentar saldo antigo como atualizado. Exibir os lançamentos locais normalmente com seu estado de sincronização.

Recalcular projeções completas no celular exigiria uma decisão adicional sobre compartilhamento e equivalência das regras financeiras; não está incluído automaticamente.

Na primeira configuração, permitir anotações locais antes de ter servidor, mas não exibir um saldo oficial inventado. Definir saldo inicial e validar pendências durante a configuração/sincronização inicial. Alterações do saldo inicial exigem conexão nesta primeira versão offline.

## Servidor doméstico

Spring Boot e PostgreSQL serão executados no PC Linux. Primeiro validar na rede doméstica; acesso fora de casa requer uma solução de acesso autenticado, ainda a escolher. Não expor o PostgreSQL à internet. A configuração atual em loopback precisa ser adaptada deliberadamente para o acesso pelo celular.

Planejar inicialização automática, reinício dos serviços, credenciais fora do Git e backup com restauração verificada. Banco local do celular não substitui backup: desinstalar o app ou limpar seus dados pode apagar operações que ainda não chegaram ao servidor.

## Critérios de aceitação

1. Criar/editar um lançamento em modo avião, fechar e reabrir o app e encontrar as alterações pendentes.
2. Reconectar e receber confirmação do servidor, mantendo uma única movimentação.
3. Simular resposta perdida após gravação; nova tentativa não duplica o efeito.
4. Criar, editar e confirmar offline o mesmo registro; sincronizar respeitando a ordem.
5. Receber erro de validação e preservar a operação para correção.
6. Editar o mesmo lançamento em dois clientes e resolver o conflito sem perda silenciosa.
7. Receber cancelamento remoto e não ressuscitar o registro como ativo.
8. Mostrar resumo desatualizado enquanto houver operações pendentes e atualizá-lo após confirmação.
9. Testar migração do banco local preservando pendências existentes.
