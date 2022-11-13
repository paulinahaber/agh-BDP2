CREATE PROCEDURE CurrencyRateAgo @YearsAgo int
AS
SELECT fcr.*, DimCurrency.CurrencyAlternateKey 
FROM [dbo].FactCurrencyRate as fcr
LEFT JOIN [dbo].DimCurrency 
ON fcr.CurrencyKey = DimCurrency.CurrencyKey
WHERE (CurrencyAlternateKey = 'GBP' OR CurrencyAlternateKey = 'EUR')
AND DATEPART("YY",DATEADD("yy",@YearsAgo,fcr.Date)) = DATEPART("yy",GETDATE()) 
AND DATEPART("mm",DATEADD("yy",@YearsAgo,fcr.Date)) = DATEPART("mm",GETDATE()) 
AND DATEPART("dd",DATEADD("yy",@YearsAgo,fcr.Date)) = DATEPART("dd",GETDATE())

