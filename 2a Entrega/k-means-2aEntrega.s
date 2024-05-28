#
# IAC 2023/2024 k-means
# 
# Grupo: 63
# Campus: Alameda
#
# Autores:
# 109441, Alexandre Delgado
# 109704, Guilherme Jose
# 109851, Francisco Goncalves
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
n_points:    .word 5
points:      .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 0,0, 0,0
k:           .word 3
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters:	.word 0, 0, 0, 0, 0

# Cada posicao contem o numero de pontos que pertencem ao cluster correspondente
#candidatosCentroids: .word 0,0, 0,0, 0,0
sum_centroids:		.word	 0, 0, 0, 0, 0, 0
n_points_clusters:	.word 	 0, 0, 0
#points_per_cluster:    .word    0, 0, 0



#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff, 0  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff
.equ LED_MATRIX_WIDTH, 32   # Definir tamanho
.equ LED_MATRIX_HEIGHT, 32  # Definir tamanho



# Codigo
 
.text
    jal ra, mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall



### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
        li a3, LED_MATRIX_0_HEIGHT
        sub a1, a3, a1
        addi a1, a1, -1
        li a3, LED_MATRIX_0_WIDTH
        mul a3, a3, a1
        add a3, a3, a0
        slli a3, a3, 2
        li a0, LED_MATRIX_0_BASE
        add a3, a3, a0   # addr
        sw a2, 0(a3)
        jr ra



# initializeScreen
# FUNCAO AUXILIAR    
# Pinta o ecra todo de branco
# Argumentos: nenhum
# Retorno: nenhum
    
initializeScreen:
    addi sp, sp, -4             # Criar espaco no stack
    sw ra, 0(sp)                # Guardar o return adress no stack
    li a2, white                # Carregar a cor para a2
    li t0, 31                   # Carregar o numero de pixeis nas colunas (0-31)
    linhas:
        li t1 31                # Carregar o numero de pixeis nas linhas (0-31)
        colunas:
            mv a0, t0           # Mover t0 para um argumento 
            mv a1, t1           # Mover t1 para um argumento
            jal printPoint      # Chamar a funcao printPoint com os argumentos (a0, a1, a2)
            addi t1, t1, -1     # Reduzir uma posicao
            bgez t1, colunas    # Se ainda existir uma posicao seguinte, chamar loop novamente
        
        addi t0, t0 -1          # Reduzir uma posicao
        bgez t0, linhas         # Se ainda existir uma posicao seguinte, chamar loop novamente
    lw ra, 0(sp)                # Carregar o return address inicial
    addi sp, sp, 4              # Restaurar o stack para o seu estado inicial
    jr ra                       # Return

    
    
### cleanScreen
# OPTIMIZATION

# Limpa todos os pontos do ecra
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    addi sp, sp, -4                 # Criar espaco na stack
    sw ra, 0(sp)                    # Guardar o return adress na stack
    la t0, points                   # Carregar o endereco do vetor pontos
    la t1, n_points               # Carregar o numero de pontos
    lw t1, 0(t1)

    loop_pontos_cleanScreen:
        beqz t1, end_loop_cleanScreen               # Se t1 for 0, terminar loop
        lw a0, 0(t0)                    # Carregar o valor de x do ponto
        lw a1, 4(t0)                    # Carregar o valor de y do ponto
        li a2, white                    # Carregar a cor para a2
        jal printPoint                  # Chamar a funcao printPoint com os argumentos (a0, a1, a2)
        addi t0, t0, 8                  # Avancar para o proximo ponto no vetor
        addi t1, t1, -1                 # Reduzir o contador de pontos
        j loop_pontos_cleanScreen                   # Repetir o loop

    end_loop_cleanScreen:
        lw ra, 0(sp)                    # Carregar o return adress inicial
        addi sp, sp, 4                  # Restaurar a stack para o seu estado inicial
        jr ra                           # Return
 



    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    la a0, points              # Endereco do vetor points
    la a1, clusters            # Endereco do vetor clusters
    la a2, colors              # Endereco do vetor colors
    lw a3, n_points            # Numero de pontos a pintar
    
    addi sp, sp, -4            # Criar espaco no stack
    sw ra, 0(sp)               # Guardar endereco de retorno
    
    
    # Loop para percorrer todos os pontos
