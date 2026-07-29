-- Modèle de staging des données INSEE.
-- Objectif : partir de la table brute INSEE_POPULATION,
-- conserver les colonnes utiles et limiter le périmètre aux années d'analyse.

with source as (

    -- Appel de la table source brute INSEE déclarée dans sources.yml
    select *
    from {{ source('raw', 'INSEE_POPULATION') }}

),

renamed as (

    select
        -- Année de référence de la population INSEE
        year_insee,

        -- Région utilisée pour la comparaison avec les étudiants OpenClassrooms
        region,

        -- Genre de la population INSEE
        gender,

        -- Tranche d'âge harmonisée avec les données étudiants
        age_group,

        -- Population INSEE correspondant au profil année / région / genre / âge
        population_insee

    from source

    -- Conservation uniquement des années utilisées dans l'analyse
    where year_insee between 2022 and 2025

)

-- Table finale du modèle de staging INSEE
select *
from renamed