USE ISPC;
Declare 
	@signal_xml nvarchar(max),
	@signal_xml_def nvarchar(max),
	@error_code int,
	@error_message_xml nvarchar(max),
	@filename nvarchar(200)
	set @signal_xml = '<ReceivedData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" DataReceivedType="AOI" LineId="1" StationName="DMNM1331" StationId="3" StationType="AOI" MachineName="AOIViTroxAgilent SJ50" MachineId="1" MachineComment="Its station adapter" MachineSoftwareVersion="001" AssetManagementNum="N/A" StationComputerAddress="10.200.43.29" SourceName="SX51200341#MP-00003894-008-BOT#AOI_SJ#SG41500187#0#1426579634000#PostRepair#1426579510781.xml">
  <ModelInfo StationCycleTime="19.024" CycleTime="19.024" RecipeName="MP-00003894-008-BOT" StartTime="2015-03-17T16:07:14+08:00" />
  <PanelInfo Barcode="SX51200341" 
  
  ProcessStartTime="2015-03-23 00:00:00" 
  
  ProcessEndTime="2015-03-23 00:00:20" 
  
  ProcessCycleTime="19.024" Result="Reviewed Passed" OperatorName="C3A" TotalCompsTestedQty="423" TotalPinsQty="0" IndictCompsQty="7" IndictPinsQty="0" DefectQty="18" ActiveDefectQty="0" ActivePinsQty="0" ActiveCompsQty="0" FalseCallDefectQty="18" FalseCallPinsQty="0" FalseCallCompsQty="7">
    <BoardInfo Barcode="SX51200341" Result="Reviewed Passed" TotalCompsTestedQty="423" TotalPinsQty="0" IndictCompsQty="7" IndictPinsQty="0" DefectQty="18" ActiveDefectQty="0" ActivePinsQty="0" ActiveCompsQty="0" FalseCallDefectQty="18" FalseCallPinsQty="0" FalseCallCompsQty="7">
      <ComponentInfo ComponentName="QB10" IndictDefectType="SOLDER BAD" RepairStatus="False Call" Algorithm="tlsih-mp-00000688-0" PartNumber="LSIH-MP-00000688-000" OriginalDefect="SOLDER BAD">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="RB98" IndictDefectType="COMPONENT MISALIGNED" RepairStatus="False Call" Algorithm="rlsih-mp-00002466-0" PartNumber="LSIH-MP-00002466-000" OriginalDefect="COMPONENT MISALIGNED">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="RB123" IndictDefectType="COMPONENT MISALIGNED" RepairStatus="False Call" Algorithm="rlsih-mp-00003039-0" PartNumber="LSIH-MP-00003039-000" OriginalDefect="COMPONENT MISALIGNED,COMPONENT MISALIGNED,COMPONENT MISALIGNED,SOLDER BAD,COMPONENT MISALIGNED">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="ECB1" IndictDefectType="COMPONENT MISALIGNED" RepairStatus="False Call" Algorithm="blsih-mp-00003364-0" PartNumber="LSIH-MP-00003364-000" OriginalDefect="COMPONENT MISALIGNED,COMPONENT POLARITY REVERSED,COMPONENT MISALIGNED">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="ECB2" IndictDefectType="COMPONENT MISALIGNED" RepairStatus="False Call" Algorithm="blsih-mp-00003364-0" PartNumber="LSIH-MP-00003364-000" OriginalDefect="COMPONENT MISALIGNED,COMPONENT POLARITY REVERSED">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="ECB3" IndictDefectType="COMPONENT MISALIGNED" RepairStatus="False Call" Algorithm="blsih-mp-00003364-0" PartNumber="LSIH-MP-00003364-000" OriginalDefect="COMPONENT MISALIGNED,COMPONENT POLARITY REVERSED,COMPONENT MISALIGNED,COMPONENT MISALIGNED,COMPONENT MISALIGNED">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
      <ComponentInfo ComponentName="QB34" IndictDefectType="SOLDER BAD" RepairStatus="False Call" Algorithm="tlsih-mp-00000688-0" PartNumber="LSIH-MP-00000688-000" OriginalDefect="SOLDER BAD">
        <Feeder Name="" PnpName="" />
      </ComponentInfo>
    </BoardInfo>
  </PanelInfo>
</ReceivedData>
'

exec user_ISPCXmlReader @signal_xml, @signal_xml_def, @error_code out, @error_message_xml out, @filename out;