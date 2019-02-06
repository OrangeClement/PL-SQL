-- -----------------------------------------------------------------------------
--             Génération d'une base de données pour
--                      Oracle Version 10g
--                        (9/1/2019 13:37:40)
-- -----------------------------------------------------------------------------
--      Nom de la base : MLR1
--      Projet : 
--      Auteur : CHANG
--      Date de dernière modification : 9/1/2019 13:37:02
-- -----------------------------------------------------------------------------

DROP TABLE SECTEUR CASCADE CONSTRAINTS;

DROP TABLE FOURNISSEUR CASCADE CONSTRAINTS;

DROP TABLE BONLIVRAISON CASCADE CONSTRAINTS;

DROP TABLE COMMANDE CASCADE CONSTRAINTS;

DROP TABLE COMMANDEGLOBALE CASCADE CONSTRAINTS;

DROP TABLE CAMION CASCADE CONSTRAINTS;

DROP TABLE PRODUIT CASCADE CONSTRAINTS;

DROP TABLE MODELE CASCADE CONSTRAINTS;

DROP TABLE MAGASIN CASCADE CONSTRAINTS;

DROP TABLE CHARGEMENT CASCADE CONSTRAINTS;

DROP TABLE COLIS CASCADE CONSTRAINTS;

DROP TABLE LIVRER CASCADE CONSTRAINTS;

DROP TABLE CONCERNER CASCADE CONSTRAINTS;

DROP TABLE ASSOCIER CASCADE CONSTRAINTS;

DROP TABLE STOCKER CASCADE CONSTRAINTS;

DROP TABLE FOURNIR CASCADE CONSTRAINTS;

DROP TABLE CONCERNERGLOB CASCADE CONSTRAINTS;

-- -----------------------------------------------------------------------------
--       CREATION DE LA BASE 
-- -----------------------------------------------------------------------------

--CREATE DATABASE MLR1;

-- -----------------------------------------------------------------------------
--       TABLE : SECTEUR
-- -----------------------------------------------------------------------------

