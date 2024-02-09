
CREATE PROCEDURE [Housekeeping].[usp_HKLostItemEnquiry_Select]
 

AS
BEGIN
	SET NOCOUNT ON;	
		
	--	SELECT LIE.[EnquiryId] ,trim(LIE.[EnquiryType]) EnquiryType     ,trim(LIE.[GuestType]) GuestType ,LIE.[GuestID],
	--	 (select CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
	--		INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=LIE.GuestID) AS  GuestName,


	--		trim(LIE.[ItemType]) ItemType,LIE.[ItemDescription],LIE.[LostDate],LIE.[LostLocation],LIE.[Status],LIE.[CreatedBy],LIE.[CreatedOn],
	--		LIE.[ModifiedBy],LIE.[ModifiedOn],LIE.[IsActive],LIE.[FoundBy],LIE.[StoredBy],LIE.[ReferenceNo],GTC.ConfigValue
	--FROM [HMSYOGH].[Housekeeping].[LostItemEnquiry] LIE
	--INNER JOIN [HMSYOGH].[Housekeeping].[GuestTicketsConfig] GTC  on LIE.[Status]=GTC.ConfigId

	SELECT LIE.[EnquiryId] ,ltrim(LIE.[EnquiryType]) EnquiryType     ,ltrim(LIE.[GuestType]) GuestType ,LIE.[GuestID],GG.ContactID,LIE.ReservationID,
	(select top (1) pr.RoomNo from [reservation].[ReservedRoom] rrr inner join [Products].[Room] pr on rrr.RoomID=pr.RoomID where rrr.reservationid=lie.ReservationID) roomno,

		--(select CD.FirstName + ' ' + CD.LastName FROM [HMSYOGH].[contact].[Details] CD
		--	INNER JOIN [HMSYOGH].[guest].[Guest] GG ON CD.ContactID=GG.ContactID WHERE GG.GuestID=LIE.GuestID) AS  GuestName,
		CD.FirstName + ' ' + CD.LastName AS GuestName,	
		CA.Street + ', ' + CA.City + ', ' + CA.State AS Address,
			ltrim(LIE.[ItemType]) ItemType,LIE.[ItemDescription],LIE.[LostDate],LIE.[LostLocation],LIE.[Status],LIE.[CreatedBy],LIE.[CreatedOn],
			LIE.[ModifiedBy],LIE.[ModifiedOn],LIE.[IsActive],LIE.[FoundBy],LIE.[StoredBy],LIE.[ReferenceNo],GTC.ConfigValue,
			CASE WHEN ltrim(LIE.[EnquiryType]) = 'L' THEN 0 ELSE 1 END IsDispose
	FROM [Housekeeping].[LostItemEnquiry] LIE
	INNER JOIN [Housekeeping].[GuestTicketsConfig] GTC  on LIE.[Status]=GTC.ConfigId
	INNER JOIN [guest].[Guest] GG on LIE.GuestID=gg.GuestID
	INNER JOIN [contact].[Details] CD ON GG.ContactID=CD.ContactID
	INNER JOIN [contact].[Address] CA ON GG.ContactID=CA.ContactID 
	where LIE.EnquiryId not in(SELECT EnquiryId FROM Housekeeping.LostItemDispatchDetails ) Order by LIE.[EnquiryId] desc 
END