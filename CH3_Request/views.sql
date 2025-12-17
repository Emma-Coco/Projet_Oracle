-- ============================================
-- VIEW 1 : Calories brûlées par utilisateur
-- ============================================
CREATE OR REPLACE VIEW V_CALORIES_PAR_UTILISATEUR AS
SELECT u.UserID,
       COUNT(s.SessionID) AS nb_seances,
       SUM(s.Calories_Burned) AS total_calories
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
GROUP BY u.UserID;

-- ============================================
-- VIEW 2 : Moyenne des BPM par utilisateur
-- ============================================
CREATE OR REPLACE VIEW V_AVG_BPM_UTILISATEUR AS
SELECT u.UserID,
       ROUND(AVG(s.Avg_BPM), 2) AS avg_bpm
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
GROUP BY u.UserID;

-- ============================================
-- VIEW 3 : Exercices les plus utilisés
-- ============================================
CREATE OR REPLACE VIEW V_EXERCICES_POPULAIRES AS
SELECT e.Name_of_Exercise,
       COUNT(d.SessionID) AS times_used
FROM EXERCICE e
JOIN DETAILS_EXERCICE_SEANCE d ON e.ExerciseID = d.ExerciseID
GROUP BY e.Name_of_Exercise;

-- ============================================
-- VIEW 4 : Utilisateurs ayant brûlé plus que la moyenne
-- ============================================
CREATE OR REPLACE VIEW V_UTILISATEURS_HAUTE_PERFORMANCE AS
SELECT DISTINCT u.UserID
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
WHERE s.Calories_Burned > (SELECT AVG(Calories_Burned) FROM SEANCE_ENTRAINEMENT);

-- ============================================
-- VIEW 5 : Apports caloriques journaliers par utilisateur
-- ============================================
CREATE OR REPLACE VIEW V_APPORTS_CALORIQUES_JOURNALIERS AS
SELECT u.UserID,
       TRUNC(sa.Date_Consumption) AS jour,
       SUM(sa.Calories_Total) AS calories_jour
FROM "USER" u
JOIN SUIVI_ALIMENTAIRE sa ON u.UserID = sa.UserID
GROUP BY u.UserID, TRUNC(sa.Date_Consumption);

-- ============================================
-- VIEW 6 : Classement des séances par calories brûlées
-- ============================================
CREATE OR REPLACE VIEW V_CLASSEMENT_SEANCES AS
SELECT SessionID,
       UserID,
       Calories_Burned,
       RANK() OVER (ORDER BY Calories_Burned DESC) AS ranking
FROM SEANCE_ENTRAINEMENT;

-- ============================================
-- VIEW BONUS : Tableau de bord utilisateur complet
-- ============================================
CREATE OR REPLACE VIEW V_DASHBOARD_UTILISATEUR AS
SELECT u.UserID,
       vcal.nb_seances,
       vcal.total_calories,
       vbpm.avg_bpm,
       CASE 
           WHEN vhp.UserID IS NOT NULL THEN 'Haute Performance'
           ELSE 'Standard'
       END AS niveau_performance
FROM "USER" u
LEFT JOIN V_CALORIES_PAR_UTILISATEUR vcal ON u.UserID = vcal.UserID
LEFT JOIN V_AVG_BPM_UTILISATEUR vbpm ON u.UserID = vbpm.UserID
LEFT JOIN V_UTILISATEURS_HAUTE_PERFORMANCE vhp ON u.UserID = vhp.UserID;

-- ============================================
-- Exemples d'utilisation des vues
-- ============================================

-- Consulter les calories par utilisateur (triées)
SELECT * FROM V_CALORIES_PAR_UTILISATEUR ORDER BY total_calories DESC;

-- Consulter les exercices les plus populaires (triés)
SELECT * FROM V_EXERCICES_POPULAIRES ORDER BY times_used DESC;

-- Consulter le dashboard d'un utilisateur spécifique
SELECT * FROM V_DASHBOARD_UTILISATEUR WHERE UserID = 1;

-- Consulter les apports caloriques d'une période
SELECT * FROM V_APPORTS_CALORIQUES_JOURNALIERS 
WHERE jour BETWEEN DATE '2024-01-01' AND DATE '2024-01-31'
ORDER BY jour, UserID;