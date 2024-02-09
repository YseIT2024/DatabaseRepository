CREATE PROC [service].[uspTypeSelect]
    @ServiceTypeID INT =NULL
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT ON
 
	IF (@ServiceTypeID IS NOT NULL)
    SELECT 
        ServiceTypeID, 
        ServiceName, 
        [Description], 
        ShowInUI, 
        InvoiceTitle,
        [IsActive],
        ISNULL([IsTaxable], 0) as IsTaxable,
        [CreatedBy],
        [CreatedOn],
        [ModifiedBy],
        [ModifiedOn]
    FROM service.Type 
    WHERE ServiceTypeID = @ServiceTypeID AND [IsActive] = 1 
    ORDER BY ServiceTypeID ASC
ELSE
    SELECT 
        ST.ServiceTypeID, 
        ST.ServiceName,
        ST.[Description], 
        ST.ShowInUI, 
        ST.InvoiceTitle,
        ST.[IsActive],
        ISNULL(ST.[IsTaxable], 0) as IsTaxable, 
        ST.[CreatedBy],
        ST.[CreatedOn],
        ST.[ModifiedBy],
        ST.[ModifiedOn],
        (SELECT COUNT([ServiceTypeID]) FROM [service].[Item] WHERE [ServiceTypeID] = ST.ServiceTypeID) as SegmentCount,
        (SELECT COUNT(sc.BookingID) FROM service.ConciergService sc 
            INNER JOIN [service].[Item] si ON sc.ServiceItemID = si.ItemID 
            WHERE si.ServiceTypeID = ST.ServiceTypeID) AS ServiceCount
    FROM [service].[Type] ST 
    WHERE ST.IsActive = 1
    ORDER BY ServiceTypeID DESC
		
    
END