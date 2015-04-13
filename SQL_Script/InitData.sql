USE ISPC
GO
INSERT INTO UserProfile VALUES(
	'Developer'	
)
GO

INSERT INTO Machine_Status VALUES(
	'Active', 1, GETDATE()
),
(
	'Idle', 1, GETDATE()
)
GO

INSERT INTO Machine_Brand VALUES
(
	'KohYoung', 1, GETDATE()
),
(
	'Parmi', 1, GETDATE()
),
(
	'Cyberoptics', 1, GETDATE()
),
(
	'Vitrox', 1, GETDATE()
),
(
	'VITechnology', 1, GETDATE()
)
GO

INSERT INTO Machine_Type VALUES
(
	'SMTPastePrinter', 1, GETDATE()
),
(
	'PickAndPlace', 1, GETDATE()
),
(
	'SPI', 1, GETDATE()
),
(
	'AOI', 1,  GETDATE()
)
GO


INSERT INTO Building VALUES(
	'TestBuilding',1, 1, GETDATE(), GETDATE() 
)
GO

INSERT INTO Segment VALUES(
	'TestSegment','N/A',1,1,1,GETDATE(), GETDATE()
)
GO

INSERT INTO BusinessUnit VALUES(
	'TestBU', 1, 1, 1, GETDATE(), GETDATE() 
)
GO

INSERT INTO Project VALUES(
	'TestProject', 1, 1, 1, 1, GETDATE(), GETDATE()
)
GO

INSERT INTO Line VALUES(
	'TestLine001', 1, 1, 0, 'B11-2F', 1, GETDATE(), GETDATE()
)
GO

INSERT INTO Station(Station_Name, StationComputerAddress, Is_Active, Line_Id, Position, Creator_Id, Creation_Time, Effect_Time) 
VALUES(
	'TestStation001', '10.200.43.12', 1, 1, 1, 1, GETDATE(), GETDATE()
)



INSERT INTO Station(Station_Name, StationComputerAddress, Is_Active, Line_Id, Position, Creator_Id, Creation_Time, Effect_Time) 
VALUES(
	'TestStation001', '10.200.43.12', 1, 1, 1, 1, GETDATE(), GETDATE()
)
