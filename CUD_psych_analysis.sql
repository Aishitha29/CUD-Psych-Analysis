SELECT COUNT(DISTINCT PATID) AS total_first_time_patients
FROM DEID_ENCOUNTER
WHERE ADMIT_DATE = (
    SELECT MIN(ADMIT_DATE) 
    FROM DEID_ENCOUNTER ee 
    WHERE ee.patid = DEID_ENCOUNTER.patid
); --Number of First-Time Patients

--------------------------------------------------------------------------------------------
             ---WITH CUD AND WITH OR WITHOUT MENTAL HEALTH DIS---
--------------------------------------------------------------------------------------------
WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    SELECT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'  -- ICD-10 codes for Cannabis Use Disorder
)
SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID; ---Patients Who Stayed for 6+ Months and Were Diagnosed with CUD

WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    SELECT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'  -- ICD-10 codes for Cannabis Use Disorder
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
WHERE c.PATID IS NULL; --Patients Who Stayed for 6+ Months Without CUD

WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWithFollowUp AS (
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
)
SELECT COUNT(DISTINCT fe.PATID) AS patients_without_followup
FROM FirstEncounter fe
LEFT JOIN PatientsWithFollowUp pwf ON fe.PATID = pwf.PATID
WHERE pwf.PATID IS NULL; ---Patients Who Did Not Return After the 6-Month Window


WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'  -- ICD-10 codes for Cannabis Use Disorder
),
PatientsWithAnxietyDepSchizo AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%'  -- Anxiety (ICD-10 codes starting with F41)
       OR DX LIKE 'F32%'  -- Depression (ICD-10 codes starting with F32)
       OR DX LIKE 'F20%'  -- Schizophrenia (ICD-10 codes starting with F20)
)
SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_and_MentalHealth
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxietyDepSchizo m ON p.PATID = m.PATID; ---Patients with Anxiety, Depression, or Schizophrenia and CUD After 6 Months

WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)  -- 6 months and beyond, no upper limit
),
PatientsWithCUD AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'  -- ICD-10 codes for Cannabis Use Disorder
),
PatientsWithPsychDisorders AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%'  -- Anxiety (ICD-10 codes starting with F41)
       OR DX LIKE 'F32%'  -- Depression (ICD-10 codes starting with F32)
       OR DX LIKE 'F20%'  -- Schizophrenia (ICD-10 codes starting with F20)
)
SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_no_psych_disorders
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
LEFT JOIN PatientsWithPsychDisorders m ON p.PATID = m.PATID
WHERE m.PATID IS NULL;  -- Patients With CUD but Without Anxiety, Depression, or Schizophrenia

---TO AVOID REPETITION

WITH FirstEncounter AS (
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)  -- 6 months and beyond
),
PatientsWithCUD AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'  -- ICD-10 codes for Cannabis Use Disorder
),
PatientsWithDepression AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F32%'  -- Depression (ICD-10 codes starting with F32)
),
PatientsWithAnxiety AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%'  -- Anxiety (ICD-10 codes starting with F41)
),
PatientsWithSchizophrenia AS (
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F20%'  -- Schizophrenia (ICD-10 codes starting with F20)
    )

