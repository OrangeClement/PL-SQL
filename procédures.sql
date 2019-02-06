create or replace PROCEDURE COMMANDE_ALERTE 
(
  P_QTETOTALE IN NUMBER,
  P_PRODNUM IN PRODUIT.PRODNUM%TYPE
) AS 
  ------
  --Procédure
  --Entrée : le numéro de produit et la quantité totale des commandes de ce produit
  ------
  V_FOUR FOURNISSEUR.FOURNUM%TYPE;--cette variable est pour stocker le numéro de fournisseur
  V_CGNUM COMMANDE.COMNUM%TYPE;--cette variable est pour stocker le numéro de commande globale
  ------
  --Cursor
  --Chercher le fournisseurs qui propose le prix minimal et son seuil est infériseur ou égale la quantité totale
  ------
  cursor fournisseurs is
    select f.fournum
    from fournir f
    where f.prodnum = P_PRODNUM
    and f.seuil <= P_QTETOTALE
    and f.histodate = (select max(f2.histodate)
                        from fournir f2
                        where f2.fournum = f.fournum
                        and f2.prodnum = f.prodnum)
    and f.proprix = (select min(f3.proprix)
                      from fournir f3
                      where f3.prodnum = P_PRODNUM
                      and f3.seuil <= P_QTETOTALE
                      and f3.histodate = (select max(f4.histodate)
                                          from fournir f4
                                          where f4.fournum = f3.fournum
                                          and f4.prodnum = f3.prodnum));
  ------
  --Cursor
  --Chercher les commandes qui concernent ce produit et qui ne sont pas encore associer à une commande globale
  ------                                      
   CURSOR COMMANDERESTANTES IS
    SELECT CO.COMNUM, CO.QTECOM
    FROM CONCERNER CO
    WHERE CO.PRODNUM = P_PRODNUM
    AND CO.COMNUM NOT IN (SELECT A.COMNUM
                          FROM ASSOCIER A
                          WHERE A.PRODNUM = CO.PRODNUM);
                          
BEGIN
    OPEN fournisseurs;
    FETCH fournisseurs INTO V_FOUR;
    --ce cursor a un seul résultat ou il n'a aucune résultat
    IF fournisseurs%FOUND THEN
      --on vérifie si ce fournisseur a déja une commande globale (mais pas contient ce produit)
      V_CGNUM := VERIFIER_COMMANDEGLOBALE(V_FOUR);
      IF V_CGNUM is not null then
      --si oui, on directement ajoute une ligne de commande pour ce produit et associe tous les commandes à cette commande globale.
        INSERT INTO CONCERNERGLOB VALUES(V_CGNUM,P_PRODNUM,P_QTETOTALE);
        FOR COMMANDE IN COMMANDERESTANTES LOOP
          INSERT INTO ASSOCIER VALUES(COMMANDE.COMNUM,P_PRODNUM,V_CGNUM);
        END LOOP; 
      ELSE
        --sinon, on crée une nouvelle commande globale
        INSERT INTO COMMANDEGLOBALE VALUES(null,V_FOUR,sysdate,null);
        INSERT INTO CONCERNERGLOB VALUES(seq_comglobnum.currval,P_PRODNUM,P_QTETOTALE);
        FOR COMMANDE IN COMMANDERESTANTES LOOP
          INSERT INTO ASSOCIER VALUES(COMMANDE.COMNUM,P_PRODNUM,seq_comglobnum.currval);
        END LOOP;
      END IF;
    END IF;
    CLOSE fournisseurs;
    
END COMMANDE_ALERTE;

---------------------

