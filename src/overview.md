# Pipeline Retention Manager

The **Pipeline Retention Manager** is an Azure DevOps extension that allows teams to automate retention leases for pipeline runs. By creating a lease, important builds are protected from automatic cleanup for a configurable number of days.

## Usage

```yaml
pool:
  vmImage: ubuntu-latest

steps:
  - task: RetentionLease@1
    name: createLease
    env:
      SYSTEM_ACCESSTOKEN: $(System.AccessToken)
    inputs:
      daysValid: 360

  - script: echo "Retention Lease ID is $(createLease.newLeaseId)"
```
