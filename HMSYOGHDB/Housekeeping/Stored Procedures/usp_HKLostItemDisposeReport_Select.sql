CREATE PROC [Housekeeping].[usp_HKLostItemDisposeReport_Select] --null,null,77,1
	@RecordId int =null,
	@EnquiryId int=null,
	@UserId int	=null,
	@DisposeId int
   
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	
  SELECT LID.DispatchId,
		  CASE 
		  WHEN LID.DisposeMode =1 THEN 'Courier'  
		  WHEN LID.DisposeMode =3 THEN 'In Person'  
		  WHEN LID.DisposeMode=4 THEN 'Destroyed' 
		  WHEN LID.DisposeMode =5 THEN 'Gifted To Staff'
		  END AS DisposeMode,LID.DisposeDate,LID.DisposeTo
      ,LID.DispatchBy,LID.Remarks,	  
	  LIE.ItemType,LIE.ItemDescription
      FROM  [Housekeeping].[LostItemDispatchDetails] LID
	INNER JOIN [Housekeeping].[LostItemEnquiry] LIE on LID.EnquiryId=LIE.EnquiryId
	INNER JOIN [guest].[Guest] GG on LIE.GuestID=gg.GuestID
	INNER JOIN [contact].[Details] CD ON GG.ContactID=CD.ContactID
	INNER JOIN [contact].[Address] CA ON GG.ContactID=CA.ContactID where LID.DispatchId=@DisposeId	
END	
