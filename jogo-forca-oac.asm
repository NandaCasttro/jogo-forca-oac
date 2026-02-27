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
letras_usadas:    .space 26
qtd_letras:       .word 0

nome_arquivo:     .asciiz "palavras.txt"
buffer_arquivo:   .space 1024

dica:             .space 40
input_buffer:     .space 4

# -------- Mensagens --------
msg_inicio:    .asciiz "\n=== JOGO DA FORCA - OAC ===\n"
msg_j1:        .asciiz "\nJogador 1, digite a palavra secreta: "
msg_j2:        .asciiz "\nJogador 2, Qual a palavra?\n"
msg_letra:     .asciiz "\nDigite uma letra: "
msg_vitoria:   .asciiz "\nVITORIA!\n"
msg_derrota:   .asciiz "\nDERROTA!\n"
msg_palavra:   .asciiz "\nA palavra era: "
msg_erros:     .asciiz "Erros: "
msg_usadas:    .asciiz "Letras usadas: "
msg_dica:      .asciiz "\nDica: "


quebra_linha:  .asciiz "\n"
barra:         .asciiz "/"
msg_erro:      .asciiz "Erro ao abrir arquivo\n"

msg_teste:         .asciiz "Palavra lida: "

############################
#           TEXT           #
############################

.text
.globl main

#################################################
#                   MAIN                        #
#################################################

main:

    jal ler_arquivo
    jal escolher_grupo_palavra

    # Mostra mensagem inicial
    li $v0, 4
    la $a0, msg_inicio
    syscall

    # Mostrar dica
    li $v0, 4
    la $a0, msg_dica
    syscall

    li $v0, 4
    la $a0, dica
    syscall

    li $v0, 4
    la $a0, quebra_linha
    syscall

    jal inicializar_palavra      # Inicializa palavra exibida com "_"

    sw $zero, erros              # Resetar erros
    sw $zero, qtd_letras         # Resetar letras já usadas

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
#               LER ARQUIVO                     #
#################################################

ler_arquivo:
    # Abrir arquivo
    li $v0, 13          # syscall open
    la $a0, nome_arquivo
    li $a1, 0
    li $a2, 0
    syscall

    bltz $v0, erro_arquivo      # se retorno < 0 vai dar erro

    move $s0, $v0
    
    # Ler arquivo
    li $v0, 14          # syscall read
    move $a0, $s0
    la $a1, buffer_arquivo
    li $a2, 1024
    syscall
    
    move $s1, $v0       # bytes lidos
    
    add $t0, $a1, $s1   # endereço buffer + bytes_lidos
    sb $zero, 0($t0)    # coloca '\0'
    
     # Fechar arquivo
    li $v0, 16
    move $a0, $s0
    syscall
    
    jr $ra

#################################################
#     ESCOLHER GRUPO E PALAVRA                 #
#################################################

escolher_grupo_palavra:

    # Contar grupos pelo ';'
    la $t0, buffer_arquivo
    li $t3, 0

conta_grupos_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, conta_grupos_fim
    li $t2, 59
    bne $t1, $t2, conta_grupos_next
    addi $t3, $t3, 1

conta_grupos_next:
    addi $t0, $t0, 1
    j conta_grupos_loop

conta_grupos_fim:
    # Escolher grupo aleatorio
    li $v0, 42
    move $a1, $t3
    syscall
    move $t4, $a0

    # Encontrar inicio do grupo escolhido
    la $t0, buffer_arquivo
    move $t7, $t0
    li $t5, 0

procura_grupo_loop:
    beq $t5, $t4, grupo_encontrado

    lb $t1, 0($t0)
    beq $t1, $zero, grupo_encontrado

    li $t2, 59
    bne $t1, $t2, procura_grupo_next

    addi $t5, $t5, 1
    addi $t0, $t0, 1

pula_quebras_grupo:
    lb $t1, 0($t0)
    li $t2, 10
    beq $t1, $t2, pula_quebras_grupo_avanca
    li $t2, 13
    beq $t1, $t2, pula_quebras_grupo_avanca
    j atualiza_inicio_grupo

pula_quebras_grupo_avanca:
    addi $t0, $t0, 1
    j pula_quebras_grupo

atualiza_inicio_grupo:
    move $t7, $t0
    j procura_grupo_loop

procura_grupo_next:
    addi $t0, $t0, 1
    j procura_grupo_loop

grupo_encontrado:
    # Copiar cabecalho (dica)
    la $t6, dica

pula_quebras_dica:
    lb $t1, 0($t7)
    li $t2, 10
    beq $t1, $t2, pula_quebras_dica_avanca
    li $t2, 13
    beq $t1, $t2, pula_quebras_dica_avanca
    j copia_dica_loop

pula_quebras_dica_avanca:
    addi $t7, $t7, 1
    j pula_quebras_dica

copia_dica_loop:
    lb $t1, 0($t7)
    beq $t1, 10, copia_dica_fim
    beq $t1, $zero, copia_dica_fim
    sb $t1, 0($t6)
    addi $t6, $t6, 1
    addi $t7, $t7, 1
    j copia_dica_loop

copia_dica_fim:
    sb $zero, 0($t6)

    # Pular quebras antes das palavras
pula_quebras_palavras:
    lb $t1, 0($t7)
    li $t2, 10
    beq $t1, $t2, pula_quebras_palavras_avanca
    li $t2, 13
    beq $t1, $t2, pula_quebras_palavras_avanca
    j inicio_palavras_ok

