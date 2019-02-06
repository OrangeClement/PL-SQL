create or replace TRIGGER INSERT_BONLIVRAISON 
BEFORE INSERT ON BONLIVRAISON 
REFERENCING NEW AS N 
FOR EACH ROW 
DECLARE
  V_CGETAT COMMANDEGLOBALE.COMGLOBETAT%TYPE;
BEGIN
  :n.bonlivnum := seq_bonlivnum.nextval;
  
  ------
  --sql
  --Chercher l'état de la commande globale concernant le bon livraison donné
  ------
  select comglobetat into V_CGETAT
  from commandeglobale
  where comglobnum = :n.comglobnum;
  
  --Si l'état de la commande globale est 'en cours de constitution' ou  est 'terminé', ne pas créer un bon livraison
  if V_CGETAT = 'en cours de constitution' then
    raise_application_error(-20106,'Cette commande globale n''est pas encore prête !!!');
  elsif V_CGETAT = 'terminé' then 
    raise_application_error(-20106,'Cette commande globale a déjà terminée!!!');
  end if;
END;

-----------------

create or replace TRIGGER INSERT_CHARGEMENT 
BEFORE INSERT ON CHARGEMENT 
REFERENCING NEW AS N 
FOR EACH ROW 
BEGIN
  :n.charnum  := seq_charnum.nextval;
  :n.chardate := sysdate +1;
  :n.charetat := 'en cours';
END;

----------------

create or replace TRIGGER INSERT_COLIS 
BEFORE INSERT ON COLIS 
REFERENCING NEW AS N 
FOR EACH ROW 

BEGIN
  :n.colnum  := seq_colnum.nextval; --on utilise ce séquence pour insérer le numéro de ce nouveau coli
  :n.coletat := 'en cours'; --l'état de coli par défaut est en cours
 
END;

-----------------

create or replace TRIGGER INSERT_COMGLOB 
BEFORE INSERT ON COMMANDEGLOBALE 
REFERENCING NEW AS N 
FOR EACH ROW
BEGIN
  :n.comglobnum := seq_comglobnum.nextval;--on utilise ce séquence pour insérer le numéro de cette nouvelle commande globale
  :n.comglobetat := 'en cours de constitution';--l'état de coli par défaut est en cours de constitution
END;

-----------------

create or replace TRIGGER INSERT_COMMANDE 
BEFORE INSERT ON COMMANDE 
REFERENCING OLD AS A NEW AS N 
FOR EACH ROW 
BEGIN
  :n.comnum := seq_comnum.nextval;--on utilise ce séquence pour insérer le numéro de cette nouvelle commande
  :n.cometat := 'en cours de constitution';--l'état de coli par défaut est en cours de constitution
END;

---------------

create or replace TRIGGER INSERT_VUE_LIVRER 
INSTEAD OF INSERT ON VUE_LIVRER 
REFERENCING NEW AS N 
DECLARE
  v_trouver boolean;--cette variable est pour vérifier si le cursor produit a un résultat
  v_livre boolean;--cette variable est pour stocker le résultat de procédure VERIFIER_COMGLOB_LIVRE
  ------
  --Cursor
  --Chercher le numéro de commande globale et la quantité commandée pour ce produit
  --par rapport au numéro de produit et la quantité de livraison que l'utilisateur a écrit
  ------
  cursor produit is
    select c.QTECOMGLOB,b.COMGLOBNUM
    from concernerglob c, bonlivraison b
    where c.comglobnum = b.comglobnum
    and c.prodnum = :n.prodnum
    and c.qtecomglob <= :n.qteliv;
  v_produit produit%rowtype;--cette variable est pour stocker une ligne dans le cursor produit

