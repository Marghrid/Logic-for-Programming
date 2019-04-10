    % % % % % % % % % % % % % % % % %
    %           GRUPO 41:           %
    %                               %
    %   Margarida Ferreira, 80832   %
    %     Miguel Marques, 83532     %
    % % % % % % % % % % % % % % % % %


%%%%%%%%    PREDICADOS AUXILIARES DE MANIPULACAO DE LISTAS:     %%%%%%%%

%%%     membro/2:
%%%     membro(E,L) afirma que E pertence a lista L.

membro(X, [X|_]) :- !.
membro(X, [_|R]) :- membro(X, R).


%%%     acede_lista/3:
%%%	acede_lista(L, Ind, El) afirma que El e o elemento de indice Ind
%%%	    da lista L. Considera-se que o primeiro elento tem indice 1.

acede_lista(L, Ind, El) :- acede_lista(L, Ind, El, 1).
acede_lista([P|_], Ind, P, Ind) :- !.
acede_lista([_|R], Ind, El, Aux) :- Aux_1 is Aux+1,
                                    acede_lista(R, Ind, El, Aux_1).

%%%     junta/3:
%%%	junta(X, Y, Z) afirma que a lista Z e o resultado de juntar a
%%%          lista X com a lista Y.

junta([], L, L):- !.
junta([P|R], L1, [P|L2]) :- junta(R, L1, L2).


%%%     inverte/2:
%%%     inverte(L1, L2) afirma que L1 e a lista L2 invertida.

inverte([], []) :- !.
inverte([P | R], I) :- inverte(R, I1), junta(I1, [P], I).


%%%%%%%%        ESTRUTURAS:     %%%%%%%%

%%%      Estrutura posicao: <pos> ::= (<linha>, <coluna>).
%%%         Construtor:
faz_pos(Lin, Col, (Lin, Col)).
%%%         Seletores:
pos_Lin((Lin, _), Lin).
pos_Col((_, Col), Col).

%%%	 Estrutura movimento: <mov> ::= (<dir>,<pos>); <dir> ::= c|b|e|d|i.
%%%         Construtor:
faz_mov(Dir, Pos, (Dir, Lin, Col)) :- pos_Lin(Pos, Lin),
                                      pos_Col(Pos, Col).
%%%         Seletores:
mov_Dir((Dir, _, _), Dir).
mov_Pos((_, Lin, Col), Pos) :- faz_pos(Lin,Col,Pos).


%%%%%%%%        PREDICADOS AUXILIARES:      %%%%%%%%

%%%     dir_possiveis/2:
%%%	dir_possiveis(Cel, DirPoss) afirma que apenas as direcoes
%%%	    especificadas na lista DirPoss podem ser seguidas a partir
%%%	    da celula Cel do tabuleiro.

dir_possiveis(Cel, DirPoss) :- dir_possiveis([d,e,b,c], Cel, DirPoss).

dir_possiveis([], _, []) :- !.

dir_possiveis([PDirs|RDirs], Cel, DirPoss) :- membro(PDirs, Cel),
					      !,
					      dir_possiveis(RDirs, Cel, DirPoss).

dir_possiveis([PDirs|RDirs], Cel, [PDirs|RDirPoss]) :-
					      dir_possiveis(RDirs, Cel, RDirPoss).


%%%     nao_visitado/2:
%%%     nao_visitado(Pos, LMov) afirma que Pos nao existe na lista LMov.

nao_visitado(_, []) :- !.
nao_visitado(Pos, [PMov|RMov]) :- \+ mov_Pos(PMov, Pos),
				  nao_visitado(Pos, RMov).


%%%     calcula_mov/4:
%%%	calcula_mov(Pos, Dir, LMovs, Mov) afirma que Mov e o movimento
%%%	    que resulta da translacao da posicao Pos segundo a direcao Dir.

