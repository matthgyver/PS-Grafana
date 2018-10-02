# Powershell module for Grafana
## I. Introduction
This module provide a simple collection of Powershell commandlet to manage Grafana by the REST API.

Simple manage Grafana users, folder, permissions ... with a windows commande line tool.

This module required at least Powershell version 5. (I've seen some problems with version 4 and JSON dashboard importation, maybe all other commandlets work great)

All contribution are welcome !
## II. Features
### 1. Common features
To simplify multiple operations, there is some commandlet to store credential. You can use this functions :

* Storing username / password credential and target URL : 

```powershell
Connect-Grafana -authLogin foobar -authPassword myPassword -url https://foo.bar.com
```
* Storing API key credential and target URL : 

```powershell
Connect-Grafana -authToken f00barazertyMynAme1sWa11t3rWh1t3 -url https://foo.bar.com
```

* Define the "context" *(working organisation for the authenticated user with plaintext method)* :

```powershell
Set-Grafana-Context -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -orgName "foo bar org."
```

* DisConnect- commandlet

```powershell
Disconnect-Grafana
```
All commandlet can be used with authentications parameters. Refer to the next chapter for more informations.
### 2. Special features
Use Get-Help to display all features of a commandlet.
By example, "get-help -full New-GrafanaDashboard" will show you that you could create a new dashboard from a template and how to use it.

### 3. Synthesis
I referenced here all commandlets that will be usefull.

All of them are not developed at this time. I just coded the ones I needed for my job.
#### Admin features
|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaSettings|[Link](http://docs.Grafana.org/http_api/admin/#settings)|Token & Plaintext|not started|
|Get-GrafanaStats|[Link](http://docs.Grafana.org/http_api/admin/#Grafana-stats)|Token & Plaintext|not started|

#### Alerting
|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaAlerts|[Link](http://docs.Grafana.org/http_api/alerting/#Get-alerts)|Token & Plaintext|not started|
|Pause-GrafanaAlerts|[Link](http://docs.Grafana.org/http_api/alerting/#pause-alert)|Token & Plaintext|not started|
|Get-GrafanaAlertsNotifications|[Link](http://docs.Grafana.org/http_api/alerting/#Get-alert-notifications)|Token & Plaintext|not started|
|New-GrafanaAlertsNotifications|[Link](http://docs.Grafana.org/http_api/alerting/#create-alert-notification)|Token & Plaintext|not started|
|Set-GrafanaAlertsNotifications|[Link](http://docs.Grafana.org/http_api/alerting/#update-alert-notification)|Token & Plaintext|not started|
|Remove-GrafanaAlertsNotifications|[Link](http://docs.Grafana.org/http_api/alerting/#delete-alert-notification)|Token & Plaintext|not started|

#### Annotations features
|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaAnnotations|[Link](http://docs.Grafana.org/http_api/annotations/#find-Annotations)|Token & Plaintext|not started|
|New-GrafanaAnnotations|[Link](http://docs.Grafana.org/http_api/annotations/#create-annotation)|Token & Plaintext|not started|
|Set-GrafanaAnnotations|[Link](http://docs.Grafana.org/http_api/annotations/#update-annotation)|Token & Plaintext|not started|
|Remove-GrafanaAnnotations|[Link](http://docs.Grafana.org/http_api/annotations/#delete-annotation-by-id)|Token & Plaintext|not started|

#### Authentication features
|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|New-GrafanaApikey|[Link](http://docs.Grafana.org/http_api/auth/#create-api-key)|Token & Plaintext|not started|
|Remove-GrafanaApikey|[Link](http://docs.Grafana.org/http_api/auth/#delete-api-key)|Token & Plaintext|not started|

#### Dashboard features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|New-GrafanaDashboard|[Link](http://docs.Grafana.org/http_api/dashboard/#create-update-Dashboard)|Token & Plaintext|OK|
|Get-GrafanaDashboard|[Link](http://docs.Grafana.org/http_api/folder_dashboard_search/)|Token & Plaintext|OK|
|Get-GrafanaDashboardContent||Token & Plaintext|OK|
|Move-GrafanaDashboard||Token & Plaintext|OK|
|Remove-GrafanaDashboard|[Link](http://docs.Grafana.org/http_api/dashboard/#delete-Dashboard-by-uid)|Token & Plaintext|OK|
|Set-GrafanaDashboard|Custom function to move or rename a dashboard|Token & Plaintext|OK|
|Get-GrafanaHomeDashboard|[Link](http://docs.Grafana.org/http_api/dashboard/#gets-the-home-Dashboard)|Token & Plaintext|not started|
|Get-GrafanaDashboardVersion|[Link](http://docs.Grafana.org/http_api/dashboard_versions/#Get-Dashboard-version)|Token & Plaintext|OK|
|Restore-GrafanaDashboard|[Link](http://docs.Grafana.org/http_api/dashboard_versions/#restore-Dashboard)|Token & Plaintext|not started|
|Compare-GrafanaHomeDashboard|[Link](http://docs.Grafana.org/http_api/dashboard_versions/#compare-Dashboard-versions)|Token & Plaintext|not started|

#### Datasource features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaDatasource|[Link](http://docs.Grafana.org/http_api/data_source/#Get-all-Datasources)|Token & Plaintext|OK|
|New-GrafanaDatasource|[Link](http://docs.Grafana.org/http_api/data_source/#create-data-source)|Token & Plaintext|not started|
|Set-GrafanaDatasource|[Link](http://docs.Grafana.org/http_api/data_source/#update-an-existing-data-source)|Token & Plaintext|not started|
|Remove-GrafanaDatasource|[Link](http://docs.Grafana.org/http_api/data_source/#delete-an-existing-data-source-by-id)|Token & Plaintext|not started|

#### Folder features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaFoldersList|[Link](http://docs.Grafana.org/http_api/folder_dashboard_search/)|Token & Plaintext|OK|
|Get-GrafanaFolder||Token & Plaintext|OK|
|New-GrafanaFolder|[Link](http://docs.Grafana.org/http_api/folder/#create-folder)|Token & Plaintext|OK|
|Remove-GrafanaFolder|[Link](http://docs.Grafana.org/http_api/folder/#delete-folder)|Token & Plaintext|OK|
|Set-GrafanaFolder|[Link](http://docs.Grafana.org/http_api/folder/#update-folder)|Token & Plaintext|OK|

#### Organisation features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaOrganisation|[Link](http://docs.Grafana.org/http_api/org/#organisation-api)|Plaintext only|OK|
|New-GrafanaOrganisation|[Link](http://docs.Grafana.org/http_api/org/#create-organisation)|Plaintext only|OK|
|Set-GrafanaOrganisation|[Link](http://docs.Grafana.org/http_api/org/#update-organisation)|Plaintext only|OK|
|Add-GrafanaUserInOrganisation|[Link](http://docs.Grafana.org/http_api/org/#add-user-in-organisation)|Plaintext only|OK|
|Get-GrafanaOrganisationUsers|[Link](http://docs.Grafana.org/http_api/org/#Get-users-in-organisation)|Plaintext only|OK|
|Set-GrafanaUserRoleInOrganisation|[Link](http://docs.Grafana.org/http_api/org/#update-users-in-organisation)|Token & Plaintext|OK|
|Remove-GrafanaUserFromOrganisation|[Link](http://docs.Grafana.org/http_api/org/#delete-user-in-organisation)|Token & Plaintext|OK|

#### Permissions features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaFolderPermissions|[Link](http://docs.Grafana.org/http_api/folder_permissions/#Get-permissions-for-a-folder)|Token & Plaintext|OK|
|New-GrafanaFolderPermissions|[Link](http://docs.Grafana.org/http_api/folder_permissions/#update-permissions-for-a-folder)|Token & Plaintext|OK|
|Remove-GrafanaFolderPermissions|[Link](http://docs.Grafana.org/http_api/folder_permissions/#update-permissions-for-a-folder)|Token & Plaintext|OK|
|Get-GrafanaDashboardPermissions|[Link](http://docs.Grafana.org/http_api/dashboard_permissions/#Get-permissions-for-a-Dashboard)|Token & Plaintext|OK|
|New-GrafanaDashboardPermissions|[Link](http://docs.Grafana.org/http_api/dashboard_permissions/#update-permissions-for-a-Dashboard)|Token & Plaintext|OK|
|Remove-GrafanaDashboardPermissions|[Link](http://docs.Grafana.org/http_api/dashboard_permissions/#update-permissions-for-a-Dashboard)|Token & Plaintext|OK|

#### Other features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaSettings|[Link](http://docs.Grafana.org/http_api/other/#Get-settings)|Token & Plaintext|not started|

#### Preferences features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaCurrentUserPrefs|[Link](http://docs.Grafana.org/http_api/preferences/#Get-current-user-prefs)|Token & Plaintext|not started|
|Set-GrafanaCurrentUserPrefs|[Link](http://docs.Grafana.org/http_api/preferences/#update-current-user-prefs)|Token & Plaintext|not started|
|Get-GrafanaCurrentOrgPrefs|[Link](http://docs.Grafana.org/http_api/preferences/#Get-current-org-prefs)|Token & Plaintext|not started|
|Set-GrafanaCurrentOrgPrefs|[Link](http://docs.Grafana.org/http_api/preferences/#update-current-org-prefs)|Token & Plaintext|not started|

#### Snapshots features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|New-GrafanaSnapshot|[Link](http://docs.Grafana.org/http_api/snapshot/#create-New-snapshot)|Token & Plaintext|not started|
|Get-GrafanaSnapshot|[Link](http://docs.Grafana.org/http_api/snapshot/#Get-snapshot-by-id)|Token & Plaintext|not started|
|Remove-GrafanaSnapshot|[Link](http://docs.Grafana.org/http_api/snapshot/#delete-snapshot-by-deletekey)|Token & Plaintext|not started|

#### Team features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|New-GrafanaTeam|[Link](http://docs.Grafana.org/http_api/team/#add-team)|Token & Plaintext|OK|
|Get-GrafanaTeam|[Link](http://docs.Grafana.org/http_api/team/#team-search-with-paging)|Token & Plaintext|OK|
|Set-GrafanaTeam|[Link](http://docs.Grafana.org/http_api/team/#update-team)|Token & Plaintext|OK|
|Remove-GrafanaTeam|[Link](http://docs.Grafana.org/http_api/team/#delete-team-by-id)|Token & Plaintext|OK|
|Get-GrafanaTeamMembers|[Link](http://docs.Grafana.org/http_api/team/#Get-team-members)|Token & Plaintext|OK|
|Add-GrafanaTeamMember|[Link](http://docs.Grafana.org/http_api/team/#add-team-member)|Plaintext only|OK|

#### Users Features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Get-GrafanaUser|[Link](http://docs.Grafana.org/http_api/user/#Get-single-user-by-username-login-or-email)|Plaintext only|OK|
|New-GrafanaUser|[Link](http://docs.Grafana.org/http_api/admin/#global-users)|Plaintext only|OK|
|Get-GrafanaUserOrgs|[Link](http://docs.Grafana.org/http_api/user/#Get-organisations-for-user)|Plaintext only|OK|
|Remove-GrafanaUser|[Link](http://docs.Grafana.org/http_api/admin/#delete-global-user)|Plaintext only|OK|
|Set-GrafanaContext|[Link](http://docs.Grafana.org/http_api/user/#switch-user-context-for-a-specified-user)|Plaintext only|OK|
|Set-StarGrafanaDashboard|[Link](http://docs.Grafana.org/http_api/user/#star-a-Dashboard)|Token & Plaintex|not started|

#### Custom features

|Commandlet|Official API documentation|Authentication|Status|
|----------|---------------------------|--------------|:--:|
|Connect-Grafana|See chapter 'Common features'|Token & Plaintext|OK|
|Disconnect-Grafana|See chapter 'Common features'||OK|

## III. Evolutions
  * Code all commandlets
  * Improve parameter verifications
  * Add pipe features
