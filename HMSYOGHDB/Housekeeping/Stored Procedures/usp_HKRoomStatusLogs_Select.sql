CREATE PROC [Housekeeping].[usp_HKRoomStatusLogs_Select] 
    @HKStatusLogID BIGINT = null,
	@RoomID INT

AS
    SET NOCOUNT ON
    SET XACT_ABORT ON

	declare @CurrentRoomstatus int;

BEGIN
    set @CurrentRoomstatus=(select isnull(RoomStatusID,0) from Products.Room where RoomID=@RoomID)

	IF (@HKStatusLogID<>NULL)

		SELECT HKRS.HKStatusLogID, HKRS.RoomID, HKRS.RoomStatusID, 
		(SELECT PRS.ROOMSTATUS FROM [HMSYOGH].[Products].[RoomStatus] PRS WHERE PRS.RoomStatusID=HKRS.RoomStatusID) AS ROOMSTATUS,
		HKRS.AttendedBy, 
		(SELECT CD.FirstName + ' ' + CD.LastName AS AttendedBy FROM [HMSYOGH].[contact].[Details] CD WHERE CD.ContactID=HKRS.AttendedBy) AS ATTENDEDBYNAME,
		HKRS.Remarks, HKRS.CreatedBy, 
		(SELECT CD.FirstName + ' ' + CD.LastName AS CreatedBy FROM [HMSYOGH].[contact].[Details] CD WHERE CD.ContactID=HKRS.CreatedBy) AS LOGINUSER,
		HKRS.CreateDate
		FROM   Housekeeping.HKRoomStatusLogs HKRS 
		WHERE  HKRS.HKStatusLogID = @HKStatusLogID order by HKRS.CreateDate desc
	ELSE
		SELECT HKRS.HKStatusLogID, HKRS.RoomID, HKRS.RoomStatusID, 
		(SELECT PRS.ROOMSTATUS FROM [HMSYOGH].[Products].[RoomStatus] PRS WHERE PRS.RoomStatusID=HKRS.RoomStatusID) AS ROOMSTATUS,
		HKRS.AttendedBy, 
		(SELECT CD.FirstName + ' ' + CD.LastName 
		FROM [HMSYOGH].[contact].[Details] CD 
		inner join [HMSYOGH].[general].[Employee] GE on CD.ContactID=GE.ContactID 
		WHERE GE.EmployeeID=HKRS.AttendedBy) AS ATTENDEDBYNAME,	HKRS.Remarks, HKRS.CreatedBy, 
		(SELECT CD.FirstName + ' ' + CD.LastName AS CreatedBy FROM [HMSYOGH].[contact].[Details] CD WHERE CD.ContactID=HKRS.CreatedBy) AS LOGINUSER,
		HKRS.CreateDate
		FROM   Housekeeping.HKRoomStatusLogs HKRS
		WHERE  HKRS.RoomID = @RoomID  order by HKRS.CreateDate desc

		SELECT E.EmployeeID, E.ContactID,CD.FirstName + ' ' + CD.LastName AS AttendedBy FROM [HMSYOGH].[general].[Employee] E
		INNER JOIN [HMSYOGH].[contact].[Details] CD ON CD.ContactID=E.ContactID
		WHERE E.IsActive=1  AND CD.DesignationID in (26,12,29,39)

		if (@CurrentRoomstatus >0 )
		begin
			SELECT ROOMSTATUSID,concat(ROOMSTATUS, '-', HKStatusName) as [ROOMSTATUS]
			FROM [HMSYOGH].[Products].[RoomStatus] 
			--where ROOMSTATUSID in (SELECT RoomStatusIDTo FROM [Housekeeping].[HKRoomStatusMoveMap] WHERE RoomStatusIDfrom=@CurrentRoomstatus)
		End
		else
			SELECT ROOMSTATUSID,HKStatusName as [ROOMSTATUS] FROM [HMSYOGH].[Products].[RoomStatus] 		
		
	

END



	