############################
#           DATA           #
############################

.data

# -------- Banco de Palavras --------
p1: .asciiz "cache"
p2: .asciiz "memoria"
p3: .asciiz "processador"
p4: .asciiz "registrador"
p5: .asciiz "pipeline"
p6: .asciiz "barramento"
p7: .asciiz "assembly"
p8: .asciiz "multiciclo"
p9: .asciiz "computadores"
p10: .asciiz "programacao"

vetor_palavras:
    .word p1
    .word p2
    .word p3
    .word p4
    .word p5
    .word p6
    .word p7
    .word p8
    .word p9
    .word p10

# -------- Variáveis do Jogo --------
palavra_escolhida: .word 0
palavra_exibida:   .space 30
letra_digitada:    .byte 0
erros:             .word 0
max_erros:         .word 6

# -------- Mensagens --------
msg_inicio:    .asciiz "\n=== JOGO DA FORCA ===\n"
msg_letra:     .asciiz "\nDigite uma letra: "
msg_vitoria:   .asciiz "\nVITORIA!\n"
msg_derrota:   .asciiz "\nDERROTA!\n"

############################
#           TEXT           #
############################

.text
.globl main

#################################################
#                   MAIN                        #
#################################################

main:

    # Mostra mensagem inicial
    li $v0, 4
    la $a0, msg_inicio
    syscall

    # Seleciona palavra aleatória
    jal select_palavra

    # Inicializa palavra exibida com "_"
    jal inicia_palavra

loop_jogo:

    # Mostrar palavra atual
    jal mostrar_palavra

    # Pedir letra ao usuário
    jal ler_letra

    # Verificar letra
    jal verificar_letra

    # Verificar fim de jogo
    jal verificar_fim

    j loop_jogo


#################################################
#           SELECIONAR PALAVRA                  #
#################################################

selecionar_palavra:
    # Aqui vamos:
    # 1. Gerar número aleatório 0-9 
    li $v0, 42
    li $a1, 10
    syscall
    
    #Resultado está em $a0
    move $t0, $a0      #guarda índice em $t0
    
    # 2. Multiplicar por 4
    li $t1, 4
    mul $t0, $t0, $t1
    
    # 3. Buscar endereço no vetor
    #Carregar endereço base do vetor
    la $t2, vetor_palavras

    #Somar deslocamento
    add $t2, $t2, $t0

    #Carregar endereço da palavra sorteada
    lw $t3, 0($t2)
   
    # 4. Salvar em palavra_escolhida
    sw $t3, palavra_escolhida

    jr $ra


#################################################
#        INICIALIZAR PALAVRA EXIBIDA
#################################################

inicializar_palavra:
    # Percorrer palavra escolhida
    # Copiar "_" para palavra_exibida
    # Parar no '\0'

    jr $ra


#################################################
#               MOSTRAR PALAVRA                 #
#################################################

mostrar_palavra:
    # Imprimir palavra_exibida

    jr $ra


#################################################
#                LER LETRA                      #
#################################################

ler_letra:

    # Mostrar mensagem
    li $v0, 4
    la $a0, msg_letra
    syscall

    # Ler caractere
    li $v0, 12
    syscall

    # Salvar em letra_digitada
    sb $v0, letra_digitada

    jr $ra


#################################################
#               VERIFICAR LETRA                 #
#################################################

verificar_letra:
    # Percorrer palavra original
    # Comparar com letra_digitada
    # Atualizar palavra_exibida
    # Se não encontrar, incrementar erros

    jr $ra


#################################################
#               VERIFICAR FIM                   #
#################################################

verificar_fim:
    # Verificar vitória
    # Verificar derrota
    # Se terminar, encerrar programa

    jr $ra
