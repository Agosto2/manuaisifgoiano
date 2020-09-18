# Instruções para implantação do Helios

O sistema é implantado via imagens Docker utilizando _tags_ para cada nova versão criada. Antes de criar uma nova _tag_ deve-se primeiro obter o _sha256_, _hash_ criptográfico, dos arquivos com o comando:

```sh
sh sha256sum.sh
```

O resultado desse comando será salvo em um arquivo texto chamado `SHA256SUMS.txt` e também exibido no terminal - esse valor deve ser adicionado à descrição da _tag_ no [Gitlab](https://gitlab.ifsp.edu.br/), por exemplo:

**SHA256: 0f0463933255daed2e610dcbe31a2b225bb87cedb3d24a6171505247171db43c**

> O arquivo criado localmente **NÃO É VERSIONADO**. No CI, durante o _build_, que é um processo automatizado, o comando descrito acima é executado e o arquivo gerado é incluído na imagem docker produzida por esse processo.

Após a conclusão do _pipeline_ do CI associado à _tag_ recém-criada, deve-se acessar o _cluster Docker_ da DSI e substituir a versão da _tag_ anterior por essa nova e atualizar a _stack_.

Em caso de necessidade, pode-se comparar o _hash_ criptográfico dos arquivos do serviço em execução com o _hash_ cridado durante o processo de _build_ da imagem. Para isso, basta acessar o terminal de um dos _containers_ do serviço `django` da _stack_ e executar novamente o mesmo comando - `sh sha256sum.sh` - o valor deve ser igual ao que está no arquivo `SHA256SUMS.txt`, na descrição da _tag_ e também no _log_ do _job_ do CI que criou a imagem Docker.
