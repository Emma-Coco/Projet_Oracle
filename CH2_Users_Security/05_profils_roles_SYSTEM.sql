-- ============================================
-- CHAPITRE 2.2 : PROFILS ET ROLES (PARTIE SYSTEM)
-- Fichier : 05_profils_roles_SYSTEM.sql
-- Connexion requise : SYSTEM
-- Date : Décembre 2025
-- ============================================
-- DESCRIPTION :
-- Ce script crée les profils de sécurité et les rôles fonctionnels,
-- puis les attribue aux utilisateurs.
-- Les privilèges sur les tables sont attribués dans le script suivant
-- (06_privileges_aux_roles.sql) qui s'exécute en admin_fitness.
-- ============================================


-- ============================================
-- PARTIE 1 : CREATION DES PROFILS
-- ============================================

-- Profil administrateur : Sécurité maximale avec flexibilité opérationnelle
CREATE PROFILE profile_admin LIMIT
    SESSIONS_PER_USER UNLIMITED
    FAILED_LOGIN_ATTEMPTS 5
    PASSWORD_LIFE_TIME 90;

-- Profil professionnel : Équilibre sécurité/productivité
CREATE PROFILE profile_professionnel LIMIT
    SESSIONS_PER_USER 5
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 90;

-- Profil utilisateur standard : Sécurité renforcée
CREATE PROFILE profile_utilisateur LIMIT
    SESSIONS_PER_USER 3
    FAILED_LOGIN_ATTEMPTS 3
    PASSWORD_LIFE_TIME 180;


-- ============================================
-- PARTIE 2 : APPLICATION DES PROFILS
-- ============================================

ALTER USER admin_fitness PROFILE profile_admin;
ALTER USER coach_fitness PROFILE profile_professionnel;
ALTER USER nutritionniste_fitness PROFILE profile_professionnel;
ALTER USER user_fitness PROFILE profile_utilisateur;


-- ============================================
-- PARTIE 3 : CREATION DES ROLES
-- ============================================

CREATE ROLE role_admin;
CREATE ROLE role_coach;
CREATE ROLE role_nutritionniste;
CREATE ROLE role_utilisateur;


-- ============================================
-- PARTIE 4 : ATTRIBUTION DES ROLES AUX UTILISATEURS
-- ============================================

GRANT role_admin TO admin_fitness;
GRANT role_coach TO coach_fitness;
GRANT role_nutritionniste TO nutritionniste_fitness;
GRANT role_utilisateur TO user_fitness;

COMMIT;

-- FIN DU SCRIPT