calcula_mov(Pos, Dir, LMovs, Mov) :- Dir == d,
				     pos_Lin(Pos, Lin),
			             pos_Col(Pos, Col),
			             Col1 is Col+1,
			             faz_pos(Lin, Col1, NPos),
		                     nao_visitado(NPos, LMovs),
		                     faz_mov(Dir, NPos, Mov);

				     Dir == e,
	                             pos_Lin(Pos, Lin),
                                     pos_Col(Pos, Col),
                                     Col1 is Col-1,
                                     faz_pos(Lin, Col1, NPos),
				     nao_visitado(NPos, LMovs),
				     faz_mov(Dir, NPos, Mov);

			             Dir == b,
			             pos_Lin(Pos, Lin),
		                     pos_Col(Pos, Col),
		                     Lin1 is Lin+1,
		                     faz_pos(Lin1, Col, NPos),
	                             nao_visitado(NPos, LMovs),
	                             faz_mov(Dir, NPos, Mov);

                                     Dir == c,
			             pos_Lin(Pos, Lin),
			             pos_Col(Pos, Col),
			             Lin1 is Lin-1,
		                     faz_pos(Lin1, Col, NPos),
		                     nao_visitado(NPos, LMovs),
		                     faz_mov(Dir, NPos, Mov).


%%%     movs_poss_aux/4:
%%%     movs_poss_aux(LDirPoss, Pos_atual, LMovs, LPoss)
%%%	    afirma que LPoss e a lista de movimentos que podem ser
%%%	    criados com as direcoes em LDirPoss a partir de Pos_atual,
%%%	    sem repetir posicoes ja visitadas, indicadas em LMovs.

movs_poss_aux([], _, _, []) :- !.

movs_poss_aux([PDirPoss|RDirPoss], Pos_atual, LMovs, [Mov|RPoss]) :-
		             calcula_mov(Pos_atual, PDirPoss, LMovs, Mov),
			     !,
			     movs_poss_aux(RDirPoss, Pos_atual, LMovs, RPoss).

movs_poss_aux([_|RDirPoss], Pos_atual, LMovs, Poss) :-
			     movs_poss_aux(RDirPoss, Pos_atual, LMovs, Poss).


%%%     escolhe_mov/2:
%%%	escolhe_mov(L,El) afirma que El e o primeiro elemento da lista L.

escolhe_mov([P|_],P).
escolhe_mov([_|R], S) :- escolhe_mov(R, S).


%%%     lista_distancias/4:
%%%	lista_distancias(LMovs, Pos_inicial, Pos_final, LDists) afirma
%%%	    que LDists e a lista que resulta de juntar as distancias das
%%%	    posicoes dos movimentos a Pos_inicial e a Pos_final aos
%%%	    movimentos segundo a forma LDists[i] =
%%%	    distmov(Dist_Pos_final, Dist_Pos_inicial, LMovs[i]).

lista_distancias([], _, _, []) :- !.
lista_distancias([PMovs|RMovs], Pos_inicial, Pos_final, [PDists|RDists]) :-
		    mov_Pos(PMovs, Pos1),
		    distancia(Pos1, Pos_inicial, Dist_Pos_inicial),
		    distancia(Pos1, Pos_final, Dist_Pos_final),
		    PDists = distmov(Dist_Pos_final, Dist_Pos_inicial, PMovs),
		    lista_distancias(RMovs, Pos_inicial, Pos_final, RDists).


%%%     tira_distancias/2:
%%%	tira_distancias(LDists, LMovs) afirma que LMovs e a lista que
%%%	resulta de retirar as distancias a lista LDists.

tira_distancias([], []) :- !.
tira_distancias([distmov(_, _, Mov)|RDists], [Mov|RMovs]) :-
	                                        tira_distancias(RDists, RMovs).


%%%%%%%%        PREDICADOS AVALIADOS:       %%%%%%%%

%%%     movs_possiveis/4:
%%%	movs_possiveis(Lab, Pos_atual, Movs, Poss) afirma que Poss sao
%%%	    os movimentos que podem ser efetuados a partir de Pos_atual,
%%%	    tendo em conta as paredes do labirinto Lab e as posicoes ja
%%%	    visitadas indicadas em Movs.

movs_possiveis(Lab, Pos_atual, Movs, Poss) :-
			     pos_Lin(Pos_atual, Ind_Linha),
		             acede_lista(Lab, Ind_Linha, Linha),
		             pos_Col(Pos_atual, Ind_Coluna),
	                     acede_lista(Linha, Ind_Coluna, Celula),
	                     dir_possiveis(Celula, Dir_Poss),
	                     inverte(Dir_Poss, Dir_Poss1),
		             movs_poss_aux(Dir_Poss1, Pos_atual, Movs, Poss).


