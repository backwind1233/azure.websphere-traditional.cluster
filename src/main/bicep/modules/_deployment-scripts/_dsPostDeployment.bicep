/*
     Copyright (c) Microsoft Corporation.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

          http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
*/

param _artifactsLocation string = deployment().properties.templateLink.uri
@secure()
param _artifactsLocationSasToken string = ''
param location string
param name string = ''
param identity object = {}
param configureAppGw bool
param resourceGroupName string
param numberOfWorkerNodes int
param workerNodePrefix string

param utcValue string = utcNow()

var const_scriptLocation = uri(_artifactsLocation, 'scripts/')

resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzureCLI'
  identity: identity
  properties: {
    azCliVersion: '2.41.0'
    environmentVariables: [  
      {
        name: 'CONFIGURE_APPGW'
        value: string(configureAppGw)
      }
      {
        name: 'RESOURCE_GROUP_NAME'
        value: resourceGroupName
      }   
      {
        name: 'NUMBER_OF_WORKER_NODES'
        value: string(numberOfWorkerNodes)
      }
      {
        name: 'WORKER_NODE_PREFIX'
        value: workerNodePrefix
      }
    ]
    primaryScriptUri: uri(const_scriptLocation, 'post-deployment.sh${_artifactsLocationSasToken}')

    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
    forceUpdateTag: utcValue
  }
}
