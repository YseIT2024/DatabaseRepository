CREATE PROCEDURE [guest].[GetGuestMatesDefualtData] 
(		
	@UserId int	,
	@ReservationID int
)
AS
BEGIN
	
	--SET NOCOUNT ON prevents the sending of DONEINPROC messages to the client for each statement in a stored procedure
	SET NOCOUNT ON;
	
		SELECT [ConfigID] as GuestTypeID, [ConfigValue] as GuestType FROM [general].[Config] where [ConfigType] =2 and [IsActive] = 1

		SELECT [GenderID],[Gender] FROM [person].[Gender]

		SELECT [CountryID] ,[CountryName]
		FROM  [general].[Country] where [IsActive] = 1 

		SELECT [IDCardTypeID], [IDCardTypeName]
		FROM  [person].[IDCardType] 

		SELECT RG.ReservationID,RG.GuestMatesID, RG.Nationality as CountryID, CT.CountryName, RG.Gender as GenderID, GD.Gender, 
		--FirstName as [Name], 
		CONCAT(T.Title,' ',D.FirstName,' ',D.LastName ) as [Name], 
		RG.GuestType as GuestTypeID,
		CO.[ConfigValue] as GuestType, 
		(SELECT top(1) d.DOB FROM [guest].[Guest] g INNER JOIN [contact].[Details] d ON g.ContactID = d.ContactID WHERE GuestID=RG.GuestID)as DOB, 
		RG.IsActive ,RG.GuestID,PR.RoomNo,PR.RoomID,(select [reservation].[fnGetRoomCategory](@ReservationId))as RoomType--RoomID added by sravani
		,ROW_NUMBER() OVER (Partition By RG.ReservationID Order by RG.GuestMatesID) as SlNo
		
		FROM [reservation].[ReservationGuestMates] RG
		INNER JOIN [general].[Country] CT ON RG.Nationality = CT.CountryID
		INNER JOIN [person].[Gender] GD ON RG.Gender = GD.GenderID
		INNER JOIN [general].[Config] CO ON RG.GuestType = CO.ConfigID and CO.ConfigType =2
		INNER JOIN [guest].[Guest] g   on RG.GuestID=g.GuestID
		INNER JOIN [contact].[Details] D ON g.ContactID = d.ContactID
		INNER JOIN [person].[Title] T ON D.TitleID = T.TitleID		--------Added by sravani---------------	    LEFT JOIN [Products].[Room] PR ON RG.RoomID = PR.RoomID        LEFT JOIN [reservation].[Reservation] r ON RG.ReservationID = r.ReservationID
		where RG.ReservationID = @ReservationID 

		select ISNULL(r.ExtraAdults,0) as ExtraAdults,ISNULL(r.ExtraChildJu,0) as ExtraChildJu,ISNULL(r.ExtraChildSe,0) as ExtraChildSe  from reservation.Reservation r where ReservationID=@ReservationID
END	
			

			
