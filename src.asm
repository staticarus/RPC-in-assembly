
; VERSION UN SEUL JOUEUR CONTRE ORDINATEUR
; (J1) = L'ordinateur tandis que (J2) = L'utilisateur du programme
%include "io.inc"


;=========================[Données et variables]=========================
section .data
   welcome db "======[ Pierre-Feuille-Ciseaux ! ]======", 0xa
   rules1 db "# Cette version se joue avec des valeurs numeriques :",0xa
   rules2 db "# Pierre = 1, Feuille = 2, Ciseaux = 3",0xa
   ordi db "# Vous etes le Joueur2 et affrontez l'ordinateur.", 10,0
   msgJ2 db "Joueur2 c'est a vous ! Entrez votre choix de valeur",10,0  
   TitleBar db 'Pierre Feuille Ciseaux',0 
                            ;db = define byte = taille allouée
                            ;0xa = retour à la ligne
                            ;10 = saut de ligne
                            ;0 = fin du message
   ChoixJ1: dd 0            ;Déclare la variable ChoixJ1 de valeur 0 (c'est l'Ordinateur)
   ChoixJ2: dd 0            ;Déclare la variable ChoixJ2 de valeur 0 (c'est l'utilisateur)
   

;=========================[Programme principal]=========================
section .text
    global CMAIN            ;Début du programme    
CMAIN:
    mov ebp, esp            ;Utilisé pour le debug
