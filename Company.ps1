## Initial create CPSC332's Company schema

## Invoke-SQLCmd -HostName "localhost" -Database "CPSC 332" -InputFile ".\00. Company.sql" -ErrorAction Stop;

## How to run SQL and bind to DataSet object
$SqlConnection = New-Object System.Data.SqlClient.SqlConnection;
$SqlConnection.ConnectionString = "Server=localhost;Database=CPSC 332;Integrated Security=True;";
$SqlConnection.Open();

$SqlCmd = New-Object System.Data.SqlClient.SqlCommand;
$Sqlcmd.CommandTimeout = 0;
$SqlCmd.Connection = $SqlConnection;

$SqlCmd.CommandText = "SELECT * FROM dbo.EMPLOYEE;";

## Using Data Reader
$DataSet = $SqlCmd.ExecuteReader();

While ($DataSet.Read()) {
    Write-Host $DataSet["Fname"];
};
$SqlConnection.Close();

## Using Data Adapter
$SqlConnection.Open();
$SqlAdapter = New-Object System.Data.SqlClient.SqlDataAdapter;
$SqlAdapter.SelectCommand = $SqlCmd;
$DataSet = New-Object System.Data.DataSet;
[Void]$SqlAdapter.Fill($DataSet);

$Employees = $DataSet.Tables[0];

Foreach($Employee In $Employees) {
    Write-Host $Employee.Fname;
};
$SqlConnection.Close();