SELECT 
    COUNT(DISTINCT CASE 
        WHEN d.PATID IS NOT NULL AND a.PATID IS NULL AND s.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Depression_only,
    
    COUNT(DISTINCT CASE 
        WHEN a.PATID IS NOT NULL AND d.PATID IS NULL AND s.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Anxiety_only,

    COUNT(DISTINCT CASE 
        WHEN s.PATID IS NOT NULL AND d.PATID IS NULL AND a.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Schizophrenia_only,

    COUNT(DISTINCT CASE 
        WHEN d.PATID IS NOT NULL AND a.PATID IS NOT NULL AND s.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Depression_Anxiety_only,

    COUNT(DISTINCT CASE 
        WHEN d.PATID IS NOT NULL AND s.PATID IS NOT NULL AND a.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Depression_Schizophrenia_only,

    COUNT(DISTINCT CASE 
        WHEN a.PATID IS NOT NULL AND s.PATID IS NOT NULL AND d.PATID IS NULL THEN p.PATID 
    END) AS patients_with_CUD_Anxiety_Schizophrenia_only,

    COUNT(DISTINCT CASE 
        WHEN d.PATID IS NOT NULL AND a.PATID IS NOT NULL AND s.PATID IS NOT NULL THEN p.PATID 
    END) AS patients_with_CUD_all_three_disorders

FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID; -- all in one


SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_and_Depression
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID; -- CUD AND D

SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_and_Anxiety
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID; -- CUD AND A

SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_and_Schizophrenia
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID; -- CUD AND S

SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_Depression_Anxiety_Only
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE s.PATID IS NULL;  -- Exclude Schizophrenia

SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_Depression_Schizophrenia
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE a.PATID IS NULL;  -- Exclude Anxiety

SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_Schizophrenia_Anxiety
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
WHERE d.PATID IS NULL;  -- Exclude Depression

-------------------------------------------------------------------------------
SELECT COUNT(DISTINCT p.PATID) AS patients_with_Anxiety_Schizophrenia_only
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID != c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
WHERE d.PATID IS NULL; D+A+S AND NO CUD


SELECT COUNT(DISTINCT p.PATID) AS patients_with_Depression_Anxiety_only
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID != c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE s.PATID IS NULL; -- D+A AND NO CUD

SELECT COUNT(DISTINCT p.PATID) AS patients_with_all_three
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID; --D+A+S AND NO CUD

SELECT COUNT(DISTINCT p.PATID) AS patients_with_Depression_Schizophrenia_only
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE a.PATID IS NULL; -- D+S AND NO CUD
-------------------------------------------------------------------------------

---Patients with CUD but Without Anxiety, Depression, or Schizophrenia

WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithPsychDisorders AS (
    -- Identify patients diagnosed with Anxiety (F41%), Depression (F32%), or Schizophrenia (F20%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%' OR DX LIKE 'F32%' OR DX LIKE 'F20%'
),
PatientsWithAnyOtherDiagnosis AS (
    -- Identify patients who have ANY diagnosis other than Anxiety, Depression, or Schizophrenia
    SELECT DISTINCT d.PATID
    FROM DEID_DIAGNOSIS d
    LEFT JOIN PatientsWithPsychDisorders p ON d.PATID = p.PATID
    WHERE p.PATID IS NULL -- Ensure they do not have any of the three psych disorders
)
SELECT COUNT(DISTINCT p.PATID) AS patients_with_CUD_no_psych_but_may_have_other_diag
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithCUD c ON p.PATID = c.PATID
LEFT JOIN PatientsWithPsychDisorders psych ON p.PATID = psych.PATID
WHERE psych.PATID IS NULL; -- Exclude those with Anxiety, Depression, or Schizophrenia

--------------------------------------------------------------------------------------------
             ---WITHOUT CUD AND WITH OR WITHOUT MENTAL HEALTH DIS---
--------------------------------------------------------------------------------------------
WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_6months
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
WHERE c.PATID IS NULL; -- Patients Without CUD Even After 6+ Months

WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithPsychDisorders AS (
    -- Identify patients diagnosed with Anxiety (F41%), Depression (F32%), or Schizophrenia (F20%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%' OR DX LIKE 'F32%' OR DX LIKE 'F20%'
),
PatientsWithAnyDiagnosis AS (
    -- Identify patients who have any diagnosis recorded in DEID_DIAGNOSIS
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_or_PsychDisorders
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
LEFT JOIN PatientsWithPsychDisorders psych ON p.PATID = psych.PATID
LEFT JOIN PatientsWithAnyDiagnosis d ON p.PATID = d.PATID
WHERE c.PATID IS NULL  -- Exclude patients with CUD
AND psych.PATID IS NULL;  -- Patients Without CUD & Without Any of the 3 Psychiatric Disorders (After 6 Months) (also includes people with no diagnosis at all)

WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithPsychDisorders AS (
    -- Identify patients diagnosed with Anxiety (F41%), Depression (F32%), or Schizophrenia (F20%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%' OR DX LIKE 'F32%' OR DX LIKE 'F20%'
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_but_with_PsychDisorders
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithPsychDisorders psych ON p.PATID = psych.PATID
WHERE c.PATID IS NULL;  -- Exclude patients with any CUD diagnosis


WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithDepression AS (
    -- Identify patients diagnosed with Depression (F32%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F32%'
),
PatientsWithAnxiety AS (
    -- Identify patients diagnosed with Anxiety (F41%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%'
),
PatientsWithSchizophrenia AS (
    -- Identify patients diagnosed with Schizophrenia (F20%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F20%'
)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_All_Three
FROM PatientsWith6MonthsFollowUp p
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
WHERE c.PATID IS NULL;
---Patients with NO CUD and All Three Psychiatric Disorders

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Schizophrenia_Anxiety
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND d.PATID IS NULL; -- Exclude Depression
--- double checking Patients with NO CUD and Schizophrenia + Anxiety (No Depression)


SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Schizophrenia_Depression
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND a.PATID IS NULL; -- Exclude Anxiety
---double checking - Patients with NO CUD and Schizophrenia + Depression (No Anxiety)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Schizophrenia_only
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND d.PATID IS NULL -- Exclude Depression
AND a.PATID IS NULL; -- Exclude Anxiety
---Patients with NO CUD and Schizophrenia ONLY (No Depression or Anxiety)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Anxiety_Schizophrenia
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND d.PATID IS NULL; -- Exclude Depression
--- Patients with NO CUD and Anxiety + Schizophrenia (No Depression)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Anxiety_Depression
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND s.PATID IS NULL; -- Exclude Schizophrenia
--double checking no CUD with D and A

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Anxiety_only
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND d.PATID IS NULL -- Exclude Depression
AND s.PATID IS NULL; -- Exclude Schizophrenia
---Patients with NO CUD and Anxiety ONLY (No Depression or Schizophrenia)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Depression_Schizophrenia
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND a.PATID IS NULL; -- Exclude Anxiety
---Patients with NO CUD and Depression + Schizophrenia (No Anxiety)

SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Depression_Anxiety
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND s.PATID IS NULL; -- Exclude Schizophrenia
---Patients with NO CUD and Depression + Anxiety (No Schizophrenia)


SELECT COUNT(DISTINCT p.PATID) AS patients_no_CUD_Depression_only
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
LEFT JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
LEFT JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE c.PATID IS NULL -- Exclude CUD
AND a.PATID IS NULL  -- Exclude Anxiety
AND s.PATID IS NULL; -- Exclude Schizophrenia
---Patients with NO CUD and Depression ONLY (No Anxiety or Schizophrenia)


-----CHECKING IF THE NUMBERS MATCH USING SCHIZOPHRENIA (INVOLVES REPEATS) ----
WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithSchizophrenia AS (
    -- Identify patients diagnosed with Schizophrenia (ICD-10 code F20%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F20%'
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_with_Schizophrenia
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithSchizophrenia s ON p.PATID = s.PATID
WHERE c.PATID IS NULL;  -- Exclude patients with any CUD diagnosis

-----CHECKING IF THE NUMBERS MATCH USING DEPRESSION  (INVOLVES REPEATS)----
WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithDepression AS (
    -- Identify patients diagnosed with Depression (ICD-10 code F32%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F32%'
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_with_Depression
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithDepression d ON p.PATID = d.PATID
WHERE c.PATID IS NULL;  -- Exclude patients with any CUD diagnosis

-----CHECKING IF THE NUMBERS MATCH USING DEPRESSION (INVOLVES REPEATS)  ----

WITH FirstEncounter AS (
    -- Get each patient's first visit
    SELECT PATID, MIN(ADMIT_DATE) AS first_encounter_date
    FROM DEID_ENCOUNTER
    GROUP BY PATID
),
PatientsWith6MonthsFollowUp AS (
    -- Get patients who had an encounter at least 6 months after their first visit
    SELECT DISTINCT e.PATID
    FROM DEID_ENCOUNTER e
    JOIN FirstEncounter fe ON e.PATID = fe.PATID
    WHERE e.ADMIT_DATE >= DATEADD('month', 6, fe.first_encounter_date)
),
PatientsWithCUD AS (
    -- Identify patients diagnosed with CUD (ICD-10 codes starting with F12)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F12%'
),
PatientsWithAnxiety AS (
    -- Identify patients diagnosed with Anxiety (ICD-10 code F41%)
    SELECT DISTINCT PATID
    FROM DEID_DIAGNOSIS
    WHERE DX LIKE 'F41%'
)
SELECT COUNT(DISTINCT p.PATID) AS patients_without_CUD_with_Anxiety
FROM PatientsWith6MonthsFollowUp p
LEFT JOIN PatientsWithCUD c ON p.PATID = c.PATID
JOIN PatientsWithAnxiety a ON p.PATID = a.PATID
WHERE c.PATID IS NULL;  -- Exclude patients with any CUD diagnosis

------------------------------------------------------------------------------------



