/*************************************************************************************************/
/****************************************ENODEB***************************************************/
/*************************************************************************************************/
/* Step 0: Create database */
/* Step 1: Create enodebTable60MinReg table: This table stores the data obtained from M2000 query */
/* Step 2: Import eNodeB M2000 query files */
/* Step 3: Create enodebTable60MinReg_AddingCells: In this table all the registers with same time but different cells are added to get eNodeB level values of Max users and Avg users */
/* Steps to get UserMax Values */
/* Step 4: Create table All_Network_PerHour to store the Avg and Max user values for all the network */
/* Step 5: Create All_Network_PerHour_WitoutTime table to leave the StartTime parameter only with the information of the date */
/* Step 6: All_Network_UserMaxValuesEachDay table: To store peak of User Max for each day */
/* Step 7: Obtain the day and hour of the third maximum value in the All_Network_UserMaxValuesEachDay table (Desired value of the report) */
/* Step 8: Obtain the data for the traffic of all the eNodeBs for the selected day and hour*/


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 0: Create database */
create database lteAudit1
create database lteAudit2
create database lteAudit3
create database lteAudit4
/* Step 0.1: Use the created data base */
Use [lteAudit]
Go

/* Or drop the database (only if necessary) */
Use [master]
Go
drop database lteAudit

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 1: Create enodebTable60MinReg table per cell */
Create Table enodebTable60MinReg
(
StartTime DATETIME,
Period INT,
NeName VARCHAR(45),
eNodeBFunction VARCHAR(45),
CellID VARCHAR(45),
CellName VARCHAR(45),
eNodeBID VARCHAR(45),
CellFDDTDDInd VARCHAR(45),
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)


Create Table enodebTable60MinReg_Total
(
StartTime DATETIME,
Period INT,
NeName VARCHAR(45),
eNodeBFunction VARCHAR(45),
CellID VARCHAR(45),
CellName VARCHAR(45),
eNodeBID VARCHAR(45),
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)

drop table dbo.enodebTable60MinReg_Total

/* Or drop the table (only if necessary) */
drop table dbo.enodebTable60MinReg

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 2: Import eNodeB M2000 query files */




BULK 
INSERT dbo.enodebTable60MinReg
FROM 'C:\SQL\52NoNil.csv'
WITH
(
FIRSTROW = 2,
FIELDTERMINATOR = ',',
ROWTERMINATOR = '0x0a'
)
GO


INSERT INTO enodebTable60MinReg_Total
SELECT StartTime, Period, NeName, eNodeBFunction, CellID, CellName, eNodeBID, TrafficUserMax, TrafficUserAvg FROM enodebTable60MinReg


SELECT COUNT(*) FROM enodebTable60MinReg
SELECT COUNT(*) FROM enodebTable60MinReg_Total


/* See imported data */
SELECT * FROM dbo.enodebTable60MinReg ORDER BY StartTime ASC

SELECT * FROM dbo.enodebTable60MinReg_Reves ORDER BY StartTime ASC

SELECT * FROM dbo.enodebTable60MinReg_Total ORDER BY StartTime ASC
SELECT * FROM dbo.enodebTable60MinReg_Total ORDER BY TrafficUserMax ASC

SELECT * FROM dbo.enodebTable60MinReg WHERE NeName = '"TATL_MLQ_090055"' ORDER BY TrafficUserMax DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE NeName = '"TMON_MLQ_180001"' ORDER BY TrafficUserMax DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE NeName = '"TANT_MLD_030018"' ORDER BY StartTime ASC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-10-14 17:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-11-18 18:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-12-07 12:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-12-16 18:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-12-12 18:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-12-07 12:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2022-12-07 17:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg WHERE StartTime = '2023-06-08 12:00:00' ORDER BY TrafficUserAvg DESC
SELECT * FROM dbo.enodebTable60MinReg 
WHERE  (DATEPART(yy, StartTime) = 2023
AND    DATEPART(mm, StartTime) = 10
AND    DATEPART(dd, StartTime) = 16)

/* Or delete inserted data */
Delete from dbo.enodebTable60MinReg Where StartTime >= '2014-01-01 00:00:00' and StartTime <= '2014-08-01 00:00:00'

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 3: Create enodebTable60MinReg_AddingCells table per eNodeB */

