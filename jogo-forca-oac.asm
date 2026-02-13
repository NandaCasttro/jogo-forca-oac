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
msg_erros:     .asciiz "Erros: "
msg_palavra:   .asciiz "\nA palavra era: "

quebra_linha:  .asciiz "\n"
barra:         .asciiz "/"


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
    addi $t1, $t1, 1   
    
    # coloca espaço entre os _
    li $t3, 32
    sb $t3, 0($t1)
    addi $t1, $t1, 1
    
    addi $t0, $t0, 1

    j loop_init

fim_init:

    sb $zero, 0($t1)          # finaliza string com '\0'
 
    jr $ra


#################################################
#               MOSTRAR PALAVRA                 #
#################################################

mostrar_palavra:

    li $v0, 4
    la $a0, palavra_exibida
    syscall

    li $v0, 4
    la $a0, quebra_linha
    syscall

    # mostrar "Erros: "
    li $v0, 4
    la $a0, msg_erros
    syscall

    # imprimir valor de erros
    li $v0, 1
    lw $a0, erros
    syscall

    # imprimir "/"
    li $v0, 4
    la $a0, barra
    syscall

    # imprimir max_erros
    li $v0, 1
    lw $a0, max_erros
    syscall

    li $v0, 4
    la $a0, quebra_linha
    syscall
    
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
    
    # Consumir ENTER
    li $v0, 12
    syscall

    jr $ra


#################################################
#               VERIFICAR LETRA                 #
#################################################

verificar_letra:

    la $t0, palavra_secreta
    la $t1, palavra_exibida

    lb $t3, letra_digitada         # letra digitada
    li $t4, 0                      # flag = não encontrou

loop_verifica:

    lb $t2, 0($t0)

    beq $t2, 10, fim_verifica   # '\n'
    beq $t2, $zero, fim_verifica

    beq $t2, $t3, acertou

continuar:

    addi $t0, $t0, 1
    addi $t1, $t1, 2
    
    j loop_verifica

acertou:

    sb $t3, 0($t1)   # coloca letra na palavra_exibida
    li $t4, 1        # marca que encontrou
    j continuar

fim_verifica:

    beq $t4, 1, fim_funcao  # se encontrou, não conta erro

    # incrementar erros
    la $t5, erros
    lw $t6, 0($t5)
    addi $t6, $t6, 1
    sw $t6, 0($t5)

fim_funcao:
    jr $ra


#################################################
#               VERIFICAR FIM                   #
#################################################

verificar_fim:

    # Verificar se venceu
    la $t0, palavra_exibida

loop_verifica_fim:

    lb $t1, 0($t0)

    beq $t1, $zero, venceu   # chegou no fim sem '_'
    
    li $t2, 95               # '_'
    beq $t1, $t2, ainda_nao_venceu

    addi $t0, $t0, 1
    j loop_verifica_fim


ainda_nao_venceu:

    # verificar se perdeu
    la $t3, erros
    lw $t4, 0($t3)

    la $t5, max_erros
    lw $t6, 0($t5)

    beq $t4, $t6, perdeu

    jr $ra


venceu:

    li $v0, 4
    la $a0, msg_vitoria
    syscall

    li $v0, 10
    syscall


perdeu:

    li $v0, 4
    la $a0, msg_derrota
    syscall

    li $v0, 10
    syscall

