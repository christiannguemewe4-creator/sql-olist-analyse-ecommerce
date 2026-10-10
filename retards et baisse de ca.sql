-- Q4 Nos clients sont-ils satisfaits ? Les commandes livrées en retard reçoivent-elles de moins bonnes notes
select count(*) as nbres_commandes,
ROUND(AVG(review_score), 2) AS note_moyenne,
CASE WHEN order_delivered_customer_date > order_estimated_delivery_date
                      THEN 'en retard' ELSE 'à l''heure' END as  statut_livraison
from order_reviews
join orders using(order_id)
where order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
  AND order_purchase_timestamp >= '2017-01-01'
  AND order_purchase_timestamp <  '2018-09-01'
group by  statut_livraison;

-- Q4 – Retards et satisfaction client (commandes livrées, janv. 2017 – août 2018)

-- Chiffre : 92 % des commandes arrivent à l’heure et obtiennent une bonne note moyenne (4,29 / 5). Les 8 % livrées en retard obtiennent seulement 2,57 / 5.

-- Comparaison : un retard fait perdre 1,7 point de satisfaction. Le client passe de « satisfait » à « mécontent ».

-- Lien avec les autres questions : les retards se concentrent à Rio de Janeiro et dans le Nord-Est (Q3). Les clients livrés en retard sont mécontents, et ils reviennent rarement : 1,03 commande par client (Q2). Cela peut freiner la croissance, qui stagne depuis début 2018 (Q1b).

-- bAction : réduire les retards en priorité à Rio et dans le Nord-Est, et contacter les clients livrés en retard (excuses, bon de réduction) pour limiter la perte de clients.