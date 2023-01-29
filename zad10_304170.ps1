[void][system.reflection.Assembly]::LoadWithPartialName("MySql.Data")

# Set path to 7zip
set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"

$index=304170
$dbusername = 'phaber'
$dbpassword = 'JrYRwWn1sk8jxDpM'

$filePath = 'http://home.agh.edu.pl/~wsarlej/dyd/bdp2/materialy/cw10/InternetSales_new.zip'
$destinationPath = Join-Path -Path $PSScriptRoot -ChildPath 'InternetSales_new.zip'

$7zPassword = "bdp2agh"
$7zFolder= $PSScriptRoot
$7zo = "-aoa"

$unzippedFile = Join-Path -Path $PSScriptRoot -ChildPath 'InternetSales_new.txt'
$tempoutput = Join-Path -Path $PSScriptRoot -ChildPath 'InternetSales_temp.txt'

$logFile =  " InternetSales_new.bad_" + [DateTime]::Now.ToString("yyyyMMdd-HHmmss");
$logFilePath = Join-Path -Path $PSScriptRoot -ChildPath $logFile


# Download file
Invoke-WebRequest -URI $filePath -OutFile $destinationPath

# Unzip file
sz x $destinationPath "-p$7zPassword" $7zo "-o$7zFolder"

#Create file for rejected lines 
New-Item $logFilePath

$hash = @{} 

$header = "ProductKey|CurrencyAlternateKey|FIRST_NAME|LAST_NAME|OrderDateKey|OrderQuantity|UnitPrice|SecretCode"

Get-Content $unzippedFile | 
% {

    $columnsArr = $_.Split("|");
                                           
    if ($hash.$_ -eq $null -and 
        $_.trim() -ne "" -and 
        $columnsArr[4] -lt 101 -and 
        ($columnsArr[6] -eq $null -or $columnsArr[6].trim() -eq "") -and
        $columnsArr[2] -like "*,*"
        )  
        
        {
        $columnTitle = $columnsArr[2].replace('"','').Split(",");
        $columnsArr[2] = $columnTitle[1] + "|" + $columnTitle[0];
        $columnsArr -join "|"        
        
        }
        
        else {$_| add-content -path $logFilePath; return} ;


    $hash.$_ = 1  ;   

     } > $tempoutput   
     

Get-Content $unzippedFile;
Clear-Content $unzippedFile ;
Add-Content -Path $unzippedFile -Value $header;
$temp = Get-Content $tempoutput; 
Add-Content -Path $unzippedFile -Value $temp;
Remove-Item -fo $tempoutput; 

# SQL

$queryCreate = "
CREATE TABLE CUSTOMERS_$nrInd
(
ProductKey int,
CurrencyAlternateKey char(5),
First_Name char(60),
Last_Name char(60),
OrderDateKey int,
OrderQuantity int,
UnitPrice float,
SecretCode varchar(10)
)"

# Create table

$connStr = "server=mysql.agh.edu.pl;Persist Security Info=false;user id=" + $dbusername + ";pwd=" + $dbpassword + ";"
$csvPath = Join-Path -Path $PSScriptRoot -ChildPath "CUSTOMERS_$index.csv"

$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connStr)
$conn.Open()
$cmd.Connection  = $conn
$cmd.CommandText = " " + $queryCreate
$cmd.ExecuteNonQuery()

# Load Data
$verifiedFile = Import-Csv -Path $unzippedFile -Delimiter '|'
foreach ($i in $verifiedFile) {
   $cmd.CommandText = 
       "INSERT INTO CUSTOMERS_$index (ProductKey,CurrencyAlternateKey,First_Name,Last_Name,OrderDateKey, OrderQuantity, UnitPrice) VALUES ("
       +$i.ProductKey+",'"+$i.CurrencyAlternateKey+"','"+$i.FIRST_NAME+"','"+$i.LAST_NAME+"',"+$i.OrderDateKey+","+$i.OrderQuantity +","+ $i.UnitPrice + ");" 
   $cmd.ExecuteNonQuery() 
}

# Move file to PROCESSED
$FolderName = Join-Path -Path $PSScriptRoot -ChildPath 'PROCESSED'
$NewName =  [DateTime]::Now.ToString("yyyyMMdd-HHmmss") + '_InternetSales_new.txt'
$NewPath = Join-Path -Path $FolderName -ChildPath $NewName
if (Test-Path $FolderName) {} else { New-Item $FolderName -ItemType Directory}
Move-Item -Path $unzippedFile -Destination $NewPath 

# Insert Secret Code
$cmd.CommandText = "UPDATE CUSTOMERS_$index set SecretCode = (SELECT uuid());"
$cmd.ExecuteNonQuery() 

# Export table 
$selectQuery = "SELECT * FROM CUSTOMERS_$index"
$req = New-Object Mysql.Data.MysqlClient.MySqlCommand($selectQuery,$conn)
$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($req)
$dataSet = New-Object System.Data.DataSet
$dataAdapter.Fill($dataSet, "Query1") | Out-Null
$dataSet.Tables["Query1"] | Export-Csv -path $csvPath -NoTypeInformation
$conn.Close()

Compress-Archive $csvPath