USE ISPC
GO

-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE user_ISPCXmlReader
	@signal_xml nvarchar(max),
	@signal_xml_def nvarchar(max),
	@error_code int out,
	@error_message_xml nvarchar(max) out,
	@filename nvarchar(200) out
AS
BEGIN
	
	-- Panel level we only catch one row data, so initialize the partial variable
	BEGIN
		--Input the xml variable
		DECLARE @idoc int
		EXEC sp_xml_preparedocument @idoc OUTPUT, @signal_xml
		--read the data of RecevicedData section
		BEGIN
			DECLARE
				@DataReceivedType nvarchar(200)				
			SELECT TOP 1
				@DataReceivedType = DataReceivedType				
			FROM OPENXML(@idoc, '/ReceivedData', 1)
			WITH(
				DataReceivedType nvarchar(200)										
			)	
			
			EXEC sp_xml_removedocument @idoc
						
			IF(@DataReceivedType = 'SPI')
				BEGIN
					exec user_SPIXmlReader @signal_xml, @signal_xml_def, @error_code out, @error_message_xml out, @filename out;
				END
			ELSE IF(@DataReceivedType = 'AOI')
				BEGIN 
					exec user_AOIXmlReader @signal_xml, @signal_xml_def, @error_code out, @error_message_xml out, @filename out;
				END
			ELSE
				BEGIN
					exec user_AOIXmlReader @signal_xml, @signal_xml_def, @error_code out, @error_message_xml out, @filename out;
				END
		END
	END			
	RETURN 0

END