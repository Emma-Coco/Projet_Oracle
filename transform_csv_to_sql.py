#!/usr/bin/env python3
"""
GÉNÉRATEUR SQL - Insertion des données Final_data.csv dans Oracle
=================================================================

Ce script génère un fichier SQL d'insertion pour la base de données Oracle
à partir du fichier Final_data.csv.

Prérequis:
- Python 3.x
- pandas (pip install pandas)
- Fichier Final_data.csv dans le même répertoire
- Fichier 03_creation_tables.sql dans le même répertoire

Usage:
    python3 generate_insertion_sql.py

Sortie:
    04_insertion_donnees.sql - Script SQL prêt à être exécuté
"""

import pandas as pd
import os

def escape_sql(value):
    """Échappe les valeurs pour SQL"""
    if pd.isna(value):
        return "NULL"
    if isinstance(value, (int, float)):
        return str(value)
    # Échappe les apostrophes
    return "'{}'".format(str(value).replace("'", "''"))

def round_float(value, decimals=2):
    """Arrondit un float ou retourne NULL"""
    if pd.isna(value):
        return "NULL"
    return round(float(value), decimals)

def map_experience_level(value):
    """
    Mappe les valeurs numériques Experience_Level vers texte
    1.x -> 'Beginner'
    2.x -> 'Intermediate' 
    3.x -> 'Advanced'
    """
    if pd.isna(value):
        return 'Beginner'
    val = float(value)
    if val < 2.0:
        return 'Beginner'
    elif val < 3.0:
        return 'Intermediate'
    else:
        return 'Advanced'

def generate_is_healthy(physical_exercise):
    """
    Génère Is_Healthy depuis Physical exercise
    > 0 -> 'Yes', sinon 'No'
    """
    if pd.isna(physical_exercise):
        return 'No'
    return 'Yes' if physical_exercise > 0 else 'No'

# ============================================
# CHARGEMENT DES DONNÉES
# ============================================

print("=" * 70)
print("GÉNÉRATEUR SQL - Insertion des données Final_data.csv")
print("=" * 70)

# Vérifier que Final_data.csv existe
if not os.path.exists('Final_data.csv'):
    print("ERREUR: Final_data.csv introuvable dans le répertoire courant")
    exit(1)

# Vérifier que 03_creation_tables.sql existe
if not os.path.exists('03_creation_tables.sql'):
    print("ERREUR: 03_creation_tables.sql introuvable dans le répertoire courant")
    exit(1)

print("\nLecture du CSV...")
df = pd.read_csv('Final_data.csv')
print(f"✓ {len(df)} lignes chargées")

# ============================================
# DÉDUPLICATION EXERCICE ET REPAS
# ============================================

print("\n📊 Déduplication des exercices et repas...")

# Exercices uniques (basé sur Name of Exercise)
exercises = {}
for _, row in df.iterrows():
    ex_name = row['Name of Exercise']
    if ex_name not in exercises:
        exercises[ex_name] = {
            'name': ex_name,
            'difficulty': row['Difficulty Level'],
            'muscle': row['Target Muscle Group'],
            'body_part': row['Body Part'],
            'equipment': row['Equipment Needed'],
            'benefit': row['Benefit'],
            'calories': round_float(row['Burns Calories (per 30 min)'], 2)
        }

# Repas uniques (basé sur meal_name + meal_type + diet_type)
meals = {}
for _, row in df.iterrows():
    meal_key = (row['meal_name'], row['meal_type'], row['diet_type'])
    if meal_key not in meals:
        meals[meal_key] = {
            'name': row['meal_name'],
            'type': row['meal_type'],
            'diet': row['diet_type'],
            'cooking': row['cooking_method'],
            'prep_time': round_float(row['prep_time_min'], 2),
            'cook_time': round_float(row['cook_time_min'], 2)
        }

print(f"✓ {len(exercises)} exercices uniques")
print(f"✓ {len(meals)} repas uniques")

# ============================================
# GÉNÉRATION DU SCRIPT SQL
# ============================================

