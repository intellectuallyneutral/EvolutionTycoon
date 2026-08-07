$ErrorActionPreference = "Stop"

Write-Host "1. Resolving and Installing Wally Dependencies..."
wally install

Write-Host "2. Generating Deterministic Sourcemap (LSP Autogenerate is DISABLED)..."
# Rojo generates the sourcemap synchronously. The pipeline waits for the exit code.
rojo sourcemap sourcemap.project.json --output sourcemap.json --include-non-scripts

Write-Host "3. Generating Package Type Thunks..."
# Generate types for the shared dependencies realm
wally-package-types --sourcemap sourcemap.json Packages/

# Generate types for the server-only dependencies realm, if present
if (Test-Path "ServerPackages") {
    wally-package-types --sourcemap sourcemap.json ServerPackages/
}

# Generate types for the development dependencies realm, if present
if (Test-Path "DevPackages") {
    wally-package-types --sourcemap sourcemap.json DevPackages/
}

Write-Host "Dependency synchronization complete. Restart Luau-LSP server if cache remains stale."
