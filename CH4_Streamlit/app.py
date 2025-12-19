import streamlit as st
import oracledb
import pandas as pd
from PIL import Image
import plotly.express as px

st.set_page_config(page_title="Oracle Fitness Dashboard - Projet", layout="wide")

try:
    image = Image.open('logo.png')
    col1, col2 = st.columns([1, 3])
    with col1:
        st.image(image, use_container_width=True)
    with col2:
        st.title("Oracle Fitness Dashboard - Projet")
except:
    st.title("Oracle Fitness Dashboard - Projet")

st.divider()

@st.cache_resource
def get_connection():
    return oracledb.connect(
        user="system",
        password="MonNouveauPassword123",
        dsn="localhost:1521/xe"
    )


@st.cache_data
def load_data():
    conn = get_connection()
    
    query_activity = """
        SELECT s.*, u.EXPERIENCE_LEVEL, u.BMI, u.FAT_PERCENTAGE, u.WEIGHT_KG
        FROM SEANCE_ENTRAINEMENT s
        JOIN "USER" u ON s.USERID = u.USERID
    """
    df_act = pd.read_sql(query_activity, conn)
    
    query_nutrition = """
        SELECT sa.*, u.WEIGHT_KG, u.FAT_PERCENTAGE
        FROM SUIVI_ALIMENTAIRE sa
        JOIN "USER" u ON sa.USERID = u.USERID
    """
    df_nut = pd.read_sql(query_nutrition, conn)
    
    query_reps = """
        SELECT d.REPS, u.EXPERIENCE_LEVEL
        FROM DETAILS_EXERCICE_SEANCE d
        JOIN SEANCE_ENTRAINEMENT s ON d.SESSIONID = s.SESSIONID
        JOIN "USER" u ON s.USERID = u.USERID
    """
    df_reps = pd.read_sql(query_reps, conn)
    
    return df_act, df_nut, df_reps

try:
    df_act, df_nut, df_reps = load_data()
    
    st.success("Connexion établie avec succès à la base de données Oracle")

    df_nut["lean_mass_kg"] = df_nut["WEIGHT_KG"] * (1 - (df_nut["FAT_PERCENTAGE"] / 100))
    df_nut["protein_per_kg"] = df_nut["PROTEINS"] / df_nut["WEIGHT_KG"]

    tab1, tab2, tab3, tab4 = st.tabs(["Performance", "Nutrition", "Santé", "KPI"])

    with tab1:
        st.subheader("Performance et Intensité")
        st.line_chart(data=df_act.sort_values(by="SESSION_DURATION_HOURS"), 
                     x="SESSION_DURATION_HOURS", y="CALORIES_BURNED", color="WORKOUT_TYPE")
        
        c1, c2 = st.columns(2)
        with c1:
            df_m = df_act.groupby('EXPERIENCE_LEVEL')['CALORIES_BURNED'].mean().reset_index()
            ordre_experience = ["Beginner", "Intermediate", "Advanced"]

            st.plotly_chart(px.bar(
                df_m, 
                x='EXPERIENCE_LEVEL', 
                y='CALORIES_BURNED', 
                color='EXPERIENCE_LEVEL', 
                title="Moyenne Calories/Niveau",
                category_orders={"EXPERIENCE_LEVEL": ordre_experience}
            ), use_container_width=True)
            
        with c2:
            st.plotly_chart(px.box(
                    df_reps, 
                    x='EXPERIENCE_LEVEL', 
                    y='REPS', 
                    color='EXPERIENCE_LEVEL', 
                    title="Distribution des Reps par Niveau",
                    category_orders={"EXPERIENCE_LEVEL": ordre_experience}
                ), use_container_width=True)

    with tab2:
        st.subheader("Analyse Nutritionnelle")
        macros = ["CARBS", "PROTEINS", "FATS"]
        totals = df_nut[macros].sum().reset_index()
        totals.columns = ['Nutriment', 'Valeur']
        st.plotly_chart(px.pie(totals, values='Valeur', names='Nutriment', hole=0.4, title="Répartition Globale Macros"), use_container_width=True)

        st.plotly_chart(px.bar(df_nut.sort_values('protein_per_kg'), x='protein_per_kg', y='lean_mass_kg', 
                               color='lean_mass_kg', title="Protéines vs Masse Maigre"), use_container_width=True)

    with tab3:
        st.subheader("Équilibre Corporel")
        st.line_chart(df_act.sort_values(by="BMI"), x="BMI", y="FAT_PERCENTAGE")
        
        cols_corr = ["CALORIES_BURNED", "SESSION_DURATION_HOURS", "AVG_BPM", "FAT_PERCENTAGE", "BMI"]
        existing = [c for c in cols_corr if c in df_act.columns]
        corr = df_act[existing].apply(pd.to_numeric, errors='coerce').corr()
        st.plotly_chart(px.imshow(corr, text_auto=".2f", color_continuous_scale='RdBu_r', title="Matrice de Corrélation"), use_container_width=True)

    with tab4:
        st.subheader("Statistiques Globales")
        k1, k2, k3, k4 = st.columns(4)
        k1.metric(" Moyenne des calories", f"{df_act['CALORIES_BURNED'].mean():.1f}")
        k2.metric("Moyenne de la durée", f"{df_act['SESSION_DURATION_HOURS'].mean():.2f}h")
        k3.metric("Moyenne des BPM", f"{df_act['AVG_BPM'].mean():.0f}")
        k4.metric("Moyenne de l'IMC", f"{df_act['BMI'].mean():.1f}")

except Exception as e:
    st.error(f"Erreur de connexion : {e}")