extern  _SetConsoleTitleA@4 ;(1/3)Permet de changer la barre de titre de la console
    push TitleBar           ;(2/3)  "
    call _SetConsoleTitleA@4;(3/3)  "   
    xor eax, eax            ;Nettoie la valeur contenue
    PRINT_STRING welcome    ;Affiche la chaîne de messages de bienvenue (grâce à l'argument 0ax)
    CALL TourJ2             ;Appelle la sous-routine du Joueur2
Nouvelle_partie2:           ;Recommence une partie à cet endroit quand on vient d'en faire une
    CALL Ordinateur         ;Appelle la sous-routine de l'ordinateur
    CALL Comparaison        ;Appelle la sous-routine Comparaison des choix
    NEWLINE
    PRINT_STRING "Rejouer = 1, 2 ou 3   |   Quitter = autre valeur"
    NEWLINE
    NEWLINE
    NEWLINE
    xor eax, eax            ;Clear eax car il est utilisé ci-dessous
    GET_DEC 1,al            ;L'input du Joueur2 est enregistré dans le registre de 8bits al
    cmp al,1                ;Si c'est 1 ou 2 ou 3 on jump vers une sous-routine dédiée
    je Nouvelle_partie1     ; "
    cmp al,2                ; "
    je Nouvelle_partie1     ; "
    cmp al,3                ; "
    je Nouvelle_partie1     ; "
    ret                     ; Fin du programme si J2 a choisi autre chose que 1,2,3    
Nouvelle_partie1:
    mov [ChoixJ2], al       ;La valeur est directement considérée comme un choix, pour fluidifier les replay
    jmp Nouvelle_partie2    ;On recommence en reprenant à la génération d'une valeur pour l'Ordi (J1).
    
    
;=========================[Sous-routines pour les calculs]=========================

TourJ2:                     ;Tour du Joueur 2
    NEWLINE                 ;
    PRINT_STRING msgJ2      ;On lui indique qu'il doit entrer une valeur
    NEWLINE                 ;
    GET_DEC 1,[ChoixJ2]     ;Sa valeur est stockée dans la variable [ChoixJ2]. 1 = byte
    ret
Ordinateur:                 ;Tour de l'Ordinateur : on va générer une valeur de 1 à 3
    xor eax, eax            ;Clear du registre car il va stocker ce qui suit
    rdtsc                   ;Read Time Stamp Counter. Nb de cycles d'horloge du CPU : c'est notre RNG
    xor edx, edx            ;Clear du registre car il va stocker le reste de la division qui suit
    mov ecx, 3              ;C'est le registre qui sera diviseur ; on va diviser par 3
    div ecx                 ;Division du nb_cycles_cpu par 3, le résultat va dans eax, le reste dans edx
    mov eax, edx            ;La valeur du reste de la division est stockée dans eax, elle varie de 0 à 2
    add eax, 1              ;On y ajoute 1, afin de générer une tranche de [1 à 3] pour pierre-feuille-ciseaux
    mov [ChoixJ1], eax      ;On stocke cette valeur dans [ChoixJ1] -> C'est le "choix" de l'ordinateur !
    ret
Comparaison:                ;Comparaison des choix des deux joueurs afin de déterminer le vainqueur
    xor eax, eax            ;On efface le contenu du registre (qui contient ah et al)
    mov ah,[ChoixJ1]        ;(1/2) On déplace les valeurs des joueurs dans des registres
    mov al,[ChoixJ2]        ;(2/2) de 8bits afin de pouvoir les comparer entre elles
    cmp ah, al              ;Comparaison des valeurs
    je Draw                 ;Si elles sont égales, on exécute la sous-routine draw
    cmp ah,1                ;On vérifie que la valeur du J1 soit ou non égale à 1
    je Cas_particulier_J1   ;Si le choix du J1=1 on entre dans cette sous-routine
    cmp al,1                ;On vérifie que la valeur du J2 soit ou non égale à 1
    je Cas_particulier_J2   ;Si le choix du J2=1 on entre dans cette sous-routine   
    cmp ah,2                ;On vérifie que la valeur du J1 soit ou non égale à 2
    je J2_win               ;(1/4) Après avoir éliminé les égalités et les 1 plus haut, il ne reste
                            ;(2/4) plus que 2 ou 3 comme valeurs possibles. 
                            ;(3/4) Si J1 vaut 2, il perd car J2 vaut 3.
    jg J1_win               ;(4/4) Si J1 vaut 3, il gagne car J2 vaut 2.
    ret
    
    
;=========================[Sous-routines pour les résultats]=========================

Draw:                       ;En cas d'égalité, affiche les messages suivants.
    PRINT_STRING "# Ordinateur : ("
    PRINT_DEC 1,[ChoixJ1]
    PRINT_STRING "). Joueur2 : ("
    PRINT_DEC 1,[ChoixJ2] 
    PRINT_STRING ")  ==> Egalite ! Les deux joueurs ont choisi la meme valeur."
    NEWLINE
    ret
Cas_particulier_J1:         ;Détermine le vainqueur dans le cas où l'Ordinateur a choisi "1" (= Pierre)
    cmp al,2                ;Si la valeur du choix de J2 est...
    je J2_win               ;...égale à 2, alors il gagne car la Feuille (2) bat la Pierre (1)
    jg J1_win               ;...plus grande que 2, alors il perd car la Pierre (1) bat les Ciseaux (3)
    ret
Cas_particulier_J2:         ;Détermine le vainqueur dans le cas où le J2 a choisi "1" (= Pierre)
    cmp ah,2                ;Si la valeur du choix de l'Ordi est...
    je J1_win               ;...égale à 2, alors il gagne car la Feuille (2) bat la Pierre (1)
    jg J2_win               ;...plus grande que 2, alors il perd car la Pierre (1) bat les Ciseaux (3)
    ret
J1_win:                     ;En cas de victoire de l'Ordinateur, affiche les messages suivants.
    PRINT_STRING "# Ordinateur : ("
    PRINT_DEC 1,[ChoixJ1]
    PRINT_STRING "). Joueur : ("
    PRINT_DEC 1,[ChoixJ2]  
    PRINT_STRING ")  ==> L'ordinateur remporte la partie !"
    NEWLINE
    ret
J2_win:                     ;En cas de victoire du Joueur2, affiche les messages suivants.
    PRINT_STRING "# Ordinateur : ("
    PRINT_DEC 1,[ChoixJ1]
    PRINT_STRING "). Joueur : ("
    PRINT_DEC 1,[ChoixJ2] 
    PRINT_STRING ")  ==> Vous remportez la partie ! :D"
    NEWLINE
    ret
    
    
    
    
    
    
    
    
    
    