create or replace PROCEDURE COMMANDE_NONALERTE 
(
  P_QTETOTALE IN NUMBER,
  P_PRODNUM IN PRODUIT.PRODNUM%TYPE
) AS 
  ------
  --Procédure
  --Entrée : le numéro de produit et la quantité totale des commandes de ce produit
  ------
  V_CGNUM COMMANDE.COMNUM%TYPE;  --cette variable est pour stocker le numéro de commande globale
  ------
  --Cursor
  --Chercher un ou plusieurs fournisseurs qui fornissent ce produit et qui proprosent le prix minimal
  ------
  CURSOR FOURNISSEURS IS
    SELECT T.FOURNUM, T.PROPRIX, T.SEUIL
    FROM (SELECT F.FOURNUM, F.PROPRIX, F.SEUIL
          FROM FOURNIR F
          WHERE F.PRODNUM = P_PRODNUM
          AND F.HISTODATE = (SELECT MAX(F2.HISTODATE)
                              FROM FOURNIR F2
                              WHERE F2.FOURNUM = F.FOURNUM
                              AND F2.PRODNUM = F.PRODNUM)) T
    WHERE T.PROPRIX = 
            (SELECT MIN(F3.PROPRIX)
                FROM FOURNIR F3
                WHERE F3.PRODNUM = P_PRODNUM
                AND F3.HISTODATE = (SELECT MAX(F4.HISTODATE)
                                    FROM FOURNIR F4
                                    WHERE F4.FOURNUM = F3.FOURNUM
                                    AND F4.PRODNUM = F3.PRODNUM))
    ORDER BY T.SEUIL ASC; --on les classons dans l'ordre ascendant par le seuil.
  
  V_FOUR FOURNISSEURS%ROWTYPE; --cette variable est pour stocker une ligne dans le cursor fournisseurs
  
  ------
  --Cursor
  --Chercher les commandes qui concernent ce produit et qui ne sont pas encore associer à une commande globale
  ------
  CURSOR COMMANDERESTANTES IS
    SELECT CO.COMNUM, CO.QTECOM
    FROM CONCERNER CO
    WHERE CO.PRODNUM = P_PRODNUM
    AND CO.COMNUM NOT IN (SELECT A.COMNUM
                          FROM ASSOCIER A
                          WHERE A.PRODNUM = CO.PRODNUM);
  
BEGIN
  --on parcourt ce cursor. 
  FOR V_FOUR IN FOURNISSEURS LOOP
    --on vérifie si la somme de quantité de ce produit est supérieure ou égale le seuil
    IF V_FOUR.SEUIL <= P_QTETOTALE THEN
      --on vérifie si ce fournisseur a déja une commande globale (mais pas contient ce produit)
      V_CGNUM := VERIFIER_COMMANDEGLOBALE(V_FOUR.FOURNUM);
      IF V_CGNUM is not null then
      --si oui, on directement ajoute une ligne de commande pour ce produit et associe tous les commandes à cette commande globale.
        INSERT INTO CONCERNERGLOB VALUES(V_CGNUM,P_PRODNUM,P_QTETOTALE);
        FOR COMMANDE IN COMMANDERESTANTES LOOP
          INSERT INTO ASSOCIER VALUES(COMMANDE.COMNUM,P_PRODNUM,V_CGNUM);
        END LOOP;
      ELSE
      --sinon, on crée une nouvelle commande globale
        INSERT INTO COMMANDEGLOBALE VALUES(null,V_FOUR.FOURNUM,sysdate,null);
        INSERT INTO CONCERNERGLOB VALUES(seq_comglobnum.currval,P_PRODNUM,P_QTETOTALE);
        FOR COMMANDE IN COMMANDERESTANTES LOOP
          INSERT INTO ASSOCIER VALUES(COMMANDE.COMNUM,P_PRODNUM,seq_comglobnum.currval);
        END LOOP;
      END IF;
    END IF;
    --puisque on a classé les fournisseurs par le seuil dans l'ordre ascendant
    --si le premier fournisseur ne satisfait pas le seuil, on n'a pas besoin de vérifier les autres.
    EXIT; 
  END LOOP;

END COMMANDE_NONALERTE;

----------------

create or replace PROCEDURE PREPARER_CHARGEMENT 
(
  P_COLNUM IN COLIS.COLNUM%TYPE, 
  P_COMNUM IN COMMANDE.COMNUM%TYPE,
  P_VOLUME IN COLIS.COLVOLUME%TYPE
) AS 
  ------
  --Procédure
  --Entrée : le numéro de commande et le numéro de colis
  ------
  ------
  --cursor 'chargement'
  --chercher le chargement disponible qui est capable de charger les colis
  --Conditions : la destination du chargement est la même que celle des colis
  ------
  cursor chargement is
    select ch.charnum,mo.modcapacite,sum(c.colvolume) as charvolume
    from chargement ch,colis c, commande co,magasin m, camion ca, modele mo
    where ch.charnum = c.charnum
    and c.comnum = co.comnum
    and co.magnum = m.magnum
    and ch.camnum = ca.camnum
    and ca.modnum = mo.modnum
    and to_char(ch.chardate,'dd/MM/yy')=to_char(sysdate+1,'dd/MM/yy')
    and m.secnum = (select m2.secnum
                    from magasin m2,commande c2
                    where m2.magnum = c2.magnum
                    and c2.comnum = P_COMNUM)
    group by ch.charnum,mo.modcapacite;
  v_char chargement%rowtype;
  
    ------
    --cursor 'camiondisponible'
    --chercher le camion disponible qui est capable de recevoir les chargements
    ------
   cursor camiondisponible is
    select ca.camnum
    from camion ca
    where ca.camnum not in (select ch.camnum
                            from chargement ch
                            where to_char(ch.chardate,'dd/MM/yy')=to_char(sysdate+1,'dd/MM/yy')
							and ch.CHARETAT = 'en cours');
  v_camion camiondisponible%rowtype;
  
