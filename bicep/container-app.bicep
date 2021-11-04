// general Azure Container App settings
param location string
param name string
param containerAppEnvironmentId string

// Container Image ref
param containerImage string
param containerPort int
// Networking
param useExternalIngress bool = false

param registry string
param registryUsername string

@secure()
param registryPassword string
param envVars array = []

resource containerApp 'Microsoft.Web/containerApps@2021-03-01' = {
    name: name
    kind: 'containerapp'
    location: location
    properties: {
        kubeEnvironmentId: containerAppEnvironmentId
        configuration: {
            activeRevisionsMode: 'multiple'
            secrets: [
                {
                    name: 'container-registry-password'
                    value: registryPassword
                }
            ]
            ingress: {
                external: useExternalIngress
                targetPort: containerPort 
             /*   traffic: [
                    {
                      revisionName: 'golang-api--s25y6d3' // sample-api:1.0.0
                      weight: 80
                    }
                    {
                      revisionName: 'golang-api--hjctnnw' // sample-api:2.0.0
                      weight: 20
                    }
                  ]
             */
            }
            registries: [
                {
                    server: registry
                    username: registryUsername
                    passwordSecretRef: 'container-registry-password'
                }
            ]
        }
        template: {
            containers: [
                {
                    image: containerImage
                    port: containerPort
                    name: name
                    env: envVars
                }
            ]
            scale: {
                minReplicas: 0
                maxReplicas: 1
            }
        }
    }
}
output fqdn string = containerApp.properties.configuration.ingress.fqdn
