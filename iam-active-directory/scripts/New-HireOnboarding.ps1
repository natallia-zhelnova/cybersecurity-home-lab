<#
.SYNOPSIS
    Joiner: bulk-creates AD users from a CSV provided by HR.
.DESCRIPTION
    For each row: creates the account in the department OU, sets a temporary
    password that must be changed at first logon, and adds the user to the
    department group (GRP-<Department>-Staff) and GRP-All-Employees.
.EXAMPLE
    .\New-HireOnboarding.ps1 -CsvPath C:\Lab\new_hires.csv
#>
param(
    [string]$CsvPath = "C:\Lab\new_hires.csv",
    [string]$BaseOU  = "OU=Corp,DC=lab,DC=local",
    [string]$Domain  = "lab.local"
)

$users    = Import-Csv $CsvPath
$password = Read-Host "Temporary password for new users" -AsSecureString

foreach ($u in $users) {
    $params = @{
        Name                  = "$($u.FirstName) $($u.LastName)"
        GivenName             = $u.FirstName
        Surname               = $u.LastName
        SamAccountName        = $u.Username
        UserPrincipalName     = "$($u.Username)@$Domain"
        Department            = $u.Department
        Title                 = $u.Title
        Path                  = "OU=$($u.Department),$BaseOU"
        AccountPassword       = $password
        ChangePasswordAtLogon = $true
        Enabled               = $true
    }
    New-ADUser @params
    Add-ADGroupMember "GRP-$($u.Department)-Staff" -Members $u.Username
    Add-ADGroupMember "GRP-All-Employees" -Members $u.Username
    Write-Host "Created $($u.Username) in $($u.Department)" -ForegroundColor Green
}
