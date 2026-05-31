#Requires -Modules Microsoft.Graph.Authentication, Microsoft.Graph.Identity.DirectoryManagement

<#
.SYNOPSIS
    Reports Microsoft 365 license consumption (assigned vs. purchased) per SKU.

.DESCRIPTION
    Connects to Microsoft Graph (interactive, delegated auth), pulls every
    subscribed SKU in the tenant, and produces an availability report. Output
    can go to the console, a CSV, or a simple HTML file.

    Uses the Microsoft Graph PowerShell SDK. The legacy MSOnline and AzureAD
    modules are deprecated and intentionally not used.

.PARAMETER OutputFormat
    Console (default), CSV, or HTML.

.PARAMETER OutputDirectory
    Directory for the CSV/HTML file. Defaults to the current directory.
    Ignored when OutputFormat is Console.

.EXAMPLE
    .\Get-LicenseReport.ps1
    Prints the report to the console.

.EXAMPLE
    .\Get-LicenseReport.ps1 -OutputFormat CSV -OutputDirectory C:\Reports
    Writes a timestamped CSV to C:\Reports.

.NOTES
    Required Graph scope: Organization.Read.All
    Connect interactively the first time so you can consent to the scope.
#>

[CmdletBinding()]
param(
    [ValidateSet('Console', 'CSV', 'HTML')]
    [string]$OutputFormat = 'Console',

    [string]$OutputDirectory = '.'
)

$ErrorActionPreference = 'Stop'

# Load shared, testable helpers.
Import-Module "$PSScriptRoot/../src/M365AdminToolkit.psm1" -Force

# --- Connect -----------------------------------------------------------------
try {
    if (-not (Get-MgContext)) {
        Write-Verbose 'No existing Graph session; connecting interactively.'
        Connect-MgGraph -Scopes 'Organization.Read.All' -NoWelcome
    }
}
catch {
    throw "Failed to connect to Microsoft Graph: $($_.Exception.Message)"
}

# --- Retrieve ----------------------------------------------------------------
try {
    $skus = Get-MgSubscribedSku -All
}
catch {
    throw "Failed to retrieve subscribed SKUs: $($_.Exception.Message)"
}

if (-not $skus) {
    Write-Warning 'No subscribed SKUs returned for this tenant.'
    return
}

# --- Transform ---------------------------------------------------------------
$report = $skus |
    ConvertTo-LicenseReportObject |
    Sort-Object -Property PercentUsed -Descending

# --- Output ------------------------------------------------------------------
switch ($OutputFormat) {
    'Console' {
        $report | Format-Table -AutoSize
    }
    'CSV' {
        $path = Join-Path $OutputDirectory ("LicenseReport_{0:yyyyMMdd_HHmmss}.csv" -f (Get-Date))
        $report | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
        Write-Information "CSV written to: $path" -InformationAction Continue
    }
    'HTML' {
        $path = Join-Path $OutputDirectory ("LicenseReport_{0:yyyyMMdd_HHmmss}.html" -f (Get-Date))
        $title = "M365 License Report - $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
        $report |
            ConvertTo-Html -Title $title -PreContent "<h1>$title</h1>" |
            Out-File -FilePath $path -Encoding UTF8
        Write-Information "HTML written to: $path" -InformationAction Continue
    }
}
