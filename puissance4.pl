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
        writeln('Le premier joueur joue les rouges (R) ! Le deuxieme les jaunes (J) !'), nl,
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
    M is Tours mod 2, % alternance entre les deux joueurs
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

    % verifier si l'entrée est valide ou si le jeton sors des limites
    verifier_validite(Colonne, Validite),
    ( Validite == true -> 
        ( Colonne = 'Q' ; Colonne = 'q' -> % quitter le jeu
            true
        ;
            reverse(P, RP), % renverser le plateau
            case_disponible(Colonne, RP, 42, Position), % récupérer la case disponible sur la colonne
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

% Récupérer la réponse du joueur humain
actions_joueur(Jeton, Colonne) :-
    write('Joueur '),
    writeln(Jeton),
    writeln('Entrez un numero de colonne (Q ou q pour quitter):'),
    read(Reponse),
    Colonne = Reponse.

% Générer la réponse du joueur non humain
actions_IA(Jeton, Colonne, P) :-
    write('IA '),
    writeln(Jeton),

    % 16% de chance de faire un mouvement au hasard
    random_between(1,6,RD),
    (RD = 1 -> 
        random_between(1,7,Choix), Colonne is Choix
    ;
        colonne_max_alignes(Jeton, P,MaxAlignes, ColonneAlignes),
        colonne_max_alignes('R', P,MaxAlignesAdversaire, ColonneAlignesAdversaire),

        (MaxAlignes = 3 ->
            Colonne is ColonneAlignes
        ;
        MaxAlignesAdversaire = 3 ->
            Colonne is ColonneAlignesAdversaire
        ; 
            (MaxAlignes = 0 -> random_between(1,7,Choix), Colonne is Choix ; Colonne is ColonneAlignes)
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

% Afficher le plateau de jeu dans la console
afficher_plateau([]).
afficher_plateau([T|Q]) :-
  taille_liste([T|Q], Taille),
  M is Taille mod 7,
  ( M == 0 -> write('|'); true),
  write(T),
  write('|'),
  ( M == 1 -> writeln(''); true),
  afficher_plateau(Q).

% Verifier si un joueur a gagné
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

% Ajouter un jeton dans la liste 
ajout_jeton([_|PQ],Jeton,1,[Jeton|PQ]).
ajout_jeton([PT|PQ],Jeton,Position,[PT|NouveauQ]) :-
    Position > 1,
    NouvellePosition is Position - 1, 
    ajout_jeton(PQ, Jeton, NouvellePosition, NouveauQ).

% Vérifier si une case est disponible dans la colonne demandée, si c'est le cas retourne la position de la case
case_disponible(_, _, 0, Position) :-
    Position = false.
case_disponible(Colonne, [PT|PQ], N, Position) :-
    TmpColonne is N mod 7, % obtenir la colonne associé à la position N de la liste

    % Si la colonne de la case N est égal à la colonne demandé 
    % on vérifie si la valeur de la case est vide, 
    %sinon on avance dans la liste pour vérifier la prochaine case de la colonne
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

% Vérifier si des jetons sont alignés
% On compte le nombre de jetons alignés en ligne, colonne et diagonale selon la position du jeton joué
jetons_alignes([PT|PQ],Jeton, Position, PosLigne, PosColonne, N, CptL, CptC, CptDDs, CptDMt,NCptL, NCptC, NCptDDs, NCptDMt) :-
    % Passer N en coordonées 2D
    position_a_coord(N, Ligne, Colonne),
    % Verifier si les coordonnées N correspond à ligne, colonne, diagonales du jeton joué
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

    % Si un des compteurs a atteint 4 on arrête, sinon on continue
    ( N > 1, TmpCptL < 4, TmpCptC < 4, TmpCptDDs < 4, TmpCptDMt < 4 ->
        N1 is N - 1,
        jetons_alignes(PQ, Jeton, Position, PosLigne, PosColonne, N1, TmpCptL, TmpCptC, TmpCptDDs, TmpCptDMt, NCptL, NCptC, NCptDDs, NCptDMt)
    ;
        NCptL = TmpCptL, NCptC = TmpCptC, NCptDDs = TmpCptDDs, NCptDMt = TmpCptDMt
    ).


% Vérifier si un jeton est dans la même ligne qu'un autre
jeton_dans_ligne(PosLigne,Ligne, DansLigne) :-
    ( Ligne == PosLigne ->
        DansLigne = true
    ; 
        DansLigne = false
    ).
% Vérifier si un jeton est dans la même colonne qu'un autre
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
% jeton situé dans la même diagonale montante
jeton_dans_diagMt(PosLigne, PosColonne, Ligne, Colonne, DansDiagMt) :-
    ( PosLigne + PosColonne =:= Ligne + Colonne ->
        DansDiagMt = true
    ; 
        DansDiagMt = false
    ).

% Compter le nombre de jetons consécutifs dans une liste 
nombre_jetons_consecutifs([], _, Compteur, Compteur).  % On a fini de parcourir la liste
nombre_jetons_consecutifs([Jeton|Q], Jeton, CompteurActuel, Compteur) :- % Si le jeton correpond +1
    NCompteurActuel is CompteurActuel + 1, 
    nombre_jetons_consecutifs(Q, Jeton, NCompteurActuel, Compteur).
nombre_jetons_consecutifs(['.'|Q], Jeton, CompteurActuel, Compteur) :- % Si la case est vide, on fait rien
    NCompteurActuel is CompteurActuel,
    nombre_jetons_consecutifs(Q, Jeton, NCompteurActuel, Compteur).
nombre_jetons_consecutifs([Autre|_], Jeton, CompteurActuel, Compteur) :- % Si la case est à l'adversaire, on arrête de compter
    Autre \= '.',  
    Autre \= Jeton, 
    NCompteurActuel is CompteurActuel,
    nombre_jetons_consecutifs([], Jeton,NCompteurActuel, Compteur). 





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%% Fonctions utiles %%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Taille d'une liste
taille_liste([], 0).
taille_liste([_|Q],Taille) :- taille_liste(Q,T), Taille is T+1.

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

% Transformer la position d'une case dans la liste en des coordonnées 2D du plateau de jeu
position_a_coord(Position, Ligne, Colonne) :-
    divmod(Position, 7, Quotient, Reste),
    (Reste = 0 -> Ligne is Quotient; Ligne is Quotient + 1),
    Mod is Position mod 7,
    ( Mod = 0  -> Colonne is 7; Colonne is Position mod 7).     

% Extraire les colonnes de la liste de jeu
extraire_colonne(NumeroColonne, P, Colonne) :-
    findall(Element,
        (between(0, 5, IndiceLigne),  % il y a 6 lignes
         Indice is IndiceLigne * 7 + NumeroColonne - 1,
         nth0(Indice, P, Element)),
        Colonne). 

% Compter le nombre d'alignement de jetons de chaque colonne
colonne_max_alignes(Jeton, P,MaxAlignment, MostAlignedColumn) :-
    numlist(1, 7, NumColonnes),
    findall(NombreAlignes-NumeroColonne,
        (member(NumeroColonne, NumColonnes),
         extraire_colonne(NumeroColonne, P, Colonne),
         nombre_jetons_consecutifs(Colonne, Jeton, 0, NombreAlignes)),
        AlignesCompteurs),

    reverse(P, RP), % renverser le plateau
    exclure_non_disponibles(AlignesCompteurs, RP, ColonnesDisponibles, Jeton),
    max_member(MaxAlignment-MostAlignedColumn, ColonnesDisponibles). % trouver la colonne avec le plus d'alignement de jetons


% Exclure les colonnes où il n'y a plus de cases disponibles
exclure_non_disponibles([], _, [], _).
exclure_non_disponibles([NombreAlignes-Colonne|Reste], P, Filtres, Jeton) :-
    case_disponible(Colonne, P, 42, Position),
    ( Position \= false ->
        % Case disponible, on garde la colonne
        Filtres = [NombreAlignes-Colonne|ResteFiltres] 
    ;   % Case non disponible on enlève la colonne
        Filtres = ResteFiltres 
    ),
    exclure_non_disponibles(Reste, P, ResteFiltres, Jeton).