Create Table enodebTable60MinReg_AddingCells
(
StartTime DATETIME,
NeName VARCHAR(45),
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)
/* Or drop the table (only if necessary) */
drop table dbo.enodebTable60MinReg_AddingCells

/* Step 3.1: Insert addition of all cell value on the hour per eNodeB */

INSERT INTO enodebTable60MinReg_AddingCells
SELECT StartTime, NeName, sum(TrafficUserMax), sum(TrafficUserAvg) FROM enodebTable60MinReg
GROUP BY StartTime, NeName ORDER BY StartTime ASC

/* See imported data */
SELECT * FROM enodebTable60MinReg_AddingCells ORDER BY NeName, StartTime ASC
SELECT * FROM enodebTable60MinReg_AddingCells WHERE StartTime = '2018-02-07 20:00:00.000' ORDER BY NeName ASC

SELECT * FROM dbo.enodebTable60MinReg_AddingCells WHERE NeName = '"PER0068"' ORDER BY TrafficUserMax DESC




/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 4: Create table All_Network_PerHour to store the Avg and Max user values for all the network */
Create Table All_Network_PerHour
(
StartTime DATETIME,
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)
/* Or drop the table (only if necessary) */
drop table All_Network_PerHour

/* Step 3.1: Insert addition of all cell value on the hour per eNodeB */

INSERT INTO All_Network_PerHour
SELECT StartTime, sum(TrafficUserMax), sum(TrafficUserAvg) FROM enodebTable60MinReg
GROUP BY StartTime ORDER BY StartTime ASC

/* See imported data -Used to get all peaks for customer montly report*/
SELECT * FROM All_Network_PerHour ORDER BY TrafficUserAvg ASC

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 5: Create All_Network_PerHour_WitoutTime table */

Create Table All_Network_PerHour_WitoutTime
(
StartTime DATETIME,
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)
/* Or drop the table (only if necessary) */
drop table All_Network_PerHour_WitoutTime

/* Step 4.1: Insert data into table by day */
INSERT INTO All_Network_PerHour_WitoutTime (StartTime, TrafficUserMax, TrafficUserAvg)
(SELECT DATEADD(dd, 0, DATEDIFF(dd, 0, StartTime)), TrafficUserMax, TrafficUserAvg FROM All_Network_PerHour)

/* See imported data */
SELECT * FROM All_Network_PerHour_WitoutTime ORDER BY StartTime, TrafficUserAvg DESC

SELECT * FROM dbo.enodebRegistersWithDayAndWitoutTime WHERE NeName = '"TANT_MLD_030018"' ORDER BY StartTime ASC
SELECT * FROM dbo.enodebRegistersWithDayAndWitoutTime WHERE NeName = '"TMED_MLD_010088"' ORDER BY TrafficUserMax DESC

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 6: All_Network_UserMaxValuesEachDay table: To store peak of User Max for each day */
Create Table All_Network_UserMaxValuesEachDay
(
StartTime DATETIME,
TrafficUserMax DECIMAL(20,5),
TrafficUserAvg DECIMAL(20,5)
)
/* Or drop the table (only if necessary) */
drop table All_Network_UserMaxValuesEachDay

/* Step 5.1: Insert peak hour highest UserMax values for each days */
INSERT INTO All_Network_UserMaxValuesEachDay
select cur.StartTime, cur.TrafficUserMax, cur.TrafficUserAvg
from All_Network_PerHour_WitoutTime cur
where not exists (
    select * 
    from All_Network_PerHour_WitoutTime high 
    where high.StartTime = cur.StartTime
    and high.TrafficUserAvg > cur.TrafficUserAvg
) ORDER BY TrafficUserMax DESC

/* View table */
SELECT * FROM All_Network_UserMaxValuesEachDay ORDER BY TrafficUserAvg DESC

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* Step 7: Obtain the day and hour of the third maximum value in the All_Network_UserMaxValuesEachDay table (Desired value of the report)*/

SELECT * FROM All_Network_PerHour WHERE TrafficUserAvg = '1993955.022'

/* Step 8: Obtain the data for the traffic of all the eNodeBs for the selected day and hour*/

SELECT * FROM enodebTable60MinReg_AddingCells WHERE StartTime = '2019-08-29 17:00:00.000' ORDER BY NeName ASC