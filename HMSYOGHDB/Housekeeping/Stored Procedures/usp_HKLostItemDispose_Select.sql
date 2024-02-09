CREATE  PROC [Housekeeping].[usp_HKLostItemDispose_Select]
	@RecordId int =null,
	@EnquiryId int=null,
	@UserId int	 
   
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	
  SELECT LID.DispatchId,LID.EnquiryId,LID.DisposalStatus,LID.DisposeMode,
  	  CASE 
		  WHEN LID.DisposeMode =1 THEN 'Courier'  
		  WHEN LID.DisposeMode =3 THEN 'In Person'  
		  WHEN LID.DisposeMode =4 THEN 'Destroyed' 
		  WHEN LID.DisposeMode=5 THEN 'Gifted to Staff'
		  END AS DisposeModeStatus,
           LID.DisposeDate,LID.DisposeTo
      ,LID.DispatchBy,LID.Remarks,LID.CreatedBy,LID.CreatedOn,LID.ModifiedBy,LID.ModifiedOn,LID.IsActive,LID.LocationId
	  ,LIE.GuestType,LIE.GuestID,
	 	CD.FirstName + ' ' + CD.LastName AS GuestName,
		CA.Street + ', ' + CA.City + ', ' + CA.State + ',' + CA.Email + ',' + CA.PhoneNumber AS Address,	  
	  LIE.ItemType,LIE.ItemDescription,LIE.LostDate,LIE.LostLocation,LIE.FoundBy,LIE.StoredBy,LIE.ReferenceNo
		FROM  [Housekeeping].[LostItemDispatchDetails] LID
	INNER JOIN [Housekeeping].[LostItemEnquiry] LIE on LID.EnquiryId=LIE.EnquiryId
	INNER JOIN [guest].[Guest] GG on LIE.GuestID=gg.GuestID
	INNER JOIN [contact].[Details] CD ON GG.ContactID=CD.ContactID
	INNER JOIN [contact].[Address] CA ON GG.ContactID=CA.ContactID	order by LID.DispatchId desc
END
