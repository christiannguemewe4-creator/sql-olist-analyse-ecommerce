SELECT customer_state as etat, 
COUNT(DISTINCT customer_unique_id) as nb_clients, 
round(sum(price),0) as ca ,
COUNT(DISTINCT order_id) as nbres_commande
FROM customers
join orders using (customer_id)
join order_items using(order_id)
WHERE order_status = 'delivered'
   AND order_purchase_timestamp >= '2017-01-01'
   AND order_purchase_timestamp <  '2018-09-01'
group by etat
order by ca desc;

WITH ca_etat AS (
    SELECT customer_state as etat, 
COUNT(DISTINCT customer_unique_id) as nb_clients, 
round(sum(price),0) as ca ,
COUNT(DISTINCT order_id) as nbres_commande
FROM customers
join orders using (customer_id)
join order_items using(order_id)
WHERE order_status = 'delivered'
   AND order_purchase_timestamp >= '2017-01-01'
   AND order_purchase_timestamp <  '2018-09-01'
group by etat
)
SELECT etat, nb_clients, nbres_commande, ca,
       ROUND(ca / SUM(ca) OVER () * 100, 1) AS part_ca_pct
FROM ca_etat
ORDER BY ca DESC;

-- Q2 – CA et clients par État (commandes livrées, janv. 2017 – août 2018)
-- Concentration : trois États, São Paulo (38,4 %), Rio de Janeiro (13,3 %) et Minas Gerais (11,8 %), génèrent 63,5 % du CA. Ils forment le Sud-Est, la région la plus peuplée et la plus riche du Brésil.
-- Petits marchés : 13 États pèsent chacun moins de 1 % du CA (environ 6 % au total), surtout au Nord et au Nord-Est. L’éloignement et les conditions de livraison pourraient l’expliquer (à vérifier en Q3).

-- Fidélité très faible : dans tous les États, le nombre de commandes est presque égal au nombre de clients (environ 1,03 commande par client). Les clients achètent une fois et ne reviennent pas, ce qui peut expliquer le plateau de 2018.

-- Action : (1) fidéliser les clients du Sud-Est, qui représentent l’essentiel du CA (programme de fidélité, relances après un premier achat) ; (2) vérifier si les délais de livraison freinent les ventes dans les États éloignés.


--  Combien de temps nos clients attendent-ils leur commande ? Les délais varient-ils selon les États ? Livrons-nous souvent en retard ?

SELECT COUNT(*) AS nb_commandes,
ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS delai_moyen, 
ROUND(avg(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 1) AS delai_promis,
   ROUND(AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                  THEN 1 ELSE 0 END) * 100, 1) AS pct_retard
FROM orders
   WHERE order_status = 'delivered'
     AND order_delivered_customer_date IS NOT NULL
     AND order_purchase_timestamp >= '2017-01-01'
     AND order_purchase_timestamp <  '2018-09-01';
     
     SELECT customer_state AS etat,                                   
       COUNT(*) AS nb_commandes,
       ROUND(AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)), 1) AS delai_moyen,
       ROUND(AVG(DATEDIFF(order_estimated_delivery_date, order_purchase_timestamp)), 1) AS delai_promis,
       ROUND(AVG(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                      THEN 1 ELSE 0 END) * 100, 1) AS pct_retard
FROM orders
JOIN customers USING (customer_id)                               
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
GROUP BY etat                                                    
ORDER BY delai_moyen DESC; 

SELECT seller_state as etat, 
COUNT(DISTINCT seller_id) as nb_vendeurs, 
round(sum(price),0) as ca ,
COUNT(DISTINCT order_id) as nbres_commande
FROM sellers
join order_items using(seller_id)
group by etat
order by ca desc;    

-- Q3 – Délais de livraison (commandes livrées, janv. 2017 – août 2018)

-- Vue globale : une commande met en moyenne 12,5 jours à arriver, alors qu’Olist promet 24,3 jours, soit deux fois plus. Grâce à cette marge, seules 8,1 % des commandes arrivent en retard.

-- Écarts entre États : São Paulo est l’État le plus rapide (8,7 jours). Les États du Nord sont les plus lents : près de 30 jours pour Roraima.

-- Cause : 60 % des vendeurs sont à São Paulo, et presque aucun dans le Nord. Les colis destinés aux États éloignés traversent tout le pays.

-- Point d’attention : Rio de Janeiro, 2ᵉ marché du pays, cumule un délai élevé (15,2 jours) et 13,5 % de retard, presque le double de la moyenne.

-- Action : (1) analyser les livraisons vers Rio pour identifier la cause des retards (transporteurs, zones difficiles d’accès) ; (2) recruter des vendeurs dans le Nord et le Nord-Est, ou y ouvrir des points de stockage, pour rapprocher les produits des clients.
                                  

