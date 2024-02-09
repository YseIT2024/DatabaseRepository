
create FUNCTION [reservation].[fnGetNightDateBasedOndatetime]

(
	@DatetoCheck Datetime,
	@Type tinyint
)

RETURNS date

AS

BEGIN
	declare @NightDate date

	if(@Type=1)
	 set @NightDate=(select top 1 date_id from general.Calendar where @DatetoCheck between start_dts and end_dts order by 1)
	else
	 set @NightDate=(select top 1 date_id from general.Calendar where @DatetoCheck between start_dts and end_dts order by 1 desc)
	return @NightDate
END
