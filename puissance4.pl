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
    ( Reponse == 'n'-> 
        writeln('Le premier joueur joue les rouges (R) ! Le deuxième les jaunes (J) !'),
        JvJ = true
    ; Reponse == 'o'-> 
        writeln('Le premier joueur joue les rouges (R) ! IA les jaunes (J) !'),
        JvJ = false
    ;
        choix_joueurs(NJvJ),
        JvJ = NJvJ  
    ).
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Boucle du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%

boucle(P, Tours, JvJ) :- 
    writeln('**********************'),
    M is Tours mod 2,
    (M == 0 -> Jeton = 'R'; Jeton = 'J'),

    ActuelTour is Tours + 1,
    (ActuelTour = 43 -> writeln('Egalité !'); true),

    write('Tours '),
    writeln((ActuelTour)),

    ((JvJ = true; Jeton = 'R') -> 
        actions_joueur(Jeton, Colonne) 
    ;
        actions_IA(Jeton, Colonne)
    ),

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
                ajout_jeton(P,Jeton,Position,NP),
                afficher_etat(NP),
                verifier_victoire(RP, Jeton, Position, Victoire),
                (Victoire = true ->
                    nl,
                    write('Vous avez gagné joueur '),
                    writeln(Jeton),
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

actions_joueur(Jeton, Colonne) :-
    write('Joueur '),
    writeln(Jeton),
    writeln('Entrez un numéro de colonne (Q ou q pour quitter):'),
    read(Reponse),
    Colonne = Reponse.

actions_IA(Jeton, Colonne) :-
    write('IA '),
    writeln(Jeton),
    random_between(1,3, Pos1),
    position_a_coord(Pos1, Pos1Ligne, Pos1Colonne),
    jetons_alignes(P, Jeton, Pos1Ligne, Pos1Colonne, 42, 0, 0, 0, 0,NCptL_Pos1, NCptC_Pos1, NCptDDs_Pos1, NCptDMt_Pos1),
    random_between(5,7, Pos2),
    position_a_coord(Pos2, Pos2Ligne, Pos2Colonne),
    jetons_alignes(P, Jeton, Pos2Ligne, Pos2Colonne, 42, 0, 0, 0, 0,NCptL_Pos2, NCptC_Pos2, NCptDDs_Pos2, NCptDMt_Pos2),
    position_a_coord(4, Pos3Ligne, Pos3Colonne),
    jetons_alignes(P, Jeton, Pos3Ligne, Pos3Colonne, 42, 0, 0, 0, 0,NCptL_Pos3, NCptC_Pos3, NCptDDs_Pos3, NCptDMt_Pos3),
    
    member(3, [NCptL_Pos1, NCptC_Pos1, NCptDDs_Pos1, NCptDMt_Pos1,NCptL_Pos2, NCptC_Pos2, NCptDDs_Pos2, NCptDMt_Pos2, NCptC_Pos3, NCptDDs_Pos3, NCptDMt_Pos3]),

    Colonne is 
    % tester 3 positions differentes
    % utiliser jetons_alignes
    % prendre la meilleur des 3 positions




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

verifier_victoire(P, Jeton, Position, Victoire) :-
    position_a_coord(Position, PosLigne, PosColonne),
    writeln('here verif'),
    jetons_alignes(P, Jeton, PosLigne, PosColonne, 42, 0, 0, 0, 0,NCptL, NCptC, NCptDDs, NCptDMt),
    ( NCptL == 3; NCptC == 3; NCptDDs ==3; NCptDMt == 3 ->
        Victoire = true
    ;
        Victoire = false
    ).
    

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

jetons_alignes([PT|PQ],Jeton, PosLigne, PosColonne, N, CptL, CptC, CptDDs, CptDMt,NCptL, NCptC, NCptDDs, NCptDMt) :-
    % Passer N en coordonées 2D
    position_a_coord(N, Ligne, Colonne),
    % Verifier si CoordN correspond à ligne, colonne, diagonales..
    jeton_dans_ligne(PosLigne, Ligne, DansLigne),
    jeton_dans_colonne(PosColonne, Colonne, DansColonne),
    jeton_dans_diagDs(PosLigne, PosColonne, Ligne, Colonne,DansDiagDs),
    jeton_dans_diagMt(PosLigne, PosColonne, Ligne, Colonne, DansDiagMt),
    
    % Si la case est dans la même ligne que le jeton joué
    (DansLigne == true ->
        ( PT == Jeton ->
            TmpCptL is CptL + 1 
        ;
            TmpCptL is 0
        )
    ; 
        TmpCptL is CptL
    ),
    
     % Si la case est dans la même colonne que le jeton joué
    (DansColonne == true ->
        ( PT == Jeton ->
            TmpCptC is CptC + 1 
        ;
            TmpCptC is 0
        )
    ; 
        TmpCptC is CptC
    ),

    % Si la case est dans la même diag descendante que le jeton joué
    (DansDiagDs == true ->
        ( PT == Jeton ->
            TmpCptDDs is CptDDs + 1 
        ;
            TmpCptDDs is 0
        )
    ; 
        TmpCptDDs is CptDDs
    ),

    
    % Si la case est dans la même diag montante que le jeton joué
    (DansDiagMt == true ->
        ( PT == Jeton ->
            TmpCptDMt is CptDMt + 1 
        ;
            TmpCptDMt is 0
        )
    ; 
        TmpCptDMt is CptDMt
    ),

    % Check if any counter has reached 3
    ( N > 1, TmpCptL < 3, TmpCptC < 3, TmpCptDDs < 3, TmpCptDMt < 3 ->
        N1 is N - 1,
        jetons_alignes(PQ, Jeton, PosLigne, PosColonne, N1, TmpCptL, TmpCptC, TmpCptDDs, TmpCptDMt, NCptL, NCptC, NCptDDs, NCptDMt)
    ;
        write('end'), nl,
        % Debugging
        write('Counters: '), write([TmpCptL, TmpCptC, TmpCptDDs, TmpCptDMt]), nl,

        NCptL = TmpCptL, NCptC = TmpCptC, NCptDDs = TmpCptDDs, NCptDMt = TmpCptDMt
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





 