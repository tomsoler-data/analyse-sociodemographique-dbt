-- Modèle intermédiaire d'agrégation des données INSEE.
-- Objectif : regrouper la population INSEE par profil sociodémographique
-- afin d'obtenir une population de référence par année, région, genre et tranche d'âge.

with insee_population as (

    -- Appel du modèle de staging contenant les données INSEE nettoyées
    select *
    from {{ ref('stg_insee_population') }}

),

aggregated as (

    select
        -- Année d'analyse, harmonisée avec l'année des données étudiants
        year_insee as year,

        -- Région de résidence
        region,

        -- Genre de la population INSEE
        gender,

        -- Tranche d'âge harmonisée avec les données étudiants
        age_group,

        -- Population INSEE totale pour chaque profil sociodémographique
        sum(population_insee) as population_insee

    from insee_population

    -- Agrégation au niveau du profil sociodémographique
    group by
        year_insee,
        region,
        gender,
        age_group

)

-- Table intermédiaire contenant la population INSEE par profil
select *
from aggregated