CREATE TABLE SECTEUR
   (
    SECNUM NUMBER(4)  NOT NULL,
    SECVILLE CHAR(32)  NULL,
    SECQUARTIER CHAR(32)  NULL
,   CONSTRAINT PK_SECTEUR PRIMARY KEY (SECNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : FOURNISSEUR
-- -----------------------------------------------------------------------------

CREATE TABLE FOURNISSEUR
   (
    FOURNUM NUMBER(4)  NOT NULL,
    FOURNOM CHAR(32)  NULL
,   CONSTRAINT PK_FOURNISSEUR PRIMARY KEY (FOURNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : BONLIVRAISON
-- -----------------------------------------------------------------------------

CREATE TABLE BONLIVRAISON
   (
    BONLIVNUM NUMBER(4)  NOT NULL,
    COMGLOBNUM NUMBER(4)  NOT NULL,
    BONDATE DATE  NULL
,   CONSTRAINT PK_BONLIVRAISON PRIMARY KEY (BONLIVNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE BONLIVRAISON
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_BONLIVRAISON_COMMANDEGLOB
     ON BONLIVRAISON (COMGLOBNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : COMMANDE
-- -----------------------------------------------------------------------------

CREATE TABLE COMMANDE
   (
    COMNUM NUMBER(4)  NOT NULL,
    MAGNUM NUMBER(4)  NOT NULL,
    COMDATE DATE  NULL,
    COMDATELIV DATE  NULL,
    COMETAT CHAR(32)  NULL   CHECK (COMETAT IN ('en cours', 'terminé', 'en cours de constitution'))
,   CONSTRAINT PK_COMMANDE PRIMARY KEY (COMNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE COMMANDE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_COMMANDE_MAGASIN
     ON COMMANDE (MAGNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : COMMANDEGLOBALE
-- -----------------------------------------------------------------------------

CREATE TABLE COMMANDEGLOBALE
   (
    COMGLOBNUM NUMBER(4)  NOT NULL,
    FOURNUM NUMBER(4)  NOT NULL,
    COMGLOBDATE DATE  NULL,
    COMGLOBETAT CHAR(32)  NULL   CHECK (COMGLOBETAT IN ('en cours de constitution', 'en cours de préparation', 'terminé'))
,   CONSTRAINT PK_COMMANDEGLOBALE PRIMARY KEY (COMGLOBNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE COMMANDEGLOBALE
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_COMMANDEGLOBALE_FOURNISSE
     ON COMMANDEGLOBALE (FOURNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CAMION
-- -----------------------------------------------------------------------------

CREATE TABLE CAMION
   (
    CAMNUM NUMBER(4)  NOT NULL,
    MODNUM NUMBER(4)  NOT NULL,
    CAMKM NUMBER(7,2)  NULL
,   CONSTRAINT PK_CAMION PRIMARY KEY (CAMNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CAMION
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CAMION_MODELE
     ON CAMION (MODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : PRODUIT
-- -----------------------------------------------------------------------------

CREATE TABLE PRODUIT
   (
    PRODNUM NUMBER(4)  NOT NULL,
    PRODLIB CHAR(32)  NULL,
    PRODVOLUME NUMBER(7,2)  NULL
,   CONSTRAINT PK_PRODUIT PRIMARY KEY (PRODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : MODELE
-- -----------------------------------------------------------------------------

CREATE TABLE MODELE
   (
    MODNUM NUMBER(4)  NOT NULL,
    MODLIBELLE CHAR(32)  NULL,
    MODCAPACITE NUMBER(7,2)  NULL
,   CONSTRAINT PK_MODELE PRIMARY KEY (MODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       TABLE : MAGASIN
-- -----------------------------------------------------------------------------

CREATE TABLE MAGASIN
   (
    MAGNUM NUMBER(4)  NOT NULL,
    SECNUM NUMBER(4)  NOT NULL,
    MAGNOM CHAR(32)  NULL
,   CONSTRAINT PK_MAGASIN PRIMARY KEY (MAGNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE MAGASIN
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_MAGASIN_SECTEUR
     ON MAGASIN (SECNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CHARGEMENT
-- -----------------------------------------------------------------------------

CREATE TABLE CHARGEMENT
   (
    CHARNUM NUMBER(4)  NOT NULL,
    CAMNUM NUMBER(4)  NULL,
    CHARDATE DATE  NULL,
    CHARETAT CHAR(32)  NULL   CHECK (CHARETAT IN ('terminé', 'en cours'))
,   CONSTRAINT PK_CHARGEMENT PRIMARY KEY (CHARNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CHARGEMENT
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CHARGEMENT_CAMION
     ON CHARGEMENT (CAMNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : COLIS
-- -----------------------------------------------------------------------------

CREATE TABLE COLIS
   (
    COLNUM NUMBER(2)  NOT NULL,
    CHARNUM NUMBER(4)  NULL,
    COMNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NULL,
    COLETAT CHAR(32)  NULL   CHECK (COLETAT IN ('en cours', 'terminé')),
    COLVOLUME NUMBER(7,2)  NULL,
    QTELIV NUMBER(4)  NULL
,   CONSTRAINT PK_COLIS PRIMARY KEY (COLNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE COLIS
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_COLIS_CHARGEMENT
     ON COLIS (CHARNUM ASC)
    ;

CREATE  INDEX I_FK_COLIS_COMMANDE
     ON COLIS (COMNUM ASC)
    ;

CREATE  INDEX I_FK_COLIS_PRODUIT
     ON COLIS (PRODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : LIVRER
-- -----------------------------------------------------------------------------

CREATE TABLE LIVRER
   (
    BONLIVNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    QTELIV NUMBER(4)  NULL,
    QTEREFUS NUMBER(4)  NULL
,   CONSTRAINT PK_LIVRER PRIMARY KEY (BONLIVNUM, PRODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE LIVRER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_LIVRER_BONLIVRAISON
     ON LIVRER (BONLIVNUM ASC)
    ;

CREATE  INDEX I_FK_LIVRER_PRODUIT
     ON LIVRER (PRODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONCERNER
-- -----------------------------------------------------------------------------

CREATE TABLE CONCERNER
   (
    COMNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    QTECOM NUMBER(4)  NULL
,   CONSTRAINT PK_CONCERNER PRIMARY KEY (COMNUM, PRODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONCERNER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONCERNER_COMMANDE
     ON CONCERNER (COMNUM ASC)
    ;

CREATE  INDEX I_FK_CONCERNER_PRODUIT
     ON CONCERNER (PRODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : ASSOCIER
-- -----------------------------------------------------------------------------

CREATE TABLE ASSOCIER
   (
    COMNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    COMGLOBNUM NUMBER(4)  NOT NULL
,   CONSTRAINT PK_ASSOCIER PRIMARY KEY (COMNUM, PRODNUM, COMGLOBNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE ASSOCIER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_ASSOCIER_COMMANDE
     ON ASSOCIER (COMNUM ASC)
    ;

CREATE  INDEX I_FK_ASSOCIER_PRODUIT
     ON ASSOCIER (PRODNUM ASC)
    ;

CREATE  INDEX I_FK_ASSOCIER_COMMANDEGLOBALE
     ON ASSOCIER (COMGLOBNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : STOCKER
-- -----------------------------------------------------------------------------

CREATE TABLE STOCKER
   (
    MAGNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    QTESTOCK NUMBER(4)  NULL,
    QTEALERTE NUMBER(4)  NULL,
    QTEMAX NUMBER(4)  NULL
,   CONSTRAINT PK_STOCKER PRIMARY KEY (MAGNUM, PRODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE STOCKER
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_STOCKER_MAGASIN
     ON STOCKER (MAGNUM ASC)
    ;

CREATE  INDEX I_FK_STOCKER_PRODUIT
     ON STOCKER (PRODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : FOURNIR
-- -----------------------------------------------------------------------------

CREATE TABLE FOURNIR
   (
    FOURNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    HISTODATE DATE  NOT NULL,
    PROPRIX NUMBER(6,2)  NULL,
    SEUIL NUMBER(4)  NULL
,   CONSTRAINT PK_FOURNIR PRIMARY KEY (FOURNUM, PRODNUM, HISTODATE)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE FOURNIR
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_FOURNIR_FOURNISSEUR
     ON FOURNIR (FOURNUM ASC)
    ;

CREATE  INDEX I_FK_FOURNIR_PRODUIT
     ON FOURNIR (PRODNUM ASC)
    ;

-- -----------------------------------------------------------------------------
--       TABLE : CONCERNERGLOB
-- -----------------------------------------------------------------------------

CREATE TABLE CONCERNERGLOB
   (
    COMGLOBNUM NUMBER(4)  NOT NULL,
    PRODNUM NUMBER(4)  NOT NULL,
    QTECOMGLOB NUMBER(4)  NULL
,   CONSTRAINT PK_CONCERNERGLOB PRIMARY KEY (COMGLOBNUM, PRODNUM)  
   ) ;

-- -----------------------------------------------------------------------------
--       INDEX DE LA TABLE CONCERNERGLOB
-- -----------------------------------------------------------------------------

CREATE  INDEX I_FK_CONCERNERGLOB_COMMANDEGLO
     ON CONCERNERGLOB (COMGLOBNUM ASC)
    ;

CREATE  INDEX I_FK_CONCERNERGLOB_PRODUIT
     ON CONCERNERGLOB (PRODNUM ASC)
    ;


-- -----------------------------------------------------------------------------
--       CREATION DES REFERENCES DE TABLE
-- -----------------------------------------------------------------------------


ALTER TABLE BONLIVRAISON ADD (
     CONSTRAINT FK_BONLIVRAISON_COMMANDEGLOBAL
          FOREIGN KEY (COMGLOBNUM)
               REFERENCES COMMANDEGLOBALE (COMGLOBNUM))   ;

ALTER TABLE COMMANDE ADD (
     CONSTRAINT FK_COMMANDE_MAGASIN
          FOREIGN KEY (MAGNUM)
               REFERENCES MAGASIN (MAGNUM))   ;

ALTER TABLE COMMANDEGLOBALE ADD (
     CONSTRAINT FK_COMMANDEGLOBALE_FOURNISSEUR
          FOREIGN KEY (FOURNUM)
               REFERENCES FOURNISSEUR (FOURNUM))   ;

ALTER TABLE CAMION ADD (
     CONSTRAINT FK_CAMION_MODELE
          FOREIGN KEY (MODNUM)
               REFERENCES MODELE (MODNUM))   ;

ALTER TABLE MAGASIN ADD (
     CONSTRAINT FK_MAGASIN_SECTEUR
          FOREIGN KEY (SECNUM)
               REFERENCES SECTEUR (SECNUM))   ;

ALTER TABLE CHARGEMENT ADD (
     CONSTRAINT FK_CHARGEMENT_CAMION
          FOREIGN KEY (CAMNUM)
               REFERENCES CAMION (CAMNUM))   ;

ALTER TABLE COLIS ADD (
     CONSTRAINT FK_COLIS_CHARGEMENT
          FOREIGN KEY (CHARNUM)
               REFERENCES CHARGEMENT (CHARNUM))   ;

ALTER TABLE COLIS ADD (
     CONSTRAINT FK_COLIS_COMMANDE
          FOREIGN KEY (COMNUM)
               REFERENCES COMMANDE (COMNUM))   ;

ALTER TABLE COLIS ADD (
     CONSTRAINT FK_COLIS_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE LIVRER ADD (
     CONSTRAINT FK_LIVRER_BONLIVRAISON
          FOREIGN KEY (BONLIVNUM)
               REFERENCES BONLIVRAISON (BONLIVNUM))   ;

ALTER TABLE LIVRER ADD (
     CONSTRAINT FK_LIVRER_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE CONCERNER ADD (
     CONSTRAINT FK_CONCERNER_COMMANDE
          FOREIGN KEY (COMNUM)
               REFERENCES COMMANDE (COMNUM))   ;

ALTER TABLE CONCERNER ADD (
     CONSTRAINT FK_CONCERNER_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE ASSOCIER ADD (
     CONSTRAINT FK_ASSOCIER_COMMANDE
          FOREIGN KEY (COMNUM)
               REFERENCES COMMANDE (COMNUM))   ;

ALTER TABLE ASSOCIER ADD (
     CONSTRAINT FK_ASSOCIER_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE ASSOCIER ADD (
     CONSTRAINT FK_ASSOCIER_COMMANDEGLOBALE
          FOREIGN KEY (COMGLOBNUM)
               REFERENCES COMMANDEGLOBALE (COMGLOBNUM))   ;

ALTER TABLE STOCKER ADD (
     CONSTRAINT FK_STOCKER_MAGASIN
          FOREIGN KEY (MAGNUM)
               REFERENCES MAGASIN (MAGNUM))   ;

ALTER TABLE STOCKER ADD (
     CONSTRAINT FK_STOCKER_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE FOURNIR ADD (
     CONSTRAINT FK_FOURNIR_FOURNISSEUR
          FOREIGN KEY (FOURNUM)
               REFERENCES FOURNISSEUR (FOURNUM))   ;

ALTER TABLE FOURNIR ADD (
     CONSTRAINT FK_FOURNIR_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;

ALTER TABLE CONCERNERGLOB ADD (
     CONSTRAINT FK_CONCERNERGLOB_COMMANDEGLOBA
          FOREIGN KEY (COMGLOBNUM)
               REFERENCES COMMANDEGLOBALE (COMGLOBNUM))   ;

ALTER TABLE CONCERNERGLOB ADD (
     CONSTRAINT FK_CONCERNERGLOB_PRODUIT
          FOREIGN KEY (PRODNUM)
               REFERENCES PRODUIT (PRODNUM))   ;


-- -----------------------------------------------------------------------------
--                FIN DE GENERATION
-- -----------------------------------------------------------------------------