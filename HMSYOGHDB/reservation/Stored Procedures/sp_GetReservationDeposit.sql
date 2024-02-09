create PROCEDURE [reservation].[sp_GetReservationDeposit]
@UserId int=Null
AS
BEGIN
    SELECT RD.StandardReservationDepositId, RD.ReservationModeId, RD.ReservationTypeId, RD.SubcategoryId, 
           RD.StandardReservationDepositPercent, RD.EffectiveFrom, RD.EffectiveTo, RD.IsActive, 
           RD.ReservationDayFrom, RD.ReservationDayTo,SC.Name,RT.ReservationType,RM.ReservationMode
    FROM [reservation].[StandardReservationDeposit]  RD
	INNER JOIN reservation.ReservationMode RM ON RD.ReservationModeId=RM.ReservationModeID
	INNER JOIN reservation.ReservationType RT ON RD.ReservationTypeId=RT.ReservationTypeID
	INNER JOIN Products.SubCategory SC ON RD.SubcategoryId=SC.SubCategoryID
	
END