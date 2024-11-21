%% Pour gagner il faut : 
% => avoir 4 jetons sur une meme ligne
% => avoir 4 jetons sur une meme diagonale
% => avoir 4 jetons sur une meme colonne
% 6 lignes, 7 colonnes

%%% Boucle du jeu
boucle :- 
    plateau(P),
    ajout_jeton(P,'R',3,NP),
    afficher_etat(NP),
    ajout_jeton(NP,'Y',20,P),
    afficher_etat(P).

%%% Initialisation du plateau de jeu %%%
% Creation d'un plateau de 6 lignes, 7 colonnes soit 42 cases
plateau(P) :- plateau(P,42), afficher_plateau(P).
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
% case 1 c'est la position 42, case 2 position 41

ajout_jeton([_|PQ],Jeton,1,[Jeton|PQ]).

ajout_jeton([PT|PQ],Jeton,Position,[PT|NouveauQ]) :-
    Position > 1,
    NouvellePosition is Position - 1, 
    ajout_jeton(PQ, Jeton, NouvellePosition, NouveauQ).


%%% Fonctions utiles
% Taille d'une liste
taille_liste([], 0).
taille_liste([_|Q],Size) :- taille_liste(Q,S), Size is S+1 .
% Empty list 
vider_liste(_, []).
% indice linéaire to coordonées 
% indice coordonée to linéaire



 