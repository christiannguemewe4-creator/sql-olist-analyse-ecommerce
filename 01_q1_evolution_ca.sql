use olist;
select  count(order_status)
from orders 
where order_status = 'delivered' ;

SELECT order_status, COUNT(*) AS nombre
FROM orders
GROUP BY order_status
ORDER BY nombre desc ;
-- 97 % des commandes ont été livrées. Seulement 1,2 % sont perdues (625 annulées et 609 produits indisponibles), 
-- le reste étant encore en cours de traitement. Les ruptures de stock pèsent presque autant que les annulations :
-- c’est une piste d’amélioration. »

SELECT min(order_purchase_timestamp) as date_debut, max(order_purchase_timestamp) as data_fin
FROM orders;

SELECT DATE_FORMAT(order_purchase_timestamp, '%Y-%m') AS mois,
       COUNT(*) AS nb_commandes
FROM orders
GROUP BY mois
ORDER BY nb_commandes desc
limit  5;

SELECT COUNT(DISTINCT order_id) AS nb_commandes, month(order_purchase_timestamp) as mois, year(order_purchase_timestamp) as annee , round(sum(price),0) as ca
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
GROUP BY annee, mois
ORDER BY annee, mois; ;

SELECT COUNT(DISTINCT order_id) AS nb_commandes, round(sum(price),0) as ca
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2017-09-01';

SELECT COUNT(DISTINCT order_id) AS nb_commandes, round(sum(price),0) as ca
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2018-01-01'
AND order_purchase_timestamp < '2018-09-01';

SELECT   year(order_purchase_timestamp) as annee, COUNT(DISTINCT order_id) AS nb_commandes, round(sum(price),0) as ca
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
AND MONTH(order_purchase_timestamp) <= 8
group by annee;

WITH ca_annuel AS (
    SELECT   year(order_purchase_timestamp) as annee, COUNT(DISTINCT order_id) AS nb_commandes, round(sum(price),0) as ca
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
AND MONTH(order_purchase_timestamp) <= 8
group by annee
)
SELECT annee,
       nb_commandes,
       ca,
       LAG(ca) OVER (ORDER BY annee) AS ca_annee_precedente,
       ROUND( (ca - LAG(ca) OVER (ORDER BY annee))
       / LAG(ca) OVER (ORDER BY annee) * 100 , 1) AS croissance_pct
FROM ca_annuel;

-- Q1 Chiffre : de janvier à août 2018, le chiffre d’affaires atteint 7,39 M R$ (prix des articles, hors frais de port), pour 53 774 commandes.
-- Comparaison : c’est +137 % par rapport à la même période de 2017 (3,11 M R$, 22 693 commandes).
-- Cause : la croissance vient entièrement du volume. Le nombre de commandes progresse aussi de +137 %, tandis que le panier moyen reste stable (137,2 R$ contre 137,4 R$).
-- Action : la plateforme gagne des clients, mais chacun ne dépense pas plus. Deux pistes : augmenter le panier moyen (ventes complémentaires, livraison offerte au-dessus d’un seuil), et vérifier que la logistique suit la hausse des volumes. 
-- C’est l’objet de la Q3 sur les délais.

-- Croissance mensuelle du CA (janv. 2017 - août 2018)

WITH ca_mensuel AS (
    SELECT   month(order_purchase_timestamp) as mois,
    COUNT(DISTINCT order_id) AS nb_commandes, round(sum(price),0) as ca,
    year(order_purchase_timestamp) as annee
FROM orders
join order_items using (order_id)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
group by mois, annee
)
SELECT mois, annee,
       nb_commandes,
       ca,
       LAG(ca) OVER (ORDER BY annee, mois) AS ca_mois_precedente,
       ROUND( (ca - LAG(ca) OVER (ORDER BY  annee, mois))
       / LAG(ca) OVER (ORDER BY annee, mois) * 100 , 1) AS croissance_pct
FROM ca_mensuel;

-- Q1b – Évolution mensuelle du CA (janv. 2017 – août 2018, commandes livrées)
-- 2017 : forte croissance. Le CA passe de 112 000 R$ en janvier à 988 000 R$ en novembre (×9). Les 
-- premiers mois sont faibles, ce qui correspond au démarrage de l’activité.
-- Novembre 2017 : pic exceptionnel (+52 % en un mois), probablement lié au Black Friday et aux
 -- promotions de fin d’année. Le CA retombe en décembre (-26 %), puis repart en janvier 2018 (+27%).
-- 2018 : plateau. De janvier à août, le CA oscille entre 826 000 et 978 000 R$. Le niveau est élevé, mais alter
-- il ne progresse plus : les variations mensuelles restent entre -12 % et +15 %, contre +40 à +50 % en 
-- 2017. Le +137 % de la Q1 vient donc de la montée de 2017, pas d’une croissance en 2018.
-- Action : (1) identifier la cause du plateau en analysant l’évolution du nombre de clients, du panier 
-- moyen et des catégories ; (2) préparer le Black Friday 2018, le meilleur levier observé en 201




