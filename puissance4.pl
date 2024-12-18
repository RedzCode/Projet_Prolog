%% Pour gagner il faut : 
% => avoir 4 jetons sur une meme ligne
% => avoir 4 jetons sur une meme diagonale
% => avoir 4 jetons sur une meme colonne
% 6 lignes, 7 colonnes

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gestion du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debut() :-
    plateau(P),
    afficher_etat(P),
    choix_joueurs(JvJ),
    boucle(P, 0, JvJ),
    writeln('Fin du puissance 4!').

choix_joueurs(JvJ) :-
    % choix J vs J
    % choix couleur si vs IA
    writeln('Jouez contre une "IA" ? Entrez o (oui) ou n (non):'),
    read(Reponse),
    ( Reponse = 'n'-> 
        writeln('Le premier joueur joue les rouges (R) ! Le deuxième les jaunes (J) !'),
        JvJ = true
    ;
        writeln('Le premier joueur joue les rouges (R) ! IA les jaunes (J) !'),
        JvJ = false
    ).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Boucle du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

boucle(P, Tours, JvJ) :- 
    writeln('**********************'),
    M is Tours mod 2,
    (M == 0 -> Token = 'R'; Token = 'J'),


    ActuelTour is Tours + 1,
    (ActuelTour = 43 -> writeln('Egalité !'); true),

    write('Tours '),
    writeln((ActuelTour)),

    (JvJ = true ; Token = 'R' -> 
        actions_joueur(P, Tours, Token, JvJ)
    ;
        actions_IA(P, Tours, Token, JvJ)
    ).

actions_joueur(P,Tours,Token, JvJ) :-
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
                boucle(P, Tours,JvJ)
            ;
                ajout_jeton(P,Token,Position,NP),
                afficher_etat(NP),
                verifier_victoire(RP, Token, Position, Victoire),
                (Victoire = true ->
                    nl,
                    write('Vous avez gagné joueur '),
                    writeln(Token),
                    true
                ;
                    ToursSuivant is Tours + 1,
                    boucle(NP, ToursSuivant, JvJ) 
                )
   
            )
        )
    ;
        writeln('Erreur !'),
        boucle(P, Tours, JvJ)
    ).

actions_IA(P,Tours,Token,JvJ) :-
    write('IA '),
    writeln(Token),

    random_between(1,7, Colonne),

    verifier_validite(Colonne, Validite),
    ( Validite == true -> 
        reverse(P, RP), % renverser le plateau
        case_disponible(Colonne, RP, 42, Position),
        (Position = false ->
            writeln('Erreur !'),
            boucle(P, Tours, JvJ)
        ;
            ajout_jeton(P,Token,Position,NP),
            afficher_etat(NP),
            verifier_victoire(RP, Token, Position, Victoire),
            (Victoire = true ->
                nl,
                write('IA a gagné '),
                true
            ;
                ToursSuivant is Tours + 1,
                boucle(NP, ToursSuivant, JvJ) 
            )

        )
        
    ;
        boucle(P, Tours, JvJ)
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

verifier_victoire(P, Token, Position, Victoire) :-
    position_a_coord(Position, PosLigne, PosColonne),
    jetons_alignes(P, Token, PosLigne, PosColonne, 42, 0, 0, 0, 0, Victoire).
    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gestion des jetons %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
        % Si empty  CptL, CptC, CptDD, CptDM
            % => casedispo = N
        % Si non empty
            %N1 is N-1
            % => case_dispo(Colonne, PQ, N1)
    % Si tmpColonne != Colonne
        % N1 us N-1
        % => case_dispo(Colonne, PQ, N1)

jetons_alignes(_,_, _, _, -1, _, _, _, _, Victoire) :- 
    Victoire = true.

jetons_alignes(_,_, _, _, 0, _, _, _, _, Victoire) :- 
    Victoire = false.

jetons_alignes([PT|PQ],Token, PosLigne, PosColonne, N, CptL, CptC, CptDDs, CptDMt, Victoire) :-
    % Passer N en coordonées 2D
    position_a_coord(N, Ligne, Colonne),
    % Verifier si CoordN correspond à ligne, colonne, diagonales..
    jeton_dans_ligne(PosLigne, Ligne, DansLigne),
    jeton_dans_colonne(PosColonne, Colonne, DansColonne),
    jeton_dans_diagDs(PosLigne, PosColonne, Ligne, Colonne,DansDiagDs),
    jeton_dans_diagMt(PosLigne, PosColonne, Ligne, Colonne, DansDiagMt),
    
    % Si la case est dans la même ligne que le jeton joué
    (DansLigne == true ->
        ( PT == Token ->
            NCptL is CptL + 1 
        ;
            NCptL is 0
        )
    ; 
        NCptL is CptL
    ),
    
     % Si la case est dans la même colonne que le jeton joué
    (DansColonne == true ->
        ( PT == Token ->
            NCptC is CptC + 1 
        ;
            NCptC is 0
        )
    ; 
        NCptC is CptC
    ),

    % Si la case est dans la même diag descendante que le jeton joué
    (DansDiagDs == true ->
        ( PT == Token ->
            NCptDDs is CptDDs + 1 
        ;
            NCptDDs is 0
        )
    ; 
        NCptDDs is CptDDs
    ),

    
    % Si la case est dans la même diag montante que le jeton joué
    (DansDiagMt == true ->
        ( PT == Token ->
            NCptDMt is CptDMt + 1 
        ;
            NCptDMt is 0
        )
    ; 
        NCptDMt is CptDMt
    ),


    ( NCptL == 3; NCptC == 3; NCptDDs ==3; NCptDMt == 3 ->
        jetons_alignes(_,_, _, _, -1,NCptL, NCptC, NCptDDs, NCptDMt, Victoire)
    ;  
        N1 is N -1,
        jetons_alignes(PQ,Token, PosLigne, PosColonne, N1, NCptL, NCptC, NCptDDs, NCptDMt,Victoire)  
    ).


jeton_dans_ligne(PosLigne,Ligne, DansLigne) :-
    ( Ligne == PosLigne ->
        DansLigne = true
    ; 
        DansLigne = false
    ).

jeton_dans_colonne(PosColonne, Colonne, DansColonne) :-
    ( Colonne == PosColonne ->
        DansColonne = true
    ; 
        DansColonne = false
    ).

% jeton situé dans la même diagonale descendante
jeton_dans_diagDs(PosLigne, PosColonne, Ligne, Colonne, DansDiagDs) :-
    ( PosLigne - PosColonne =:= Ligne - Colonne ->
        DansDiagDs = true
    ; 
        DansDiagDs = false
    ).

jeton_dans_diagMt(PosLigne, PosColonne, Ligne, Colonne, DansDiagMt) :-
    ( PosLigne + PosColonne =:= Ligne + Colonne ->
        DansDiagMt = true
    ; 
        DansDiagMt = false
    ).



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

position_a_coord(Position, Ligne, Colonne) :-
    divmod(Position, 7, Quotient, Reste),
    (Reste = 0 -> Ligne is Quotient; Ligne is Quotient + 1),
    Mod is Position mod 7,
    ( Mod = 0  -> Colonne is 7; Colonne is Position mod 7).      





 