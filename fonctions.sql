create or replace FUNCTION CALCULERQTETOTALE 
(
  P_PRODNUM IN PRODUIT.PRODNUM%TYPE 
) RETURN NUMBER AS 
  ------
  --fonction
  --Entrée : le numéro d'un produit
  --Sortie : la somme des quantités du produit donné dont commandes sont en attente
  ------
  V_RES NUMBER;
  ------
  --Cursor
  --Chercher les commandes en attente concernant le produit demandé qui n'a pas encore été factorisé dans des commandes globales
  --Obtenir les numéros des commandes et les quantités du produit concernant chaque commande
  ------
  CURSOR COMMANDERESTANTES IS
    SELECT CO.COMNUM, CO.QTECOM
    FROM CONCERNER CO
    WHERE CO.PRODNUM = P_PRODNUM
    AND CO.COMNUM NOT IN (SELECT A.COMNUM
                          FROM ASSOCIER A
                          WHERE A.PRODNUM = CO.PRODNUM);
BEGIN
  V_RES := 0;
  --S'il existe des commandes en attente concernant ce produit
  --Il faut parcourir les commandes et calculer la somme des quantité du produit des commandes en attente
    FOR COMMANDE IN COMMANDERESTANTES LOOP
        V_RES := V_RES + COMMANDE.QTECOM;
    END LOOP;
  RETURN V_RES;
END CALCULERQTETOTALE;

-----------------------

create or replace FUNCTION VERIFIER_CMD_ALERTE 
(
   P_PRODNUM IN PRODUIT.PRODNUM%TYPE  
) RETURN BOOLEAN AS

  ------
  --fonction
  --Entrée : le numéro d'un produit
  --Sortie : s'il existe des commandes qui concerne le produit donnée et ce produit n'a pas encore été factorié et est en alerte
  ------
  V_RES BOOLEAN;
  ------
  --Cursor
  --Chercher les commandes en attente concernant le produit demandé qui n'a pas encore été factorisé dans des commandes globales
  --Obtenir les numéros des commandes
  --Obtenir dans chaque commande trouvée, l'écart de la quantité stokée et la quantité alerte concernant le produit demandé
  ------
  CURSOR COMMANDERESTANTES IS
    SELECT C.COMNUM, S.QTESTOCK-S.QTEALERTE AS ALERTE
      FROM COMMANDE C, STOCKER S,CONCERNER CC
      WHERE C.MAGNUM = S.MAGNUM
      AND C.COMNUM = CC.COMNUM
      AND S.PRODNUM = CC.PRODNUM
      AND CC.PRODNUM = P_PRODNUM
      AND C.COMNUM NOT IN (SELECT A.COMNUM
                                FROM ASSOCIER A
                                WHERE A.PRODNUM = CC.PRODNUM);
BEGIN
  V_RES := FALSE ;
  --S'il existe des commandes en attente concernant ce produit
  --Parcourir les commandes
  FOR COMMANDE IN COMMANDERESTANTES LOOP
  --Si la quantité stockée est inférieur ou égale à la quantité alerte, ce produit de cette commande est en alerte
    IF COMMANDE.ALERTE <= 0 THEN
    --retourner vrai
      V_RES := TRUE;
    END IF;
  END LOOP;
  RETURN V_RES;
END VERIFIER_CMD_ALERTE;

----------------

create or replace FUNCTION VERIFIER_COMGLOB_LIVRE 
(
  P_comglobnum IN commandeglobale.comglobnum%type 
) RETURN BOOLEAN AS
  ------
  --fonction
  --Entrée : le numéro d'une commande globale
  --Sortie : si tous les produits dans cette commandeglobale ont été livrés
  ------
  v_res boolean;
  ------
  --Cursor
  --Chercher les produits d'une commande globalen'ont pas été livrés ou ont été livrés insuffisamment
  ------
  cursor produits is 
    select cg.prodnum
    from concernerglob cg
    where cg.comglobnum = P_comglobnum
    and cg.prodnum not in (
        select l.prodnum
        from bonlivraison b, livrer l
        where b.bonlivnum = l.bonlivnum
        and b.comglobnum = cg.comglobnum
        and l.qteliv <> l.qterefus);
  v_prodnum produits%rowtype;
      
BEGIN
  v_res := false;
  open produits;
  fetch produits into v_prodnum;
  --Vérifier s'il y a des résultats
  --S'il n'y a pas de résultats, retourner vrai 
  if produits%notfound then
    v_res := true;
  end if;
  close produits;
  RETURN v_res;
END VERIFIER_COMGLOB_LIVRE;

----------------

create or replace FUNCTION VERIFIER_COMMANDEGLOBALE 
(
  P_FOURNUM IN FOURNISSEUR.FOURNUM%TYPE
) RETURN NUMBER AS
  ------
  --fonction
  --Entrée : le numéro d'un fournisseur
  --Sortie : le numéro d'une commande globale de ce fournisseur s'il existe, cette commande globale est en 'en cours de constitution'
  ------
  V_RES NUMBER;
  ------
  --Cursor
  --Chercher une commande globale qui est en cours de constitution de ce fournisseur
  ------
  CURSOR CG IS
    SELECT C.COMGLOBNUM
    FROM COMMANDEGLOBALE C
    WHERE C.FOURNUM = P_FOURNUM
    AND C.COMGLOBETAT = 'en cours de constitution';
  V_LIGNECG CG%ROWTYPE;
  
BEGIN
  V_RES := NULL;
  OPEN CG;
  FETCH CG INTO V_LIGNECG;
  --Vérifier s'il y a des résultats
  --S'il existe une commande globale, retourner son numéro
  IF CG%FOUND THEN
    V_RES := V_LIGNECG.COMGLOBNUM;
  END IF;
  CLOSE CG;
  RETURN V_RES;
END VERIFIER_COMMANDEGLOBALE;

----------------

create or replace FUNCTION VERIFIER_LIGNECOMMANDEGLOBALE 
(
  P_PRODNUM IN PRODUIT.PRODNUM%TYPE
) RETURN COMMANDEGLOBALE.COMGLOBNUM%TYPE AS 
  ------
  --Fonction
  --Entrée : le numéro d'un produit
  --Sortie : le numéro d'une commande globale concernant ce produit s'il existe
  --cette commande globale est 'en cours de constitution' 
  ------
  V_RES COMMANDEGLOBALE.COMGLOBNUM%TYPE;
  ------
  --Cursor
  --Chercher une commande globale qui est en cours de constitution et qui contient ce produit
  ------
  CURSOR CG IS
    SELECT CG.COMGLOBNUM
    FROM COMMANDEGLOBALE C, CONCERNERGLOB CG
    WHERE CG.PRODNUM = P_PRODNUM
    AND C.COMGLOBNUM = CG.COMGLOBNUM
    AND C.COMGLOBETAT = 'en cours de constitution';
  V_LIGNECG CG%ROWTYPE;
    
BEGIN
  V_RES := null;
  OPEN CG;
  FETCH CG INTO V_LIGNECG;
  --Vérifier s'il y a des résultats
  --S'il a une commande globale, retourner son numéro
  IF CG%FOUND THEN
    V_RES := V_LIGNECG.COMGLOBNUM;
  END IF;
  CLOSE CG;
  RETURN V_RES;
END VERIFIER_LIGNECOMMANDEGLOBALE;

-------------