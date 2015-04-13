USE ISPC
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE user_AOIXmlReader
	@signal_xml nvarchar(max),
	@signal_xml_def nvarchar(max),
	@error_code int out,
	@error_message_xml nvarchar(max) out,
	@filename nvarchar(200) out
AS
BEGIN
	BEGIN TRAN
	-- Panel level we only catch one row data, so initialize the partial variable
	BEGIN
		--Input the xml variable
		DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT, @signal_xml
		
		
		--read the data of RecevicedData section
		BEGIN
			DECLARE
				@DataReceivedType nvarchar(200),
				@LineId int,
				@StationId int,
				@StationName nvarchar(200),
				@StationType nvarchar(200),
				@MachineName nvarchar(200),
				@MachineId int,
				@MachineComment nvarchar(200),
				@MachineSoftwareVersion nvarchar(200),
				@AssetManagementNum nvarchar(200),
				@StationComputerAddress nvarchar(200)
			SELECT TOP 1
				@DataReceivedType = DataReceivedType,
				@LineId = LineId,
				@StationId = StationId,
				@StationName = StationName,
				@StationType = StationType,
				@MachineName = MachineName,
				@MachineId = MachineId,
				@MachineComment = MachineComment,
				@MachineSoftwareVersion = MachineSoftwareVersion,
				@AssetManagementNum = AssetManagementNum
			FROM OPENXML(@idoc, '/ReceivedData', 1)
			WITH(
				DataReceivedType nvarchar(200),
				LineId int,
				StationId int,
				StationName nvarchar(200),
				StationType nvarchar(200),
				MachineName nvarchar(200),
				MachineId int,
				MachineComment nvarchar(200),
				MachineSoftwareVersion nvarchar(200),
				AssetManagementNum nvarchar(200),
				StationComputerAddress nvarchar(200)				
			)	
		END
		
		
		--read the data of ModelInfo section
		BEGIN
			DECLARE 
				@ModelId int,
				@ModelName nvarchar(200),
				@ModelCreationTime datetime
			SELECT TOP 1
				@ModelName = RecipeName,
				@ModelCreationTime = StartTime
			FROM OPENXML(@idoc, '/ReceivedData/ModelInfo', 1)
			WITH(
				RecipeName nvarchar(200),
				StartTime datetime				
			)
			SELECT @ModelId = Model_Id 
			FROM Model 
			WHERE Model_Name = @ModelName AND [Type] = @StationType
			IF ISNULL(@ModelId, 0) = 0
				BEGIN
					INSERT INTO Model(Model_Name, [Type], Creator_Id, Creation_Time)
					VALUES(@ModelName, @StationType, 1, @ModelCreationTime)
					SET @ModelId = @@IDENTITY;				
				END
		END
		
		
		--Read the data of Panel section
		BEGIN
			DECLARE
				@PanelId int,
				@ResultId int,
				@PanelBarcode nvarchar(200),
				@ProcessStartTime datetime,
				@ProcessEndTime datetime,
				@ProcessCycleTime float,
				@ProcessStatus nvarchar(50),
				@OperatorName nvarchar(50),
				@TotalCompsTestedQty int,
				@TotalPinsQty int,
				@IndictCompsQty int,
				@IndictPinsQty int,
				@DefectQty int,
				@ActiveCompsQty	int,
				@ActivePinsQty int,
				@ActiveDefectQty int,								
				@FalseCallCompsQty int,
				@FalseCallPinsQty int,
				@FalseCallDefectQty int								
			SELECT TOP 1
				@PanelBarcode = Barcode,
				@ProcessStartTime = ProcessStartTime,
				@ProcessEndTime = ProcessEndTime,
				@ProcessCycleTime = ProcessCycleTime,
				@ProcessStatus = Result,
				@OperatorName = OperatorName,
				@TotalCompsTestedQty = TotalCompsTestedQty,
				@TotalPinsQty = TotalPinsQty,
				@IndictCompsQty = IndictCompsQty,
				@IndictPinsQty = IndictPinsQty,
				@DefectQty = DefectQty,
				@ActiveCompsQty = ActiveCompsQty,
				@ActivePinsQty = ActivePinsQty,
				@ActiveDefectQty = ActiveDefectQty,
				@FalseCallCompsQty = FalseCallCompsQty,
				@FalseCallPinsQty = FalseCallPinsQty,
				@FalseCallDefectQty = FalseCallDefectQty
			FROM OPENXML(@idoc, 'ReceivedData/PanelInfo', 1)
			WITH(
				Barcode nvarchar(200),
				ProcessStartTime datetime,
				ProcessEndTime datetime,
				ProcessCycleTime float,
				Result nvarchar(50),
				OperatorName nvarchar(50),
				TotalCompsTestedQty int,
				TotalPinsQty int,
				IndictCompsQty int,
				IndictPinsQty int,
				DefectQty int,
				ActiveCompsQty int,
				ActivePinsQty int,
				ActiveDefectQty int,
				FalseCallDefectQty int,
				FalseCallPinsQty int,
				FalseCallCompsQty int				
			)												
		END
		
		
		--Integrated the RecevicedData section, ModelInfo section and Panel section
		BEGIN
			SELECT @ResultId = Result_Id FROM Result WHERE [Description] = @ProcessStatus AND Machine_Type_Id = 4
			IF ISNULL(@ResultId, 0) = 0
			BEGIN
				INSERT INTO Result VALUES('Unknown', @ProcessStatus, @MachineName, 4, 1, GETDATE())
				SET @ResultId =@@IDENTITY
			END
			
			INSERT INTO AOI_Panel VALUES(
				@StationId,
				@PanelBarcode,
				@ModelId,
				@ProcessStartTime,
				@ProcessEndTime,
				@ProcessCycleTime,
				@ResultId,
				@OperatorName,
				@TotalCompsTestedQty,
				@TotalPinsQty,
				@IndictCompsQty,
				@IndictPinsQty,
				@DefectQty,				
				@ActiveDefectQty,
				@ActivePinsQty,
				@ActiveCompsQty,
				@FalseCallDefectQty,
				@FalseCallPinsQty,
				@FalseCallCompsQty,				
				GETDATE()
			)
			SET @PanelId = @@IDENTITY
		END
		
		
		--Read board list data from file based on one panel and stored into SPI_Board
		BEGIN
			IF EXISTS(SELECT *FROM tempdb..sysobjects(NOLOCK) WHERE id=OBJECT_ID('TEMPD..#TempBoardDetail'))
			DROP TABLE #TempBoardDetail
			CREATE TABLE #TempBoardDetail(
				PanelId int,
				BoardBarcode nvarchar(200) COLLATE DATABASE_DEFAULT,
				ProcessStatus nvarchar(200) COLLATE DATABASE_DEFAULT,
				TotalCompsTestedQty int ,
				TotalPinsQty int ,
				IndictCompsQty int ,
				IndictPinsQty int ,
				DefectQty int ,
				ActiveDefectQty int,
				ActivePinsQty int ,
				ActiveCompsQty int,
				FalseCallDefectQty int,
				FalseCallPinsQty int ,
				FalseCallCompsQty int 						
			)
			
			INSERT INTO #TempBoardDetail
			SELECT @PanelId, Barcode, Result, TotalCompsTestedQty, TotalPinsQty, IndictCompsQty, IndictPinsQty, DefectQty,
				   ActiveDefectQty, ActivePinsQty, ActiveCompsQty, FalseCallDefectQty, FalseCallPinsQty, FalseCallCompsQty
			FROM OPENXML(@idoc, 'ReceivedData/PanelInfo/BoardInfo', 1)
			WITH(
				Barcode nvarchar(200),
				Result nvarchar(200),
				TotalCompsTestedQty int,
				TotalPinsQty int,
				IndictCompsQty int,
				IndictPinsQty int,
				DefectQty int,
				ActiveDefectQty int,
				ActivePinsQty int,
				ActiveCompsQty int,
				FalseCallDefectQty int,
				FalseCallPinsQty int,
				FalseCallCompsQty int
			)
			INSERT INTO AOI_Board
			SELECT tb.PanelId, tb.BoardBarcode,r.Result_Id, tb.TotalCompsTestedQty,
				tb.TotalPinsQty, tb.IndictCompsQty, tb.IndictPinsQty, tb.DefectQty,
				tb.ActiveDefectQty, tb.ActivePinsQty, tb.ActiveCompsQty, tb.FalseCallDefectQty,
				tb.FalseCallPinsQty, tb.FalseCallCompsQty
			FROM #TempBoardDetail tb
			LEFT JOIN Result r ON r.Description = tb.ProcessStatus	AND r.Machine_Type_Id = 4
		END		
		
	
		--stored the component details to the TempCompDetail table
		BEGIN
			IF EXISTS(SELECT * FROM tempdb..sysobjects(NOLOCK) WHERE id=OBJECT_ID('tempdb..#TempCompDetail'))
			DROP TABLE #TempCompDetail
			CREATE TABLE #TempCompDetail(
				BoardBarcode nvarchar(200) COLLATE DATABASE_DEFAULT,
				ComponentName nvarchar(50) COLLATE DATABASE_DEFAULT,
				DefectType	nvarchar(50) COLLATE DATABASE_DEFAULT,
				RepairResult nvarchar(200) COLLATE DATABASE_DEFAULT,
				Algorithm nvarchar(200) COLLATE DATABASE_DEFAULT,
				PartNumber nvarchar(200) COLLATE DATABASE_DEFAULT,
				RemarkDefectType nvarchar(200) COLLATE DATABASE_DEFAULT		
			)	
			INSERT INTO #TempCompDetail
			SELECT *
			FROM OPENXML(@idoc, 'ReceivedData/PanelInfo/BoardInfo/ComponentInfo', 1)
			WITH(
				BoardBarcode nvarchar(200) '../@Barcode',
				ComponentName nvarchar(50),
				IndictDefectType nvarchar(50),
				RepairStatus nvarchar(200),
				Algorithm nvarchar(200),
				PartNumber nvarchar(200),
				OriginalDefect nvarchar(200)
			)		
		END
		
		
		--add the new result and new defect type
		BEGIN
			DECLARE @TempDefectTypeId int
			DECLARE	@Description nvarchar(200)
			DECLARE	My_Cursor CURSOR -- define the cursor
			FOR(SELECT c.DefectType FROM #TempCompDetail c GROUP BY c.DefectType)
			OPEN My_Cursor;
			FETCH NEXT FROM My_Cursor INTO @Description;
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @TempDefectTypeId = NULL;
					SELECT @TempDefectTypeId = d.Defect_Type_Id	FROM Defect_Type d 
					WHERE d.Description = @Description AND d.Machine_Type_Id = 4
					IF(ISNULL(@TempDefectTypeId, 0) = 0)
					BEGIN
						INSERT INTO Defect_Type VALUES('Unknown', @Description, @MachineName, 4, 1, GETDATE())
					END
					FETCH NEXT FROM My_Cursor INTO @Description;
				END
			CLOSE My_Cursor; 
			DEALLOCATE My_Cursor;	
		END		
		BEGIN
			DECLARE @TempResultId int
			DECLARE @ResultDescription nvarchar(200)
			DECLARE My_Cursor2 CURSOR --define the cursor
			FOR (SELECT c.RepairResult FROM #TempCompDetail c GROUP BY c.RepairResult)
			OPEN My_Cursor2;
			FETCH NEXT FROM My_Cursor2 INTO @ResultDescription;
			WHILE @@FETCH_STATUS = 0
				BEGIN
					SET @TempResultId = NULL;
					SELECT @TempResultId = r.Result_Id FROM Result r
					WHERE r.Description = @ResultDescription AND r.Machine_Type_Id = 4
					IF(ISNULL(@TempResultId, 0) = 0)
					BEGIN 
						INSERT INTO Result VALUES('Unknown', @ResultDescription, @MachineName, 4, 1, GETDATE())						
					END
					FETCH NEXT FROM My_Cursor2 INTO @ResultDescription;
				END
			CLOSE My_Cursor2;
			DEALLOCATE My_Cursor2;
		END				
			
		--pour into component data to the AOI_Component
		BEGIN			
			INSERT INTO AOI_Component(Board_Id, Component_Name, Defect_Type_Id, Repair_State_Result_Id, Algorithm, PartNumber, RemarkDefectType)
			SELECT b.Board_Id, c.ComponentName, d.Defect_Type_Id, r.Result_Id, c.Algorithm, c.PartNumber, C.RemarkDefectType
			FROM #TempCompDetail c
			LEFT JOIN AOI_Board b ON b.Board_Barcode = c.BoardBarcode AND b.Panel_Id = @PanelId
			LEFT JOIN Defect_Type d ON d.Description = c.DefectType	AND d.Machine_Type_Id = 4
			LEFT JOIN Result r ON r.Description = c.RepairResult AND r.Machine_Type_Id = 4
		END
		
	
	END
	DROP TABLE #TempCompDetail;
	DROP TABLE #TempBoardDetail;
	EXEC sp_xml_removedocument @idoc
	COMMIT
	RETURN 0
END