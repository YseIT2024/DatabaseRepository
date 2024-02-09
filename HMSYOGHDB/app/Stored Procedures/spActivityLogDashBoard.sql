/****** Script for SelectTopNRows command from SSMS  ******/


CREATE Proc [app].[spActivityLogDashBoard] --18
(
@ActivityTypeId int = 0,
@UserId int=0,
@LocationId int=0,
@ActivityGroup varchar(250)=null
)
AS
Begin
	if (@ActivityGroup is not null or @ActivityTypeId>0)
	begin
		--SELECT AL.*, R.ReservationID ,AT.ActivityType, L.LocationCode, L.LocationName, 
		--U.UserName, CD.FirstName+' ' +CD.LastName AS FullName,AL.ActivityTitle
		--  FROM [app].[ActivityLog] AL
		--Join [reservation].[Reservation] R on R.ReservationID=R.ReservationID
		--JOin [app].[ActivityType] AT ON AT.ActivityTypeID=AL.ActivityTypeID 
		--Join [general].[Location] L On L.LocationID=AL.LocationID
		--JOin [app].[user] U On U.UserID=AL.UserID
		--Join [Contact].[Details] CD ON CD.ContactID=U.ContactID
		--where AT.ActivityGroup = @ActivityGroup OR AL.ActivityTypeID=@ActivityTypeId

		SELECT AL.LogID,al.ActivityTypeID,al.LocationID,[dbo].[GetDatetimeBasedonTimezone] (FORMAT(al.DateTime, 'dd-MMM-yyyy HH:mm')) AS DateTime,al.Activity
		,al.UserID,al.ReferenceNo, AT.ActivityType, L.LocationCode, L.LocationName, 
		U.UserName FullName,
		CD.FirstName+' ' +CD.LastName AS UserName ,AL.ActivityTitle		
		  FROM [app].[ActivityLog] AL
		--Join [reservation].[Reservation] R on R.ReservationID=R.ReservationID
		JOin [app].[ActivityType] AT ON AT.ActivityTypeID=AL.ActivityTypeID 
		Join [general].[Location] L On L.LocationID=AL.LocationID
		JOin [app].[user] U On U.UserID=AL.UserID
		Join [Contact].[Details] CD ON CD.ContactID=U.ContactID
		where AT.ActivityGroup = @ActivityGroup OR AL.ActivityTypeID=@ActivityTypeId
		Order By AL.LogID DESC
	end
else
	begin
		--SELECT AL.*, R.ReservationID ,AT.ActivityType, L.LocationCode, L.LocationName, 
		--U.UserName, CD.FirstName+' ' +CD.LastName AS FullName,AL.ActivityTitle
		--  FROM [app].[ActivityLog] AL
		--Join [reservation].[Reservation] R on R.ReservationID=R.ReservationID
		--JOin [app].[ActivityType] AT ON AT.ActivityTypeID=AL.ActivityTypeID 
		--Join [general].[Location] L On L.LocationID=AL.LocationID
		--JOin [app].[user] U On U.UserID=AL.UserID
		--Join [Contact].[Details] CD ON CD.ContactID=U.ContactID
		SELECT AL.LogID,al.ActivityTypeID,al.LocationID,[dbo].[GetDatetimeBasedonTimezone] (FORMAT(al.DateTime, 'dd-MMM-yyyy HH:mm')) AS DateTime,al.Activity
		,al.UserID,al.ReferenceNo, AT.ActivityType, L.LocationCode, L.LocationName, 
		U.UserName FullName,
		CD.FirstName+' ' +CD.LastName AS UserName ,AL.ActivityTitle		
		  FROM [app].[ActivityLog] AL
		--Join [reservation].[Reservation] R on R.ReservationID=R.ReservationID
		JOin [app].[ActivityType] AT ON AT.ActivityTypeID=AL.ActivityTypeID 
		Join [general].[Location] L On L.LocationID=AL.LocationID
		JOin [app].[user] U On U.UserID=AL.UserID
		Join [Contact].[Details] CD ON CD.ContactID=U.ContactID		
		Order By AL.LogID DESC
	end
End