output_file = '04_insertion_donnees.sql'
COMMIT_INTERVAL = 1000  # COMMIT tous les 1000 INSERT

print(f"\n  Génération du script SQL: {output_file}")

with open(output_file, 'w', encoding='utf-8') as f:
    
    # ========== HEADER ==========
    f.write("-- ============================================\n")
    f.write("-- SCRIPT D'INSERTION - Base de données Fitness\n")
    f.write(f"-- Généré automatiquement pour {len(df)} lignes\n")
    f.write("-- ============================================\n\n")
    f.write("SET SERVEROUTPUT ON;\n")
    f.write("SET TIMING ON;\n")
    f.write("SET ECHO OFF;\n\n")
    
    # ========== NETTOYAGE ==========
    f.write("PROMPT === ÉTAPE 1/7 : Nettoyage ===\n")
    f.write("PURGE RECYCLEBIN;\n")
    f.write("DROP TABLE SUIVI_ALIMENTAIRE CASCADE CONSTRAINTS;\n")
    f.write("DROP TABLE DETAILS_EXERCICE_SEANCE CASCADE CONSTRAINTS;\n")
    f.write("DROP TABLE SEANCE_ENTRAINEMENT CASCADE CONSTRAINTS;\n")
    f.write("DROP TABLE REPAS CASCADE CONSTRAINTS;\n")
    f.write("DROP TABLE EXERCICE CASCADE CONSTRAINTS;\n")
    f.write('DROP TABLE "USER" CASCADE CONSTRAINTS;\n')
    f.write("PURGE RECYCLEBIN;\n\n")
    
    # ========== CRÉATION DES TABLES ==========
    f.write("PROMPT === ÉTAPE 2/7 : Création des tables ===\n")
    with open('03_creation_tables.sql', 'r', encoding='utf-8') as create_file:
        f.write(create_file.read())
    f.write("\n\n")
    
    # ========== DÉSACTIVATION DES CONTRAINTES FK ==========
    f.write("PROMPT === ÉTAPE 3/7 : Désactivation des contraintes FK ===\n")
    f.write("ALTER TABLE SEANCE_ENTRAINEMENT DISABLE CONSTRAINT fk_seance_user;\n")
    f.write("ALTER TABLE DETAILS_EXERCICE_SEANCE DISABLE CONSTRAINT fk_details_session;\n")
    f.write("ALTER TABLE DETAILS_EXERCICE_SEANCE DISABLE CONSTRAINT fk_details_exercise;\n")
    f.write("ALTER TABLE SUIVI_ALIMENTAIRE DISABLE CONSTRAINT fk_suivi_user;\n")
    f.write("ALTER TABLE SUIVI_ALIMENTAIRE DISABLE CONSTRAINT fk_suivi_meal;\n\n")
    
    # ========== INSERT EXERCICES ==========
    f.write(f"PROMPT === ÉTAPE 4/7 : Insertion de {len(exercises)} exercices ===\n")
    for ex in exercises.values():
        f.write(f"INSERT INTO EXERCICE (Name_of_Exercise, Difficulty_Level, Target_Muscle_Group, Body_Part, Equipment_Needed, Benefit, Burns_Calories_per_30_min) ")
        f.write(f"VALUES ({escape_sql(ex['name'])}, {escape_sql(ex['difficulty'])}, {escape_sql(ex['muscle'])}, ")
        f.write(f"{escape_sql(ex['body_part'])}, {escape_sql(ex['equipment'])}, {escape_sql(ex['benefit'])}, {ex['calories']});\n")
    f.write("COMMIT;\n\n")
    
    # ========== INSERT REPAS ==========
    f.write(f"PROMPT === ÉTAPE 4/7 : Insertion de {len(meals)} repas ===\n")
    for meal in meals.values():
        f.write(f"INSERT INTO REPAS (meal_name, meal_type, diet_type, cooking_method, prep_time_min, cook_time_min) ")
        f.write(f"VALUES ({escape_sql(meal['name'])}, {escape_sql(meal['type'])}, {escape_sql(meal['diet'])}, ")
        f.write(f"{escape_sql(meal['cooking'])}, {meal['prep_time']}, {meal['cook_time']});\n")
    f.write("COMMIT;\n\n")
    
    # ========== INSERT USERS ==========
    f.write(f"PROMPT === ÉTAPE 5/7 : Insertion de {len(df)} utilisateurs ===\n")
    for idx, row in df.iterrows():
        f.write(f"INSERT INTO \"USER\" (Age, Gender, Weight_kg, Height_m, Fat_Percentage, BMI, Experience_Level) ")
        f.write(f"VALUES ({round_float(row['Age'])}, {escape_sql(row['Gender'])}, ")
        f.write(f"{round_float(row['Weight (kg)'])}, {round_float(row['Height (m)'])}, ")
        f.write(f"{round_float(row['Fat_Percentage'])}, {round_float(row['BMI'])}, ")
        f.write(f"{escape_sql(map_experience_level(row['Experience_Level']))});\n")
        
        if (idx + 1) % COMMIT_INTERVAL == 0:
            f.write(f"COMMIT; -- {idx + 1} users insérés\n")
    f.write("COMMIT;\n\n")
    
    # ========== INSERT SEANCES D'ENTRAINEMENT ==========
    f.write(f"PROMPT === ÉTAPE 5/7 : Insertion de {len(df)} séances d'entraînement ===\n")
    for idx, row in df.iterrows():
        user_id = idx + 1  # UserID correspond à l'ordre d'insertion
        
        # Gestion de Rating (peut être NULL)
        rating_val = row.get('rating', None)
        rating_str = "NULL" if pd.isna(rating_val) else str(round_float(rating_val, 0))
        
        # Génération de Is_Healthy depuis Physical exercise
        is_healthy = generate_is_healthy(row.get('Physical exercise', 0))
        
        f.write(f"INSERT INTO SEANCE_ENTRAINEMENT (UserID, Session_Duration_hours, Workout_Frequency_days_week, Workout_Type, Calories_Burned, Max_BPM, Avg_BPM, Resting_BPM, Rating, Is_Healthy) ")
        f.write(f"VALUES ({user_id}, {round_float(row['Session_Duration (hours)'])}, {round_float(row['Workout_Frequency (days/week)'], 0)}, ")
        f.write(f"{escape_sql(row['Workout_Type'])}, {round_float(row['Calories_Burned'])}, ")
        f.write(f"{round_float(row['Max_BPM'], 0)}, {round_float(row['Avg_BPM'], 0)}, {round_float(row['Resting_BPM'], 0)}, ")
        f.write(f"{rating_str}, {escape_sql(is_healthy)});\n")
        
        if (idx + 1) % COMMIT_INTERVAL == 0:
            f.write(f"COMMIT; -- {idx + 1} séances insérées\n")
    f.write("COMMIT;\n\n")
    
    # ========== INSERT DETAILS EXERCICE SEANCE ==========
    f.write(f"PROMPT === ÉTAPE 6/7 : Insertion de {len(df)} détails exercices ===\n")
    for idx, row in df.iterrows():
        session_id = idx + 1  # SessionID correspond à l'ordre d'insertion
        f.write(f"INSERT INTO DETAILS_EXERCICE_SEANCE (SessionID, ExerciseID, Sets, Reps, Workout) ")
        f.write(f"VALUES ({session_id}, ")
        f.write(f"(SELECT ExerciseID FROM EXERCICE WHERE Name_of_Exercise = {escape_sql(row['Name of Exercise'])} AND ROWNUM = 1), ")
        f.write(f"{round_float(row['Sets'], 0)}, {round_float(row['Reps'], 0)}, {escape_sql(row['Workout'])});\n")
        
        if (idx + 1) % COMMIT_INTERVAL == 0:
            f.write(f"COMMIT; -- {idx + 1} détails insérés\n")
    f.write("COMMIT;\n\n")
    
    # ========== INSERT SUIVI ALIMENTAIRE ==========
    f.write(f"PROMPT === ÉTAPE 6/7 : Insertion de {len(df)} suivis alimentaires ===\n")
    for idx, row in df.iterrows():
        user_id = idx + 1  # UserID correspond à l'ordre d'insertion
        f.write(f"INSERT INTO SUIVI_ALIMENTAIRE (UserID, MealID, serving_size_g, Daily_meals_frequency, Water_Intake_liters, Calories_Total, Carbs, Proteins, Fats, sugar_g, sodium_mg, cholesterol_mg) ")
        f.write(f"VALUES ({user_id}, ")
        f.write(f"(SELECT MealID FROM REPAS WHERE meal_name = {escape_sql(row['meal_name'])} AND meal_type = {escape_sql(row['meal_type'])} AND diet_type = {escape_sql(row['diet_type'])} AND ROWNUM = 1), ")
        f.write(f"{round_float(row['serving_size_g'])}, {round_float(row['Daily meals frequency'], 0)}, ")
        f.write(f"{round_float(row['Water_Intake (liters)'])}, {round_float(row['Calories'])}, ")
        f.write(f"{round_float(row['Carbs'])}, {round_float(row['Proteins'])}, {round_float(row['Fats'])}, ")
        f.write(f"{round_float(row['sugar_g'])}, {round_float(row['sodium_mg'])}, {round_float(row['cholesterol_mg'])});\n")
        
        if (idx + 1) % COMMIT_INTERVAL == 0:
            f.write(f"COMMIT; -- {idx + 1} suivis insérés\n")
    f.write("COMMIT;\n\n")
    
    # ========== RÉACTIVATION DES CONTRAINTES FK ==========
    f.write("PROMPT === ÉTAPE 7/7 : Réactivation des contraintes FK ===\n")
    f.write("ALTER TABLE SEANCE_ENTRAINEMENT ENABLE CONSTRAINT fk_seance_user;\n")
    f.write("ALTER TABLE DETAILS_EXERCICE_SEANCE ENABLE CONSTRAINT fk_details_session;\n")
    f.write("ALTER TABLE DETAILS_EXERCICE_SEANCE ENABLE CONSTRAINT fk_details_exercise;\n")
    f.write("ALTER TABLE SUIVI_ALIMENTAIRE ENABLE CONSTRAINT fk_suivi_user;\n")
    f.write("ALTER TABLE SUIVI_ALIMENTAIRE ENABLE CONSTRAINT fk_suivi_meal;\n\n")
    
    # ========== VÉRIFICATION ==========
    f.write("PROMPT === VÉRIFICATION FINALE ===\n")
    f.write("SELECT 'USER: ' || COUNT(*) FROM \"USER\";\n")
    f.write("SELECT 'EXERCICE: ' || COUNT(*) FROM EXERCICE;\n")
    f.write("SELECT 'REPAS: ' || COUNT(*) FROM REPAS;\n")
    f.write("SELECT 'SEANCE_ENTRAINEMENT: ' || COUNT(*) FROM SEANCE_ENTRAINEMENT;\n")
    f.write("SELECT 'DETAILS_EXERCICE_SEANCE: ' || COUNT(*) FROM DETAILS_EXERCICE_SEANCE;\n")
    f.write("SELECT 'SUIVI_ALIMENTAIRE: ' || COUNT(*) FROM SUIVI_ALIMENTAIRE;\n\n")
    f.write("PROMPT === INSERTION TERMINÉE ===\n")

file_size_mb = os.path.getsize(output_file) / (1024 * 1024)

print(f"  Script SQL généré avec succès!")
print(f"   Fichier: {output_file}")
print(f"   Taille: {file_size_mb:.1f} MB")
print(f"\n  Pour exécuter:")
print(f"   sqlplus admin_fitness/password@//localhost:1521/XEPDB1 @{output_file}")
print("\n" + "=" * 70)