-----------------------------------
----Création des utilisateurs------
-----------------------------------

---------Chef de projet------------
-- USER SQL
CREATE USER ZYCJ_CHEF IDENTIFIED BY ZYCJ
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";
-- ROLES
GRANT "CONNECT" TO ZYCJ_CHEF ;
GRANT "RESOURCE" TO ZYCJ_CHEF ;

-- SYSTEM PRIVILEGES
GRANT CREATE VIEW TO ZYCJ_CHEF ;

----Utilisateur final--Fournisseur----
-- USER SQL
CREATE USER ZYCJ_USER IDENTIFIED BY ZYCJ 
DEFAULT TABLESPACE "USERS"
TEMPORARY TABLESPACE "TEMP";
-- ROLES
GRANT "CONNECT" TO ZYCJ_USER ;

-----------Rôle--Fournisseur----------
--Exécuter dans compte "adminimp"
CREATE ROLE ZYCJ_ROLE_FOUR;
GRANT SELECT,UPDATE ON ZYCJ_CHEF.COMMANDEGLOBALE TO ZYCJ_ROLE_FOUR;
GRANT SELECT,UPDATE ON ZYCJ_CHEF.FOURNISSEUR TO ZYCJ_ROLE_FOUR;
GRANT SELECT ON ZYCJ_CHEF.CONCERNERGLOB TO ZYCJ_ROLE_FOUR;
GRANT SELECT,INSERT ON ZYCJ_CHEF.FOURNIR TO ZYCJ_ROLE_FOUR;
GRANT SELECT,INSERT ON ZYCJ_CHEF.BONLIVRAISON TO ZYCJ_ROLE_FOUR;
GRANT SELECT,INSERT ON ZYCJ_CHEF.VUE_LIVRER TO ZYCJ_ROLE_FOUR;
GRANT SELECT ON ZYCJ_CHEF.PRODUIT TO ZYCJ_ROLE_FOUR;

GRANT ZYCJ_ROLE_FOUR TO ZYCJ_USER;

--Donner le droit de mise à jour seulement pour l'attribut COMGLOBETAT dans la table COMMANDEGLOBALE
REVOKE UPDATE ON ZYCJ_CHEF.COMMANDEGLOBALE FROM ZYCJ_ROLE_FOUR;
GRANT UPDATE(COMGLOBETAT) ON ZYCJ_CHEF.COMMANDEGLOBALE TO ZYCJ_ROLE_FOUR;

-------------Test----------------------
--Connecter avec le compte de fournisseur
set role ZYCJ_ROLE_FOUR;
select *
from ZYCJ_CHEF.fournir;
--Résultat:
   FOURNUM    PRODNUM HISTODATE    PROPRIX      SEUIL
---------- ---------- --------- ---------- ----------
         1          1 07/12/18          ,7        400
         1          1 07/01/19         ,65        400
         1          2 07/01/19        1,23        300
         1          3 07/01/19          ,2        250
         1          4 07/01/19        1,15        300
         2          1 07/01/19           1        100
         2          2 07/01/19          ,9        150
         2          3 07/01/19          ,3        160
         2          4 07/01/19        1,23         90
         3          3 07/01/19          ,5         25


UPDATE ZYCJ_CHEF.COMMANDEGLOBALE
SET COMGLOBDATE = sysdate
where COMGLOBNUM = 1;
--Résultat:
--Erreur SQL : ORA-01031: privilèges insuffisants
--01031. 00000 -  "insufficient privileges"