loop_points_printClusters:
    beqz a3, end_loop_printClusters          # Se a3 (contador de pontos) for zero, sair do loop
    
    lw t0, 0(a0)               # Carregar o ponto atual (coordenada x)
    lw t1, 4(a0)               # Carregar o ponto atual (coordenada y)
    lw t2, 0(a1)               # Carregar o indice do cluster atual de clusters
    
    slli t2, t2, 2             # Multiplicar o indice do cluster por 4 (tamanho da palavra) para obter o offset
    add t2, t2, a2             # Adicionar o offset ao endereco base do vetor colors
    lw t3, 0(t2)               # Carregar a cor correspondente ao cluster
    
    # Preparar argumentos para printPoint
    mv a0, t0                  # Coordenada x
    mv a1, t1                  # Coordenada y
    mv a2, t3                  # Cor correspondente ao cluster
    addi sp, sp, -4            # Criar espaco no stack
    sw ra, 0(sp)               # Guardar endereco de retorno

    jal ra, printPoint         # Pinta o ponto na matriz
    
    lw ra, 0(sp)               # Recuperar endereco de retorno
    addi sp, sp, 4             # Restaurar a stack para o seu estado inicial
    
    addi a0, a0, 8             # Avançar para o próximo ponto em points (2 palavras = 8 bytes)
    addi a1, a1, 4             # Avançar para o próximo indice em clusters (1 palavra = 4 bytes)
    addi a3, a3, -1            # Decrementar o contador de pontos
    
    j loop_points_printClusters              # Repetir o loop
    
end_loop_printClusters:
    lw ra, 0(sp)               # Recuperar endereco de retorno
    addi sp, sp, 4             # Restaurar a stack para o seu estado inicial
    
    jr ra



### printCentroids:
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    la t0, centroids           # t0 = endereco base do vetor
    la t1, k                
    lw a1, 0(a1)               # t1 = numero de pontos
    slli t1, t1, 1             # t1 = numero de pontos * 2 = numero de elementos no vetor
    
    li a2, black               # Cor e o terceiro argumento do printPoint
    
    li t2, 0                                    # t2 = i
    
    for_printCentroids:
        bge t2, t1, skip_for_printCentroids    # Loop for corre apenas enquanto i < numero de elementos do vetor
        
        slli t3, t2, 2                          # i*4
        add t4, t0, t3                          # Endereco base + (i*4)
        lw a0, 0(t4)                            # Coordenada x e o primeiro argumento do printPoint
        lw a1, 4(t4)                            # Coordenada y e o segundo argumento
        
        #A cor ja esta no a2
        
        #(printPoint nao interfere com registos temporarios)
        addi sp, sp, -4                         # Criar espaco no stack
        sw ra, 0(sp)                            # Guardar endereco de retorno

        jal ra, printPoint                      # Pinta ponto na matriz
        
        lw ra, 0(sp)                            # Recuperar endereco de retorno
        addi sp, sp, 4                          # Restaurar a stack para o seu estado inicial
        
        
        addi t2, t2, 2                          # Proximo x esta em i+2
        j for_printCentroids
        
    skip_for_printCentroids:
        jr ra
        
    
    
    
### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    la t0, points
    la t1, clusters                            # Load do address do vetor clusters
    la t2, n_points_clusters
    la t3, sum_centroids                       # Load do address do vetor para somar as coordenadas           
    mv a0, s0                                  # Copia do numero de pontos

    loop_calculateCentroids:
        beqz a0, finish_calculateCentroids     # Verifica se ha pontos a analisar
        
        lw t5, 0(t1)                           # Load do numero do cluster
        
        add t2, t2, t5                         # Adiciona o valor do cluster ao address do n_points clusters
        lw t6, 0(t2)                           # Load do numero de pontos do cluster
        addi t6, t6, 1                         # Incrementa o numero de pontos do cluster
        sw t6, 0(t2)                           # Guarda o valor
        sub t2, t2, t5                         # Da reset do address do vetor n_points_clusters
        
        slli t5, t5, 1                         # Multiplica por 2 porque ha 2 coordenadas
        add t3, t3, t5                         # Adiciona ao address do cluster
        
        lw t4, 0(t0)                           # Load da coordenada x
        
        lw t6, 0(t3)                           # Da load da soma das coordenadas x
        add t6, t6, t4                         # Soma a coordenada x
        sw t6, 0(t3)                           # Guarda a soma
        
        lw t4, 4(t0)                           # Load da coordenada y
    
        lw t6, 4(t3)                           # Load da soma das coordenadas y do cluster
        add t6, t6, t4                         # Adiciona a coordenada do ponto a soma
        sw t6, 4(t3)                           # Guarda a soma
        
        sub t3, t3, t5                         # Da reset no address do vetor sum_centroids
        addi t0, t0, 8                         # Passa o address do vetor points para o proximo
        addi t1, t1, 4                         # Passa o address do vetor clusters para o proximo ponto
        addi a0, a0, -1                        # Decrementa o numero de pontos que ainda falta analisar
                
        j loop_calculateCentroids              # Volta ao inicio

    finish_calculateCentroids:
        div t0, t0, s0                         # Calcula media das coordenadas x
        div t1, t1, s0                         # Calcula media das coordenadas y
        la x28, centroids                      # Load do address dos centroides
        sw t0, 0(x28)                          # Guarda a coordenada x 
        sw t1, 4(x28)                          # Guarda a coordenada y
        jr ra                                  # Termina







### initializeCentroids
# Inicializa os valores iniciais do vetor centroids. Escolhe cada coordenada de forma pseudo-aleatoria.

# E usado um Linear Congruential Generator para gerar uma sequencia de valores que vao ser as coordenadas.
# E usado o tempo desde o Unix epoch como seed para o LCG para nao ser gerada sempre a mesma sequencia.
# Os outros parametros escolhidos foram dois numeros primos, 7 como coeficiente e 13 como incremento.
# O modulo e 32 para garantir que as coordenadas estao dentro da grelha.

# O LCG fica definido pela seguinte recorrencia:
# X0 = tempo desde Unix epoch (ms)
# Xn+1 = (7Xn + 13) mod 32

# Argumentos: nenhum
# Retorno: nenhum

initializeCentroids:
    li a7, 30          # Esta systemcall retorna o tempo em milisegundos desde o Unix epoch para a0 e a1
    ecall              # a0 ficara com os 32 bits inferiores do tempo em ms. Como sao esses os que mais mudam, sao os que irei usar
    
    la t0, k
    lw t0, 0(t0)
    slli t0, t0, 1     # Vetor centroides tera k*2 elementos pois sao 2 coordenadas por centroide
        
    li t1, 0           # i = 0
    
    la t2, centroids
    li t3, 7
    li t4, 32
    
    for_initializeCentroids:
        bge t1, t0, skip_for_initializeCentroids    # Loop for corre enquanto i < k*2 (numero de elementos vetor)
        
        mul t5, t3, a0        # Multiplica a seed (ou o valor anterior da sequencia) pelo coeficiente
        addi t5, t5, 13       # Adiciona o incremento
        rem t5, t5, t4        # Faz o modulo de 32
        
        bgez t5, skip_abs_coord    # Caso a coordenada calculada seja positiva salta-se a proxima instrucao
        neg t5, t5                 # Caso seja negativa calcula-se o simetrico
        
        skip_abs_coord:
            sw t5, 0(t2)          # Guarda a coordenada no vetor
            addi t2, t2, 4        # Avanca o endereco para o endereco da posicao seguinte
            addi t1, t1, 1        # i++
            mv a0, t5             # Poe coordenada como o ultimo valor obtido da sequencia
        
            j for_initializeCentroids    # Salta de novo para o loop
    
        
    skip_for_initializeCentroids:
        jr ra
    




### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0 
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
        sub a0, a2, a0                # x0 - x1
        bgez a0, skip1_manhattan      # Se diferenca for positiva, salta a proxima instrucao
        neg a0, a0                    # Se for negativa, fica o simetrico
        
        skip1_manhattan:
            sub a1, a3, a1                # y0 - y1
            bgez a1, skip2_manhattan      # Se diferenca for positiva, salta a proxima instrucao
            neg a1, a1                    # Se for negativa, fica o simetrico
        
            skip2_manhattan:
                add a0, a0, a1            # A distancia e a soma das duas diferencas em valor absoluto
                jr ra
        


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    la t0, k
    sw t0, 0(t0)
    slli t0, t0, 1    # Numero centroides * 2 e o numero de elementos do vetor centroids
    
    la t1, centroids
    li t2, 0            # t2 ira guardar a maior distancia
    li t3, 0            # t3 = i --> ira guardar o indice do x do centroide em cada iteracao
    li t5, 0            # t5 ira guardar o indice do cluster mais proximo 
    
    for_nearestCluster:
        bge t3, t0, skip_for_nearestCluster    # O loop corre enquanto i nao chegar ao numero de elementos do vetor
        
        lw a2, 0(t1)    # Carrega x do centroide
        lw a3, 4(t1)    # Carrega y do centroide
        
        # Guardar contexto da funcao
        addi sp, sp, -12
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        
        jal ra, manhattanDistance
        
        mv t4, a0        # t4 tem agora a distancia do ponto dado ao centroide desta iteracao
        
        # Restaurar contexto da funcao
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 12
        
        
        # Se distancia antiga (t2) continuar a ser a maior que a calculada, prepara a proxima iteracao do loop
        bgt t2, t4, prox_iteracao_nearestCluster
        # Se não, atualiza o indice em t5 para o do cluster correspondente ao centroide desta iteracao
        srai t5, t3, 1    # t5 = t3/2 --> indice e metade do indice da coordenada x do centroide
        mv t2, t4         # Distancia em t4 passa a ser a maior distancia
        
        prox_iteracao_nearestCluster:
            addi t3, t3, 2        # Proxima coordenada x esta em i+2
            addi t1, t1, 8        # Ou seja, avanco 2 posicoes no vetor (8 bytes)
            j for_nearestCluster

    
    skip_for_nearestCluster:
        mv a0, t5        # Poe o valor de retorno no registo adequado
        jr ra


# updateClusters


updateClusters:
    la t0, points
    la t1, k
    lw t1, 0(t1)
    slli t1, t1, 1        # k*2 e o numero de elementos de points

    li t2, 0    # i = 0
    
    for_updateClusters:
        bge t2, t1, 




### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:
    addi sp, sp, -4
    sw ra, 0(sp)
  
    jal ra initializeScreen

    jal ra initializeCentroids
    
    jal ra printClusters
    jal ra printCentroids
    
    la t0, L
    lw t0, 0(t0)
    li t1, 0
    
    main_loop:
        beq t1, t0, skip_main_loop
        
        addi sp, sp, -8
        sw t0, 0(sp)
        sw t1, 4(sp)
        
        jal ra updateClusters
        
        jal ra cleanScreen
        
        jal ra printClusters
        
        jal ra printCentroids
        
        jal ra calculateCentroids
        beqz a0, skip_main_loop
        
        lw t1, 4(sp)
        lw t0, 0(sp)
        addi sp, sp, 8
        
        addi t1, t1, 1    # i++
        
        j main_loop
        
    skip_main_loop:
    
    
    lw ra, 0(sp)
    addi sp, sp, 4
    jr ra
    
    #addi sp, sp, -4
    #sw ra, 0(sp)
    
    #jal ra, initializeScreen
    
    #jal ra, initializeCentroids
    
    #jal ra, printCentroids
    
    #jal ra, cleanScreen

    #lw ra, 0(sp)
    #addi sp, sp, 4
    
    #jr ra
