-- Modèle intermédiaire d'agrégation des étudiants OpenClassrooms.
-- Objectif : regrouper les étudiants Data par profil sociodémographique
-- afin d'obtenir un nombre d'étudiants par année, région, genre et tranche d'âge.

with students as (

    -- Appel du modèle de staging contenant les données étudiants nettoyées
    select *
    from {{ ref('stg_students') }}

),

aggregated as (

    select
        -- Année d'analyse, basée sur l'année de début du parcours
        year_path_started as year,

        -- Région de résidence de l'étudiant
        region,

        -- Genre standardisé dans le modèle stg_students
        gender,

        -- Tranche d'âge de l'étudiant
        age_group,

        -- Nombre d'étudiants OpenClassrooms distincts pour chaque profil
        count(distinct user_id) as nb_students_oc

    from students

    -- Agrégation au niveau du profil sociodémographique
    group by
        year_path_started,
        region,
        gender,
        age_group

)

-- Table intermédiaire contenant les effectifs étudiants par profil
select *
from aggregated