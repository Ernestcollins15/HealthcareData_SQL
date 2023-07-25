
--Visit Table
CREATE TABLE Visit_Tbl(
  VisitId VARCHAR(20) PRIMARY KEY,
  PatientCode VARCHAR(20),
  DateTime  TIMESTAMP,
  MedicalCenter VARCHAR(20),
  VisitCategory VARCHAR(20),
  Payor VARCHAR(20),
  NPSScore INT
);

--Invoice Table
CREATE TABLE Invoice_Tbl (
  VisitCode VARCHAR(20),
  Amount DECIMAL(10, 2),
  Amount_adjusted DECIMAL(10, 2),
  FOREIGN KEY (VisitId) REFERENCES Visit_Tbl(VisitId)
);
--Diagosis Table
CREATE TABLE Diagnosis_Tbl(
   VisitCode VARCHAR(20),
   Diagnosis VARCHAR(20),
   FOREIGN KEY (VisitCode) REFERENCES Visit_Tbl(VisitId)
   
   
  ----- #####IMPROVED
  
  --Visit Table

CREATE TABLE Visit_Tbl(
  VisitId VARCHAR(20) PRIMARY KEY,
  PatientCode VARCHAR(20),
  DateTime  TIMESTAMP,
  MedicalCenter VARCHAR(20),
  VisitCategory VARCHAR(20),
  Payor VARCHAR(20),
  NPSScore INT
);

--Invoice Table

CREATE TABLE Invoice_Tbl (
  VisitCode VARCHAR(20),
  Amount DECIMAL(10, 2),
  Amount_adjusted DECIMAL(10, 2),
  FOREIGN KEY (VisitId) REFERENCES Visit_Tbl(VisitId)
);

--Diagosis Table

CREATE TABLE Diagnosis_Tbl(
   VisitCode VARCHAR(20),
   Diagnosis VARCHAR(20),
   FOREIGN KEY (VisitCode) REFERENCES Visit_Tbl(VisitId)
);

--ALTER TABLE Diagnosis_Tbl RENAME COLUMN Visitcode TO visit_code

ALTER TABLE visit_Tbl RENAME COLUMN datetime TO dte

--- Joining Visit and Diagnosis Tables
SELECT v.medicalcenter,d.diagnosis
FROM visit_tbl v
JOIN Diagnosis_tbl d
ON
visitId = visit_code
;

---Creating a View for the Visit and Diagnosis table
CREATE OR REPLACE VIEW visit_diag_join AS(
SELECT v.medicalcenter,d.diagnosis
FROM visit_tbl v
JOIN Diagnosis_tbl d
ON
visitId = visit_code )
;

	
SELECT * FROM visit_diag_join;	

	
--What was the most common diagnosis in 2022 for Tassia and Embakasi branches combined? 
SELECT MAX(diagnosis) MostCommonDiagnosis FROM visit_diag_join
WHERE medicalcenter =  'Pipeline'
;

--- Joining Visit and Invoice Table

SELECT v.patientcode,v.datetime,v.medicalcenter,i.Amount_adjusted
FROM visit_tbl v
LEFT JOIN Invoice_tbl i
ON
visitId = visitcode
;

---Creating a view For the Visit and Invoice Table
CREATE OR REPLACE VIEW visit_invoice_join AS(
SELECT v.patientcode,v.datetime,v.medicalcenter,i.Amount_adjusted
FROM visit_tbl v
LEFT JOIN Invoice_tbl i
ON
visitId = visitcode)
;


SELECT * FROM visit_invoice_join;


---Creating  a Join for the three tables 
SELECT v.patientcode,v.dte,v.medicalcenter,v.visitcategory,v.payor,v.npsscore,i.Amount_adjusted,d.diagnosis
FROM visit_tbl v
LEFT JOIN Invoice_tbl i
ON
visitId = visitcode
LEFT JOIN Diagnosis_tbl d
ON
visitcode = visit_code
;

---Creating a view for this join
CREATE OR REPLACE VIEW v_i_d_join AS(
SELECT v.patientcode,v.dte,v.medicalcenter,v.visitcategory,v.payor,v.npsscore,i.Amount_adjusted,d.diagnosis
FROM visit_tbl v
LEFT JOIN Invoice_tbl i
ON
visitId = visitcode
LEFT JOIN Diagnosis_tbl d
ON
visitcode = visit_code)
;

SELECT * FROM v_i_d_join;

--Which medical center was the least profitable (in absolute numbers) in 2022?  {Assume a gross average margin of 30% per visit}
SELECT DISTINCT
medicalcenter,
SUM(amount_adjusted) OVER(PARTITION BY medicalcenter) yield
FROM v_i_d_join
ORDER BY yield DESC
;

--Which payor was the most profitable (in absolute numbers) for Penda Health in 2022? {Assume a gross average margin of 30% per visit}.
SELECT DISTINCT
payor,
SUM(amount_adjusted) OVER(PARTITION BY payor) yield
FROM v_i_d_join
ORDER BY yield DESC

SELECT * FROM Invoice_tbl;
SELECT * FROM Diagnosis_tbl;
SELECT * FROM visit_tbl;


--What was the average spending per visit for visits that had a diagnosis of acute gastritis?
SELECT
diagnosis,
AVG(amount_adjusted) spending
FROM v_i_d_join
WHERE diagnosis = 'acute gastritis'
GROUP BY diagnosis
;

--Blended healthcare model
SELECT COUNT(patientcode)
FROM v_i_d_join 
WHERE 
visitcategory = 'In-person Visit' 
AND 
visitcategory ='Telemedicine Visit'
;

--- 
SELECT *,
EXTRACT(DAY FROM dte) AS day_value,
EXTRACT(MONTH FROM dte) AS month_value
FROM visit_tbl;



SELECT 
EXTRACT(DAY FROM dte) AS day_value,
EXTRACT(MONTH FROM dte) AS month_value
FROM visit_tbl;


);



