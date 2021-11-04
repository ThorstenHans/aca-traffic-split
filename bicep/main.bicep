param location string = resourceGroup().location
param envName string = 'blog-sample'

param containerImage string
param containerPort int

param registry string
param registryUsername string

@secure()
param registryPassword string

module law 'law.bicep' = {
    name: 'log-analytics-workspace'
    params: {
        location: location
        name: envName
    }
}

module containerAppEnvironment 'environment.bicep' = {
    name: 'container-app-environment'
    params: {
        name: envName
        location: location
        lawClientId: law.outputs.clientId
        lawClientSecret: law.outputs.clientSecret
    }
}

module containerApp 'container-app.bicep' = {
    name: 'container-app-golang'
    params: {
        name: 'golang-api'
        location: location
        containerAppEnvironmentId: containerAppEnvironment.outputs.id
        containerImage: containerImage
        containerPort: containerPort
        envVars: []
        useExternalIngress: true
        registry: registry
        registryUsername: registryUsername
        registryPassword: registryPassword
    }
}
output fqdn string = containerApp.outputs.fqdn
