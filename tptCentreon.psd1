@{
    # Identidad del módulo
    RootModule           = 'tptCentreon.psm1'
    ModuleVersion        = '0.0.1'
    GUID                 = '2d2ad8e9-da3d-4327-8e2f-51a646d4db14'
    Author               = 'Tarrerator'
    CompanyName          = 'Tarrerator'
    Copyright            = '(c) 2026 Tarrerator'

    # Descripción
    Description          = 'Módulo PowerShell que envuelve la API REST oficial de Centreon para monitorización: inventario de hosts, servicios, métricas, alertas y estado de conexión.'

    # Compatibilidad
    PowerShellVersion    = '7.2'
    CompatiblePSEditions = @('Desktop', 'Core')

    # Exportaciones explícitas: nada de comodines
    FunctionsToExport    = @(
        'Connect-tptCentreon'
        'Get-tptCentreonHosts'
        'Get-tptCentreonServices'
        'Get-tptCentreonMetrics'
        'Get-tptCentreonAlerts'
        'Get-tptCentreonStatus'
    )
    CmdletsToExport      = @()
    VariablesToExport    = @()
    AliasesToExport      = @()

    PrivateData          = @{
        PSData = @{
            Tags         = @('Centreon', 'REST', 'API', 'Monitoring', 'Inventory')
            ProjectUri   = 'https://github.com/Tarrerator/tptCentreon'
            ReleaseNotes = 'Esqueleto del módulo: manifiesto, cargador y estructura Public/Private.'
            LicenseUri   = 'https://opensource.org/licenses/GPL-3.0'
        }
    }
}
