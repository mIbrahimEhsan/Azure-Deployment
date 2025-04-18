param sourceVnetName string
param targetVnetId string
param peeringName string

resource vnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2022-11-01' = {
  name: '${sourceVnetName}/${peeringName}'
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: targetVnetId
    }
  }
}
