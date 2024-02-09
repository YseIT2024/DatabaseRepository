


CREATE PROCEDURE [Housekeeping].[usp_HKMissingAndDamages_SelectAll]
(
    @UserId int=null,
	@Action int=Null --Added by Arabinda on 20-04-2023
)
AS
BEGIN
	SET NOCOUNT ON;
	if @Action=1
	begin
	SELECT hm.TransId, hm.TransactionType,
	CASE
		WHEN hm.TransactionType = 1 THEN 'Missing'
		WHEN hm.TransactionType = 2 THEN 'Damages'  
    END AS TransactionTypeName,	
	hm.TransDate,
	hm.PersonResponsible,
	--hm.ItemId,
	--si.Name,
	hm.ItemDescription,
	hm.Quantity,
	--hm.LocationType,
	--CASE
	--	WHEN hm.LocationType = 1 THEN 'Room'
	--	WHEN hm.LocationType = 2 THEN 'Public Area'
	--	WHEN hm.LocationType = 3 THEN 'HK SubStore'
	--	WHEN hm.LocationType = 4 THEN 'Executive Cabin'  
 --   END AS LocationTypeName,
	--hm.LocationId,
	hm.LocationDescription,
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
	hm.ReceiptNo,hm.Narration,hm.CreatedBy,hm.CreatedOn,hm.ModifiedBy,hm.ModifiedOn			
	FROM [Housekeeping].[HKMissingAndDamages] hm where TransactionType=1
	ORDER BY hm.TransId DESC              ------DONE BY MURUGESH S-----
	--INNER join service.Item si on hm.ItemId=si.ItemID

   SELECT Distinct  CD.FirstName
   FROM [Housekeeping].[HKMissingAndDamages] RI
   INNER JOIN app.[User] au ON  @UserId =au.UserID
   INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID;
END
 else if @Action=2	
		BEGIN
		SELECT hm.TransId, hm.TransactionType,
	CASE
		WHEN hm.TransactionType = 1 THEN 'Missing'
		WHEN hm.TransactionType = 2 THEN 'Damages'  
    END AS TransactionTypeName,	
	hm.TransDate,
	hm.PersonResponsible,
	--hm.ItemId,
	--si.Name,
	hm.ItemDescription,
	hm.Quantity,
	--hm.LocationType,
	--CASE
	--	WHEN hm.LocationType = 1 THEN 'Room'
	--	WHEN hm.LocationType = 2 THEN 'Public Area'
	--	WHEN hm.LocationType = 3 THEN 'HK SubStore'
	--	WHEN hm.LocationType = 4 THEN 'Executive Cabin'  
 --   END AS LocationTypeName,
	--hm.LocationId,
	hm.LocationDescription,
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
	hm.ReceiptNo,hm.Narration,hm.CreatedBy,hm.CreatedOn,hm.ModifiedBy,hm.ModifiedOn			
	FROM [Housekeeping].[HKMissingAndDamages] hm where TransactionType=2
	ORDER BY hm.TransId DESC              ------DONE BY MURUGESH S-----
	--INNER join service.Item si on hm.ItemId=si.ItemID
	  SELECT Distinct  CD.FirstName
   FROM [Housekeeping].[HKMissingAndDamages] RI
   INNER JOIN app.[User] au ON  @UserId =au.UserID
   INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID;
END
    else --All list 
	BEGIN
	SELECT hm.TransId, hm.TransactionType,
	CASE
		WHEN hm.TransactionType = 1 THEN 'Missing'
		WHEN hm.TransactionType = 2 THEN 'Damages'  
    END AS TransactionTypeName,	
	hm.TransDate,
	hm.PersonResponsible,
	--hm.ItemId,
	--si.Name,
	hm.ItemDescription,
	hm.Quantity,
	--hm.LocationType,
	--CASE
	--	WHEN hm.LocationType = 1 THEN 'Room'
	--	WHEN hm.LocationType = 2 THEN 'Public Area'
	--	WHEN hm.LocationType = 3 THEN 'HK SubStore'
	--	WHEN hm.LocationType = 4 THEN 'Executive Cabin'  
 --   END AS LocationTypeName,
	--hm.LocationId,
	hm.LocationDescription,
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
	hm.ReceiptNo,hm.Narration,hm.CreatedBy,hm.CreatedOn,hm.ModifiedBy,hm.ModifiedOn			
	FROM [Housekeeping].[HKMissingAndDamages] hm 
	ORDER BY hm.TransId DESC
SELECT Distinct  CD.FirstName
   FROM [Housekeeping].[HKMissingAndDamages] RI
   INNER JOIN app.[User] au ON  @UserId =au.UserID
   INNER JOIN [contact].[Details] CD ON au.ContactID = CD.ContactID;
	END
	END

