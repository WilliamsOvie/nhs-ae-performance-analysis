select * from nhs_ae_data

-- Check total records
SELECT COUNT(*) AS Total_Records
FROM nhs_ae_data;

-- Check the reporting period
SELECT
    MIN(Reporting_Month) AS First_Month,
    MAX(Reporting_Month) AS Last_Month,
    COUNT(DISTINCT Reporting_Month) AS Number_Of_Months
FROM nhs_ae_data;

-- Check the table structure
SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'dbo'
  AND TABLE_NAME = 'NHS_AE_Data'
ORDER BY ORDINAL_POSITION;

-- Analysis 01: Validate Plymouth NHS Trust Reporting Coverage
SELECT
    [Org Code],
    [Org name],
    COUNT(DISTINCT Reporting_Month) AS Months_Reported,
    MIN(Reporting_Month) AS First_Month,
    MAX(Reporting_Month) AS Last_Month
FROM [dbo].[NHS_AE_Data]
WHERE [Org Code] = 'RK9'
GROUP BY
    [Org Code],
    [Org name];

    -- Analysis 02: Monthly Type 1 A&E Attendance Trends
   SELECT
   Reporting_Month,
    CAST(
        [A&E attendances Type 1] AS INT
    ) AS Type1_Attendances
FROM [dbo].[NHS_AE_Data]
WHERE [Org Code] = 'RK9'
ORDER BY Reporting_Month;

-- Analysis 03: Monthly Type 1 A&E Four-Hour Performance
SELECT
    Reporting_Month,

    CAST([A&E attendances Type 1] AS INT)
        AS Total_Attendances,

    CAST([Attendances over 4hrs Type 1] AS INT)
        AS Over_4_Hours,

    ROUND(
        100.0 *
        (
            [A&E attendances Type 1]
            - [Attendances over 4hrs Type 1]
        )
        / NULLIF([A&E attendances Type 1], 0),
        2
    ) AS Within_4_Hours_Pct

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] = 'RK9'

ORDER BY Reporting_Month;

-- Analysis 04: NHS England Monthly Type 1 A&E Performance
SELECT
    Reporting_Month,

    SUM([A&E attendances Type 1])
        AS England_Type1_Attendances,

    SUM([Attendances over 4hrs Type 1])
        AS England_Over4Hours,

    ROUND(
        100.0 *
        (
            SUM([A&E attendances Type 1])
            - SUM([Attendances over 4hrs Type 1])
        )
        / NULLIF(
            SUM([A&E attendances Type 1]), 0
        ),
        2
    ) AS England_Within4Hours_Pct

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] <> 'TOTAL'

GROUP BY Reporting_Month

ORDER BY Reporting_Month;

 
 -- Analysis 05: Plymouth vs NHS England Four-Hour Performance Gap
WITH Monthly_Performance AS (
    SELECT
        Reporting_Month,

        ROUND(
            100.0 * SUM(
                [A&E attendances Type 1]
                - [Attendances over 4hrs Type 1]
            )
            / NULLIF(SUM([A&E attendances Type 1]), 0),
            2
        ) AS England_Pct,

        ROUND(
            100.0 * SUM(
                CASE WHEN [Org Code] = 'RK9'
                    THEN [A&E attendances Type 1]
                       - [Attendances over 4hrs Type 1]
                    ELSE 0
                END
            )
            / NULLIF(
                SUM(
                    CASE WHEN [Org Code] = 'RK9'
                        THEN [A&E attendances Type 1]
                        ELSE 0
                    END
                ), 0
            ),
            2
        ) AS Plymouth_Pct

    FROM [dbo].[NHS_AE_Data]
    GROUP BY Reporting_Month
)

SELECT
    Reporting_Month,
    England_Pct,
    Plymouth_Pct,
    ROUND(Plymouth_Pct - England_Pct, 2)
        AS Performance_Gap_PP
FROM Monthly_Performance
ORDER BY Reporting_Month;




-- Analysis 06: Monthly A&E Waiting Times After Decision to Admit
-- Provider: University Hospitals Plymouth NHS Trust (RK9)
-- Period: April 2025 - March 2026

SELECT
    Reporting_Month,

    CAST(
        [Patients who have waited 4-12 hs from DTA to admission]
        AS INT
    ) AS Waits_4_to_12_Hours,

    CAST(
        [Patients who have waited 12+ hrs from DTA to admission]
        AS INT
    ) AS Waits_12_Plus_Hours

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] = 'RK9'

ORDER BY Reporting_Month;


-- Analysis 07: Monthly Emergency Admissions
-- Provider: University Hospitals Plymouth NHS Trust
-- Period: April 2025 - March 2026

SELECT
    Reporting_Month,

    CAST(
        [Emergency admissions via A&E - Type 1]
        AS INT
    ) AS Type1_Emergency_Admissions,

    CAST(
        [Emergency admissions via A&E - Type 2]
        AS INT
    ) AS Type2_Emergency_Admissions,

    CAST(
        [Emergency admissions via A&E - Other A&E department]
        AS INT
    ) AS Other_AE_Emergency_Admissions,

    CAST(
        [Other emergency admissions]
        AS INT
    ) AS Other_Emergency_Admissions

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] = 'RK9'

ORDER BY Reporting_Month;


-- Analysis 08: Monthly Type 1 Emergency Admission Rate
-- Provider: University Hospitals Plymouth NHS Trust (RK9)
-- Period: April 2025 - March 2026

SELECT
    Reporting_Month,

    CAST(
        [A&E attendances Type 1] AS INT
    ) AS Type1_Attendances,

    CAST(
        [Emergency admissions via A&E - Type 1] AS INT
    ) AS Type1_Emergency_Admissions,

    ROUND(
        100.0 *
        [Emergency admissions via A&E - Type 1]
        / NULLIF([A&E attendances Type 1], 0),
        2
    ) AS Admission_Rate_Pct

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] = 'RK9'

ORDER BY Reporting_Month;


-- Analysis 09: Emergency Admission Ratio vs Four-Hour Performance
-- Provider: University Hospitals Plymouth NHS Trust (RK9)
-- Period: April 2025 - March 2026

SELECT
    Reporting_Month,

    ROUND(
        100.0 *
        [Emergency admissions via A&E - Type 1]
        / NULLIF([A&E attendances Type 1], 0),
        2
    ) AS Admission_Rate_Pct,

    ROUND(
        100.0 *
        (
            [A&E attendances Type 1]
            - [Attendances over 4hrs Type 1]
        )
        / NULLIF([A&E attendances Type 1], 0),
        2
    ) AS Within_4_Hours_Pct

FROM [dbo].[NHS_AE_Data]

WHERE [Org Code] = 'RK9'

ORDER BY Reporting_Month;



