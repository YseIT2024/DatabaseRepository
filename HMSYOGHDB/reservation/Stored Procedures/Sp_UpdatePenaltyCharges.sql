CREATE proc [reservation].[Sp_UpdatePenaltyCharges]
(
@TimeId int,
@SubCategoryID int,
@EarlyCheckInCharges decimal (18,6),
@LateCheckOutCharges decimal (18,6),
@UserID int 
)
AS
Begin 

Update [reservation].[PenaltyCharges] Set EarlyCheckInCharges=@EarlyCheckInCharges,LateCheckOutCharges=@LateCheckOutCharges,ModifiedBy=@UserID ,ModifiedOn=GETDATE()  where SubcategoryId =@SubCategoryID AND TimeId=@TimeId

END