# Jogo da Forca

![Assembly](https://img.shields.io/badge/Assembly-MIPS-blue)
![Simulador](https://img.shields.io/badge/Simulador-MARS-orange)
![Interface](https://img.shields.io/badge/Interface-Python-green)
![Status](https://img.shields.io/badge/Status-Concluído-brightgreen)

Projeto desenvolvido para a disciplina de **Organização e Arquitetura de Computadores (OAC)**.
O sistema implementa o jogo da forca utilizando:

- 🧠 Assembly MIPS (lógica do jogo)
- 🖥️ Python com Tkinter (interface gráfica)
- ☕ MARS 4.5 (simulador MIPS)
- 🔗 Comunicação via subprocess (Python ↔ MIPS)

---

O objetivo do projeto foi implementar o jogo da forca **integralmente em Assembly MIPS**, aplicando conceitos de:

- Organização dos segmentos `.data` e `.text`
- Manipulação manual de memória
- Uso de registradores
- Controle de fluxo com saltos
- Implementação de loops em baixo nível
- Entrada e saída via syscalls
- Leitura de arquivos
- Geração de números aleatórios
- Controle de estado do jogo

*A interface gráfica em Python atua apenas como camada de interação, enquanto **toda a lógica do jogo está implementada em Assembly**.*

---

# 🏗️ Estrutura do Programa em MIPS

![Arquivo](https://img.shields.io/badge/Arquivo-jogo--forca--oac.asm-blue)


O código está dividido em dois segmentos principais:

---

## 🔹 Segmento `.data`

Responsável por armazenar:

- Palavra secreta
- Palavra exibida (com "_")
- Letra digitada
- Contador de erros
- Número máximo de erros
- Vetor de letras já utilizadas
- Buffer de leitura do arquivo
- Dica do grupo
- Mensagens exibidas ao usuário

## 🔹 Segmento .text

Contém toda a lógica do jogo organizada em procedimentos.

**main:**
- jal ler_arquivo
- jal escolher_grupo_palavra
- jal inicializar_palavra

**loop_jogo:**
- jal mostrar_palavra
- jal ler_letra
- jal verificar_letra
- jal verificar_fim
- j loop_jogo

---

## Interface (Camada Auxiliar)

A interface gráfica foi implementada em Python utilizando Tkinter.
Responsável apenas por:
- Exibir a palavra
- Desenhar a forca
- Mostrar letras usadas
- Enviar entrada do usuário
- Exibir resultado final

*A lógica do jogo permanece totalmente em Assembly.*

---

## Conclusão

O projeto demonstra a implementação de um sistema interativo com foco na aplicação prática de conceitos de OAC.
Toda a lógica do jogo foi desenvolvida em Assembly MIPS, evidenciando controle de memória, fluxo e processamento.

---

## Desenvolvedores

`Ariele de Carvalho Mendonça`  
`Anderson Andrade Santos`  
`David Santos Silvino`  
`Fernanda de Castro Alencar Batista`  
`Victor Pereira Gois`

Professor: `André Luiz Menezes`

---
 
> ## UNIVERSIDADE FEDERAL DE SERGIPE - CAMPUS ITABAIANA
> DEPARTAMENTO DE SISTEMAS DE INFORMAÇÃO - 2025.2

