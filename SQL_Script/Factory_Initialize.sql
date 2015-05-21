 USE MASTER;
GO
-- CREATE ISPC DATABASE
IF  EXISTS(SELECT * FROM SysDatabases WHERE name='ISPC')	
	BEGIN
		DROP DATABASE ISPC			
	END
	
	CREATE DATABASE ISPC
		ON PRIMARY
		(
			NAME = 'ISPC_DAT',
			FILENAME = 'D:\ISPC Database\ISPC_DAT.MDF'
		)
		LOG ON
		(
			NAME = 'ISPC_LOG',
			FILENAME = 'D:\ISPC Database\ISPC_DAT.LDF'
		)
GO

USE ISPC;
GO
--CREATE UserProfile Table
CREATE TABLE [dbo].[UserProfile](
	[UserId] [int] IDENTITY(1,1) NOT NULL,
	[UserName] [nvarchar](56) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[UserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
--CREATE webpages_Membership Tabel
CREATE TABLE [dbo].[webpages_Membership](
	[UserId] [int] NOT NULL,
	[CreateDate] [datetime] NULL,
	[ConfirmationToken] [nvarchar](128) NULL,
	[IsConfirmed] [bit] NULL,
	[LastPasswordFailureDate] [datetime] NULL,
	[PasswordFailuresSinceLastSuccess] [int] NOT NULL,
	[Password] [nvarchar](128) NOT NULL,
	[PasswordChangedDate] [datetime] NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[PasswordVerificationToken] [nvarchar](128) NULL,
	[PasswordVerificationTokenExpirationDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[webpages_Membership] ADD  DEFAULT ((0)) FOR [IsConfirmed]
GO

ALTER TABLE [dbo].[webpages_Membership] ADD  DEFAULT ((0)) FOR [PasswordFailuresSinceLastSuccess]
GO
--CREATE webpages.OAuthMembership Table
CREATE TABLE [dbo].[webpages_OAuthMembership](
	[Provider] [nvarchar](30) NOT NULL,
	[ProviderUserId] [nvarchar](100) NOT NULL,
	[UserId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Provider] ASC,
	[ProviderUserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
--CREATE webpages_Roles Table
CREATE TABLE [dbo].[webpages_Roles](
	[RoleId] [int] IDENTITY(1,1) NOT NULL,
	[RoleName] [nvarchar](256) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[RoleName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
--CREATE webpages_UserInRoles Table
CREATE TABLE [dbo].[webpages_UsersInRoles](
	[UserId] [int] NOT NULL,
	[RoleId] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_RoleId] FOREIGN KEY([RoleId])
REFERENCES [dbo].[webpages_Roles] ([RoleId])
GO

ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_RoleId]
GO

ALTER TABLE [dbo].[webpages_UsersInRoles]  WITH CHECK ADD  CONSTRAINT [fk_UserId] FOREIGN KEY([UserId])
REFERENCES [dbo].[UserProfile] ([UserId])
GO

ALTER TABLE [dbo].[webpages_UsersInRoles] CHECK CONSTRAINT [fk_UserId]
GO

--CREATE Building Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE type='Building')
	CREATE TABLE Building(
		Building_Id INT IDENTITY(1,1) PRIMARY KEY,
		Building_Name NVARCHAR(200) NOT NULL,
		Is_Active BIT NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_UserProfile_Building FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)
	)
GO

--CREATE Segment Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Segment')
	CREATE TABLE Segment(
		Segment_Id INT IDENTITY(1,1) PRIMARY KEY,
		Segment_Name NVARCHAR(50) NOT NULL,
		Segment_Code NVARCHAR(50) NOT NULL,
		Is_Active BIT NOT NULL,
		Building_Id INT NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_Building_Segment FOREIGN KEY (Building_Id) REFERENCES Building(Building_Id),
		CONSTRAINT FK_UserProfile_Segment FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)
	)
GO

--CREATE BusinessUnit Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='BusinessUnit')
	CREATE TABLE BusinessUnit(
		BU_Id INT IDENTITY(1,1) PRIMARY KEY,
		BU_Name NVARCHAR(50) NOT NULL,
		Segment_Id INT NOT NULL,
		Is_Active BIT NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_Segment_BU FOREIGN KEY(Segment_Id) REFERENCES Segment(Segment_Id),
		CONSTRAINT FK_UserProfile_BusinessUnit FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)
		
	)
GO

--CREATE Project Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Project')
	CREATE TABLE Project(
		Project_Id INT IDENTITY(1,1) PRIMARY KEY,		
		Project_Name nvarchar(50) NOT NULL,
		Is_Active BIT NOT NULL,
		Segment_Id INT NOT NULL,
		BU_Id INT, --ALLOW NULL
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_BU_Project FOREIGN KEY(BU_Id) REFERENCES BusinessUnit(BU_Id),
		CONSTRAINT FK_Segment_Project FOREIGN KEY(Segment_Id) REFERENCES Segment(Segment_Id),
		CONSTRAINT FK_UserProfile_Project FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO

--CREATE Line Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Line')
	CREATE TABLE Line(
		Line_Id INT IDENTITY(1,1) PRIMARY KEY,
		Line_Name NVARCHAR(50) NOT NULL,
		Segment_Id INT NOT NULL,
		Is_Active BIT NOT NULL,
		Is_NPI BIT NOT NULL,
		Line_Location NVARCHAR(200) NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_Segment_Line FOREIGN KEY(Segment_Id) REFERENCES Segment(Segment_Id),		
		CONSTRAINT FK_UserProfile_Line FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO

--CREATE Machine_Brand Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Machine_Brand')
	CREATE TABLE Machine_Brand(
		Machine_Brand_Id INT IDENTITY(1,1) PRIMARY KEY,
		Machine_Brand_Name NVARCHAR(50) NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_UserProfile_Machine_Brand FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO
--CREATE Machine_Type Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Machine_Type')
	CREATE TABLE Machine_Type(
		Machine_Type_Id INT IDENTITY(1,1) PRIMARY KEY,
		Machine_Type_Name NVARCHAR(50) NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_UserProfile_Machine_Type FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO

--CREATE Machine_Model Tablew
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Machine_Model')
	CREATE TABLE Machine_Model(
		Machine_Model_Id INT IDENTITY(1,1) PRIMARY KEY,
		Machine_Brand_Id INT NOT NULL,
		Machine_Type_Id INT NOT NULL,
		Machine_Model_Name NVARCHAR(50) NOT NULL,
		Machine_Picture_Url NVARCHAR(200) NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_Machine_Brand_Machine_Model FOREIGN KEY(Machine_Brand_Id) REFERENCES Machine_Brand(Machine_Brand_Id),
		CONSTRAINT FK_Machine_Type_Machine_Model FOREIGN KEY(Machine_Type_Id) REFERENCES Machine_Type(Machine_Type_Id),
		CONSTRAINT FK_UserProfile_Machine_Model FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)			
	)
GO

--CREATE Machine_Status Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Machine_Status')
	CREATE TABLE Machine_Status(
		Machine_Status_Id INT IDENTITY(1,1) PRIMARY KEY,
		Machine_Status NVARCHAR(50) NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_UserProfile_Machine_Status FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO
--CREATE Machine Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Machine')
	CREATE TABLE Machine(
		Machine_Id INT IDENTITY(1,1) PRIMARY KEY,
		Machine_Asset_Num NVARCHAR(50) NOT NULL,
		Machine_Name NVARCHAR(50) NOT NULL,
		Machine_Status_Id INT NOT NULL,
		Machine_Model_Id INT NOT NULL,	
		Building_Id INT NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_Machine_Model_Machine FOREIGN KEY(Machine_Model_Id) REFERENCES Machine_Model(Machine_Model_Id),	
		CONSTRAINT FK_Machine_Status_Machine FOREIGN KEY(Machine_Status_Id) REFERENCES Machine_Status(Machine_Status_Id),
		CONSTRAINT FK_UserProfile_Machine FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO

--CREATE Station Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Station')
	CREATE TABLE Station(
		Station_Id INT IDENTITY(1,1) PRIMARY KEY,
		Station_Name NVARCHAR(50) NOT NULL,
		StationComputerAddress NVARCHAR(200) NOT NULL,
		Machine_Id INT,
		Is_Active BIT NOT NULL,
		Line_Id INT NOT NULL,
		Position INT NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		Effect_Time DATETIME NOT NULL,
		CONSTRAINT FK_Machine_Station FOREIGN KEY(Machine_Id) REFERENCES Machine(Machine_Id),
		CONSTRAINT FK_Line_Station FOREIGN KEY(Line_Id) REFERENCES Line(Line_Id),
		CONSTRAINT FK_UserProfile_Station FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)		
	)
GO

--CREATE Model Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Model')
	CREATE TABLE Model(
		Model_Id INT IDENTITY(1,1)PRIMARY KEY,
		Model_Name NVARCHAR(200) NOT NULL,
		[Type] NVARCHAR(50) NOT NULL,
		Project_Id INT,
		Components NVARCHAR(max),
		CpkComponents NVARCHAR(max),
		XBarComponents NVARCHAR(max),
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_Project_Model FOREIGN KEY(Project_Id) REFERENCES Project(Project_Id),
		CONSTRAINT FK_UserProfile_Model FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId)
	)
GO

--Create Result Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Result')
	CREATE TABLE Result(
		Result_Id INT IDENTITY(1,1) PRIMARY KEY,
		Result_Name NVARCHAR(50) NOT NULL,
		[Description] NVARCHAR(200),
		MachineBrandName NVARCHAR(200),
		Machine_Type_Id int NOT NULL,
		Creator_Id INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_UserProfile_Result FOREIGN KEY(Creator_Id) REFERENCES UserProfile(UserId),
		CONSTRAINT FK_Machine_Type_Result FOREIGN KEY(Machine_Type_Id) REFERENCES Machine_Type(Machine_Type_Id)
	)
GO

--CREATE SPI_Panel Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='SPI_Panel')
	CREATE TABLE SPI_Panel(
		Panel_Id INT IDENTITY(1,1),
		Station_Id INT NOT NULL,
		Model_Id INT NOT NULL,
		Unit NVARCHAR(50),
		Operator_Name NVARCHAR(50),
		Panel_Barcode NVARCHAR(200),
		Total_Pads_Num INT NOT NULL,
		Error_Pads_Num INT NOT NULL,
		Squeegee NVARCHAR(50),
		Start_Time DATETIME NOT NULL,
		End_Time DATETIME NOT NULL,
		Cycle_Time FLOAT NOT NULL,
		Result_Id int NOT NULL,
		Volume_Avg FLOAT NOT NULL,
		Height_Avg FLOAT NOT NULL,
		Area_Avg FLOAT NOT NULL,
		Timespan DATETIME NOT NULL,
		Cp FLOAT,
		Cpk FLOAT,
		CONSTRAINT PK_SPI_Panel PRIMARY KEY NONCLUSTERED (Panel_Id),
		CONSTRAINT FK_Model_SPI_Panel FOREIGN KEY(Model_Id) REFERENCES Model(Model_Id),		
		CONSTRAINT FK_Station_SPI_Panel FOREIGN KEY(Station_Id) REFERENCES 	Station(Station_Id),
		CONSTRAINT FK_Result_SPI_Panel FOREIGN KEY(Result_Id) REFERENCES Result(Result_Id)
	)
GO

--CREATE SPI_Board table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='SPI_Board')
	CREATE TABLE SPI_Board(
		Board_Id INT IDENTITY(1,1),
		Panel_Id INT NOT NULL,
		Board_Name NVARCHAR(50) NOT NULL,
		Board_Barcode NVARCHAR(200) NOT NULL,
		Result_Id INT NULL,
		TotalPads_Num INT NOT NULL,
		ErrorPads_Num INT NOT NULL,
		CONSTRAINT PK_SPI_Board PRIMARY KEY NONCLUSTERED (Board_Id),
		CONSTRAINT FK_SPI_Panel_SPI_Board FOREIGN KEY(Panel_Id) REFERENCES SPI_Panel(Panel_Id),
		CONSTRAINT FK_Result_SPI_Board FOREIGN KEY(Result_Id) REFERENCES Result(Result_Id)
	)
GO
--CREATE Defect_Type table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Defect_Type')
	CREATE TABLE Defect_Type(
		Defect_Type_Id INT IDENTITY(1,1) PRIMARY KEY,
		Defect_Type_Name NVARCHAR(50) NOT NULL,
		[Description] NVARCHAR(200),
		MachineBrandName NVARCHAR(200),
		Machine_Type_Id INT NOT NULL,
		CreatorId INT NOT NULL,
		Creation_Time DATETIME NOT NULL,
		CONSTRAINT FK_Machine_Type_Defect_Type FOREIGN KEY(Machine_Type_Id) REFERENCES Machine_Type(Machine_Type_Id)
	)
GO

--CREATE SPI_Pad table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='SPI_Pad')
	CREATE TABLE SPI_Pad(
		Pad_Id INT IDENTITY(1,1),
		Board_Id INT NOT NULL,
		Component_Name NVARCHAR(50),
		Defect_Type_Id INT NOT NULL,
		Height FLOAT,
		Real_Area FLOAT,
		Area FLOAT,
		Real_Volume FLOAT,
		Volume FLOAT,
		Offset_X FLOAT,
		Offset_Y FLOAT,
		Position_X FLOAT,
		Position_Y FLOAT,
		Pad_X FLOAT,
		Pad_Y FLOAT,
		CONSTRAINT PK_SPI_Pad PRIMARY KEY NONCLUSTERED (Pad_Id),
		CONSTRAINT FK_SPI_Board_SPI_Pad FOREIGN KEY(Board_Id) REFERENCES SPI_Board(Board_Id),
		CONSTRAINT FK_Defect_Type_SPI_Pad FOREIGN KEY(Defect_Type_Id) REFERENCES Defect_Type(Defect_Type_Id)
	)
GO
--Create Feeder Table
IF NOT EXISTS(SELECT Name FROM sysobjects WHERE TYPE='Feeder')
	CREATE TABLE Feeder(
		Feeder_Id INT IDENTITY(1,1) PRIMARY KEY,
		Station_Id INT NOT NULL,
		CONSTRAINT FK_Station_Feeder FOREIGN KEY(Station_Id) REFERENCES Station(Station_Id)
	)
GO

--Create AOI_Panel Table
CREATE TABLE AOI_Panel
(
	Panel_Id INT IDENTITY(1,1),
	Station_Id INT NOT NULL,
	Panel_Barcode NVARCHAR(200),
	Model_Id INT NOT NULL,
	Start_Time DATETIME NOT NULL,
	End_Time DATETIME NOT NULL,
	Cycle_Time FLOAT NOT NULL,
	Result_Id INT NOT NULL,
	Operator_Name NVARCHAR(50),
	Total_Comps_Num INT,
	Total_Pins_Num INT,
	Indict_Comps_Num INT,
	Indict_Pins_Num INT,
	Defect_Num INT,
	Active_Defect_Num INT,
	Active_Pins_Num INT,
	Active_Comps_Num INT,
	FalseCall_Defect_Num INT,
	FalseCall_Pins_Num INT,
	FalseCall_Comps_Num INT,
	Timespan DATETIME NOT NULL,
	CONSTRAINT PK_AOI_Panel PRIMARY KEY NONCLUSTERED (Panel_Id),
	CONSTRAINT FK_Model_AOI_Panel FOREIGN KEY(Model_Id) REFERENCES Model(Model_Id),
	CONSTRAINT FK_Station_AOI_Panel FOREIGN KEY(Station_Id) REFERENCES Station(Station_Id),
	CONSTRAINT FK_Result_AOI_Panel FOREIGN KEY(Result_Id) REFERENCES Result(Result_Id)
)
GO

CREATE TABLE AOI_Board
(
	Board_Id INT IDENTITY(1,1),
	Panel_Id INT NOT NULL,
	Board_Barcode NVARCHAR(200),
	Result_Id INT NOT NULL,
	Total_Comps_Num INT,
	Total_Pins_Num INT,
	Indict_Comps_Num INT,
	Indict_Pins_Num INT,
	Defect_Num INT,
	Active_Defect_Num INT,
	Active_Pins_Num INT,
	Active_Comps_Num INT,
	FalseCall_Defect_Num INT,
	FalseCall_Pins_Num INT,
	FalseCall_Comps_Num INT,
	CONSTRAINT PK_AOI_Board PRIMARY KEY NONCLUSTERED (Board_Id),
	CONSTRAINT FK_AOI_Panel_AOI_Board FOREIGN KEY(Panel_Id) REFERENCES AOI_Panel(Panel_Id),
	CONSTRAINT FK_Result_AOI_Board FOREIGN KEY(Result_Id) REFERENCES Result(Result_Id)
)	
GO

CREATE TABLE AOI_Component
(
	Component_Id INT IDENTITY(1,1),
	Board_Id INT NOT NULL,
	Component_Name NVARCHAR(50) NOT NULL,
	Defect_Type_Id INT NOT NULL,
	Repair_State_Result_Id INT NOT NULL,
	Algorithm NVARCHAR(200),
	PartNumber NVARCHAR(200),
	Feeder_Id INT,
	RemarkDefectType NVARCHAR(200),
	CONSTRAINT PK_AOI_Component PRIMARY KEY NONCLUSTERED (Component_Id),
	CONSTRAINT FK_Feeder_AOI_Component FOREIGN KEY(Feeder_Id) REFERENCES Feeder(Feeder_Id),
	CONSTRAINT FK_AOI_Board_AOI_Component FOREIGN KEY(Board_Id) REFERENCES AOI_Board(Board_Id),
	CONSTRAINT FK_Defect_Type_AOI_Component FOREIGN KEY(Defect_Type_Id) REFERENCES Defect_Type(Defect_Type_Id),	
	CONSTRAINT FK_Result_AOI_Component FOREIGN KEY(Repair_State_Result_Id) REFERENCES Result(Result_Id)
)	
GO

--Building the CLUSTERED Index on SPI table and AOI table 
CREATE CLUSTERED INDEX StationId_index
	ON AOI_Panel(Station_Id)
GO

CREATE CLUSTERED INDEX BoardId_index
	ON AOI_Component(Board_Id)
GO

CREATE CLUSTERED INDEX PanelId_index
	ON AOI_Board(Panel_Id)
GO

CREATE CLUSTERED INDEX StationId_index
	ON SPI_Panel(Station_Id)
GO

CREATE CLUSTERED INDEX BoardId_index
	ON SPI_Pad(Board_Id)
GO

CREATE CLUSTERED INDEX PanelId_index
	ON SPI_Board(Panel_Id)
GO
--Building the CLUSTERED Index on SPI table and AOI table

--Building the NONCLUSTERED Index on the frequently utilized table
CREATE NONCLUSTERED INDEX UserId_index
	ON Building(Creator_Id)
GO

CREATE NONCLUSTERED INDEX BuildingIdindex
	ON Segment(Building_Id)
GO

CREATE NONCLUSTERED INDEX SegmentId_index
	ON BusinessUnit(Segment_Id)
GO

CREATE NONCLUSTERED INDEX SegmentId_BUId_index
	ON Project(Segment_Id, BU_Id)
GO

CREATE NONCLUSTERED INDEX SegmentId_index
	ON Line(Segment_Id)
GO

CREATE NONCLUSTERED INDEX LineId_MachineId_index
	ON Station(Line_Id, Machine_Id)
GO

CREATE NONCLUSTERED INDEX ModelId_StartTime_EndTime_ResultId_index
	ON SPI_Panel(Model_Id,Start_Time, End_Time, Result_Id)
GO

CREATE NONCLUSTERED INDEX ComponentName_DefectTypeId_index
	ON SPI_Pad(Component_Name, Defect_Type_Id)
GO

CREATE NONCLUSTERED INDEX Description_Machine_Type_Id_index
	ON Defect_Type([Description], Machine_Type_Id)
GO

CREATE NONCLUSTERED INDEX PanelId_BoardName_index
	ON SPI_Board(Panel_Id, Board_Name)
GO

CREATE NONCLUSTERED INDEX ModelName_Type_index
	ON Model(Model_Name, [Type])
GO
--Building the NONCLUSTERED Index on the frequently utilized table