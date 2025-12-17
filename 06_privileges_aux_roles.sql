-- ============================================
-- CHAPITRE 2.3 : PRIVILEGES AUX ROLES (PARTIE admin_fitness)
-- Fichier : 06_privileges_aux_roles.sql
-- Connexion requise : admin_fitness
-- Date : Décembre 2025
-- ============================================
-- DESCRIPTION :
-- Ce script attribue les privilèges sur les tables aux rôles fonctionnels.
-- Doit être exécuté APRÈS 05_profils_roles_SYSTEM.sql
-- ============================================
-- JUSTIFICATION DES CHOIX :
--
-- CHOIX 1 : Séparation stricte coach / nutritionniste
-- ----------------------------------------------------
-- POURQUOI : Principe du moindre privilège + conformité RGPD
-- - Coach : Aucun accès aux données nutritionnelles (REPAS, SUIVI_ALIMENTAIRE)
-- - Nutritionniste : Aucun accès aux données d'entraînement (EXERCICE, SEANCE, DETAILS)
-- - Justification : Limite l'exposition des données sensibles de santé
--
-- CHOIX 2 : user_fitness accède uniquement via vues
-- --------------------------------------------------
-- POURQUOI : Isolation des données par utilisateur
-- - Pas de privilèges directs sur les tables sensibles
-- - Accès uniquement aux catalogues (EXERCICE, REPAS) en lecture
-- - Accès aux données personnelles via vues filtrées (v_mes_seances, etc.)
-- ============================================


-- ============================================
-- ROLE_ADMIN : Accès complet
-- ============================================

GRANT SELECT, INSERT, UPDATE, DELETE ON "USER" TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON EXERCICE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON REPAS TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SEANCE_ENTRAINEMENT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON DETAILS_EXERCICE_SEANCE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON SUIVI_ALIMENTAIRE TO role_admin;


-- ============================================
-- ROLE_COACH : Entraînements UNIQUEMENT
-- ============================================
-- Accès en lecture : Profils utilisateurs + catalogue exercices
GRANT SELECT ON "USER" TO role_coach;
GRANT SELECT ON EXERCICE TO role_coach;

-- Gestion complète : Séances d'entraînement
GRANT SELECT, INSERT, UPDATE, DELETE ON SEANCE_ENTRAINEMENT TO role_coach;
GRANT SELECT, INSERT, UPDATE, DELETE ON DETAILS_EXERCICE_SEANCE TO role_coach;

-- PAS D'ACCÈS : REPAS, SUIVI_ALIMENTAIRE (séparation des responsabilités)


-- ============================================
-- ROLE_NUTRITIONNISTE : Nutrition UNIQUEMENT
-- ============================================
-- Accès en lecture : Profils utilisateurs + catalogue repas
GRANT SELECT ON "USER" TO role_nutritionniste;
GRANT SELECT ON REPAS TO role_nutritionniste;

-- Gestion complète : Suivi alimentaire
GRANT SELECT, INSERT, UPDATE, DELETE ON SUIVI_ALIMENTAIRE TO role_nutritionniste;

-- PAS D'ACCÈS : EXERCICE, SEANCE_ENTRAINEMENT, DETAILS_EXERCICE_SEANCE


-- ============================================
-- ROLE_UTILISATEUR : Catalogues + Vues uniquement
-- ============================================
-- Accès en lecture : Catalogues seulement
GRANT SELECT ON EXERCICE TO role_utilisateur;
GRANT SELECT ON REPAS TO role_utilisateur;

-- PAS D'ACCÈS direct aux tables sensibles (USER, SEANCE, DETAILS, SUIVI)
-- L'accès aux données personnelles se fait via les vues sécurisées
-- (voir fichier 07_vues_securisees.sql)

COMMIT;


-- ============================================
-- VERIFICATION
-- ============================================

SELECT grantee, table_name, privilege
FROM user_tab_privs_made
WHERE grantee LIKE 'ROLE_%'
ORDER BY grantee, table_name, privilege;

-- Résultat attendu : ~22 lignes de privilèges

-- FIN DU SCRIPT (PARTIE admin_fitness)