BEGIN
    
    --Vérifier s'il existe des chargements disponibles
    open chargement;
    fetch chargement into v_char;
    if chargement%notfound then
        --S'il n'existe pas de chargement
        --Créer un chargement
        --Chercher un camion disponible
        open camiondisponible;
        fetch camiondisponible into v_camion;
        if camiondisponible%found then
            --affecter ce nouvelle chargement à un camion
            insert into chargement values (null,v_camion.camnum ,null,null);
        end if;
        close camiondisponible;
        --Affecter ce chargement au coli concerné
        update colis set charnum = seq_charnum.currval,coletat ='terminé' where colnum = P_COLNUM;
        update commande set comdateliv = sysdate+1 where comnum = P_COMNUM;
    else
        --S'il existe un chargement disponible
        --Vérifier si ce chargement a une volume suffisante pour les colis
        if P_VOLUME + v_char.charvolume < v_char.modcapacite then 
            --S'il est suffisant, affecter ce chargement à chaque colis concerné
            update colis set charnum = v_char.charnum,coletat ='terminé' where colnum = P_COLNUM;
            update commande set comdateliv = sysdate+1 where comnum = P_COMNUM;
        else
            --S'il n'est pas suffisant, créer un nouveau chargement
            --Nous supposons que la volume de tous les colis dans une commande est toujours inférieur à la capacité d'une camion 
            open camiondisponible;
            fetch camiondisponible into v_camion;
            if camiondisponible%found then
                insert into chargement values (null,v_camion.camnum ,null,null);
            end if;
            close camiondisponible;
            --Affecter ce chargement à chaque colis concernés
            update colis set charnum = seq_charnum.currval,coletat ='terminé' where colnum = P_COLNUM;
            update commande set comdateliv = sysdate+1 where comnum = P_COMNUM;
        end if;
    end if;
END PREPARER_CHARGEMENT;

------------------

create or replace PROCEDURE PREPARER_COLIS 
(
  P_PRODNUM IN PRODUIT.PRODNUM%TYPE,
  P_COMGLOBNUM IN COMMANDEGLOBALE.COMGLOBNUM%TYPE
) AS 
  ------
  --Procédure
  --Entrée : le numéro de produit et le numéro de commande globale
  ------
  v_prodvolume produit.prodvolume%type;--cette variable est pour stocker le volume d'un produit
  ------
  --Cursor
  --Chercher le numéro de commande et la quantité commandée pour les commandes qui sont assoiciés à cette commande globale
  ------
  cursor coli is
    select c.comnum,c.qtecom
    from concerner c, associer a
    where c.comnum = a.comnum
    and c.prodnum = a.prodnum
    and a.comglobnum = P_COMGLOBNUM
    and a.prodnum = P_PRODNUM;
    
BEGIN    
   --cette requête nous aide d'obtenir le volume de ce produit 
    select prodvolume into v_prodvolume
    from produit
    where prodnum = P_PRODNUM;
  
  --pour chaque commande qui associer à ce produit et à cette commande globale, on crée un coli
  FOR un_coli in coli loop    
    --quand on insére un coli, on calcule le volume de ce coli
    INSERT INTO COLIS VALUES(null,null,un_coli.comnum,P_PRODNUM,null,v_prodvolume*un_coli.qtecom,un_coli.qtecom);
    PREPARER_CHARGEMENT(seq_colnum.currval,un_coli.comnum,v_prodvolume*un_coli.qtecom);
  END LOOP;
END PREPARER_COLIS;

----------------------

create or replace PROCEDURE VERIFIER_COLI 
(
  P_comglobnum IN commandeglobale.comglobnum%type 
) AS 
  ------
  --Procédure
  --Entrée : le numéro de commande globale
  ------
  ------
  --Cursor
  --Vérifier tous les commandes s'on a bien reçu tous les produits qui concerent ces commandes
  ------
  cursor commandes_termines is
    select c.comnum
    from associer a, concerner c
    where a.comglobnum = P_comglobnum
    and a.comnum = c.comnum
    and c.comnum not in 
                (select c.comnum
                from associer a, concerner c
                where a.comglobnum = P_comglobnum
                and a.comnum = c.comnum
                and c.prodnum not in 
                          (select colis.prodnum
                          from colis
                          where colis.comnum = c.comnum));
BEGIN
  --si oui, on change l'état de commande à 'terminé'
  for une_commande in commandes_termines loop
    update commande set cometat = 'terminé' where comnum = une_commande.comnum;
  end loop;
END VERIFIER_COLI;

-----------------------