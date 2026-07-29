# Notebooks

Ce dossier contient les notebooks Python utilisés pour préparer les données avant leur chargement dans Snowflake et leur transformation avec dbt.

## Préparation des données INSEE

Le notebook `01_prepare_insee_population.ipynb` permet notamment de :

- lire les données démographiques de l’INSEE pour les années 2022 à 2025 ;
- sélectionner et harmoniser les régions utiles à l’analyse ;
- transformer les données au format long ;
- aligner les tranches d’âge avec celles utilisées dans les données étudiantes ;
- regrouper les populations âgées de 60 ans ou plus ;
- effectuer des contrôles de cohérence ;
- produire un fichier préparé pour son chargement dans Snowflake.

Les fichiers Excel sources et les fichiers CSV générés ne sont pas publiés dans ce dépôt.