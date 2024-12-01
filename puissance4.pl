%% Pour gagner il faut : 
% => avoir 4 jetons sur une meme ligne
% => avoir 4 jetons sur une meme diagonale
% => avoir 4 jetons sur une meme colonne
% 6 lignes, 7 colonnes

Token(rouge).
Token(jaune).

debut() :-
    plateau(P),
    afficher_etat(P),
    choix_joueurs(),
    boucle(P, 0).

choix_joueurs() :-
    % choix J vs J
    % choix couleur si vs IA
    writeln('Le premier joueur joue les rouges (R) ! Le deuxième les jaunes (J) !').

%%% Boucle du jeu
boucle(P, Tours) :- 
    writeln(Tours mod 2),
    M is Tours mod 2,
    (M == 0 -> Token = 'R'; Token = 'J'),
    writeln(Token),
    write('Tours '),
    writeln(Tours+1),
    write('Joueur '),
    writeln(Token),
    writeln('Entrez un numéro de colonne (or Q to exit):'),
    read(Colonne), % Entrée utilisateur
    ( Colonne = 'Q' -> 
        writeln('Fin du puissance 4!')
    ;
        (Colonne < 1 -> 
        boucle(P, Tours)
        ;
        ajout_jeton(P,Token,Colonne,NP),
        afficher_etat(NP),
        ToursSuivant is Tours + 1,
        boucle(NP, ToursSuivant)   
        )
    ).


%%% Initialisation du plateau de jeu %%%
% Creation d'un plateau de 6 lignes, 7 colonnes soit 42 cases
plateau(P) :- plateau(P,42).
% cas de base, quand il n'y a plus de case à ajouter
plateau([], 0) :- !.
% Ajout un 0 dans une liste N fois  
plateau(['.'|Q], N) :- 
    N1 is N-1,
    plateau(Q, N1).

%%% Etat du jeu
% Afficher etat du jeu
afficher_etat(P) :-
    writeln(''),
    afficher_plateau(P).

% Afficher le plateau
afficher_plateau([]).
afficher_plateau([T|Q]) :-
  write(T),
  taille_liste([T|Q], Taille),
  M is Taille mod 7,
  write('|'),
  ( M == 1 -> writeln(''); true),
  afficher_plateau(Q).

%%% Gestion des jetons %%%
% recreer un  nouveau plateau qui au bon index on ajoute  la valeur ?
% TODO : ajouter une fonction qui verif position entré et si en dehors pas aller dans ajout_jeton
% mais du coup on peut gerer cette verif au moment ou l'utilisateur ecrit (2,3)
% case 42 c'est la position 42, case 1 position 1, quand on cree le tableau la derniere case est crée

ajout_jeton([_|PQ],Jeton,1,[Jeton|PQ]).

ajout_jeton([PT|PQ],Jeton,Position,[PT|NouveauQ]) :-
    Position > 1,
    NouvellePosition is Position - 1, 
    ajout_jeton(PQ, Jeton, NouvellePosition, NouveauQ).

%verif
verifier_validite(Colonne, validite) :-
    % verif entre 1 et 7
    write('test')

numero_indice(Colonne) :-
    IndiceCase is 35 + Colonne.

% Transformer numéro de colonne en indice sur le plateau
case_disponible(IndiceCase, P) :-
    % si P[indiceColonne] est == '.' alors on retourne IndiceColonne
    NouveauIndiceCase is IndiceCase - 6,
    recuperer_indice(NouveauIndiceCase, P).*/

% on parcourt le plateau pour voir les cases disponibles
% on parcourt en incrémentant donc il faut aller une case de colonne en plus
% pour voir si elle est remplie et donner l'indice de la case precedente dans la colonne
% Ou alors voir comment parcourir à l'envers
% reverse(List, ReversedList), % Reverse the list
case_disponible(IndiceCase, [PT|PQ], N) :-
    (IndiceCase == N -> NouveauIndiceCase is IndiceCase - 6; true),
    N1 is N-1,
    case_disponible(NouveauIndiceCase, PQ, N1)

%%% Fonctions utiles
% Taille d'une liste
taille_liste([], 0).
taille_liste([_|Q],Size) :- taille_liste(Q,S), Size is S+1 .
% Empty list 
vider_liste(NewList) :- NewList = [].




 