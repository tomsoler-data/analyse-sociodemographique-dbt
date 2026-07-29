-- Modèle de staging des données étudiants OpenClassrooms.
-- Objectif : partir de la table brute STUDENTS, garder les colonnes utiles,
-- filtrer les étudiants du parcours Data et standardiser les valeurs de genre.

with source as (

    -- Appel de la table source brute déclarée dans sources.yml
    select
        user_id,
        path_category_name,
        age_group,
        gender,
        region,
        year_path_started
    from {{ source('raw', 'STUDENTS') }}

),

renamed as (

    select
        -- Identifiant unique de l'étudiant
        user_id,

        -- Catégorie du parcours, conservée pour vérifier que l'analyse porte sur les parcours Data
        path_category_name,

        -- Tranche d'âge de l'étudiant
        age_group,

        -- Région de résidence de l'étudiant
        region,

        -- Année de début du parcours
        year_path_started,

        -- Standardisation du genre :
        -- les valeurs nulles ou vides sont regroupées en "Non renseigné"
        -- les codes M et F sont transformés en libellés lisibles
        case
            when gender is null then 'Non renseigné'
            when trim(gender) = '' then 'Non renseigné'
            when gender = 'M' then 'Homme'
            when gender = 'F' then 'Femme'
            else gender
        end as gender

    from source

    -- Filtrage du périmètre d'analyse : uniquement les étudiants du parcours Data
    where path_category_name = 'Data'

)

-- Table finale du modèle de staging
select
    user_id,
    path_category_name,
    age_group,
    gender,
    region,
    year_path_started
from renamed