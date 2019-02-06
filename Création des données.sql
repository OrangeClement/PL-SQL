--base de données produit
insert into produit values(0001,'cola',0.6);
insert into produit values(0002,'chocola',0.5);
insert into produit values(0003,'pain',0.8);
insert into produit values(0004,'bonbon',0.5);

--base de données fournisseur
insert into fournisseur values(0001,'Patis_Service');
insert into fournisseur values(0002,'Maison_Alex');
insert into fournisseur values(0003,'Damaski_shop');

--base de données 'secteur'
insert into secteur values (31, 'Toulouse','nord');
insert into secteur values (75, 'Paris','centre');

--base de données 'camion'
insert into magasin values (1,75,'La claire lune');
insert into magasin values (2,31,'Pain charmant');
insert into magasin values (3,75,'Tout est ICI');

--base de données 'modele'
insert into modele values (1,'Peterbilt',900);

--base de données 'camion'
insert into camion values (1,1,500);
insert into camion values (2,1,1000);
insert into camion values (3,1,1000);
insert into camion values (4,1,2000);
insert into camion values (5,1,3000);
insert into camion values (6,1,5000);

--base de données 'stocker'
insert into stocker values (1,1,100,20,200);
insert into stocker values (1,2,50,10,200);
insert into stocker values (1,3,10,25,50);
insert into stocker values (2,3,100,50,300);
insert into stocker values (2,4,30,10,100);
insert into stocker values (3,1,150,50,500);
insert into stocker values (3,2,100,40,350);
insert into stocker values (3,3,70,40,200);
insert into stocker values (3,4,300,10,600);

--base de données 'fournir'
insert into fournir values (1,1,'07/12/18',0.7,400);
insert into fournir values (1,1,'07/1/19',0.65,400);
insert into fournir values (1,2,'07/1/19',1.23,300);
insert into fournir values (1,3,'07/1/19',0.2,250);
insert into fournir values (1,4,'07/1/19',1.15,300);
insert into fournir values (2,1,'07/1/19',1,100);
insert into fournir values (2,2,'07/1/19',0.9,150);
insert into fournir values (2,3,'07/1/19',0.3,160);
insert into fournir values (2,4,'07/1/19',1.23,90);
insert into fournir values (3,3,'07/1/19',0.5,25);

commit;


