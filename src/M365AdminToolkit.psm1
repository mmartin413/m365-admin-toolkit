<#
.SYNOPSIS
    Shared helper functions for the M365 Admin Toolkit.

.DESCRIPTION
    This module deliberately contains NO Microsoft Graph calls. Keeping the
    transformation logic pure means it can be unit-tested in CI without
    authenticating to a tenant or installing the Graph SDK.
#>

function ConvertTo-LicenseReportObject {
    <#
    .SYNOPSIS
        Transforms raw subscribed-SKU objects into a flat report shape.

    .DESCRIPTION
        Accepts objects shaped like the output of Get-MgSubscribedSku and emits
        a normalized PSCustomObject with computed availability and utilization.

    .PARAMETER SubscribedSku
        One or more SKU objects exposing SkuPartNumber, SkuId, ConsumedUnits,
        and a PrepaidUnits object with an Enabled property.

    .EXAMPLE
        Get-MgSubscribedSku -All | ConvertTo-LicenseReportObject
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]]$SubscribedSku
    )

    process {
        foreach ($sku in $SubscribedSku) {
            $prepaid  = [int]$sku.PrepaidUnits.Enabled
            $consumed = [int]$sku.ConsumedUnits
            $percent  = if ($prepaid -gt 0) {
                [math]::Round(($consumed / $prepaid) * 100, 1)
            }
            else { 0 }

            [pscustomobject]@{
                SkuPartNumber = $sku.SkuPartNumber
                SkuId         = $sku.SkuId
                Prepaid       = $prepaid
                Consumed      = $consumed
                Available     = $prepaid - $consumed
                PercentUsed   = $percent
            }
        }
    }
}

Export-ModuleMember -Function ConvertTo-LicenseReportObject
