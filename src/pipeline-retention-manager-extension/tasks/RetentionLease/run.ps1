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

$request = ConvertTo-Json $rawRequest -Depth 10

$uri = "$env:SYSTEM_COLLECTIONURI$env:SYSTEM_TEAMPROJECT/_apis/build/retention/leases?api-version=6.0-preview.1"

$newLease = Invoke-RestMethod `
    -Uri $uri `
    -Method POST `
    -Headers $headers `
    -ContentType $contentType `
    -Body $request

$newLeaseId = $null

# The API response shape has varied over time and across endpoints.
# Handle common shapes:
# - { value: [ { leaseId: 123 } ] }
# - { leaseId: 123 }
# - [ { leaseId: 123 } ]
if ($null -ne $newLease) {
    if ($newLease.PSObject.Properties.Name -contains 'value' -and $null -ne $newLease.value -and $newLease.value.Count -gt 0) {
        $newLeaseId = $newLease.value[0].leaseId
    }
    elseif ($newLease -is [System.Array] -and $newLease.Count -gt 0) {
        $newLeaseId = $newLease[0].leaseId
    }
    elseif ($newLease.PSObject.Properties.Name -contains 'leaseId') {
        $newLeaseId = $newLease.leaseId
    }
}

if ([string]::IsNullOrWhiteSpace([string]$newLeaseId)) {
    $responseJson = $null
    try { $responseJson = ConvertTo-Json $newLease -Depth 20 -Compress } catch { }
    throw "Retention lease created but no leaseId was returned. Response: $responseJson"
}

Write-Host "##vso[task.setvariable variable=newLeaseId;isOutput=true]$newLeaseId"
