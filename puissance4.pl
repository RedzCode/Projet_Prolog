%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Gestion du jeu %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

debut() :-
    plateau(P),
    afficher(P),
    choix_joueurs(JvJ),
    boucle(P, 0, JvJ),
    writeln('Fin du puissance 4!').

% Choisir si on veut faire un joueur vs joueur OU un joueur vs IA
choix_joueurs(JvJ) :-
    writeln('Jouez contre une "IA" ? Entrez o (oui) ou n (non):'),
    read(Reponse),
    ( Reponse == 'n'-> 
        nl,
        writeln('Le premier joueur joue les rouges (R) ! Le deuxième les jaunes (J) !'), nl,
        JvJ = true
    ; Reponse == 'o'-> 
        nl,
        writeln('Le premier joueur joue les rouges (R) ! IA les jaunes (J) !'), nl,
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
        actions_IA(Jeton, Colonne, P)
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
                afficher(NP),
                verifier_victoire(RP, Jeton, Position, Victoire),
                (Victoire = true ->
                    nl,
                    write('Vous avez gagne joueur '),
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
    writeln('Entrez un numero de colonne (Q ou q pour quitter):'),
    read(Reponse),
    Colonne = Reponse.

actions_IA(Jeton, Colonne, P) :-
    write('IA '),
    writeln(Jeton),

    % 16% de chance de faire un mouvement au hasard
    random_between(1,6,RD),
    (RD = 1 -> 
        random_between(1,7,Choix), Colonne is Choix
    ;
        column_with_most_alignment(Jeton, P,MaxAlignment, MostAlignedColumn),
        column_with_most_alignment('R', P,MaxAlignmentR, MostAlignedColumnR),

        (MaxAlignment = 3 ->
            Colonne is MostAlignedColumn
        ;
        MaxAlignmentR = 3 ->
            Colonne is MostAlignedColumnR
        ; 
            (MaxAlignment = 0 -> random_between(1,7,Choix), Colonne is Choix ; Colonne is MostAlignedColumn)
        )
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

% Afficher le jeu
afficher(P) :-
    nl,
    writeln(' 1 2 3 4 5 6 7'),
    afficher_plateau(P),
    nl.

afficher_plateau([]).
afficher_plateau([T|Q]) :-
  taille_liste([T|Q], Taille),
  M is Taille mod 7,
  ( M == 0 -> write('|'); true),
  write(T),
  write('|'),
  ( M == 1 -> writeln(''); true),
  afficher_plateau(Q).

verifier_victoire(P, Jeton, Position, Victoire) :-
    position_a_coord(Position, PosLigne, PosColonne),
    jetons_alignes(P, Jeton,Position, PosLigne, PosColonne, 42, 0, 0, 0, 0,NCptL, NCptC, NCptDDs, NCptDMt),
    ( NCptL == 4; NCptC == 4; NCptDDs == 4; NCptDMt == 4 ->
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

jetons_alignes([PT|PQ],Jeton, Position, PosLigne, PosColonne, N, CptL, CptC, CptDDs, CptDMt,NCptL, NCptC, NCptDDs, NCptDMt) :-
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
             % Si c'est la case où on veut mettre le jeton
           (Position == N -> TmpCptL is CptL + 1 ; TmpCptL is 0)
        )
    ; 
        TmpCptL is CptL
    ),
    
     % Si la case est dans la même colonne que le jeton joué
    (DansColonne == true ->
        ( PT == Jeton ->
            TmpCptC is CptC + 1 
        ;
            % Si c'est la case où on veut mettre le jeton
           (Position == N -> TmpCptC is CptC + 1 ; TmpCptC is 0)
           
        )
    ; 
        TmpCptC is CptC
    ),

    % Si la case est dans la même diag descendante que le jeton joué
    (DansDiagDs == true ->
        ( PT == Jeton ->
            TmpCptDDs is CptDDs + 1 
        ;
            % Si c'est la case où on veut mettre le jeton
           (Position == N -> TmpCptDDs is CptDDs + 1 ; TmpCptDDs is 0)
        )
    ; 
        TmpCptDDs is CptDDs
    ),

    
    % Si la case est dans la même diag montante que le jeton joué
    (DansDiagMt == true ->
        ( PT == Jeton ->
            TmpCptDMt is CptDMt + 1 
        ;
            % Si c'est la case où on veut mettre le jeton
           (Position == N -> TmpCptDMt is CptDMt + 1 ; TmpCptDMt is 0)
        )
    ; 
        TmpCptDMt is CptDMt
    ),

    % Si un des compteurs a atteint 4
    ( N > 1, TmpCptL < 4, TmpCptC < 4, TmpCptDDs < 4, TmpCptDMt < 4 ->
        N1 is N - 1,
        jetons_alignes(PQ, Jeton, Position, PosLigne, PosColonne, N1, TmpCptL, TmpCptC, TmpCptDDs, TmpCptDMt, NCptL, NCptC, NCptDDs, NCptDMt)
    ;
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




% Helper predicate to filter out unavailable columns
exclude_unavailable_columns([], _, [], _).
exclude_unavailable_columns([AlignmentCount-Column|Rest], Grid, Filtered, Jeton) :-
    case_disponible(Column, Grid, 42, Position),
    ( Position \= false -> % Check if column is available
        Filtered = [AlignmentCount-Column|RestFiltered] % Keep it
    ;   Filtered = RestFiltered % Skip it
    ),
    exclude_unavailable_columns(Rest, Grid, RestFiltered, Jeton).

% Find the column with the most aligned tokens of Jeton
column_with_most_alignment(Jeton, Grid,MaxAlignment, MostAlignedColumn) :-
    numlist(1, 7, Columns), % Generate a list of column indices
    findall(AlignmentCount-ColumnNumber,
        (member(ColumnNumber, Columns),
         extract_column(ColumnNumber, Grid, Column),
         count_consecutive(Column, Jeton, 0, AlignmentCount)),
        AlignmentCounts),

    reverse(Grid, RP), % renverser le plateau
    exclude_unavailable_columns(AlignmentCounts, RP, AvailableAlignmentCounts, Jeton),
    max_member(MaxAlignment-MostAlignedColumn, AvailableAlignmentCounts). % Find the max alignment


% helper predicate that tracks consecutive tokens
% count_consecutive(List, Token, Count) will count the consecutive occurrences of Token in List
count_consecutive([], _, Count, Count).  % Base case: no more elements, return count 0

count_consecutive([Token|Tail], Token, CurrentCount, Count) :-
    NCurrentCount is CurrentCount + 1, 
    count_consecutive(Tail, Token, NCurrentCount, Count).
    

count_consecutive(['.'|Tail], Token, CurrentCount, Count) :-
    NCurrentCount is CurrentCount,
    count_consecutive(Tail, Token, NCurrentCount, Count).


count_consecutive([Other|_], Token, CurrentCount, Count) :-
    Other \= '.',  % Ignore '.' characters
    Other \= Token,  % Stop counting if a different token is encountered
    NCurrentCount is CurrentCount,
    count_consecutive([], Token,NCurrentCount, Count).  % Continue to next element

extract_column(ColumnNumber, Grid, Column) :-
    RowWidth = 7,
    findall(Element,
        (between(0, 5, RowIndex),  % Rows are indexed 0 to 5
         Index is RowIndex * RowWidth + ColumnNumber - 1,
         nth0(Index, Grid, Element)),
        Column).
 