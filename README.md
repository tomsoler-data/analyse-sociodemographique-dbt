# Analyse sociodémographique d’étudiants Data

Projet de transformation et d’analyse de données réalisé dans le cadre de ma formation Data Analyst chez OpenClassrooms.

L’objectif est d’étudier l’évolution du profil sociodémographique des étudiants suivant une formation Data et de comparer leur répartition avec les données démographiques de l’INSEE.

## Objectifs du projet

- Nettoyer et standardiser les données étudiantes
- Préparer les données démographiques de l’INSEE
- Structurer les transformations avec dbt
- Contrôler la qualité et la cohérence des données
- Analyser les évolutions par année, genre, tranche d’âge et région
- Produire une table finale exploitable pour l’analyse et la visualisation

## Technologies utilisées

- Python
- pandas
- Jupyter Notebook
- SQL
- Snowflake
- dbt
- YAML
- Git
- Visual Studio Code

## Préparation des données avec Python

Avant leur chargement dans Snowflake, les données démographiques de l’INSEE sont préparées avec Python et pandas.

Cette étape permet de :

- sélectionner les années 2022 à 2025 ;
- conserver les régions utiles à l’analyse ;
- harmoniser les noms des régions ;
- transformer les données au format long ;
- aligner les tranches d’âge avec celles des données étudiantes ;
- regrouper les populations âgées de 60 ans ou plus ;
- effectuer des contrôles de cohérence ;
- exporter un fichier prêt à être chargé dans Snowflake.

➡️ [Consulter le notebook de préparation](notebooks/01_prepare_insee_population.ipynb)

## Architecture du projet

Le workflow est organisé en plusieurs couches.

### Staging

Les modèles de staging préparent et standardisent les données brutes.

- `stg_students` : nettoyage et standardisation des données étudiantes
- `stg_insee_population` : préparation des données démographiques de l’INSEE

### Intermediate

Les modèles intermédiaires consolident les données selon les dimensions utiles à l’analyse.

- `int_students_by_profile`
- `int_insee_population_by_profile`

Les principales dimensions utilisées sont :

- l’année ;
- la région ;
- le genre ;
- la tranche d’âge.

### Marts

Le modèle final rassemble les indicateurs nécessaires à l’analyse.

- `mart_sociodemographic_comparison`

Il permet notamment de comparer le nombre d’étudiants observés avec la population de référence et de calculer un indicateur de représentation.

## Qualité des données

Des tests dbt sont mis en place dans les fichiers YAML afin de vérifier notamment :

- l’absence de valeurs nulles sur les colonnes essentielles ;
- la validité des valeurs de genre ;
- la cohérence des dimensions utilisées ;
- la fiabilité des données produites par les modèles.

## Analyses réalisées

Le projet permet d’étudier :

- l’évolution du nombre d’étudiants entre 2022 et 2025 ;
- la répartition des étudiants par genre ;
- la répartition par tranche d’âge ;
- les différences entre les régions ;
- la représentation des étudiants par rapport à la population de référence.

## Structure prévue du dépôt

```text
analyse-sociodemographique-dbt/
├── models/
│   ├── staging/
│   ├── intermediate/
│   └── marts/
├── analyses/
├── screenshots/
├── dbt_project.yml
├── README.md
└── .gitignore
