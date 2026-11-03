# utf-8
function Connect-tptCentreon {
    <#
    .SYNOPSIS
        Autentica contra el API REST de Centreon y guarda el token para llamadas posteriores.

    .DESCRIPTION
        Establece una conexión autenticada con el servidor Centreon. Llama a
        Test-tptCentreonConnection para obtener el authToken y lo guarda en el
        estado del módulo ($script:CentreonToken). Si la autenticación tiene éxito,
        devuelve un objeto PSCustomObject con detalles de la conexión.

    .PARAMETER Url
        URL base del servidor Centreon (incluir scheme y puerto).
        Si no se proporciona, usa $script:CentreonUrl si existe, o 'https://centreon.local'.

    .PARAMETER Credential
        Credenciales de Centreon (usuario y contraseña). Se requieren para la autenticación.

    .EXAMPLE
        Connect-tptCentreon -Url 'https://centreon.example.com:8080' -Credential (Get-Credential)
        Autentica con el servidor Centreon y guarda el token.

    .EXAMPLE
        Connect-tptCentreon
        Usa las credenciales por defecto desde el prompt y la URL guardada en el módulo.

    .OUTPUTS
        System.Management.Automation.PSObject con propiedades:
        Url, User, Connected (true), ApiVersion.
    #>
    [CmdletBinding()]
    [OutputType([System.Object])]
    param(
        [string]$Url = $null,

        [Parameter(Mandatory = $true)]
        [ValidateNotNull()]
        [PSCredential]$Credential
    )

    # Usar URL por defecto si no se proporciona
    if (-not $Url) {
        $Url = $script:CentreonUrl ?? "https://centreon.local"
    }

    # Autenticar contra Centreon
    $token = Test-tptCentreonConnection -Url $Url -Credential $Credential

    # Guardar token y URL en estado del módulo
    $script:CentreonToken = $token
    $script:CentreonUrl = $Url

    # Construir objeto de conexión
    [PSCustomObject]@{
        Url = $Url
        User = $Credential.UserName
        Connected = $true
        ApiVersion = '1.0'
    }
}