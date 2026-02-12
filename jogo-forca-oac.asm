############################
#           DATA           #
############################

.data

# -------- Variaveis --------
palavra_secreta:  .space 40
palavra_exibida:  .space 40
letra_digitada:   .byte 0

erros:            .word 0
max_erros:        .word 6

# -------- Mensagens --------
msg_inicio:    .asciiz "\n=== JOGO DA FORCA - OAC ===\n"
msg_j1:        .asciiz "\nJogador 1, digite a palavra secreta: "
msg_j2:        .asciiz "\nJogador 2, Qual a palavra?\n"
msg_letra:     .asciiz "\nDigite uma letra: "
msg_vitoria:   .asciiz "\nVITORIA!\n"
msg_derrota:   .asciiz "\nDERROTA!\n"
msg_palavra:   .asciiz "\nA palavra era: "

quebra_linha:  .asciiz "\n"


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

    jal ler_palavra              # ler palavra do jogador 1

    jal inicializar_palavra      # Inicializa palavra exibida com "_"

    sw $zero, erros              # Resetar erros

    # Avisar Jogador 2
    li $v0, 4
    la $a0, msg_j2
    syscall
    
#################################################
#               LOOP PRINCIPAL                  #
#################################################

loop_jogo:

    jal mostrar_palavra     # Mostrar palavra atual

    jal ler_letra           # Pedir letra ao usuário

    jal verificar_letra     # Verificar letra

    jal verificar_fim       # Verificar fim de jogo

    j loop_jogo


#################################################
#           LER PALAVRA (JOGADOR 1)             #
#################################################

ler_palavra:
    # Mostrar mensagem
    li $v0, 4
    la $a0, msg_j1
    syscall

    # Ler string
    li $v0, 8
    la $a0, palavra_secreta
    li $a1, 40
    syscall

    jr $ra


#################################################
#        INICIALIZAR PALAVRA EXIBIDA            #
#################################################

inicializar_palavra:

    la $t0, palavra_secreta    # ponteiro origem
    la $t1, palavra_exibida    # ponteiro destino

loop_init:

    lb $t2, 0($t0)             # carrega caractere atual

    beq $t2, 10, fim_init      # se '\n' -> parar
    beq $t2, $zero, fim_init   # se '\0' -> parar

    li $t3, 95                 # '_'
    sb $t3, 0($t1)

    addi $t0, $t0, 1
    addi $t1, $t1, 1

    j loop_init

fim_init:

    sb $zero, 0($t1)          # finaliza string com '\0'
 
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