%%%     distancia/3:
%%%	distancia((L1, C1),(L2, C2),Dist) afirma que
%%%     Dist = abs(L1 - L2) + abs(C1 - C2).

distancia((L1,C1), (L2,C2), Dist) :- abs((L1-L2), DifL),
				     abs((C1-C2), DifC),
				     Dist is DifL + DifC.


%%%     ordena_poss/4:
%%%	ordena_poss(Poss, Poss_ord, Pos_inicial, Pos_final) significa
%%%	que Poss_ord e o resultado de ordenar os movimentos possiveis
%%%	Poss, em relacao a distancia a Pos_inicial e a distancia a Pos_final.

ordena_poss(Poss, Poss_ord, Pos_inicial, Pos_final) :-
		     lista_distancias(Poss, Pos_inicial, Pos_final, Dists),
		     sort(2, >=, Dists, Dists_ord),
		     sort(1, =<, Dists_ord, Dists_ord1),
		     tira_distancias(Dists_ord1, Poss_ord).


%%%     resolve1/4:
%%%	resolve1(Lab, Pos_inicial, Pos_final, Movs) significa que a
%%%	    sequencia de movimentos Movs e uma solucao para o labirinto
%%%	    Lab, desde Pos_inicial ate Pos_final selecionando o movimento
%%%         a efetuar de acordo com a ordem de direcoes c,b,e,d.

resolve1(Lab, Pos_inicial, Pos_final, Movs) :-
	          faz_mov(i, Pos_inicial, MovIni),
		  resolve1(Lab, Pos_inicial, Pos_final, Movs, [MovIni]),
		  !.

resolve1(_, _, Pos_final, Movs, [PMovs_Aux|RMovs_Aux]) :-
					  mov_Pos(PMovs_Aux, Pos_final),
				          !,
					  inverte([PMovs_Aux|RMovs_Aux], Movs).

resolve1(Lab, Pos_inicial, Pos_final, Movs, [PMovs_Aux|RMovs_Aux]) :-
		  mov_Pos(PMovs_Aux, Pos_atual),
		  movs_possiveis(Lab, Pos_atual, [PMovs_Aux|RMovs_Aux], Poss),
		  escolhe_mov(Poss, Mov),
		  junta([Mov], [PMovs_Aux|RMovs_Aux], NMovsAux),
		  resolve1(Lab, Pos_inicial, Pos_final, Movs,  NMovsAux).


%%%     resolve2/4:
%%%	resolve2(Lab, Pos_inicial, Pos_final, Movs) significa que a
%%%	    sequencia de movimentos Movs e uma solucao para o labirinto
%%%	    Lab, desde Pos_inicial ate Pos_final, selecionando a cada passo
%%%	    o movimento de acordo com a ordenacao obtida em ordena_poss/4.

resolve2(Lab, Pos_inicial, Pos_final, Movs) :-
	           faz_mov(i, Pos_inicial, MovIni),
		   resolve2(Lab, Pos_inicial, Pos_final, Movs, [MovIni]),
		   !.

resolve2(_, _, Pos_final, Movs, [PMovs_Aux|RMovs_Aux]) :-
	                                mov_Pos(PMovs_Aux, Pos_final),
					!,
				        inverte([PMovs_Aux|RMovs_Aux], Movs).

resolve2(Lab, Pos_inicial, Pos_final, Movs, [PMovs_Aux|RMovs_Aux]) :-
		   mov_Pos(PMovs_Aux, Pos_atual),
		   movs_possiveis(Lab, Pos_atual, [PMovs_Aux|RMovs_Aux], Poss),
		   ordena_poss(Poss, Poss_ord, Pos_inicial, Pos_final),
		   escolhe_mov(Poss_ord, Mov),
		   junta([Mov], [PMovs_Aux|RMovs_Aux], NMovsAux),
		   resolve2(Lab, Pos_inicial, Pos_final, Movs,  NMovsAux).
