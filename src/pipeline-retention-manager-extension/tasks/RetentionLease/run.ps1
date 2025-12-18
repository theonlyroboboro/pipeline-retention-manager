param(
    [Parameter(Mandatory = $true)]
    [int]$DaysValid
)

$contentType = "application/json"

$headers = @{
    Authorization = "Bearer $env:SYSTEM_ACCESSTOKEN"
}

$rawRequest = @{
    daysValid       = $DaysValid
    definitionId    = $env:SYSTEM_DEFINITIONID
    ownerId         = "User:$env:BUILD_REQUESTEDFORID"
    protectPipeline = $false
    runId           = $env:BUILD_BUILDID
}

$request = ConvertTo-Json @($rawRequest)

$uri = "$env:SYSTEM_COLLECTIONURI$env:SYSTEM_TEAMPROJECT/_apis/build/retention/leases?api-version=6.0-preview.1"

$newLease = Invoke-RestMethod `
    -Uri $uri `
    -Method POST `
    -Headers $headers `
    -ContentType $contentType `
    -Body $request

$newLeaseId = $newLease.value[0].leaseId

Write-Host "##vso[task.setvariable variable=newLeaseId;isOutput=true]$newLeaseId"
