%% Pour gagner il faut : 
% => avoir 4 jetons sur une meme ligne
% => avoir 4 jetons sur une meme diagonale
% => avoir 4 jetons sur une meme colonne
% 6 lignes, 7 colonnes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gestion du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Token(rouge).
Token(jaune).

debut() :-
    plateau(P),
    afficher_etat(P),
    choix_joueurs(),
    boucle(P, 0),
    writeln('Fin du puissance 4!').

choix_joueurs() :-
    % choix J vs J
    % choix couleur si vs IA
    writeln('Le premier joueur joue les rouges (R) ! Le deuxième les jaunes (J) !').


%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Boucle du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

boucle(P, Tours) :- 
    writeln('**********************'),
    M is Tours mod 2,
    (M == 0 -> Token = 'R'; Token = 'J'),


    ActuelTour is Tours + 1,
    (ActuelTour = 43 -> writeln('Egalité !'); true),

    write('Tours '),
    writeln((ActuelTour)),
    write('Joueur '),
    writeln(Token),
    writeln('Entrez un numéro de colonne (Q ou q pour quitter):'),
    read(Colonne),
    verifier_validite(Colonne, Validite),
    ( Validite == true -> 
        ( Colonne = 'Q' ; Colonne = 'q' -> 
            true
        ;
            reverse(P, RP), % renverser le plateau
            case_disponible(Colonne, RP, 42, Position),
            (Position = false ->
                writeln('Erreur !'),
                boucle(P, Tours)
            ;
                ajout_jeton(P,Token,Position,NP),
                afficher_etat(NP),
                verifier_victoire(P, Token, Position, Victoire),
                writeln(Victoire),
                ToursSuivant is Tours + 1,
                boucle(NP, ToursSuivant)    
            )
        )
    ;
        writeln('Erreur !'),
        boucle(P, Tours)
    ).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Initialisation du plateau de jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Creation d'un plateau de 6 lignes, 7 colonnes soit 42 cases
plateau(P) :- plateau(P,42).
% cas de base, quand il n'y a plus de case à ajouter
plateau([], 0) :- !.
% Ajout un . dans une liste N fois  
plateau(['.'|Q], N) :- 
    N1 is N-1,
    plateau(Q, N1).


%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Etat du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%

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

verifier_victoire([PT,PQ], Token, Position, Victoire) :-
    Victoire = false.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gestion des jetons %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% case 42 c'est la position 42, case 1 position 1, quand on cree le tableau la derniere case est crée

ajout_jeton([_|PQ],Jeton,1,[Jeton|PQ]).

ajout_jeton([PT|PQ],Jeton,Position,[PT|NouveauQ]) :-
    Position > 1,
    NouvellePosition is Position - 1, 
    ajout_jeton(PQ, Jeton, NouvellePosition, NouveauQ).

case_disponible(_, _, 0, Position) :-
    Position = false.

case_disponible(Colonne, [PT|PQ], N, Position) :-
    TmpColonne is N mod 7, % obtenir la colonne associé à N
    ( ( TmpColonne = Colonne; (Colonne = 7, TmpColonne = 0) )  ->
        ( PT = '.' ->
            Position = N
        ;
            N1 is N-1,
            case_disponible(Colonne, PQ, N1, Position)
        )
    ;
        N1 is N-1,
        case_disponible(Colonne, PQ, N1, Position)
    ).
    % verif si TmpColonne = Colonne
    % Si TmpColonne = Colonne 
        % => verif si  PQ is empty
        % Si empty 
            % => casedispo = N
        % Si non empty
            %N1 is N-1
            % => case_dispo(Colonne, PQ, N1)
    % Si tmpColonne != Colonne
        % N1 us N-1
        % => case_dispo(Colonne, PQ, N1)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Fonctions utiles %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Taille d'une liste
taille_liste([], 0).
taille_liste([_|Q],Size) :- taille_liste(Q,S), Size is S+1 .

% Verifier la validité de l'entrée du joueur
verifier_validite(Colonne, Validite) :-
    ( est_nombre(Colonne) ->
        Validite = true
    ; est_quitter(Colonne) ->
        Validite = true
    ; 
        Validite = false
    ).
% Verifier si c'est un numéro
est_nombre(Colonne) :-
    number(Colonne),       
    Colonne >= 1,          
    Colonne =< 7.          

% Vérifier si l'entrée est un Q
est_quitter(Colonne) :-
    Colonne = 'Q';
    Colonne = 'q'.      





 