USE ISPC
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE user_SPIXmlReader
	@signal_xml nvarchar(max),
	@signal_xml_def nvarchar(max),
	@error_code int out,
	@error_message_xml nvarchar(max) out,
	@filename nvarchar(200) out
AS
BEGIN
	BEGIN TRAN
	
	-- Panel level we only catch one row data. 
	--So initialize the  partial variable
	BEGIN
	
		--Input the xml variable
		DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT, @signal_xml
		
		-- read the data of RecevicedData section
		BEGIN
			DECLARE 
				@DataReceivedType nvarchar(200),
				@LineId int,	
				@StationId int,						
				@StationType nvarchar(200),
				@MachineName nvarchar(200),
				@MachineId nvarchar(200),
				@MachineComment nvarchar(200),
				@MachineSoftwareVersion nvarchar(200),
				@AssetManagementNum nvarchar(200),
				@StationComputerAddress nvarchar(200)	
			SELECT TOP 1
				@DataReceivedType = DataReceivedType,
				@LineId = LineId,	
				@StationId = StationId,							
				@StationType = StationType,
				@MachineName = MachineName,
				@MachineId = MachineId,
				@MachineComment = MachineComment,
				@MachineSoftwareVersion = MachineSoftwareVersion,
				@AssetManagementNum = AssetManagementNum,
				@StationComputerAddress = StationComputerAddress
			FROM OPENXML(@idoc, '/ReceivedData', 1)
			WITH(
				DataReceivedType nvarchar(200),
				LineId int,
				StationId int,				
				StationType nvarchar(200),
				MachineName nvarchar(200),
				MachineId int,
				MachineComment nvarchar(200),
				MachineSoftwareVersion nvarchar(200),
				AssetManagementNum nvarchar(200),
				StationComputerAddress nvarchar(200)	
			)		
		END
		-- read the data of RecevicedData section
		
		
		--read the data of ModelInfo section
		BEGIN 
			DECLARE
				@ModelId int,
				@ModelName nvarchar(200),
				@ModelCreationTime datetime,
				@ModelComponentsName nvarchar(max)		
			SELECT TOP 1
				@ModelName = RecipeName,
				@ModelCreationTime = StartTime,
				@ModelComponentsName = ComponentsName
			FROM OPENXML(@idoc, '/ReceivedData/ModelInfo', 1)
			WITH(
				RecipeName nvarchar(200),
				StartTime datetime,
				ComponentsName nvarchar(max)
			)
			SELECT @ModelId=Model_Id 
			FROM Model 
			WHERE Model_Name = @ModelName AND [Type]=@StationType			
			IF ISNULL(@ModelId, 0) = 0
				BEGIN					
					INSERT INTO Model(Model_Name, [Type], Components, Creator_Id, Creation_Time) VALUES(@ModelName, @StationType, @ModelComponentsName, 1, @ModelCreationTime)
					SET @ModelId = @@IDENTITY;
				END	
		END
		--Read the data of ModelInfo section
		
		--Read the data of Panel section
		BEGIN
			DECLARE
				@PanelId int,
				@PanelBarcode nvarchar(200),
				@InspectionUnit nvarchar(50),
				@ResultId int,
				@ProcessStatus nvarchar(50),
				@OperatorName nvarchar(50),
				@TotalPadsQty int,
				@ErrorPadsQty int,
				@Squeegee nvarchar(50),
				@ProcessStartTime datetime,
				@ProcessEndTime datetime,
				@ProcessCycleTime float,
				@VolumeAvg float,
				@HeightAvg float,
				@AreaAvg float		
			SELECT TOP 1
				@PanelBarcode = Barcode,
				@InspectionUnit = InspectionUnit,
				@ProcessStatus = ProcessStatus,
				@OperatorName = OperatorName,
				@TotalPadsQty = TotalPadsQty,
				@ErrorPadsQty = ErrorPadsQty,
				@Squeegee = Squeegee,
				@ProcessStartTime = ProcessStartTime,
				@ProcessEndTime = ProcessEndTime,
				@ProcessCycleTime = ProcessCycleTime,
				@VolumeAvg = VolumeAvg,
				@HeightAvg = HeightAvg,
				@AreaAvg = AreaAvg
			FROM OPENXML(@idoc, 'ReceivedData/PanelInfo', 1)
			WITH(
				Barcode nvarchar(200),
				InspectionUnit nvarchar(50),
				ProcessStatus nvarchar(50),
				OperatorName nvarchar(50),
				TotalPadsQty int,
				ErrorPadsQty int,
				Squeegee nvarchar(50),
				ProcessStartTime datetime,
				ProcessEndTime datetime,
				ProcessCycleTime float,
				VolumeAvg float,
				HeightAvg float,
				AreaAvg float
			)		
		END	
		--Read the data of Panel section
		
		--Integrated the RecevicedData section, ModelInfo section and Panel section
		BEGIN
			SELECT @ResultId = Result_Id FROM Result WHERE [Description] = @ProcessStatus AND Machine_Type_Id = 3
			IF ISNULL(@ResultId, 0) = 0
			BEGIN
				INSERT INTO Result VALUES('Unknown', @ProcessStatus, @MachineName, 3, 1, GETDATE())
				SET @ResultId = @@IDENTITY	
			END 
						
			INSERT INTO SPI_Panel VALUES(
				@StationId,
				@ModelId,
				@InspectionUnit,
				@OperatorName,
				@PanelBarcode,
				@TotalPadsQty,
				@ErrorPadsQty,
				@Squeegee,
				@ProcessStartTime,
				@ProcessEndTime,
				@ProcessCycleTime,
				@ResultId,
				@VolumeAvg,
				@HeightAvg,
				@AreaAvg,
				GETDATE(),
				0,
				0
			)
			SET @PanelId = @@IDENTITY
		END
		--Integrated the RecevicedData section, ModelInfo section and Panel section
		
		--Read board list data from file based on one panel and stored into SPI_Board
		BEGIN
			IF EXISTS (SELECT * FROM tempdb..sysobjects (NOLOCK) WHERE id=OBJECT_ID('tempdb..#TempBoardDetail')) 
			DROP TABLE #TempBoardDetail
			CREATE TABLE #TempBoardDetail(
				PanelId int,
				BoardName nvarchar(50) COLLATE DATABASE_DEFAULT,
				BoardBarcode nvarchar(200) COLLATE DATABASE_DEFAULT,
				ResultDescription nvarchar(200) COLLATE DATABASE_DEFAULT,
				TotalPads int,
				ErrorPads int
			)
						
			INSERT INTO #TempBoardDetail  
			SELECT @PanelId, BoardName, BoardBarcode, ProcessStatus, TotalPads, ErrorPads
			FROM OPENXML(@idoc, '/ReceivedData/PanelInfo/SPIBoardsDetail/SPIBoard', 1) 
			WITH(
				BoardName nvarchar(50), 
				BoardBarcode nvarchar(200),
				ProcessStatus nvarchar(200),
				TotalPads int,
				ErrorPads int	
			)
			
			INSERT INTO SPI_Board
			SELECT tb.PanelId, tb.BoardName, tb.BoardBarcode, r.Result_Id, tb.TotalPads, tb.ErrorPads
			FROM #TempBoardDetail tb
			LEFT JOIN Result r ON r.[Description] = tb.ResultDescription AND r.Machine_Type_Id = 3
			
		END		
		--Read board list data from file based on one panel
		
		--stored the pad details to the TempPadDetail table
		BEGIN
			IF EXISTS (SELECT * FROM tempdb..sysobjects (NOLOCK) WHERE id=OBJECT_ID('tempdb..#TempPadDetail')) 
			DROP TABLE #TempPadDetail
			CREATE TABLE #TempPadDetail(
				PadId int,				
				BoardName nvarchar(50) COLLATE DATABASE_DEFAULT,
				ComponentName nvarchar(50) COLLATE DATABASE_DEFAULT,
				DefectType nvarchar(50) COLLATE DATABASE_DEFAULT,				
				Height float,
				RealArea float,
				Area float,
				RealVolume float,
				Volume float,
				OffsetX float,
				OffsetY float,
				PositionX float,
				PositionY float,
				PadX float,
				PadY float	
			)
			INSERT INTO #TempPadDetail			
			SELECT *
			FROM OPENXML(@idoc, '/ReceivedData/PanelInfo/SPIBoardsDetail/SPIBoard/SPIPadsDetail/SPIPad', 1)		
			WITH(
				PadId int,
				BoardName nvarchar(50) '../../@BoardName',
				ComponentName nvarchar(50),
				DefectType nvarchar(50),
				Height float,
				RealArea float,
				Area float,
				RealVolume float,
				Volume float,
				OffsetX float,
				OffsetY float,
				PositionX float,
				PositionY float,
				PadX float,
				PadY float
			)
			
		END 
				
		--stored the pad details to the TempPadDetail table			
		BEGIN						
		DECLARE @TempDefectTypeId int
		DECLARE @Description nvarchar(200)		
		DECLARE My_Cursor CURSOR -- define the cursor
		FOR (SELECT p.DefectType FROM #TempPadDetail p GROUP BY P.DefectType)
		OPEN My_Cursor;
		FETCH NEXT FROM My_Cursor INTO @Description;
		WHILE @@FETCH_STATUS = 0
			BEGIN
				SET @TempDefectTypeId = NULL;																
				SELECT @TempDefectTypeId = d.Defect_Type_Id FROM Defect_Type d WHERE d.[Description] = @Description AND d.Machine_Type_Id = 3											
				IF(ISNULL(@TempDefectTypeId, 0) = 0)
				BEGIN					
					INSERT INTO Defect_Type VALUES('Unknown', @Description, @MachineName, 3, 1, GETDATE())									
				END					
				FETCH NEXT FROM My_Cursor INTO @Description;
			END
		CLOSE My_Cursor; 
		DEALLOCATE My_Cursor;	
		END
		
		--pour into pad data to the SPI_Pad
		BEGIN			
			INSERT INTO SPI_Pad
			SELECT b.Board_Id, p.ComponentName,d.Defect_Type_Id, p.Height,
			p.RealArea, p.Area, p.RealVolume, p.Volume, p.OffsetX, p.OffsetY, p.PositionX, p.PositionY, p.PadX, p.PadY
			FROM #TempPadDetail p
			LEFT JOIN SPI_Board b ON b.Board_Name = p.BoardName AND b.Panel_Id = @PanelId
			LEFT JOIN Defect_Type d ON d.[Description] = p.DefectType	AND d.Machine_Type_Id = 3						
		END
	END
	DROP TABLE #TempPadDetail;
	DROP TABLE #TempBoardDetail;
	EXEC sp_xml_removedocument @idoc
	
	COMMIT
	
	RETURN 0

END