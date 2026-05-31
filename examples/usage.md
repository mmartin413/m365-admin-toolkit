# Usage examples

## Console output

```powershell
./scripts/Get-LicenseReport.ps1
```

Sample (values illustrative):

```
SkuPartNumber              SkuId                                Prepaid Consumed Available PercentUsed
-------------              -----                                ------- -------- --------- -----------
SPE_E3                     abc...001                                100       98         2        98.0
ENTERPRISEPACK             abc...002                                 50       31        19        62.0
POWER_BI_STANDARD          abc...003                                500       40       460         8.0
```

## CSV export

```powershell
./scripts/Get-LicenseReport.ps1 -OutputFormat CSV -OutputDirectory ./reports
# -> ./reports/LicenseReport_20260531_140212.csv
```

## HTML export

```powershell
./scripts/Get-LicenseReport.ps1 -OutputFormat HTML -OutputDirectory ./reports
# -> ./reports/LicenseReport_20260531_140212.html
```

## First-run authentication

On first run you'll be prompted to sign in and consent to the
`Organization.Read.All` scope. Subsequent runs reuse the session until it
expires. To sign out:

```powershell
Disconnect-MgGraph
```
