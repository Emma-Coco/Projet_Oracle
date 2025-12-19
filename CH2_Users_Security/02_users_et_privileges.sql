-- ============================================
-- CHAPITRE 2.1 : CREATION DES UTILISATEURS
-- Connexion requise : SYSTEM
-- Date : Décembre 2025
-- ============================================
-- DESCRIPTION :
-- Ce script crée les quatre utilisateurs Oracle de l'application
-- fitness / nutrition, en définissant leurs mots de passe,
-- tablespaces, quotas d’espace disque et privilèges système
-- nécessaires à la connexion.
--
-- L’administrateur dispose de privilèges étendus pour la gestion
-- du schéma, tandis que les autres utilisateurs disposent
-- uniquement du privilège CREATE SESSION.
-- Les rôles applicatifs sont attribués dans un script séparé.
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