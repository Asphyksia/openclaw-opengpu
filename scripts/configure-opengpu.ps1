# OpenGPU Relay Configuration Script for OpenClaw (Windows/PowerShell)
$ErrorActionPreference = "Stop"

# Get paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$ConfigDir = if ($env:OPENCLAW_CONFIG_DIR) { $env:OPENCLAW_CONFIG_DIR } else { "$env:USERPROFILE\.openclaw" }
$ConfigFile = Join-Path $ConfigDir "openclaw.json"
$EnvFile = Join-Path $ProjectRoot ".env"

# Print functions
function Print-Header {
    Clear-Host
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "  OpenClaw + OpenGPU Relay Setup" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
}

function Print-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Print-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

# Show main menu
function Show-Menu {
    Write-Host ""
    Write-Host "OpenGPU Relay Configuration Menu:" -ForegroundColor Cyan
    Write-Host "  1) Configure or update OpenGPU (API key + default model)"
    Write-Host "  2) View current configuration"
    Write-Host "  3) Test OpenGPU connection"
    Write-Host "  4) Remove OpenGPU configuration"
    Write-Host "  5) Exit"
    Write-Host ""
}

# Test OpenGPU API key
function Test-OpenGpuKey {
    param([string]$ApiKey)

    Write-Host "Validating OpenGPU API key..." -ForegroundColor Cyan

    try {
        $headers = @{
            "Authorization" = "Bearer $ApiKey"
        }

        $response = Invoke-RestMethod -Uri "https://relay.opengpu.network/v1/models" `
            -Headers $headers `
            -TimeoutSec 10

        Print-Success "OpenGPU API key is valid!"
        return $true
    }
    catch {
        Print-Error "Invalid OpenGPU API key"
        return $false
    }
}

# Get API key from user
function Get-OpenGpuApiKey {
    while ($true) {
        Write-Host ""
        $apiKey = Read-Host "Enter your OpenGPU Relay API Key (from https://relaygpu.com)"

        if ([string]::IsNullOrWhiteSpace($apiKey)) {
            Print-Error "API key cannot be empty"
            continue
        }

        if (Test-OpenGpuKey -ApiKey $apiKey) {
            return $apiKey
        }

        $retry = Read-Host "Try again? (y/n)"
        if ($retry -ne "y" -and $retry -ne "Y") {
            throw "Configuration cancelled by user"
        }
    }
}

# Select model
function Select-Model {
    Write-Host ""
    Write-Host "Select your default model:" -ForegroundColor Cyan
    Write-Host "  1) gpt-oss-120b (120B parameters, powerful) - Recommended"
    Write-Host "  2) gpt-oss-20b  (20B parameters, faster)"
    Write-Host "  3) llama-3.2-3b (3B parameters, fastest)"
    Write-Host "  4) deepseek-r1-8b (8B parameters, reasoning)"
    Write-Host ""

    while ($true) {
        Write-Host "Enter choice (1-4) or press Enter for default [1]: " -NoNewline
        $choice = Read-Host
        $choice = if ([string]::IsNullOrWhiteSpace($choice)) { "1" } else { $choice }

        switch ($choice) {
            "1" { return "opengpu/openai/gpt-oss-120b" }
            "2" { return "opengpu/openai/gpt-oss-20b" }
            "3" { return "opengpu/llama-3.2-3b" }
            "4" { return "opengpu/deepseek-r1-8b" }
            default {
                Print-Error "Invalid choice. Please enter 1-4"
            }
        }
    }
}

# Update .env file
function Update-EnvFile {
    param([string]$ApiKey)

    Write-Host ""

    if (Test-Path $EnvFile) {
        $backupFile = "$EnvFile.backup.$(Get-Date -Format 'yyyyMMddHHmmss')"
        Copy-Item $EnvFile $backupFile
        Write-Host "Backed up .env to: $backupFile" -ForegroundColor Yellow
    }

    # Read existing content
    $envContent = if (Test-Path $EnvFile) { Get-Content $EnvFile } else { @() }

    # Remove existing OPENGPU_API_KEY
    $envContent = $envContent | Where-Object { $_ -notmatch "^OPENGPU_API_KEY=" }

    # Add new API key
    $envContent += "OPENGPU_API_KEY=$ApiKey"

    # Write back
    $envContent | Set-Content -Path $EnvFile

    Print-Success ".env file updated"
}

# Create OpenClaw config
function New-OpenClawConfig {
    param(
        [string]$ApiKey,
        [string]$DefaultModel
    )

    if (!(Test-Path $ConfigDir)) {
        New-Item -ItemType Directory -Path $ConfigDir -Force | Out-Null
    }

    Write-Host "Creating OpenClaw configuration..." -ForegroundColor Cyan

    $config = @"
{
  "env": {
    "OPENGPU_API_KEY": "${ApiKey}"
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "${DefaultModel}"
      },
      "sandbox": {
        "mode": "all",
        "scope": "agent",
        "workspaceAccess": "none"
      },
      "workspace": "~/.openclaw/workspace"
    },
    "list": [
      {
        "id": "main",
        "identity": {
          "name": "Clawd",
          "theme": "helpful assistant",
          "emoji": "🦞"
        }
      }
    ]
  },
  "gateway": {
    "mode": "local",
    "bind": "loopback",
    "port": 18789
  },
  "logging": {
    "level": "info",
    "consoleLevel": "info",
    "consoleStyle": "pretty",
    "redactSensitive": "tools"
  }
}
"@

    $config | Set-Content -Path $ConfigFile

    Print-Success "Configuration created at: $ConfigFile"
}

