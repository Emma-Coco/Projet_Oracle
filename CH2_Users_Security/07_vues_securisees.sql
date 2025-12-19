-- ============================================
-- CHAPITRE 2.4 : VUES SECURISEES
-- Fichier : 07_vues_securisees.sql
-- Connexion requise : admin_fitness
-- Date : Décembre 2025
-- ============================================
-- DESCRIPTION :
-- Ce script crée les vues sécurisées qui filtrent les données par utilisateur
-- et accorde les privilèges à user_fitness.

-- ============================================
-- PARTIE 1 : CREATION DES VUES SECURISEES
-- ============================================

-- Vue des séances de l'utilisateur connecté (UserID = 1)
CREATE OR REPLACE VIEW v_mes_seances AS
SELECT *
FROM SEANCE_ENTRAINEMENT
WHERE UserID = 1;

-- Vue des détails d'exercices liés aux séances de l'utilisateur
CREATE OR REPLACE VIEW v_mes_details AS
SELECT *
FROM DETAILS_EXERCICE_SEANCE
WHERE SessionID IN (
    SELECT SessionID
    FROM SEANCE_ENTRAINEMENT
    WHERE UserID = 1
);

-- Vue du suivi alimentaire de l'utilisateur
CREATE OR REPLACE VIEW v_mon_suivi AS
SELECT *
FROM SUIVI_ALIMENTAIRE
WHERE UserID = 1;


-- ============================================
-- PARTIE 2 : ATTRIBUTION DES PRIVILEGES SUR LES VUES
-- ============================================

-- user_fitness peut faire toutes les opérations sur ses vues
GRANT SELECT, INSERT, UPDATE, DELETE ON v_mes_seances TO user_fitness;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_mes_details TO user_fitness;
GRANT SELECT, INSERT, UPDATE, DELETE ON v_mon_suivi TO user_fitness;

COMMIT;

-- -- FIN DU SCRIPT