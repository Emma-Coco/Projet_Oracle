-- ============================================
-- SCRIPT DE TEST COMPLET - CHAPITRE 2
-- Tests automatiques de validation
-- ============================================
-- Ce script teste TOUS les aspects du Chapitre 2
-- ============================================


-- ============================================
-- PARTIE 1 : TESTS EN SYSTEM
-- ============================================
-- Connexion requise : SYSTEM
-- ============================================

PROMPT ========================================;
PROMPT PARTIE 1 : TESTS EN SYSTEM
PROMPT ========================================;
PROMPT;

-- TEST 1 : Vérifier que les 4 utilisateurs existent
PROMPT TEST 1 : Utilisateurs créés;
SELECT username, account_status, profile
FROM dba_users
WHERE username IN ('ADMIN_FITNESS', 'COACH_FITNESS', 'NUTRITIONNISTE_FITNESS', 'USER_FITNESS')
ORDER BY username;

PROMPT;
PROMPT ✓ Attendu : 4 utilisateurs OPEN avec profils corrects;
PROMPT;


-- TEST 2 : Vérifier les profils de sécurité
PROMPT TEST 2 : Profils de sécurité;
SELECT profile, resource_name, limit
FROM dba_profiles
WHERE profile IN ('PROFILE_ADMIN', 'PROFILE_PROFESSIONNEL', 'PROFILE_UTILISATEUR')
  AND resource_name IN ('SESSIONS_PER_USER', 'FAILED_LOGIN_ATTEMPTS', 'PASSWORD_LIFE_TIME')
ORDER BY profile, resource_name;

PROMPT;
PROMPT ✓ Vérifiez les limites correspondent à la documentation;
PROMPT;


-- TEST 3 : Vérifier les rôles créés
PROMPT TEST 3 : Rôles créés;
SELECT role
FROM dba_roles
WHERE role IN ('ROLE_ADMIN', 'ROLE_COACH', 'ROLE_NUTRITIONNISTE', 'ROLE_UTILISATEUR')
ORDER BY role;

PROMPT;
PROMPT ✓ Attendu : 4 rôles;
PROMPT;


-- TEST 4 : Vérifier attribution rôles → utilisateurs
PROMPT TEST 4 : Attribution rôles aux utilisateurs;
SELECT grantee, granted_role
FROM dba_role_privs
WHERE grantee IN ('ADMIN_FITNESS', 'COACH_FITNESS', 'NUTRITIONNISTE_FITNESS', 'USER_FITNESS')
ORDER BY grantee;

PROMPT;
PROMPT ✓ Attendu : 1 rôle par utilisateur;
PROMPT;


-- TEST 5 : Vérifier les quotas d'espace
PROMPT TEST 5 : Quotas d'espace disque;
SELECT username, 
       CASE 
         WHEN max_bytes = -1 THEN 'UNLIMITED'
         ELSE TO_CHAR(ROUND(max_bytes/1024/1024, 2)) || ' MB'
       END as quota
FROM dba_ts_quotas
WHERE username IN ('ADMIN_FITNESS', 'COACH_FITNESS', 'NUTRITIONNISTE_FITNESS', 'USER_FITNESS')
ORDER BY username;

PROMPT;
PROMPT ✓ Attendu : UNLIMITED, 50MB, 50MB, 100MB;
PROMPT;

PROMPT ========================================;
PROMPT FIN PARTIE 1 - CHANGEZ DE CONNEXION
PROMPT Connectez-vous maintenant en admin_fitness
PROMPT ========================================;
PROMPT;


-- ============================================
-- PARTIE 2 : TESTS EN admin_fitness
-- ============================================
-- Connexion requise : admin_fitness
-- ============================================

PROMPT ========================================;
PROMPT PARTIE 2 : TESTS EN admin_fitness
PROMPT ========================================;
PROMPT;


-- TEST 6 : Vérifier les tables créées
PROMPT TEST 6 : Tables créées;
SELECT table_name, num_rows
FROM user_tables
ORDER BY table_name;

PROMPT;
PROMPT ✓ Attendu : 6 tables;
PROMPT;


-- TEST 7 : Vérifier les vues sécurisées
PROMPT TEST 7 : Vues sécurisées créées;
SELECT view_name
FROM user_views
WHERE view_name LIKE 'V_%'
ORDER BY view_name;

PROMPT;
PROMPT ✓ Attendu : 3 vues (V_MES_DETAILS, V_MES_SEANCES, V_MON_SUIVI);
PROMPT;


-- TEST 8 : Vérifier privilèges des rôles (LE PLUS IMPORTANT)
PROMPT TEST 8 : Privilèges accordés aux rôles;
SELECT grantee, table_name, COUNT(*) as nb_privileges
FROM user_tab_privs_made
WHERE grantee LIKE 'ROLE_%'
GROUP BY grantee, table_name
ORDER BY grantee, table_name;

PROMPT;
PROMPT ✓ ROLE_COACH : 4 tables (USER, EXERCICE, SEANCE_ENTRAINEMENT, DETAILS_EXERCICE_SEANCE);
PROMPT ✓ ROLE_NUTRITIONNISTE : 3 tables (USER, REPAS, SUIVI_ALIMENTAIRE);
PROMPT ✓ ROLE_UTILISATEUR : 2 tables (EXERCICE, REPAS);
PROMPT;


