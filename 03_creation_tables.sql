-- ============================================
-- CHAPITRE 1/2 : CRÉATION DES TABLES
-- Fichier : 03_creation_tables.sql
-- Connexion : admin_fitness
-- ============================================

-- ============================================
-- TABLE 1 : USER
-- ============================================

CREATE TABLE "USER" (
    UserID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Age NUMBER(3) NOT NULL CHECK (Age BETWEEN 10 AND 120),
    Gender VARCHAR2(10) CHECK (Gender IN ('Male', 'Female', 'Other')),
    Weight_kg NUMBER(5,2) CHECK (Weight_kg > 0),
    Height_m NUMBER(3,2) CHECK (Height_m BETWEEN 0.5 AND 3.0),
    Fat_Percentage NUMBER(4,2) CHECK (Fat_Percentage BETWEEN 0 AND 100),
    BMI NUMBER(4,2),
    Experience_Level VARCHAR2(20) CHECK (Experience_Level IN ('Beginner', 'Intermediate', 'Advanced')),
    Created_Date DATE DEFAULT SYSDATE
);

-- ============================================
-- TABLE 2 : EXERCICE
-- ============================================

CREATE TABLE EXERCICE (
    ExerciseID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    Name_of_Exercise VARCHAR2(100) NOT NULL UNIQUE,
    Difficulty_Level VARCHAR2(20) CHECK (Difficulty_Level IN ('Beginner', 'Intermediate', 'Advanced')),
    Target_Muscle_Group VARCHAR2(50),
    Body_Part VARCHAR2(50),
    Equipment_Needed VARCHAR2(50),
    Benefit VARCHAR2(200),
    Burns_Calories_per_30_min NUMBER(5,2) CHECK (Burns_Calories_per_30_min >= 0)
);

-- ============================================
-- TABLE 3 : SEANCE_ENTRAINEMENT
-- ============================================

CREATE TABLE SEANCE_ENTRAINEMENT (
    SessionID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID NUMBER NOT NULL,
    Session_Duration_hours NUMBER(4,2) CHECK (Session_Duration_hours > 0),
    Workout_Frequency_days_week NUMBER(1) CHECK (Workout_Frequency_days_week BETWEEN 1 AND 7),
    Workout_Type VARCHAR2(50),
    Calories_Burned NUMBER(6,2) CHECK (Calories_Burned >= 0),
    Max_BPM NUMBER(3) CHECK (Max_BPM BETWEEN 40 AND 220),
    Avg_BPM NUMBER(3) CHECK (Avg_BPM BETWEEN 40 AND 220),
    Resting_BPM NUMBER(3) CHECK (Resting_BPM BETWEEN 30 AND 120),
    Rating NUMBER(2) CHECK (Rating BETWEEN 1 AND 10),
    Is_Healthy VARCHAR2(3) CHECK (Is_Healthy IN ('Yes', 'No')),
    Session_Date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_seance_user FOREIGN KEY (UserID) REFERENCES "USER"(UserID) ON DELETE CASCADE
);

-- ============================================
-- TABLE 4 : DETAILS_EXERCICE_SEANCE
-- ============================================

CREATE TABLE DETAILS_EXERCICE_SEANCE (
    SessionID NUMBER NOT NULL,
    ExerciseID NUMBER NOT NULL,
    Sets NUMBER(2) CHECK (Sets > 0),
    Reps NUMBER(3) CHECK (Reps > 0),
    Workout VARCHAR2(50),
    PRIMARY KEY (SessionID, ExerciseID),
    CONSTRAINT fk_details_session FOREIGN KEY (SessionID) REFERENCES SEANCE_ENTRAINEMENT(SessionID) ON DELETE CASCADE,
    CONSTRAINT fk_details_exercise FOREIGN KEY (ExerciseID) REFERENCES EXERCICE(ExerciseID) ON DELETE CASCADE
);

-- ============================================
-- TABLE 5 : REPAS (avant SUIVI_ALIMENTAIRE car FK)
-- ============================================

CREATE TABLE REPAS (
    MealID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    meal_name VARCHAR2(100) NOT NULL,
    meal_type VARCHAR2(50) CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
    diet_type VARCHAR2(50),
    cooking_method VARCHAR2(50),
    prep_time_min NUMBER(4) CHECK (prep_time_min >= 0),
    cook_time_min NUMBER(4) CHECK (cook_time_min >= 0)
);

-- ============================================
-- TABLE 6 : SUIVI_ALIMENTAIRE
-- ============================================

CREATE TABLE SUIVI_ALIMENTAIRE (
    RecordID NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    UserID NUMBER NOT NULL,
    MealID NUMBER NOT NULL,
    Date_Consumption DATE DEFAULT SYSDATE,
    serving_size_g NUMBER(6,2) CHECK (serving_size_g > 0),
    Daily_meals_frequency NUMBER(2) CHECK (Daily_meals_frequency BETWEEN 1 AND 10),
    Water_Intake_liters NUMBER(4,2) CHECK (Water_Intake_liters >= 0),
    Calories_Total NUMBER(6,2) CHECK (Calories_Total >= 0),
    Carbs NUMBER(6,2) CHECK (Carbs >= 0),
    Proteins NUMBER(6,2) CHECK (Proteins >= 0),
    Fats NUMBER(6,2) CHECK (Fats >= 0),
    sugar_g NUMBER(6,2) CHECK (sugar_g >= 0),
    sodium_mg NUMBER(6,2) CHECK (sodium_mg >= 0),
    cholesterol_mg NUMBER(6,2) CHECK (cholesterol_mg >= 0),
    CONSTRAINT fk_suivi_user FOREIGN KEY (UserID) REFERENCES "USER"(UserID) ON DELETE CASCADE,
    CONSTRAINT fk_suivi_meal FOREIGN KEY (MealID) REFERENCES REPAS(MealID) ON DELETE CASCADE
);

-- ============================================
-- VÉRIFICATIONS
-- ============================================

PROMPT ========================================
PROMPT Tables créées :
PROMPT ========================================

SELECT table_name 
FROM user_tables 
ORDER BY table_name;

PROMPT ========================================
PROMPT Contraintes d intégrité :
PROMPT ========================================

SELECT constraint_name, constraint_type, table_name
FROM user_constraints
ORDER BY table_name, constraint_type;

PROMPT ========================================
PROMPT Création des tables terminée !
PROMPT Prochaine étape : insertion de données
PROMPT ========================================