--- Patientcount From Kimathi Street between month 5 and 9 
SELECT COUNT(patientcode) visit_count
FROM visits
WHERE  month_value BETWEEN 5 AND 9 AND medicalcenter = 'Kimathi Street' 
;

SELECT MAX(medicalcenter) 


---Visitcategory yield
SELECT DISTINCT
visitcategory,
SUM(amount_adjusted) OVER(PARTITION BY visitcategory) yield
FROM v_i_d_join
ORDER BY yield DESC

---
SELECT DISTINCT
   diagnosis,
   SUM(amount_adjusted) OVER(PARTITION BY diagnosis) yield
FROM v_i_d_join
WHERE diagnosis IS NOT NULL
ORDER BY yield DESC
;


CREATE VIEW diag AS (
SELECT DISTINCT
diagnosis,
SUM(amount_adjusted) OVER(PARTITION BY diagnosis) yield
FROM v_i_d_join
WHERE diagnosis IS NOT NULL
ORDER BY yield DESC)
;


---Patients with the Second most visit
WITH counts AS (
SELECT patientcode,
COUNT(patientcode) 
FROM visit_tbl 
GROUP BY patientcode
),

ranked AS(
SELECT *, RANK() OVER(ORDER BY "count" DESC) "rank"
FROM counts)

SELECT * FROM ranked WHERE rank = 2

---


---what percent of visits in April 2022 happened within 30 days of the preceding visit by the same patient?

SELECT COUNT(*)
FROM visit_tbl v1
JOIN visit_tbl v2 ON v1.patientcode = V2.patientcode
WHERE
v1.dte > v2.dte AND 
v1.dte - v2.dte <= INTERVAL '30 days' AND
v1.dte >= '2022-04-01'
AND 
v1.dte < '2022-05-01';

---Self joning Visit table to find the Patients who visited within 30 days of the last visit 

SELECT v1.visitId,v1.patientcode,v1.dte,v1.medicalcenter,v1.visitcategory,v1.payor,v1.npsscore
FROM visit_tbl v1
JOIN visit_tbl v2 ON v1.patientcode = V2.patientcode
WHERE
v1.dte > v2.dte AND 
v1.dte - v2.dte <= INTERVAL '30 days' AND
v1.dte >= '2022-04-01'
AND 
v1.dte < '2022-05-01'
;

SELECT * FROM visits;

--
SELECT 
patientcode,
"month_value",
COUNT(patientcode) cnt
FROM visits
WHERE "month_value" = 3
GROUP BY patientcode,"month_value"
ORDER BY patientcode

create view pst AS(
SELECT 
   patientcode,
  "month_value" AS Monthvalue,
   COUNT(patientcode) cnt
FROM 
   visits
WHERE
   "month_value" = 3
GROUP BY patientcode,Monthvalue ORDER BY patientcode)

select max(cnt) from pst

select sum(cnt) from pst where cnt BETWEEN  2 AND 31


SELECT 
patientcode,
"day_value",
COUNT(patientcode) cnt
FROM visits
WHERE "day_value" BETWEEN 1 AND 31
GROUP BY patientcode,"day_value"
ORDER BY patientcode


create view pstd AS(
SELECT 
patientcode,
"day_value",
COUNT(patientcode) cnt
FROM visits
WHERE "day_value" BETWEEN 1 AND 31
GROUP BY patientcode,"day_value"
ORDER BY patientcode)
d
SELECT COUNT(*) AS visit_count
FROM visits v1
WHERE v1.visit_date >= '2022-04-01'
  AND v1.visit_date < '2022-05-01'
  AND EXISTS (
    SELECT 1 --checks if there is any matching row in the table
    FROM visits v2
    WHERE v2.visit_date < v1.visit_date
      AND v2.visit_date >= v1.visit_date - INTERVAL '30 days'
  );
