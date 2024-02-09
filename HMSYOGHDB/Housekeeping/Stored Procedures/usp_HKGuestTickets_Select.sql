

CREATE PROC [Housekeeping].[usp_HKGuestTickets_Select]	
			@TicketId int=null,
			@TicketTypeId int=null,
			@GuestTypeId int =null,
			@RoomId int =null,
			@GuestId int =null,
			@GuestName varchar(250) =null,
			@ReservationNo int =null,
			@RequestFor int =null,
			@Subject varchar(50) =null,
			@Description varchar(500) =null,
			@RequestDate datetime =null,
			@RequestTime datetime =null,
			@Assignee int =null ,
			@Status int =null,
			@ActionBy int =null,
			@ActionDate datetime =null,		
			@IsActive Bit  =null, 
			@userId int =null,  
			@LocationID int =null
			--@FromDate datetime =null, 
			--@ToDate datetime =null
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	DECLARE @FilterQuery varchar(500)=null;

	--if @TicketId > 0		
	--	set @FilterQuery='TicketId=' + @TicketId
	--else if


	SELECT GT.[TicketId] , GT.[TicketTypeId]   
		,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[TicketTypeId] ) AS TicketType
	  , GT.[GuestTypeId]     
	  ,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[GuestTypeId] ) AS GuestType
	  , GT.[RoomId] , rr.[GuestId] , GT.[GuestName] , GT.[ReservationNo] , GT.[RequestFor]  AS RequestForId   
	  ,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[RequestFor] ) AS RequestFor
	  ,GD.Department 
	  ,GT.[Subject] , GT.[Description], GT.[RequestDate]  
	 -- ,IIF(GT.[RequestTime] ='00:00',NULL,GT.[RequestTime]) AS RequestTime
	  , GT.[RequestTime] ------> COMMENTED BY MURUGESH S
	  , GT.[Assignee] ,(select FirstName + ' ' + LastName from  [contact].[Details] where ContactID=GT.[Assignee]) as AssigneeName
	  , GT.[Status]  as StatusCode    
	  ,(SELECT ConfigValue FROM [Housekeeping].[GuestTicketsConfig] WHERE CONFIGCODE= GT.[Status] ) AS Status
	  , GT.[ActionBy],(select FirstName + ' ' + LastName from  [contact].[Details] WHERE ContactID= GT.[ActionBy]) as ActionByName
      , GT.[ActionDate]   ,IIF(GT.[ActionTime] ='00:00',NULL,GT.[ActionTime]) AS ActionTime
	 -- , GT.[ActionTime]   ----> COMMENTED BY MURUGESH S
	  , GT.[ActionNarration] , GT.[CreatedBy], GT.[CreatedOn] , GT.[IsActive] , GT.[ModifiedBy] , GT.[ModifiedOn], GT.[LocationId]
	  FROM [Housekeeping].[GuestTickets] GT
	  inner join [Housekeeping].[GuestTicketsConfig] HGT on HGT.ConfigCode=GT.RequestFor
	  inner join [Housekeeping].[GuestTicketsTypeDepartmentMapping] HG on HG.ConfigId=HGT.ConfigId
	  inner join [general].[Department] GD on HG.DepartmentId=GD.DepartmentID
	  Left join reservation.Reservation rr on GT.ReservationNo=rr.ReservationID
	  ORDER BY TicketId DESC   ----Added by sravani------------	
	
	  select * from [contact].[Details]
	  --where @FilterQuery

	  	------------TicketType  LOOKUP EDIT
	  SELECT [ConfigId], [ConfigValue] as TicketType, [ConfigType]   FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='TT' AND  [IsActive]=1
      
		-----------------FOR GuestType
	 SELECT [ConfigId], [ConfigValue] AS GuestType, [ConfigType]   FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='GT' AND  [IsActive]=1
  --     ---------For Status
    SELECT [ConfigId],configcode AS StatusId, [ConfigValue] StatusValue  FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='ST' AND  [IsActive]=1
END	




