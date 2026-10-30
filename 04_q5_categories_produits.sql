-- Q5: Quelles catégories de produits génèrent le plus de chiffre d’affaires ? Sur lesquelles devons-nous concentrer nos efforts

SELECT COUNT(DISTINCT order_id) AS nb_commandes, 
product_category_name_english as nomproduit, 
round(sum(price),0) as ca
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
JOIN category_translation USING (product_category_name)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
group BY nomproduit;


WITH ca_total AS (
    SELECT COUNT(DISTINCT order_id) AS nb_commandes, 
product_category_name_english as nomproduit, 
round(sum(price),0) as ca
FROM orders
JOIN order_items USING (order_id)
JOIN products USING (product_id)
JOIN category_translation USING (product_category_name)
where order_status = 'delivered' 
AND order_purchase_timestamp >= '2017-01-01'
AND order_purchase_timestamp < '2018-09-01'
GROUP BY nomproduit
)
SELECT nomproduit,
nb_commandes,
ca,
ROUND(ca / SUM(ca) OVER () * 100, 1) AS part_ca_pct
FROM ca_total
order by ca desc
limit 10;

-- Q5 – Catégories de produits (commandes livrées, janv. 2017 – août 2018)

-- Chiffre : les 10 premières catégories représentent 63,3 % du CA. La première, health_beauty (beauté et santé), pèse 9,5 %. Aucune catégorie ne domine, donc l’activité est déjà diversifiée.

-- Comparaison : il existe deux façons de faire du CA. bed_bath_table (linge de maison) mise sur le volume : 9 267 commandes, mais un panier moyen de 110 R$. watches_gifts (montres et cadeaux) mise sur le prix : 5 491 commandes seulement, mais un panier de 212 R$, presque le double.

-- Action : (1) des promotions sur les catégories d’achat régulier (beauté, linge de maison) pour faire revenir les clients, ce qui répond au problème de fidélité de la Q2 ; (2) mettre en avant les catégories cadeaux pour le Black Friday et les fêtes, les meilleurs mois de 2017 (Q1b) ; (3) continuer à diversifier l’offre pour ne pas dépendre de quelques catégories.


