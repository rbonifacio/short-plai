### Notas 

(a) Não teremos aula na próxima segunda feira (21/08). Teremos uma palestra com o Prof. Gustavo Pinto, da Universidade Federal do Pará (local: auditório do CIC). 

(b) Para instalar o lhs2tex, primeiro você precisa ter instalado a plataforma Haskell (http://www.haskell.org). 

---
    [Fazer download do Cabal 2.0.](https://www.haskell.org/cabal/download.html) Após descompactar, seguir os passos:
    * ghc -threaded --make Setup
 A instalação pode ser local, com escolha da pasta usando --prefix, por exemplo --prefix=/home/user/install/cabal    
    * ./Setup configure --user
    * ./Setup build
    * ./Setup install
---


Em seguida, na linha de comando (suponho que você esteja trabalhando em uma máquina Unix like), executar o comando: 

   * cabal install lhs2tex

Isso deve instalar o lhs2tex no diretório <home>/.cabal/bin (isso no Linux). Ajustar o caminho deste arquivo no Makefile

---
Pode ser necessário a instalação de pacotes adicionais do latex, caso não tenha a versão completa. Assim, executar os comandos:
    * sudo apt-get update
    * sudo apt-get install texlive-math-extra texlive-latex-extra texlive-latex-base texlive-generic-extra texlive-science texlive-fonts-extra
---


(c) Na raiz do projeto, executar o comando make, gerando o arquivo PLAI.pdf

(d) O código fonte haskell das linguagens AE (Arithmetic Expressions) e LAE (Let + Arithmetic Expressions) está disponível no diretório c2.  
