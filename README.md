# M365 Admin Toolkit

![Lint and Test](https://github.com/<your-username>/m365-admin-toolkit/actions/workflows/lint.yml/badge.svg)
![PowerShell](https://img.shields.io/badge/PowerShell-7%2B-5391FE)
![License: MIT](https://img.shields.io/badge/License-MIT-green)

PowerShell tooling for common Microsoft 365 / Entra ID administration tasks,
built on the **Microsoft Graph PowerShell SDK**. Reusable, idempotent, and
CI-checked — not one-off scripts.

> The legacy `MSOnline` and `AzureAD` modules are deprecated. This toolkit uses
> Microsoft Graph throughout.

## The problem it solves

Admins repeatedly need answers to questions like *"How many licenses are we
actually using?"* and *"Where are we about to run out?"* Clicking through the
admin center doesn't scale and isn't repeatable. This toolkit produces
exportable, scriptable reports.

## Features

| Script | What it does |
|---|---|
| `Get-LicenseReport.ps1` | Reports purchased vs. consumed licenses per SKU, with availability and % utilization. Console / CSV / HTML output. |

> Roadmap: stale-account finder (sign-in logs), MFA / auth-method gap report.

## Screenshot

<!-- Replace with a real screenshot or terminal GIF before publishing. -->
_Add a screenshot of the console or HTML output here. A short asciinema/GIF of
a run is the single highest-impact thing you can add to this README._

## Prerequisites

- PowerShell 7+
- Microsoft Graph PowerShell SDK modules:
  ```powershell
  Install-Module Microsoft.Graph.Authentication -Scope CurrentUser
  Install-Module Microsoft.Graph.Identity.DirectoryManagement -Scope CurrentUser
  ```
- An account that can consent to / has the **`Organization.Read.All`** Graph scope
- A dev or trial tenant is recommended for demos (never commit real tenant data)

## Usage

```powershell
# Console output (prompts for interactive sign-in the first time)
./scripts/Get-LicenseReport.ps1

# Export to CSV
./scripts/Get-LicenseReport.ps1 -OutputFormat CSV -OutputDirectory ./reports

# Export to HTML
./scripts/Get-LicenseReport.ps1 -OutputFormat HTML -OutputDirectory ./reports
```

See [`examples/usage.md`](examples/usage.md) for sample output.

## Repository structure

```
m365-admin-toolkit/
├─ .github/workflows/lint.yml   # PSScriptAnalyzer + Pester on every push/PR
├─ src/M365AdminToolkit.psm1    # Pure, Graph-free helper functions (unit-tested)
├─ scripts/Get-LicenseReport.ps1
├─ examples/usage.md
└─ tests/Toolkit.Tests.ps1      # Pester v5
```

The transformation logic lives in the module with **no Graph calls**, so it can
be unit-tested in CI without a tenant or credentials. The script handles auth
and I/O.

## Development

```powershell
# Lint
Invoke-ScriptAnalyzer -Path . -Recurse

# Test
Invoke-Pester -Path ./tests
```

## Security notes

- No secrets in source. Authentication is interactive/delegated by design.
- `.gitignore` excludes generated reports and local credential artifacts.
- Use a trial tenant for any screenshots or recordings.

## License

[MIT](LICENSE)
