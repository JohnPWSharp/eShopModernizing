If ($useralias -eq $null) {
    Write-Host "Please set useralias and start the script again"
    exit
}

If ($serveradminpassword -eq $null) {
    Write-Host "Please set serveradminpassword and start the script again"
    exit
}

If ($resourcegroupname -eq $null) {
    Write-Host "Please set resourcegroupname and start the script again"
    exit
}

$location = "eastus"
$webappplanname = (-join($useralias,"-webappplan"))
$webappname = (-join($useralias,"-webapp"))
$serveradminname = "ServerAdmin"
$servername = (-join($useralias, "-workshop-server"))
$dbname = "eShop"

# Create an Azure App Service plan. The App Service plan specifies the location, size, and features of the web server farm that hosts your app.
New-AzAppServicePlan -Name $webappplanname -ResourceGroup $resourcegroupname -Location $location

# Create an Azure Web App using the App Service plan. You'll deploy the code for the on-premises web app to this web app in a later exercise.
New-AzWebApp -Name $webappname -AppServicePlan $webappplanname -ResourceGroup $resourcegroupname

# Assign a managed identity to the web app. You'll require this identity later.
Set-AzWebApp -AssignIdentity $true -Name $webappname -ResourceGroupName $resourcegroupname

# Create a new Azure SQL Database server.
New-AzSqlServer -ServerName $servername -ResourceGroupName $resourcegroupname -Location $location -SqlAdministratorCredentials $(New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $serveradminname, $(ConvertTo-SecureString -String $serveradminpassword -AsPlainText -Force))

# Open the SQL Database server firewall to allow access to services hosted in Azure.
New-AzSqlServerFirewallRule -ResourceGroupName $resourcegroupname -ServerName $servername -FirewallRuleName "AllowedIPs" -StartIpAddress "0.0.0.0" -EndIpAddress "0.0.0.0"

# Create a database on the SQL Database server.
# The database will be populated later, when you migrate the web app.
New-AzSqlDatabase  -ResourceGroupName $resourcegroupname -ServerName $servername -DatabaseName $dbName -RequestedServiceObjectiveName "S0"

Write-Host "Setup complete"