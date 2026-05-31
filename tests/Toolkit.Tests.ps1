BeforeAll {
    Import-Module "$PSScriptRoot/../src/M365AdminToolkit.psm1" -Force
}

Describe 'ConvertTo-LicenseReportObject' {

    It 'calculates available licenses and utilization correctly' {
        $mock = [pscustomobject]@{
            SkuPartNumber = 'ENTERPRISEPACK'
            SkuId         = '00000000-0000-0000-0000-000000000001'
            ConsumedUnits = 80
            PrepaidUnits  = [pscustomobject]@{ Enabled = 100 }
        }

        $result = $mock | ConvertTo-LicenseReportObject

        $result.Available   | Should -Be 20
        $result.PercentUsed | Should -Be 80
        $result.Consumed    | Should -Be 80
        $result.Prepaid     | Should -Be 100
    }

    It 'reports negative availability when overallocated' {
        $mock = [pscustomobject]@{
            SkuPartNumber = 'OVERSUB'
            SkuId         = '00000000-0000-0000-0000-000000000002'
            ConsumedUnits = 12
            PrepaidUnits  = [pscustomobject]@{ Enabled = 10 }
        }

        $result = $mock | ConvertTo-LicenseReportObject

        $result.Available   | Should -Be -2
        $result.PercentUsed | Should -Be 120
    }

    It 'handles zero prepaid units without dividing by zero' {
        $mock = [pscustomobject]@{
            SkuPartNumber = 'EMPTY'
            SkuId         = '00000000-0000-0000-0000-000000000003'
            ConsumedUnits = 0
            PrepaidUnits  = [pscustomobject]@{ Enabled = 0 }
        }

        $result = $mock | ConvertTo-LicenseReportObject

        $result.PercentUsed | Should -Be 0
        $result.Available   | Should -Be 0
    }

    It 'processes multiple SKUs from the pipeline' {
        $mocks = @(
            [pscustomobject]@{ SkuPartNumber = 'A'; SkuId = '1'; ConsumedUnits = 1; PrepaidUnits = [pscustomobject]@{ Enabled = 2 } }
            [pscustomobject]@{ SkuPartNumber = 'B'; SkuId = '2'; ConsumedUnits = 5; PrepaidUnits = [pscustomobject]@{ Enabled = 5 } }
        )

        $result = $mocks | ConvertTo-LicenseReportObject

        $result.Count | Should -Be 2
    }
}
