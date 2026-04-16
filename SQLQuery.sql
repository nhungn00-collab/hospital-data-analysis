CREATE DATABASE HOSPITAL
SELECT * FROM [dbo].[hospital data analysis]
--2.Data cleaning

SELECT COUNT(DISTINCT Patient_ID) AS total_patients
FROM [hospital data analysis];

DELETE
FROM [dbo].[hospital data analysis]
WHERE length_of_stay IS NULL
   OR outcome IS NULL
   OR satisfaction IS NULL;

ALTER TABLE [dbo].[hospital data analysis]
ALTER COLUMN cost FLOAT;

DELETE
FROM [dbo].[hospital data analysis]
WHERE patient_id NOT IN (
    SELECT MIN(patient_id)
    FROM [dbo].[hospital data analysis]
    GROUP BY patient_id
);

SELECT
  SUM(CASE WHEN Patient_ID IS NULL THEN 1 ELSE 0 END) AS null_patientid,
  SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS null_age,
  SUM(CASE WHEN Gender IS NULL THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN Condition IS NULL THEN 1 ELSE 0 END) AS null_condition,
  SUM(CASE WHEN [Procedure] IS NULL THEN 1 ELSE 0 END) AS null_procedure,
  SUM(CASE WHEN Cost IS NULL THEN 1 ELSE 0 END) AS null_cost,
  SUM(CASE WHEN Length_of_Stay IS NULL THEN 1 ELSE 0 END) AS null_LOS,
  SUM(CASE WHEN Readmission IS NULL THEN 1 ELSE 0 END) AS null_readmission,
  SUM(CASE WHEN Outcome IS NULL THEN 1 ELSE 0 END) AS null_outcome,
  SUM(CASE WHEN Satisfaction IS NULL THEN 1 ELSE 0 END) AS null_satisfaction
FROM [hospital data analysis];

--3.KPIs: Success rate, Avg length of stay, Avg cost, Avg satisfaction, Readmission rate
SELECT
  COUNT(*) AS total_cases,
  AVG(length_of_stay) AS avg_los,
  AVG(cost) AS avg_cost,
  AVG(satisfaction) AS avg_satisfactionscore,
  SUM(CASE WHEN outcome = 'Recovered' THEN 1 ELSE 0 END)*1.0 / COUNT(*) *100 AS success_rate,
  SUM(CASE WHEN readmission = 'Yes' THEN 1 ELSE 0 END)*1.0 / COUNT(*) *100 AS readmission_rate
FROM [hospital data analysis];

--4.1.Treatment Effectiveness (HIỆU QUẢ ĐIỀU TRỊ)
--4.1.1.xác định tỷ lệ hồi phục theo từng mặt bệnh
SELECT Condition,
  COUNT(*) AS total_cases,
  SUM(CASE WHEN outcome = 'Recovered' THEN 1 ELSE 0 END)*1.0/COUNT(*) AS success_rate
FROM [hospital data analysis]
GROUP BY Condition
ORDER BY success_rate;

--4.1.2.xác định tỷ lệ hồi phục theo phương pháp điều trị
SELECT [Procedure], 
  COUNT(*) AS total_cases,
  SUM(CASE WHEN outcome = 'Recovered' THEN 1 ELSE 0 END)*1.0 / COUNT(*) AS success_rate
FROM [hospital data analysis]
GROUP BY [Procedure];

--4.2.LOS & COST
--4.2.1.LOS theo outcome
SELECT Outcome,
  AVG(Length_of_Stay) AS avg_los
FROM [hospital data analysis]
GROUP BY outcome;

--4.2.2.LOS theo condition
SELECT Condition,
  AVG(length_of_stay) AS avg_los
FROM [hospital data analysis]
GROUP BY Condition
ORDER BY avg_los DESC;

--4.2.3.Cost theo outcome
SELECT outcome,
  AVG(cost) AS avg_cost
FROM [hospital data analysis]
GROUP BY outcome;

--4.2.4.Cost theo Condition, avg satisfaction
SELECT Condition,
  AVG(cost) AS avg_cost,
  AVG(satisfaction) AS avg_satisfaction
FROM [hospital data analysis]
GROUP BY Condition
ORDER BY avg_cost DESC;

--4.3.Patient Satisfaction 
--4.3.1.Satisfaction theo outcome & cost
SELECT outcome,
  AVG(satisfaction) AS avg_satisfaction,
  AVG(cost) AS avg_cost
FROM [hospital data analysis]
GROUP BY outcome;

--4.3.2.Satisfaction theo LOS 
WITH los_bucket AS (
    SELECT
        *,
        CASE
            WHEN length_of_stay <= 5 THEN '0-5 days'
            WHEN length_of_stay <= 10 THEN '6-10 days'
            WHEN length_of_stay <= 20 THEN '11-20 days'
            ELSE '20+ days'
        END AS los_group
    FROM [hospital data analysis]
) 
SELECT
    los_group,
    AVG(Satisfaction) AS avg_satisfaction
FROM los_bucket
GROUP BY los_group 
ORDER BY los_group;

--4.4.Readmission Risk
--4.4.1.Readmission rate theo condition
SELECT Condition ,
  SUM(CASE WHEN readmission = 'Yes' THEN 1 ELSE 0 END)*1.0 / COUNT(*) AS readmission_rate,
  AVG(satisfaction) AS avg_satisfaction,
  AVG(cost) AS avg_cost
FROM [hospital data analysis]
GROUP BY Condition
ORDER BY readmission_rate DESC;

--4.4.2.Readmission vs satisfaction & cost
SELECT readmission,
  AVG(cost) AS avg_cost,
  AVG(satisfaction) AS avg_satisfaction
FROM [hospital data analysis]
GROUP BY readmission;