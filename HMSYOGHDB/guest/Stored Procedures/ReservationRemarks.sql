create PROCEDURE Guest.ReservationRemarks
    @ReservationID int,
    @FolioNumber int,
    @AmtAfterTax decimal,
    @Remarks varchar(255),
    @CreatedOn date
AS
BEGIN
    SELECT *
FROM [account].[GuestLedgerDetails] GLD
JOIN [reservation].[Reservation] R
    ON GLD.FolioNo = R.FolioNumber
END