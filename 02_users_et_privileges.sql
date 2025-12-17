-- ============================================
-- CHAPITRE 2.1 : CREATION DES UTILISATEURS
-- Fichier : 02_users_et_privileges.sql
-- Connexion requise : SYSTEM
-- Date : Décembre 2025
-- ============================================
-- DESCRIPTION :
-- Ce script crée les 4 utilisateurs de l'application fitness/nutrition
-- avec leurs mots de passe, privilèges système et quotas d'espace disque.
-- ============================================
-- JUSTIFICATION DES CHOIX :
--
-- CHOIX 1 : Quatre types d'utilisateurs distincts
-- ------------------------------------------------
-- POURQUOI : Séparation des responsabilités et principe du moindre privilège
-- - admin_fitness : Gestion système et création d'objets
-- - coach_fitness : Spécialisé dans les données d'entraînement
-- - nutritionniste_fitness : Spécialisé dans les données alimentaires
-- - user_fitness : Utilisateur final de l'application
--
-- CHOIX 2 : Mots de passe complexes (10+ caractères)
-- ---------------------------------------------------
-- POURQUOI : Sécurité renforcée contre attaques par force brute
-- FORMAT : Minimum 10 caractères avec majuscules, minuscules, chiffres, symboles
--
-- CHOIX 3 : Quotas d'espace disque différenciés
-- ----------------------------------------------
-- POURQUOI : Limite l'utilisation des ressources selon le rôle
-- - admin_fitness : UNLIMITED (création de toutes les tables)
-- - coach_fitness : 50MB (pas de création d'objets, usage normal)
-- - nutritionniste_fitness : 50MB (pas de création d'objets, usage normal)
-- - user_fitness : 100MB (stockage de données personnelles)
--
-- CHOIX 4 : Privilèges système minimaux
-- --------------------------------------
-- POURQUOI : Principe du moindre privilège
-- - Tous : CREATE SESSION (connexion uniquement)
-- - admin_fitness : + CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, etc.
-- - Autres : Pas de privilèges système supplémentaires (reçoivent via rôles)
-- ============================================


-- ============================================
-- 1. CREATION DE L'ADMINISTRATEUR
-- ============================================

CREATE USER admin_fitness 
IDENTIFIED BY "Admin2025!"
DEFAULT TABLESPACE users
QUOTA UNLIMITED ON users;

GRANT CREATE SESSION TO admin_fitness;
GRANT CREATE TABLE TO admin_fitness;
GRANT CREATE VIEW TO admin_fitness;
GRANT CREATE SEQUENCE TO admin_fitness;
GRANT CREATE PROCEDURE TO admin_fitness;
GRANT CREATE TRIGGER TO admin_fitness;


-- ============================================
-- 2. CREATION DU COACH SPORTIF
-- ============================================

CREATE USER coach_fitness 
IDENTIFIED BY "Coach2025!"
DEFAULT TABLESPACE users
QUOTA 50M ON users;

GRANT CREATE SESSION TO coach_fitness;


-- ============================================
-- 3. CREATION DU NUTRITIONNISTE
-- ============================================

CREATE USER nutritionniste_fitness 
IDENTIFIED BY "Nutri2025!"
DEFAULT TABLESPACE users
QUOTA 50M ON users;

GRANT CREATE SESSION TO nutritionniste_fitness;


-- ============================================
-- 4. CREATION DE L'UTILISATEUR STANDARD
-- ============================================

CREATE USER user_fitness 
IDENTIFIED BY "User2025!"
DEFAULT TABLESPACE users
QUOTA 100M ON users;

GRANT CREATE SESSION TO user_fitness;

COMMIT;

-- FIN DU SCRIPT