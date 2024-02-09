
CREATE PROC [Housekeeping].[usp_HKMissingAndDamage_Invoice]			
	@TransId int =0
AS 
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON

	IF @TransId >0
		BEGIN
		
		  SELECT hm.TransId, hm.TransactionType,
	             CASE
		             WHEN hm.TransactionType = 1 THEN 'Missing'
		             WHEN hm.TransactionType = 2 THEN 'Damages'  
                    END AS TransactionTypeName,hm.AmountCharged,
	hm.ReceiptNo,hm.CreatedBy,hm.CreatedOn			
	FROM [Housekeeping].[HKMissingAndDamages] hm  
	where TransId =@TransId
		
			SELECT hm.TransId, hm.TransactionType,
	             CASE
		             WHEN hm.TransactionType = 1 THEN 'Missing'
		             WHEN hm.TransactionType = 2 THEN 'Damages'  
                    END AS TransactionTypeName,	
	         hm.TransDate,hm.ItemDescription,hm.Quantity,hm.LocationDescription,
             hm.ActionTaken,
	         CASE
		        WHEN hm.ActionTaken = 1 THEN 'Charged To Guest'
		        WHEN hm.ActionTaken = 2 THEN 'Charged To Staff'  
		        WHEN hm.ActionTaken = 3 THEN 'Charged To Company'
                END AS ActionTakenName,	
	         hm.Status,
	         CASE
		         WHEN hm.Status = 1 THEN 'No Action Status'
		         WHEN hm.Status = 2 THEN 'Yes Action Status'  
                 END AS StatusName,	

	hm.InformedBy,hm.InformedDate,hm.InformedTo,hm.ReplacementDate,hm.AmountCharged,
	hm.ReceiptNo,hm.Narration		
	FROM [Housekeeping].[HKMissingAndDamages] hm  
	where TransId = @TransId 
END	
END


