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
-- JUSTIFICATION DES CHOIX :
--
-- CHOIX 1 : Vues avec filtre statique (UserID = 1)
-- -------------------------------------------------
-- POURQUOI : Démonstration académique du concept de Row-Level Security
-- - En production : Filtre dynamique avec contexte utilisateur (VPD/RLS)
-- - Pour le TP : Filtre statique sur UserID = 1 pour simplicité
-- - Principe démontré : Isolation des données via vues
--
-- CHOIX 2 : Trois vues pour user_fitness
-- ---------------------------------------
-- POURQUOI : Couvrir toutes les données personnelles
-- - v_mes_seances : Séances d'entraînement de l'utilisateur
-- - v_mes_details : Détails des exercices de ses séances
-- - v_mon_suivi : Suivi alimentaire de l'utilisateur
-- ============================================


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


-- ============================================
-- VERIFICATION
-- ============================================

-- Vérifier que les vues existent
SELECT view_name
FROM user_views
WHERE view_name LIKE 'V_%'
ORDER BY view_name;

-- Vérifier les privilèges accordés
SELECT grantee, table_name, privilege
FROM user_tab_privs_made
WHERE table_name LIKE 'V_%'
ORDER BY table_name, privilege;

-- FIN DU SCRIPT