BEGIN  
  v_trouver := false;--on suppose qu'il n'y a pas de résultat dans ce cursor
  
  --on ajoute une ligne dans la tableau LIVRER
  INSERT INTO LIVRER VALUES(:n.bonlivnum,:n.prodnum,:n.qteliv,null);
  
  open produit;
  fetch produit into v_produit;  
  --si ce produit existe et la quantité est correcte , on mise à jour qterefus par rapport aux règles
  IF produit%FOUND THEN
    v_trouver := true;
    update livrer
      set qterefus = qteliv - v_produit.QTECOMGLOB
      where bonlivnum = :n.bonlivnum
      and prodnum = :n.prodnum;      
    PREPARER_COLIS(:n.prodnum,v_produit.COMGLOBNUM); --on prépare les colis pour ce produit
    --on vérifie si tous les produits dans cette commande globale sont bien livré
    v_livre := VERIFIER_COMGLOB_LIVRE(v_produit.COMGLOBNUM);
    if v_livre = true then
      --si oui, on change l'état de cette commande globale à 'terminé'
      update commandeglobale set comglobetat = 'terminé' where comglobnum = v_produit.COMGLOBNUM;
    end if;    
    --puis, on vérifie si tous les colis sont prêts pour ce commande
    VERIFIER_COLI(v_produit.COMGLOBNUM);
  END IF;
  CLOSE produit;
  
  --si la quantité de produit n'est pas bon ou ce produit n'est pas commandé dans cette commande globale, on refuse ce produit
  if v_trouver = false then
    update livrer
      set qterefus = qteliv
      where bonlivnum = :n.bonlivnum
      and prodnum = :n.prodnum;    
  end if;
END;

-----------

create or replace TRIGGER UPDATE_VUE_COM 
INSTEAD OF UPDATE ON VUE_COMMANDE 
REFERENCING OLD AS A NEW AS N 
DECLARE
  V_CGNUM COMMANDEGLOBALE.COMGLOBNUM%TYPE;
  V_SOMMEQTE NUMBER;
  V_ALERTE BOOLEAN;
  ------
  --Cursor
  --Chercher tous les lignes de commandes dont commande vient de mise à jour
  ------
  CURSOR LES_LIGNECOMMANDE IS
    Select c.prodnum, c.qtecom
    From concerner c
    Where c.comnum = :n.comnum;  
 
BEGIN
  --Si cette commande passe dans l'état 'en cours'
  if :a.cometat = 'en cours de constitution' and :n.cometat = 'en cours' then 
      update commande set cometat = 'en cours' where comnum = :n.comnum;
      --Parcourir chaque ligne de commande
      for une_lignecommande in LES_LIGNECOMMANDE loop
          --Faire appel la fonction 'VERIFIER_LIGNECOMMANDEGLOBALE()'
          --Vérifie s'il existe déjà une commande globale qui concerne ce produit
          V_CGNUM := VERIFIER_LIGNECOMMANDEGLOBALE(une_lignecommande.PRODNUM);
          
          IF V_CGNUM is not null then
              --Si oui, associer cette commande et ce produit à cette commande globale
              INSERT INTO ASSOCIER VALUES(:N.COMNUM,une_lignecommande.PRODNUM,V_CGNUM);
              --Augmenter le quantité du produit de cette commande globale et 
              UPDATE CONCERNERGLOB 
                SET QTECOMGLOB = QTECOMGLOB + une_lignecommande.QTECOM
                WHERE COMGLOBNUM = V_CGNUM
                AND PRODNUM = une_lignecommande.PRODNUM;
          ELSE
              --S'il n'existe pas une commande globale
              --Calculer la somme des quantité de ce produit dans tous les commandes qui ne sont pas encore factorisée
              V_SOMMEQTE := CALCULERQTETOTALE(une_lignecommande.PRODNUM);
              --Vérifie s'il existe une commande en alert parmi ces commandes
              V_ALERTE := VERIFIER_CMD_ALERTE(une_lignecommande.PRODNUM);
              IF V_ALERTE = TRUE THEN
                 --Si oui, on utilise cette procedure pour traiter cette ligne de commande
                  COMMANDE_ALERTE(V_SOMMEQTE,une_lignecommande.PRODNUM);
              ELSE
                  --Sinon, on utilise cette procedure pour traiter cette ligne de commande
                  COMMANDE_NONALERTE(V_SOMMEQTE,une_lignecommande.PRODNUM);
              END IF;
          END IF;   
      END LOOP;
  --Si cette commande passe dans l'etat 'terminé'
  elsif :a.cometat = 'en cours' and :n.cometat = 'terminé' then
    update commande set comdateliv = sysdate+1 where comnum = :n.comnum;
    --Faire appel le procédure 'PREPARER_CHARGEMENT()'
    PREPARER_CHARGEMENT(:n.comnum,:n.magnum);  
  end if;
END;

-------------