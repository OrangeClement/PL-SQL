 delete colis;
 delete chargement;
 delete livrer;
 delete bonlivraison;
 delete associer;
 delete concerner;
 delete concernerglob;
 delete commande;
 delete commandeglobale;

--- Règle de factorisation ---

--Magasin 1 effectue une commande concernant les produits 1 et 3
--Produit 3 de ce magasin est en alerte
insert into commande values (null,1,'08/01/19',null,null);
insert into concerner values (seq_comnum.currval,1,50);
insert into concerner values (seq_comnum.currval,3,30);
update vue_commande set cometat = 'en cours' where comnum = 1;
--Résultats attendus:
--Produit 1 sera en attente
--Produit 3 sera été factorisé (Créer une commande globale et ajouter une ligne de commande globale)

--Magasin 3 effectue une commande concernant le produit 4
insert into commande values (null,3,sysdate,null,null);
insert into concerner values (seq_comnum.currval,4,300);
update vue_commande set cometat = 'en cours' where comnum = 2;
--Résultats attendus:
--Produit 4 sera été factorisé (Créer une commande globale et ajouter une ligne de commande globale)

--Magasin 2 effectue une commande concernant le produit 3
insert into commande values (null, 2,sysdate,null,null);
insert into concerner values (seq_comnum.currval,3,220);
update vue_commande set cometat = 'en cours' where comnum = 3;
--Résultats attendus:
--Produit 3 sera été factorisé (Il existe une commande globale concernant ce produit, donc la quantité du produit de la commande globale va augmenter)

--Magasin 3 effectue une commande concernant le produit 1
insert into commande values (null,3,sysdate,null,null);
insert into concerner values (seq_comnum.currval,1,350);
update vue_commande set cometat = 'en cours' where comnum = 4;
--Résultats attendus:
--Produit 1 sera été factorisé
--Il n'existe pas une commande globale concernant ce produit
--Le fournisseur le moins cher a déjà une commande globale
--Parce que la somme des quantité de ce produit (commande 1 et commande 4) est égale au seuil de ce fournisseur
--Ajouter une nouvelle ligne de commande globale concernant ce produit










----Test ZYCJ_USER -----------
set role ZYCJ_ROLE_FOUR;
--chercher la commande globale de ce fournisseur et ses produits concernants
SELECT CMG.COMGLOBNUM,CG.PRODNUM,CG.QTECOMGLOB
FROM ZYCJ_CHEF.COMMANDEGLOBALE CMG, ZYCJ_CHEF.CONCERNERGLOB CG
WHERE CMG.FOURNUM = 3
AND CMG.COMGLOBNUM = CG.COMGLOBNUM;

UPDATE ZYCJ_CHEF.COMMANDEGLOBALE SET COMGLOBETAT = 'en cours de préparation' where COMGLOBNUM = 1;
commit;

--Fournisseur 3 effectue un bon livraison et ajoute les lignes de bon livraison
insert into ZYCJ_CHEF.bonlivraison values (null,1,sysdate);
commit;
--chercher le numéro de bonlivraison
select bonlivnum
from ZYCJ_CHEF.bonlivraison
where comglobnum = 1;

insert into ZYCJ_CHEF.vue_livrer values (,1,300,null);
commit;
--Résultats attendus
--Faux produit: qterefus = qteliv

insert into ZYCJ_CHEF.bonlivraison values (null,1,sysdate);
commit;
--chercher le numéro de bonlivraison
select bonlivnum
from ZYCJ_CHEF.bonlivraison
where comglobnum = 1;
insert into ZYCJ_CHEF.vue_livrer values (,3,200,null);
commit;
--Résultats attendus
--Bon produit mais qte insuffisante: qterefus = qteliv

insert into ZYCJ_CHEF.bonlivraison values (null,1,sysdate);
commit;
--chercher le numéro de bonlivraison
select bonlivnum
from ZYCJ_CHEF.bonlivraison
where comglobnum = 1;
insert into ZYCJ_CHEF.vue_livrer values (,3,250,null);
commit;
--Résultats attendus
--Bon produit et qte correcte: qterefus = 0
--Commande globale 1 passera dans l'état 'terminé'
--Deux colis seront crées
--Commande 3 passera dans l'état 'terminé'
--Le coli concernant la commande 3 sera chargé et passera dans l'état 'terminé'
--Deux chargements vont été créés

insert into ZYCJ_CHEF.bonlivraison values (null,1,sysdate);
--Résultats attendus
--Insertion réfusée
--Parce que la commande globale 2 est terminé








--- règle de livraison / règle de la gestion des colis et la gestion des chargements ---

insert into bonlivraison values (null,2,sysdate);
--Résultats attendus
--Insertion réfusée
--Parce que la commande globale 2 est en cours de constitution

--Les fournisseurs changent l'état de ses commandes globales
update commandeglobale set comglobetat = 'en cours de préparation' where comglobnum = 2;

--Magasin 2 effectue une commande concernant le produit 4
insert into commande values (null,2,sysdate,null,null);
insert into concerner values (seq_comnum.currval,4,20);
update vue_commande set cometat = 'en cours' where comnum = 5;
--Résultats attendus
--Le produit ne sera pas être factorisé
--Parce qu'il n'y a plus de commandes globales dont l'état est en cour de constitution
--La quantité du produit ne satisfait le seuil à commander du founisseur le moins cher

--Fournisseur 1 effectue un bon livraison et ajoute les lignes de bon livraison
insert into bonlivraison values (null,2,sysdate);
insert into vue_livrer values (seq_bonlivnum.currval,4,300,null);
--Résultats attendus
--Bon produit 4 : qterefus = 0
--Un colis seront crées
--Commande 2 passera dans l'état 'terminé'
--Le coli concernant la commande 2 sera chargé et passera dans l'état 'terminé'

insert into vue_livrer values (seq_bonlivnum.currval,1,450,null);
--Bon produit 1 : qterefus = 50
--Commande globale 2 passera dans l'état 'terminé'
--Commande 1 et 4 passeront dans l'état 'terminé'
--Les colis concernant la commande 1 et 4 sera chargé et passera dans l'état 'terminé'












