-- ===========================================================
-- 05_PROFILS_ROLES_PRIVILEGES.SQL  (VERSION FINALE CORRIGÉE)
-- Projet ADBM - Application Fitness
-- Objectif : Créer les profils et rôles, et attribuer les privilèges
-- Compatibilité totale avec les vues sécurisées (06)
-- ===========================================================


-- ===========================================================
-- 1. Création des profils
-- ===========================================================

CREATE PROFILE profile_admin LIMIT
    SESSIONS_PER_USER UNLIMITED
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME 180;

CREATE PROFILE profile_professionnel LIMIT
    SESSIONS_PER_USER 3
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME 180;

CREATE PROFILE profile_utilisateur LIMIT
    SESSIONS_PER_USER 1
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 365;


-- ===========================================================
-- 2. Attribution des profils aux utilisateurs
-- ===========================================================

ALTER USER admin_fitness PROFILE profile_admin;
ALTER USER coach_fitness PROFILE profile_professionnel;
ALTER USER nutritionniste_fitness PROFILE profile_professionnel;
ALTER USER user_fitness PROFILE profile_utilisateur;


-- ===========================================================
-- 3. Création des rôles
-- ===========================================================

CREATE ROLE role_admin;
CREATE ROLE role_coach;
CREATE ROLE role_nutritionniste;
CREATE ROLE role_utilisateur;


-- ===========================================================
-- 4. Attribution des privilèges aux rôles
-- ===========================================================

---------------------------------------------------------------
-- 4.1 Rôle ADMIN : accès complet au schéma
---------------------------------------------------------------
GRANT CREATE SESSION TO role_admin;
GRANT CREATE TABLE TO role_admin;
GRANT ALTER ANY TABLE TO role_admin;
GRANT DROP ANY TABLE TO role_admin;

-- droits sur toutes les tables du schéma
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.USER TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.SEANCE_ENTRAINEMENT TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.DETAILS_EXERCICE_SEANCE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.SUIVI_ALIMENTAIRE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.EXERCICE TO role_admin;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.REPAS TO role_admin;


---------------------------------------------------------------
-- 4.2 Rôle COACH : accès aux données d'entraînement
---------------------------------------------------------------
GRANT CREATE SESSION TO role_coach;

GRANT SELECT ON admin_fitness.USER TO role_coach; 
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.SEANCE_ENTRAINEMENT TO role_coach;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.DETAILS_EXERCICE_SEANCE TO role_coach;

-- Accès en lecture seule aux catalogues
GRANT SELECT ON admin_fitness.EXERCICE TO role_coach;


---------------------------------------------------------------
-- 4.3 Rôle NUTRITIONNISTE : accès aux données alimentaires
---------------------------------------------------------------
GRANT CREATE SESSION TO role_nutritionniste;

GRANT SELECT ON admin_fitness.USER TO role_nutritionniste;
GRANT SELECT, INSERT, UPDATE, DELETE ON admin_fitness.SUIVI_ALIMENTAIRE TO role_nutritionniste;

GRANT SELECT ON admin_fitness.REPAS TO role_nutritionniste;


---------------------------------------------------------------
-- 4.4 Rôle UTILISATEUR (version compatible vues sécurisées)
---------------------------------------------------------------
GRANT CREATE SESSION TO role_utilisateur;

-- ❗ IMPORTANT ❗
-- NE PAS DONNER les privilèges directs sur les tables sensibles.
-- L'utilisateur doit passer exclusivement par les vues filtrées.
-- On lui donne seulement accès en lecture aux tables "catalogues".

GRANT SELECT ON admin_fitness.EXERCICE TO role_utilisateur;
GRANT SELECT ON admin_fitness.REPAS TO role_utilisateur;

-- Les accès aux vues (v_mes_seances, v_mon_suivi, v_mes_details)
-- sont gérés dans 06_vues_securisees.sql et non ici.


-- ===========================================================
-- 5. Attribution des rôles aux utilisateurs
-- ===========================================================

GRANT role_admin TO admin_fitness;
GRANT role_coach TO coach_fitness;
GRANT role_nutritionniste TO nutritionniste_fitness;
GRANT role_utilisateur TO user_fitness;


-- ===========================================================
-- FIN DU SCRIPT
-- ===========================================================
