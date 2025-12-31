--------------- Tuning et monitoring -------------


---***Ajuster work_mem pour éviter les temp file spills**--
--verification :
--work_mem est la mémoire allouée à une opération de tri ou de hash pour chaque requête (ORDER BY, DISTINCT, JOIN, AGGREGATE).
--Si work_mem est trop faible, PostgreSQL écrit les données sur disque (temp file spill) → ralentissement important.
--Si work_mem est trop élevé, risque de consommer trop de RAM si plusieurs requêtes concurrentes.
EXPLAIN (ANALYZE, BUFFERS) 
SELECT * 
FROM ordre 
ORDER BY date_creation;
--ajustement
-- Temporaire pour la session
SET work_mem = '64MB';
-- Permanent pour le serveur (postgresql.conf)
work_mem = 64MB



---***Optimiser fillfactor pour maximiser les HOT updates
--- fillfactor = pourcentage de remplissage d’une page.
--Utile pour les tables avec beaucoup de mises à jour.
--Permet aux mises à jour de rester dans la même page (HOT updates) → moins de fragmentation et I/O.
-- Table ordre, mise à jour fréquente du statut
ALTER TABLE ordre SET (fillfactor = 70);