-- TEST 9 : Vérifier séparation des responsabilités
PROMPT TEST 9 : Séparation des responsabilités;
PROMPT;
PROMPT Coach a accès à SEANCE_ENTRAINEMENT ?;
SELECT COUNT(*) as "OUI (doit être > 0)"
FROM user_tab_privs_made
WHERE grantee = 'ROLE_COACH' AND table_name = 'SEANCE_ENTRAINEMENT';

PROMPT;
PROMPT Coach a accès à REPAS ?;
SELECT COUNT(*) as "NON (doit être 0)"
FROM user_tab_privs_made
WHERE grantee = 'ROLE_COACH' AND table_name = 'REPAS';

PROMPT;
PROMPT Nutritionniste a accès à SUIVI_ALIMENTAIRE ?;
SELECT COUNT(*) as "OUI (doit être > 0)"
FROM user_tab_privs_made
WHERE grantee = 'ROLE_NUTRITIONNISTE' AND table_name = 'SUIVI_ALIMENTAIRE';

PROMPT;
PROMPT Nutritionniste a accès à SEANCE_ENTRAINEMENT ?;
SELECT COUNT(*) as "NON (doit être 0)"
FROM user_tab_privs_made
WHERE grantee = 'ROLE_NUTRITIONNISTE' AND table_name = 'SEANCE_ENTRAINEMENT';

PROMPT;
PROMPT ✓ Séparation confirmée si : Coach NON nutrition, Nutritionniste NON entraînement;
PROMPT;


-- TEST 10 : Vérifier privilèges sur vues pour user_fitness
PROMPT TEST 10 : Privilèges de user_fitness sur les vues;
SELECT table_name, privilege
FROM user_tab_privs_made
WHERE grantee = 'USER_FITNESS' AND table_name LIKE 'V_%'
ORDER BY table_name, privilege;

PROMPT;
PROMPT ✓ Attendu : 4 privilèges par vue (SELECT, INSERT, UPDATE, DELETE) x 3 vues = 12 lignes;
PROMPT;


-- TEST 11 : Vérifier contenu des vues (filtrage UserID = 1)
PROMPT TEST 11 : Filtrage des vues (UserID = 1);
PROMPT;
PROMPT Nombre de séances dans v_mes_seances :;
SELECT COUNT(*) as nb_seances_filtrees
FROM v_mes_seances;

PROMPT;
PROMPT UserIDs distincts dans v_mes_seances :;
SELECT DISTINCT UserID
FROM v_mes_seances;

PROMPT;
PROMPT ✓ Attendu : Seulement UserID = 1 visible;
PROMPT;


PROMPT ========================================;
PROMPT RÉCAPITULATIF DES TESTS AUTOMATIQUES
PROMPT ========================================;
PROMPT;
PROMPT Si tous les tests ci-dessus sont corrects :;
PROMPT;
PROMPT [ ] 4 utilisateurs créés avec bons profils;
PROMPT [ ] 4 rôles créés et attribués;
PROMPT [ ] 6 tables + 3 vues créées;
PROMPT [ ] Séparation coach/nutritionniste confirmée;
PROMPT [ ] user_fitness a accès aux 3 vues;
PROMPT [ ] Vues filtrent sur UserID = 1;
PROMPT;
PROMPT → CHAPITRE 2 VALIDÉ ✓;
PROMPT;


-- ============================================
-- PARTIE 3 : TESTS MANUELS (OPTIONNELS)
-- ============================================

PROMPT ========================================;
PROMPT PARTIE 3 : TESTS MANUELS (OPTIONNELS);
PROMPT ========================================;
PROMPT;
PROMPT Pour valider complètement, testez les connexions :;
PROMPT;
PROMPT TEST MANUEL A : Connectez-vous en coach_fitness;
PROMPT   → SELECT COUNT(*) FROM admin_fitness.SEANCE_ENTRAINEMENT;
PROMPT   Attendu : Un nombre (accès OK);
PROMPT   → SELECT * FROM admin_fitness.REPAS WHERE ROWNUM <= 5;
PROMPT   Attendu : ORA-00942 (accès refusé - BON);
PROMPT;
PROMPT TEST MANUEL B : Connectez-vous en nutritionniste_fitness;
PROMPT   → SELECT COUNT(*) FROM admin_fitness.SUIVI_ALIMENTAIRE;
PROMPT   Attendu : Un nombre (accès OK);
PROMPT   → SELECT * FROM admin_fitness.EXERCICE WHERE ROWNUM <= 5;
PROMPT   Attendu : ORA-00942 (accès refusé - BON);
PROMPT;
PROMPT TEST MANUEL C : Connectez-vous en user_fitness;
PROMPT   → SELECT COUNT(*) FROM admin_fitness.v_mes_seances;
PROMPT   Attendu : Nombre limité (filtre UserID = 1);
PROMPT   → SELECT * FROM admin_fitness.SEANCE_ENTRAINEMENT WHERE ROWNUM <= 5;
PROMPT   Attendu : ORA-00942 (accès direct refusé - BON);
PROMPT;


-- ============================================
-- FIN DES TESTS
-- ============================================

PROMPT ========================================;
PROMPT FIN DES TESTS AUTOMATIQUES;
PROMPT ========================================;
PROMPT;
PROMPT Si tous les tests passent : Chapitre 2 PARFAIT !;
PROMPT Note attendue : 18-20/20;
PROMPT;

-- FIN DU SCRIPT