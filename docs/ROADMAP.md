# utf-8
# Roadmap

## Conexión
- [x] Connect-tptCentreon: autenticación contra la API REST de Centreon
- [ ] Configurar conexión manual ~/.tpt/tptCentreon.yaml

## Inventario
- [x] Get-tptCentreonHosts: hosts de Centreon
- [x] Get-tptCentreonServices: servicios de Centreon
- [x] Get-tptCentreonMetrics: métricas de hosts
- [x] Get-tptCentreonAlerts: alertas de Centreon
- [ ] Get-tptCentreonBusinessView: Business View de Centreon
- [ ] Get-tptCentreonTopology: topología de Centreon

## Administración
- [ ] New-tptCentreonHost: crear nuevo host
- [ ] Remove-tptCentreonHost: eliminar host
- [ ] New-tptCentreonService: crear nuevo servicio
- [ ] Set-tptCentreonService: editar servicio

## Observabilidad
- [ ] Get-tptCentreonMetrics (histórico, con rango temporal): métricas históricas con rango de tiempo
- [ ] Test-tptCentreonHealth: prueba de estado de Centreon

## Calidad
- [ ] Testes Pester: suite de tests para el módulo
- [ ] CI: integración continua
