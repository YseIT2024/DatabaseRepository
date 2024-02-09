
CREATE PROC [Housekeeping].[usp_HKGuestTickets_Pageload]			
			@userId int=NULL,   
			@LocationID int=NULL
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON


		------------REQUEST FOR LOOKUP EDIT
	  SELECT [ConfigId], configcode AS RequiredFor, [ConfigValue]   FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='RF' AND  [IsActive]=1
      
		---------------FOR ASSIGNEE AND ACTION BY

      SELECT E.EmployeeID, E.ContactID,CD.FirstName + ' ' + CD.LastName AS BellBoy FROM [HMSYOGH].[general].[Employee] E
		INNER JOIN [HMSYOGH].[contact].[Details] CD ON CD.ContactID=E.ContactID
		WHERE E.IsActive=1 

		---------------FOR STATUS
	 SELECT [ConfigId], configcode AS StatusId, [ConfigValue] StatusValue  FROM [HMSYOGH].[Housekeeping].[GuestTicketsConfig]  WHERE [ConfigType] ='ST' AND  [IsActive]=1
   

END	
