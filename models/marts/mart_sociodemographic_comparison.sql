-- Modèle final de comparaison sociodémographique.
-- Objectif : comparer la répartition des étudiants OpenClassrooms Data
-- avec la population INSEE de référence, par année, région, genre et tranche d'âge.
--
-- Ce modèle produit la table finale exportable en CSV.

with students as (

    -- Appel du modèle intermédiaire contenant les étudiants agrégés par profil
    select
        year,
        region,
        gender,
        age_group,
        nb_students_oc
    from {{ ref('int_students_by_profile') }}

    -- Pour comparer avec l'INSEE, on garde uniquement les genres Homme/Femme.
    -- Les valeurs "Non renseigné" existent côté OpenClassrooms,
    -- mais ne sont pas comparables directement avec les données INSEE.
    where gender in ('Homme', 'Femme')

),

insee_population as (

    -- Appel du modèle intermédiaire contenant la population INSEE agrégée par profil
    select
        year,
        region,
        gender,
        age_group,
        population_insee
    from {{ ref('int_insee_population_by_profile') }}

),

joined_raw as (

    select
        -- Dimensions communes utilisées pour la comparaison
        i.year,
        i.region,
        i.gender,
        i.age_group,

        -- Population INSEE correspondant au même profil sociodémographique
        i.population_insee,

        -- Nombre d'étudiants OpenClassrooms avant traitement des valeurs nulles
        s.nb_students_oc as nb_students_oc_raw

    from insee_population as i

    -- Jointure entre la population INSEE et les étudiants OpenClassrooms
    -- sur les dimensions communes : année, région, genre et tranche d'âge.
    --
    -- Le choix d'un left join à partir de l'INSEE permet de conserver
    -- tous les profils présents dans la population de référence,
    -- même lorsqu'aucun étudiant OpenClassrooms ne correspond.
    left join students as s
        on i.year = s.year
        and i.region = s.region
        and i.gender = s.gender
        and i.age_group = s.age_group

),

joined as (

    select
        year,
        region,
        gender,
        age_group,
        population_insee,

        -- Si aucun étudiant n'existe pour un profil INSEE donné,
        -- on remplace la valeur nulle par 0.
        coalesce(nb_students_oc_raw, 0) as nb_students_oc

    from joined_raw

),

with_totals as (

    select
        year,
        region,
        gender,
        age_group,
        nb_students_oc,
        population_insee,

        -- Total annuel des étudiants OpenClassrooms comparables.
        -- Ce total sert à calculer la part de chaque profil dans la population étudiante.
        sum(nb_students_oc) over (
            partition by year
        ) as total_students_oc_year,

        -- Total annuel de la population INSEE comparable.
        -- Ce total sert à calculer la part de chaque profil dans la population INSEE.
        sum(population_insee) over (
            partition by year
        ) as total_population_insee_year

    from joined

),

final as (

    select
        year,
        region,
        gender,
        age_group,
        nb_students_oc,
        population_insee,
        total_students_oc_year,
        total_population_insee_year,

        -- Part du profil dans la population étudiante OpenClassrooms de l'année.
        -- nullif permet d'éviter une division par zéro.
        nb_students_oc / nullif(total_students_oc_year, 0) as part_students_oc,

        -- Part du profil dans la population INSEE de l'année.
        -- nullif permet d'éviter une division par zéro.
        population_insee / nullif(total_population_insee_year, 0) as part_population_insee,

        -- Indice de représentation.
        -- Il compare la part du profil chez OpenClassrooms
        -- à la part du même profil dans la population INSEE.
        --
        -- Si l'indice est supérieur à 1, le profil est surreprésenté
        -- chez les étudiants OpenClassrooms par rapport à l'INSEE.
        --
        -- Si l'indice est inférieur à 1, le profil est sous-représenté.
        (nb_students_oc / nullif(total_students_oc_year, 0))
        /
        nullif((population_insee / nullif(total_population_insee_year, 0)), 0)
            as representation_index

    from with_totals

)

-- Table finale consolidée utilisée pour l'analyse et l'export CSV
select
    year,
    region,
    gender,
    age_group,
    nb_students_oc,
    population_insee,
    total_students_oc_year,
    total_population_insee_year,
    part_students_oc,
    part_population_insee,
    representation_index
from final