# View current configuration
function View-Config {
    Write-Host ""

    if (Test-Path $EnvFile) {
        Write-Host "=== Current .env file ===" -ForegroundColor Cyan
        Get-Content $EnvFile
    } else {
        Print-Info "No .env file found at $EnvFile"
    }

    Write-Host ""
    Write-Host "=== Current OpenClaw config ===" -ForegroundColor Cyan
    if (Test-Path $ConfigFile) {
        Get-Content $ConfigFile
    } else {
        Print-Info "No OpenClaw configuration found at $ConfigFile"
    }
}

# Test OpenGPU connection using key from .env
function Test-OpenGpuConnection {
    if (-not (Test-Path $EnvFile)) {
        Print-Error "No .env file found at $EnvFile. Please configure OpenGPU first (option 1)."
        return
    }

    $envContent = Get-Content $EnvFile
    $apiLine = $envContent | Where-Object { $_ -match "^OPENGPU_API_KEY=" }
    if (-not $apiLine) {
        Print-Error "No OPENGPU_API_KEY found in .env. Please configure OpenGPU first (option 1)."
        return
    }

    $apiKey = $apiLine.Split("=", 2)[1]
    if ([string]::IsNullOrWhiteSpace($apiKey)) {
        Print-Error "OPENGPU_API_KEY in .env is empty."
        return
    }

    Write-Host ""
    Print-Info "Testing OpenGPU Relay connection..."

    if (Test-OpenGpuKey -ApiKey $apiKey) {
        Print-Success "OpenGPU Relay connection successful!"
    } else {
        Print-Error "Failed to validate OpenGPU API key against OpenGPU Relay."
    }
}

# Remove OpenGPU configuration
function Remove-OpenGpuConfig {
    Write-Host ""
    Print-Info "This will remove OpenGPU configuration from:"
    Write-Host "  - $EnvFile"
    Write-Host "  - $ConfigFile"
    Write-Host ""
    $confirm = Read-Host "Are you sure? (y/n)"

    if ($confirm -eq "y" -or $confirm -eq "Y") {
        if (Test-Path $EnvFile) {
            $envContent = Get-Content $EnvFile | Where-Object { $_ -notmatch "^OPENGPU_API_KEY=" }
            $envContent | Set-Content -Path $EnvFile
            Print-Success "Removed OPENGPU_API_KEY from .env"
        }

        if (Test-Path $ConfigFile) {
            Remove-Item $ConfigFile -Force
            Print-Success "Removed OpenClaw configuration file"
        }

        Print-Info "You can now reconfigure OpenClaw with ./docker-setup.sh"
    } else {
        Print-Info "Operation cancelled"
    }
}

# Main function
function Main {
    Print-Header

    # Check Docker
    $docker = Get-Command docker -ErrorAction SilentlyContinue
    if (-not $docker) {
        Print-Error "Docker is not installed. Please install Docker Desktop first."
        Read-Host "Press Enter to exit"
        exit 1
    }

    Print-Info "This will configure OpenClaw to use OpenGPU Network's Relay API"
    Write-Host ""

    if (Test-Path $EnvFile) {
        $envContent = Get-Content $EnvFile
        $hasKey = $envContent | Where-Object { $_ -match "^OPENGPU_API_KEY=" }
        if ($hasKey) {
            Print-Success "OpenGPU is already configured (API key found in .env)."
        } else {
            Print-Info "No OPENGPU_API_KEY found in .env. Use option 1 to configure it."
        }
    } else {
        Print-Info "No .env file found yet. Use option 1 to configure OpenGPU."
    }

    while ($true) {
        Show-Menu
        $choice = Read-Host "Enter choice [1]"
        $choice = if ([string]::IsNullOrWhiteSpace($choice)) { "1" } else { $choice }

        switch ($choice) {
            "1" {
                try {
                    Write-Host ""
                    Write-Host "=== Step 1: API Key ===" -ForegroundColor Cyan
                    $apiKey = Get-OpenGpuApiKey

                    Write-Host ""
                    Write-Host "=== Step 2: Select Model ===" -ForegroundColor Cyan
                    $model = Select-Model
                    Write-Host "Selected model: $model" -ForegroundColor Green

                    Write-Host ""
                    Write-Host "=== Step 3: Update Configuration ===" -ForegroundColor Cyan
                    Update-EnvFile -ApiKey $apiKey
                    New-OpenClawConfig -ApiKey $apiKey -DefaultModel $model

                    Write-Host ""
                    Write-Host "========================================" -ForegroundColor Green
                    Write-Host "  Configuration Complete!" -ForegroundColor Green
                    Write-Host "========================================" -ForegroundColor Green
                    Write-Host ""
                    Write-Host "Your model: $model"
                    Write-Host ""
                    Write-Host "Next steps:" -ForegroundColor Cyan
                    Write-Host "  1. Restart the gateway:"
                    Write-Host "     docker compose restart"
                    Write-Host ""
                    Write-Host "  2. Or start it:"
                    Write-Host "     docker compose up -d"
                    Write-Host ""
                    Write-Host "  3. Dashboard:"
                    Write-Host "     http://localhost:18789"
                    Write-Host ""
                }
                catch {
                    Write-Host ""
                    Print-Error "Configuration failed: $_"
                }
            }
            "2" {
                View-Config
                Read-Host "Press Enter to return to the menu"
            }
            "3" {
                Test-OpenGpuConnection
                Read-Host "Press Enter to return to the menu"
            }
            "4" {
                Remove-OpenGpuConfig
                Read-Host "Press Enter to return to the menu"
            }
            "5" {
                return
            }
            default {
                Print-Error "Invalid choice. Please enter 1-5."
            }
        }
    }
}

# Run main
Main
