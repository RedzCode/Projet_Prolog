%Problème des 8 reines : placer 8 reines sur un échiquier sans qu'aucune ne mette une autre en échec.
%Il faut donc placer 8 reines sur des cases sans que celles-ci ne partagent de ligne de colonne ou de diagonales.

%echiquier (liste des numéros de lignes)
%L'indice de chaque terme correspond à son numéro de colonne, on respecte donc de base la règle des colonnes différentes.
%La valeur du terme correspond à son numéro de ligne 
echiquier([1,2,3,4,5,6,7,8]).

%Numéro des colonnes (indices de l'echiquier)
%indice(0,[X|_],X).
%indice(N,[_|Q],X):-
%    N>0,
%    N1 is N-1,
%    indice(N1,[_|Q],X).

%"Numéro" des diagonales 
%diagonales 1 :  \\\\\\\ de haut à droite (1) jusqu'à bas à gauche (15)
diagonale1([], []). 

diagonale1([T|Q],[Res|Rest]):-
    diagonale1(Q, Rest),
    length([T|Q],L),  
    Indice is L-1,  
    Res is T+Indice.
%Renvoi la liste des indices de diagonales 1 de chaque case

%diagonales 2 :  /////// de haut à gauche (-6) jusqu'à bas à droite (8)
diagonale2([], []). 

diagonale2([T|Q],[Res|Rest]):-
    diagonale2(Q, Rest),
    length([T|Q],L),  
    Indice is L-1,  
    Res is T-Indice.
%Renvoi la liste des indices de diagonales 2 de chaque case

%Vérification de la condition de la diagonale 1
verifier_diagonale1(Liste):-
    diagonale1(Liste, Diagonale),  
    is_set(Diagonale).

%Vérification de la condition de la diagonale 2
verifier_diagonale2(Liste):-
    diagonale2(Liste, Diagonale),  
    is_set(Diagonale).

%vérification de la condition horizontale : un is_set sur la liste suffira
echiquier_valide(Liste):-
    is_set(Liste), % inutile avec les améliorations
    verifier_diagonale1(Liste),
    verifier_diagonale2(Liste).

%Générer un échiquier validant lignes et colonnes


%Permuter les termes jusqu'a trouver la bonne combinaisons