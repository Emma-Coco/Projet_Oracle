-- ============================================
-- Requête 1 : Calories brûlées par utilisateur (jointure + agrégation)
 -- ============================================ 
 SELECT u.UserID,
       COUNT(s.SessionID) AS nb_seances,
       SUM(s.Calories_Burned) AS total_calories
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
GROUP BY u.UserID
ORDER BY total_calories DESC;

-- ============================================
-- Requête 2 : Moyenne des BPM par utilisateur (AVG)
 -- ============================================
 SELECT u.UserID,
       ROUND(AVG(s.Avg_BPM), 2) AS avg_bpm
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
GROUP BY u.UserID;

 
 -- ============================================
-- Requête 3 : Exercices les plus utilisés (COUNT + jointure)
 -- ============================================
 SELECT e.Name_of_Exercise,
       COUNT(d.SessionID) AS times_used
FROM EXERCICE e
JOIN DETAILS_EXERCICE_SEANCE d ON e.ExerciseID = d.ExerciseID
GROUP BY e.Name_of_Exercise
ORDER BY times_used DESC;

 -- ============================================
--  Requête 4 : Utilisateurs ayant brûlé plus que la moyenne (sous-requête)
 -- ============================================    
SELECT DISTINCT u.UserID
FROM "USER" u
JOIN SEANCE_ENTRAINEMENT s ON u.UserID = s.UserID
WHERE s.Calories_Burned >
      (SELECT AVG(Calories_Burned) FROM SEANCE_ENTRAINEMENT);


 -- ============================================
-- Requête 5 : Apports caloriques journaliers par utilisateur (SUM)
 -- ============================================
 SELECT u.UserID,
       TRUNC(sa.Date_Consumption) AS jour,
       SUM(sa.Calories_Total) AS calories_jour
FROM "USER" u
JOIN SUIVI_ALIMENTAIRE sa ON u.UserID = sa.UserID
GROUP BY u.UserID, TRUNC(sa.Date_Consumption)
ORDER BY jour;

 -- ============================================
-- Requête 6 : Classement des séances par calories brûlées (fonction analytique)
 -- ============================================
 
 SELECT SessionID,
       UserID,
       Calories_Burned,
       RANK() OVER (ORDER BY Calories_Burned DESC) AS ranking
FROM SEANCE_ENTRAINEMENT;

 -- ============================================
-- Optimisation
 -- ============================================
 
 -- Accélérer les recherches par date dans tes tables principales
CREATE INDEX idx_session_date ON SEANCE_ENTRAINEMENT(Session_Date);
CREATE INDEX idx_meal_date ON SUIVI_ALIMENTAIRE(Date_Consumption);

-- Accélérer les jointures par utilisateur
CREATE INDEX idx_userid_seance ON SEANCE_ENTRAINEMENT(UserID);
CREATE INDEX idx_userid_meal ON SUIVI_ALIMENTAIRE(UserID);
 