pula_quebras_palavras_avanca:
    addi $t7, $t7, 1
    j pula_quebras_palavras

inicio_palavras_ok:
    move $s2, $t7

    # Contar palavras do grupo
    move $t0, $s2
    li $t8, 0
    li $t9, 0

conta_palavras_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, conta_palavras_fim
    li $t2, 59
    beq $t1, $t2, conta_palavras_fim
    li $t2, 10
    beq $t1, $t2, conta_palavras_nl

    bne $t9, $zero, conta_palavras_next
    addi $t8, $t8, 1
    li $t9, 1

conta_palavras_next:
    addi $t0, $t0, 1
    j conta_palavras_loop

conta_palavras_nl:
    li $t9, 0
    addi $t0, $t0, 1
    j conta_palavras_loop

conta_palavras_fim:
    # Escolher palavra aleatoria
    li $v0, 42
    move $a1, $t8
    syscall
    move $t4, $a0

    # Selecionar palavra dentro do grupo
    move $t0, $s2
    li $t5, 0
    li $t9, 0

seleciona_palavra_loop:
    lb $t1, 0($t0)
    beq $t1, $zero, seleciona_palavra_fim
    li $t2, 59
    beq $t1, $t2, seleciona_palavra_fim
    li $t2, 10
    beq $t1, $t2, seleciona_palavra_nl

    bne $t9, $zero, seleciona_palavra_next
    beq $t5, $t4, copia_palavra
    addi $t5, $t5, 1
    li $t9, 1
    j seleciona_palavra_next

seleciona_palavra_next:
    addi $t0, $t0, 1
    j seleciona_palavra_loop

seleciona_palavra_nl:
    li $t9, 0
    addi $t0, $t0, 1
    j seleciona_palavra_loop

copia_palavra:
    la $t6, palavra_secreta

copia_palavra_loop:
    lb $t1, 0($t0)
    beq $t1, 10, copia_palavra_fim
    beq $t1, 13, copia_palavra_fim
    beq $t1, 59, copia_palavra_fim
    beq $t1, $zero, copia_palavra_fim
    sb $t1, 0($t6)
    addi $t6, $t6, 1
    addi $t0, $t0, 1
    j copia_palavra_loop

copia_palavra_fim:
    sb $zero, 0($t6)

seleciona_palavra_fim:
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
    beq $t2, 13, fim_init      # se '\r' -> parar
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
    
    # Mostrar "Letras usadas: "
    li $v0, 4
    la $a0, msg_usadas
    syscall

    # Carregar quantidade de letras usadas
    lw $t0, qtd_letras
    la $t1, letras_usadas
    li $t2, 0

loop_mostrar_usadas:

    beq $t2, $t0, fim_mostrar_usadas

    lb $a0, 0($t1)
    li $v0, 11          # imprimir caractere
    syscall

    # imprimir espaço
    li $a0, 32
    li $v0, 11
    syscall

    addi $t1, $t1, 1
    addi $t2, $t2, 1
    j loop_mostrar_usadas

fim_mostrar_usadas:

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

ler_letra_loop:
    # Ler string curta para evitar erro no syscall 12
    li $v0, 8
    la $a0, input_buffer
    li $a1, 4
    syscall

    lb $t0, input_buffer
    li $t1, 10
    beq $t0, $t1, ler_letra_loop
    li $t1, 13
    beq $t0, $t1, ler_letra_loop

    # Salvar primeira letra digitada
    sb $t0, letra_digitada

    jr $ra


#################################################
#               VERIFICAR LETRA                 #
#################################################

verificar_letra:

    lb $t3, letra_digitada      # letra digitada
    
    la $t7, palavra_exibida
    
    la $t0, letras_usadas
    lw $t1, qtd_letras
    li $t2, 0                   # contador

loop_verifica_usadas:

    beq $t2, $t1, letra_nova    # chegou no fim -> é nova

    lb $t4, 0($t0)
    beq $t4, $t3, fim_funcao    # já foi digitada -> sair

    addi $t0, $t0, 1
    addi $t2, $t2, 1
    j loop_verifica_usadas

letra_nova:

    # salvar letra no vetor
    la $t0, letras_usadas
    lw $t1, qtd_letras
    add $t0, $t0, $t1
    sb $t3, 0($t0)

    addi $t1, $t1, 1
    sw $t1, qtd_letras   

    la $t0, palavra_secreta
    la $t1, palavra_exibida
    li $t4, 0                   # flag = não encontrou
    
loop_verifica:

    lb $t2, 0($t0)

    beq $t2, 10, fim_verifica   # '\n'
    beq $t2, 13, fim_verifica   # '\r'
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
    beq $t1, 13, venceu       # trata CR como fim
    
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

    li $v0, 4
    la $a0, msg_palavra
    syscall

    li $v0, 4
    la $a0, palavra_secreta
    syscall
    
    li $v0, 10
    syscall


perdeu:

    li $v0, 4
    la $a0, msg_derrota
    syscall
    
    li $v0, 4
    la $a0, msg_palavra
    syscall

    li $v0, 4
    la $a0, palavra_secreta
    syscall

    li $v0, 10
    syscall
    
erro_arquivo:
    li $v0, 4
    la $a0, msg_erro
    syscall

    li $v0, 10
    syscall

