
CREATE PROC [Housekeeping].[usp_GetDepartmentTickets]				
			@userId int =null,  
			@LocationID int =null,
			@DepartmentId int =null
			--@FromDate datetime =null, 
			--@ToDate datetime =null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	select @DepartmentId=CD.DepartmentId from contact.Details CD
			INNER JOIN app.[User] AU ON CD.ContactID=AU.ContactID
			WHERE au.UserID=@userId

	SELECT GT.[TicketId] , GT.[TicketTypeId]   
		,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[TicketTypeId] ) AS TicketType
	  , GT.[GuestTypeId]     
	  ,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[GuestTypeId] ) AS GuestType
	  , GT.[RoomId] , GT.[GuestId] , GT.[GuestName] , GT.[ReservationNo] , GT.[RequestFor]  AS RequestForId   
	  ,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[RequestFor] ) AS RequestFor
	  ,GD.Department, GT.[Subject] , GT.[Description], GT.[RequestDate]	  , GT.[RequestTime] 
	  , GT.[Assignee] ,(select FirstName + ' ' + LastName from  [contact].[Details] where ContactID=GT.[Assignee]) as AssigneeName
	  , GT.[Status]  as StatusCode    
	  ,(SELECT ConfigValue FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[Status] ) AS Status
	  , GT.[ActionBy],(select FirstName + ' ' + LastName from  [contact].[Details] WHERE ContactID= GT.[ActionBy]) as ActionByName
      , GT.[ActionDate]   ,IIF(GT.[ActionTime] ='00:00',NULL,GT.[ActionTime]) AS ActionTime	
	  , GT.[ActionNarration] , GT.[CreatedBy], GT.[CreatedOn] , GT.[IsActive] , GT.[ModifiedBy] , GT.[ModifiedOn], GT.[LocationId]
	  FROM [HMSYOGH].[Housekeeping].[GuestTickets] GT
	  inner join [Housekeeping].[GuestTicketsConfig] HGT on HGT.ConfigCode=GT.RequestFor
	  inner join [Housekeeping].[GuestTicketsTypeDepartmentMapping] HG on HG.ConfigId=HGT.ConfigId
	  inner join [general].[Department] GD on HG.DepartmentId=GD.DepartmentID
	  WHERE GD.DepartmentID=@DepartmentId AND GT.LocationId=@LocationID
	  ORDER BY TicketId DESC   
	 
	
	 
     ---------For Status
    SELECT [ConfigId],configcode AS StatusId, [ConfigValue] StatusValue  FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='ST' AND  [IsActive]=1
END	

