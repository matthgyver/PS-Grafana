#
#TODO: 
#   - add licence file
#
#   This module required Powershell version 5

# ----------------------------------------------------------------------------------
#       Functions with token or plaintext authentication
# ----------------------------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Datasource functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Get-GrafanaDatasource{
    <#
    .SYNOPSIS
        Function for list all or specific datasource from organization.
    .DESCRIPTION
        If datasource name is'nt passed in parameter, commandlet return all of them.

        Output is an object collection with this propertys :
            id          : 9
            orgId       : 7
            name        : foobar
            type        : elasticsearch
            typeLogoUrl : public/app/plugins/datasource/elasticsearch/img/elasticsearch.svg
            access      : proxy
            url         : http://localhost:9200
            password    :
            user        :
            database    :
            basicAuth   : False
            isDefault   : False
            jsonData    : @{esVersion=5; keepCookies=System.Object[]; maxConcurrentShardRequests=256; timeField=@timestamp}
            readOnly    : False

    .EXAMPLE
        Get all datasources :
            Get-GrafanaDatasource -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr"
        Get datasource named "foobar"
            Get-GrafanaDatasource -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                   -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Name of datasource to get
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name
    )
    
    $name = $name -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $resource = "/api/datasources"
    if ( $name -notmatch "^$" ){ $resource += "/$name" }

    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $dashboardList = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ContentType 'application/json;charset=utf-8'

    return $dashboardList
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Dashboard functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Get-GrafanaDashboard{
    <#
    .SYNOPSIS
        Function for list all of dashboards from organization or single dashboard propertys.
    .DESCRIPTION
        Output is an object collection with this property :
            id          : 01
            uid         : 0123456
            title       : fooBar
            uri         : db/fooBar
            url         : /d/0123456/fooBar
            type        : dash-db
            tags        : {}
            isStarred   : False
            folderId    : 03
            folderUid   : ZZA116516
            folderTitle : Folder1
            folderUrl   : /dashboards/f/ZZA116516/Folder1

    .EXAMPLE
        List all dashboards propertys of an organisation :
            Get-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr"
        
        Get all propertys of specific dashboard :
            Get-Grafana-Dashboards -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar

            Get-Grafana-Dashboards -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -uid whxgUL4iz
            
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Dashboard name
    .PARAMETER uid
        Dashboard uid
    .PARAMETER id
        Dashboard id        
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$uid,
        [Parameter(Mandatory=$false)]
        [string]$id
    )
    
    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $resource = "/api/search"
    $param = "?type=dash-db&query="
    $url += "$resource/$param"
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $dashboardList = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ContentType 'application/json;charset=utf-8'

    if ( $name -notmatch "^$" ){
        # It's possible to have multiple dashboard with same name
        $resultToReturn = $dashboardList | Where-Object { $_.title -imatch "^$name$" }
    }elseif ( $uid -notmatch "^$" ) {
        $resultToReturn = $dashboardList | Where-Object { $_.uid -imatch "^$uid$" }
    }elseif ( $id -notmatch "^$" ) {
        $resultToReturn = $dashboardList | Where-Object { $_.id -imatch "^$id$" }
    }else{
        $resultToReturn = $dashboardList
    }
    return $resultToReturn
}
function Get-GrafanaDashboardVersion{
    <#
    .SYNOPSIS
        Function for print dashboard versions.
    .DESCRIPTION
        Return exemple :
            id            : 111
            dashboardId   : 59
            parentVersion : 1
            restoredFrom  : 0
            version       : 2
            created       : 2018-05-28T11:56:13+02:00
            createdBy     : foobar
            message       : new
    .EXAMPLE
        Get dashboard content of dashboard named "foobar" :
            Get-GrafanaDashboardVersion -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar -version 3
        
        Get dashboard content of dashboard with uid "whxgUL4iz" :
            Get-GrafanaDashboardVersion -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -uid whxgUL4iz
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Dashboard name
    .PARAMETER uid
        Dashboard uid
    .PARAMETER id
        Dashboard id
    .PARAMETER latest
        Return only the latest version
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$uid,
        [Parameter(Mandatory=$false)]
        [int]$id,        
        [Parameter(Mandatory=$false)]
        [switch]$latest
    )
    
    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $dashboard = Get-GrafanaDashboard-Obj -authLogin $authLogin -authPassword $authPassword `
                                           -url $url -authToken $authToken -name $name `
                                           -uid $uid -id $id
 
    $resource = "/api/dashboards/id/$($dashboard.id)/versions"
    $url += "$resource"
    if ( $latest -eq $true ){
        $param = "?limit=1"
        $url += $param
    }

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $dashboardVersions = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ContentType 'application/json;charset=utf-8'
    
    return $dashboardVersions
}
function Get-GrafanaDashboardContent{
    <#
    .SYNOPSIS
        Function for print dashboard JSON.
        Print latest version by default
    .DESCRIPTION
        Return exemple
            id            : 111
            dashboardId   : 59
            parentVersion : 1
            restoredFrom  : 0
            version       : 2
            created       : 2018-05-28T11:56:13+02:00
            message       : new
            data          : @{annotations=; editable=True; gnetId=; graphTooltip=0; id=59; links=System.Object[]; panels=System.Object[];
                            schemaVersion=16; style=dark; tags=System.Object[]; templating=; time=; timepicker=; timezone=browser; title=barfoo;
                            uid=NZ1hy2Viz; version=2}
            createdBy     : foobar
    .EXAMPLE
        Get dashboard content of dashboard named "foobar" in version 3:
            Get-GrafanaDashboardContent -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar -version 3
        
        Get dashboard content of dashboard with uid "whxgUL4iz" :
            Get-GrafanaDashboardContent -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -uid whxgUL4iz
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Dashboard name
    .PARAMETER uid
        Dashboard uid
    .PARAMETER id
        Dashboard id        
    .PARAMETER version
        Dashboard version         
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$uid,
        [Parameter(Mandatory=$false)]
        [int]$id,        
        [Parameter(Mandatory=$false)]
        [int]$version
    )
    
    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    $dashboard = Get-GrafanaDashboard-Obj -authLogin $authLogin -authPassword $authPassword `
                                            -url $url -authToken $authToken -name $name `
                                            -uid $uid -id $id
    if ( $version -eq 0 ){
        $version = (Get-GrafanaDashboardVersion -authLogin $authLogin -authPassword $authPassword `
                                                 -url $url -authToken $authToken -id $dashboard.id `
                                                 -latest).version
    }

    $resource = "/api/dashboards/id/$($dashboard.id)/versions/$version"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $dashboardContent = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ContentType 'application/json;charset=utf-8'
    
    return $dashboardContent
}

function Move-GrafanaDashboard{
    <#
    .SYNOPSIS
        Function to Move a dashboard to a folder
    .DESCRIPTION
        Return exemple :
            id      : 56
            slug    : foobar
            status  : success
            uid     : null
            url     : /d/null/foobar
            version : 2               
    .EXAMPLE
        Move a dashboard named "foobar" inside "myFolder" folder :
            Move-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar" -folder myFolder
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Name of dashboard to create
    .PARAMETER folder
        Folder in which to store the new dashboard.
        Use name "root" to move the folder at the root
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$folder
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    if ( $folder -notmatch "^root$" ){
        $folderId = ( Get-GrafanaFolder -url $url -authLogin $authLogin -authPassword $authPassword `
                                         -authToken $authToken -name $folder ).id
    }else{
        $folderId = 0
    }
    
    $dashboard = (Get-GrafanaDashboardContent -authLogin $authLogin -authPassword $authPassword `
                                               -authToken $authToken -url $url -name $name).data
    
    $body = @{
        dashboard = $dashboard
        folderId = $folderId
        overwrite = $false
    }

    $jsonBody = ConvertTo-Json -InputObject $body -Depth 100 -Compress  
    
    $resource = "/api/dashboards/db"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody
}

function New-GrafanaDashboard{
    <#
    .SYNOPSIS
        Function to create a new dashboard
    .DESCRIPTION
        Return exemple :
            id      : 56
            slug    : foobar
            status  : success
            uid     : null
            url     : /d/null/foobar
            version : 2               
    .EXAMPLE
        Create a new dashboard named "foobar" from template:
            New-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar" -templatePath "c:/<path>/<to>/<folder>/myTemplate.json" -datasourcePath "c:/<path>/<to>/<folder>/myDatasource.json"

        Create a new empty dashboard named "foobar" :
            New-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar"
        
        Create a new empty dashboard named "foobar" inside "myFolder" folder :
            New-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar" -folder myFolder
        
        Create a new empty dashboard named "foobar" and add tags "wonderfull,best":
            New-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar" -tag "wonderfull,best"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Name of dashboard to create
    .PARAMETER folder
        Folder in which to store the new dashboard
    .PARAMETER tag
        Tag to assign at the dashboard.
        Could contain multiple values separated by ","
    .PARAMETER templatePath
        Path to JSON template file.
        A template is a JSON file exported with Grafana UI (http://docs.grafana.org/reference/export_import/)
        You could use variables on this file. See parameter 'jsonVarObj'
    .PARAMETER datasourcePath
        Path to JSON datasources definition file.
        Exemple of content :
        [
            {
                "name" : "DS_SRC1",
                "pluginId" : "elasticsearch",
                "type" : "datasource",
                "value" : "src1"
            },
            {
                "name" : "DS_SRC2",
                "pluginId" : "elasticsearch",
                "type" : "datasource",
                "value" : "src2"
            }            
        ]
    .PARAMETER hashVars
        JSON PSObject contain variable name as key and value to subtitue.
        Variable defined in template file between "$$" (ex: $$<myVar>$$) are replaced
        by those defined in this object
        Exemple of content :
        $myVars = @{
            "userFirstName" : "foo",
            "userLastName" : bar
        }
        In the template, "$$userFirstName$$"" will be replaced by "foo" and "$$userLastName$$" by "bar"
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$folder,
        [Parameter(Mandatory=$false)]
        [string]$tag,
        [Parameter(Mandatory=$false)]
        [string]$templatePath,
        [Parameter(Mandatory=$false)]
        [string]$datasourcePath,
        [Parameter(Mandatory=$false)]
        [hashtable]$hashVars
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    $arrayTag = $tag.Split(",")

    if ( $folder -notmatch "^$" ){
        $folderId = ( Get-GrafanaFolder -url $url -authLogin $authLogin -authPassword $authPassword `
                                         -authToken $authToken -name $folder ).id
    }else{
        $folderId = 0
    }
    
    # Workaround to avoid this problem :
    #   https://stackoverflow.com/questions/20848507/why-does-powershell-give-different-result-in-one-liner-than-two-liner-when-conve
    $typeData = Get-TypeData System.array
    Remove-TypeData $typeData    
    
    if ( $templatePath -notmatch "^$" ){
        if ( (Test-Path $templatePath) -eq $false ){
            Write-Error "Template file not found !"
            exit 4
        }
        $jsonTplFile = Get-Content -Path $templatePath -Encoding UTF8

        if ( $hashVars -ne $null ){
            $jsonTplFile = Replace-Grafana-Var-In-Tpl $jsonTplFile $hashVars
        }
        $dashboard = $jsonTplFile | ConvertFrom-Json | ConvertTo-Hashtable
        $dashboard.title = $name
        $dashboard.tags = $arrayTag

        $jsonDataSrcFile = Get-Content -Path $datasourcePath -Encoding UTF8
        $jsonDataSrcFile = $jsonDataSrcFile | ConvertFrom-Json 
        $inputs = $jsonDataSrcFile | ConvertTo-Hashtable

        $resource = "/api/dashboards/import"
    }else{
        $dashboard = @{ 
            id = $null
            uid = $null
            title = $name
            tags = $arrayTag
            timezone = "browser"
            schemaVersion = 16
            version = 0
        }
        $resource = "/api/dashboards/db"
    }

    $body = @{
        dashboard = $dashboard
        inputs = @($inputs)
        folderId = $folderId
        overwrite = $false
    }

    $jsonBody = ConvertTo-Json -InputObject $body -Depth 100 -Compress  
    $url += "$resource"

    Update-TypeData $typeData
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody

    # Import API does'nt permit to set target folder so we should move it
    if ( ( $templatePath -notmatch "^$" ) -and  ($folder -notmatch "^$") ){
        Move-GrafanaDashboard -name $name -folder $folder | Out-Null
    }
}

function Remove-GrafanaDashboard{
    <#
    .SYNOPSIS
        Function to delete a dashboard.
    .DESCRIPTION
        Return example :
            message                  title
            -------                  -----
            Dashboard foobar deleted foobar 
    .EXAMPLE
        Remove dashboard named "foobar"
            Remove-GrafanaDashboard -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Dashboard name to delete
    .PARAMETER uid
        Dashboard uid to delete        
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$uid
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    if ( $uid -match "^$" ){                                       
        $dashboards = Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                        -authToken $authToken -url $url -name $name
        # Write-Host $dashboards
        # $tmp = $dashboards.Count
        # Write-Host $tmp
        # exit
        if( $dashboards.Count -gt 1 ){
            Write-Host "There is more that one dashboard named '$name' !" -ForegroundColor Red
            ForEach ( $dashboard in $dashboards ){
                Write-Host "`t $($dashboard.title) : "
                Write-Host "`t`tUID : $($dashboard.uid)"
                Write-Host "`t`tFolder : $($dashboard.folderTitle)"
                Write-Host "`t`tTags : $($dashboard.tags)"
            }
            Write-Host "You should remove dashboard with uid parameter" -ForegroundColor Yellow
            return
        }
        elseif( $dashboards -ne $null ){
            $uid = $dashboards.uid
        }else{
            Write-Error "No dashboard named '$name' found !"
            return
        }
    }

    $resource = "/api/dashboards/uid/$uid"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method DELETE -ContentType 'application/json;charset=utf-8'
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Folders functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Get-GrafanaFolderList{
    <#
    .SYNOPSIS
        Function for list all of folders from organization
    .DESCRIPTION
        Output is an object collection with this property :
            id        : 03
            uid       : ZIc_5zaeaz
            title     : Folder1
            uri       : db/folder1
            url       : /dashboards/f/ZIc_5zaeaz/folder1
            type      : dash-folder
            tags      : {}
            isStarred : False

        API equivalent : /api/search?type=dash-folder&query=
    .EXAMPLE
        Get-GrafanaFolderList -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                        -authToken $authToken

    $resource = "/api/search"
    $param = "?type=dash-folder&query="
    $url += "$resource/$param"
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $folderList = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -ContentType 'application/json;charset=utf-8'
    
    return $folderList
}

function Get-GrafanaFolder{
    <#
    .SYNOPSIS
        Function to search folder by name
    .DESCRIPTION
        Return example :
            id        : 03
            uid       : ZIc_5zaeaz
            title     : Folder1
            uri       : db/folder1
            url       : /dashboards/f/ZIc_5zaeaz/folder1
            type      : dash-folder
            tags      : {}
            isStarred : False
    .EXAMPLE
        Get-GrafanaFolder -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name myFolder
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication    
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Name of folder to search
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name
    )

    $folder = Get-GrafanaFolderList -url $url -authToken $authToken -authLogin $authLogin `
                                       -authPassword $authPassword | Where-Object { $_.title -eq $name }

    return $folder
}

function New-GrafanaFolder{
    <#
    .SYNOPSIS
        Function to create a new folder in organisation associate to
         the token
    .DESCRIPTION
        Return object with this propertys :
            id        : 55
            uid       : US5RG56mz
            title     : Foo Bar
            url       : /dashboards/f/US5RG56mz/foo-bar
            hasAcl    : False
            canSave   : True
            canEdit   : True
            canAdmin  : True
            createdBy : Anonymous
            created   : 2018-05-18T12:11:56+02:00
            updatedBy : Anonymous
            updated   : 2018-05-18T12:11:56+02:00
            version   : 1        
    .EXAMPLE
        New-GrafanaFolder -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name "Foo Bar"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Name of folder to create
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    $body = @{ title = $name }

    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/folders"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $newFolder = Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody
    
    return $newFolder
}

function Remove-GrafanaFolder{
    <#
    .SYNOPSIS
        Function to remove folder from organisation
    .DESCRIPTION
        Return example :
            message                 title
            -------                 -----
            Folder Foo Bar deleted Foo Bar        
    .EXAMPLE
        Remove-GrafanaFolder -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Folder name to delete
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    $folderUid = (Get-GrafanaFolder -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $name).uid
    
    $resource = "/api/folders/$folderUid"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method DELETE -ContentType 'application/json;charset=utf-8'

}

function Set-GrafanaFolder{
    <#
    .SYNOPSIS
        Function to set some folder propertys
    .DESCRIPTION
        It will automaticaly add 1 on the version number and overwrite the current propertys
        Return example :
            id        : 50
            uid       : YCgsg15za
            title     : foo bar
            url       : /dashboards/f/YCgsg8Mik/foo-bar
            hasAcl    : True
            canSave   : True
            canEdit   : True
            canAdmin  : True
            createdBy : foobar
            created   : 2018-05-04T11:41:45+02:00
            updatedBy : admin
            updated   : 2018-05-24T17:29:21+02:00
            version   : 2
    .EXAMPLE
        Set-GrafanaFolder -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                            -name foobar -newName barfoo
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Folder name to edit
    .PARAMETER newName
        New name of the folder
    .PARAMETER newUid
        New uid of the folder
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$newName,
        [Parameter(Mandatory=$false)]
        [string]$newUid
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    $folder = Get-GrafanaFolder -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $name

    $body = @{}                                     
    if ( $newName -notmatch "^$" ){ $body.Add('title',$newName) }
    if ( $newUid -notmatch "^$" ){ $body.Add('uid',$newUid) }
    $version = ($folder.version + 1)
    $body.Add('version',$version)
    $body.Add('overwrite',$true)

    $jsonBody = $body | ConvertTo-Json -Compress                                     

    $resource = "/api/folders/$($folder.uid)"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Put -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Permissions functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function Get-GrafanaFolderPermissions{
    <#
    .SYNOPSIS
        Function to list all permissions of a folder
    .DESCRIPTION
        Return example :
            folderId       : 51
            created        : 2018-05-18T13:57:12+02:00
            updated        : 2018-05-18T13:57:12+02:00
            userId         : 33
            userLogin      : Foo Bar
            userEmail      : foo@bar.com
            userAvatarUrl  : /avatar/2d7ce6802371724bcece7bc384e214c8
            teamId         : 0
            teamEmail      :
            teamAvatarUrl  :
            team           :
            permission     : 1
            permissionName : View
            uid            : YCgjhs8Mik
            title          : MyFolder
            slug           : MyFolder
            isFolder       : True
            url            : /dashboards/f/YCgjhs8Mik/MyFolder
            inherited      : False
        
        Return nothing if the rights are by default (admin access for Admin)
    .EXAMPLE
        Get folder permissions of "foobar" folder :
            Get-GrafanaFolderPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                           -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Folder name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $folderUid = (Get-GrafanaFolder -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $name).uid 
    $resource = "/api/folders/$folderUid/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $permissions = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ContentType 'application/json;charset=utf-8'

    return $permissions

}

function New-GrafanaFolderPermissions{
    <#
    .SYNOPSIS
        Function to add a new permission to a folder.
        If userId and teamId parameter is missing the permission is
        allowed for all user with the role define in "role" parameter
    .DESCRIPTION
        Return example :          
            message
            -------
            Folder permissions updated
    .EXAMPLE
        Add viewer role to user with uid 11 :
            New-GrafanaFolderPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                          -userId 11 -folderUid YCgsg8Mik -role Viewer
        
        Add editor role for user with editor role on the organisation :
            New-GrafanaFolderPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                           -folderUid YCgsg8Mik -role Editor
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER userLogin
        Login of user to add in ACL        
    .PARAMETER folderName
        Name of the folder to modify    
    .PARAMETER userId
        User id (not uid !) from Grafana database
    .PARAMETER teamId
        Team id from Grafana database
    .PARAMETER role
        Role for the user into the organisation
            Viewer : read access            (id 1)
            Editor : Read / write access    (id 2)
            Admin : administrator access    (id 4)
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$userLogin,
        [Parameter(Mandatory=$false)]
        [string]$folderName,        
        [Parameter(Mandatory=$false)]
        [int]$userId,
        [Parameter(Mandatory=$false)]
        [int]$teamId,    
        [Parameter(Mandatory=$true)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$role      
    )

    $permissionMapping = @{
        Viewer = 1
        Editor = 2
        Admin  = 4
    }
    
    $folderUid = (Get-GrafanaFolder -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $folderName).uid

    if ( $userId -eq 0 ){
        $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                    -url $url -login $userLogin).id
    }

    $url = Set-Grafana-Url -url $url
    # Collect current permissions to rebuilt it with the new entry
    $currentPermissions = Get-GrafanaFolderPermissions -url $url -name $folderName `
                                    -authLogin $authLogin -authPassword $authPassword -authToken $authToken
    
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $rebuildedPermissions = @()
    # Build query body with the current permissions
    foreach ($permission in $currentPermissions) {
        $tmpAcl = @{}
        if ( ( $permission.userId -eq 0 ) -and ( $permission.teamId -eq 0 ) ){
            $tmpAcl.add('role', $permission.role)
        }else{
            $tmpAcl.add('userId',$permission.userId)
            $tmpAcl.add('teamId',$permission.teamId)
        }
        $tmpAcl.add('permission',$permission.permission)
        $rebuildedPermissions += $tmpAcl
    }

    # Add new permissions to the body
    $newPermission = @{}
    if ( ( $userId -eq 0 ) -and ( $teamId -eq 0 ) ){    # If addition is for 'system' group
        $newPermission.add('role',$role)
    }elseif ( $teamId -ne 0 ) {                         # If addition is for a team
        $newPermission.add('teamId',$teamId)
    }else{                                              # If addition is for user
        $newPermission.add('userId',$userId)
    }
    $newPermission.add('permission',$permissionMapping["$role"])

    $rebuildedPermissions += $newPermission
    $body = @{items = $rebuildedPermissions}
    
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/folders/$folderUid/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
        Invoke-RestMethod -Uri $url -Headers $headers -Method POST -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody
    }catch{
        Write-Error "Unable to modify folder permissions : $_"
    }
}

function Remove-GrafanaFolderPermissions{
    <#
    .SYNOPSIS
        Function to remove a permission from a folder.
        If userId and teamId parameter is missing the permission is
        removed for all user with the role define in "role" parameter
    .DESCRIPTION
        Return example :          
            message
            -------
            Dashboard permissions updated
    .EXAMPLE
        Remove-GrafanaFolderPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                          -userId 11 -folderUid YCgsg8Mik
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER userLogin
        Login of user to remove from ACL
    .PARAMETER userId
        User id (not uid !) from Grafana database
    .PARAMETER teamId
        Team id from Grafana database
    .PARAMETER folderName
        Name of the folder to modify
    .PARAMETER role
        Role for the user into the organisation
            Viewer : read access            (id 1)
            Editor : Read / write access    (id 2)
            Admin : administrator access    (id 4)
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$userLogin,
        [Parameter(Mandatory=$false)]
        [string]$folderName,                
        [Parameter(Mandatory=$false)]
        [int]$userId,
        [Parameter(Mandatory=$false)]
        [int]$teamId,       
        [Parameter(Mandatory=$false)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$role      
    )

    $url = Set-Grafana-Url -url $url
    $folderUid = (Get-GrafanaFolder -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $folderName).uid

    if ( $userLogin -notmatch "^$" ){
        $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                    -url $url -login $userLogin).id
    }

    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    # Collect current permissions to rebuilt it without the entry
    $currentPermissions = Get-GrafanaFolderPermissions -url $url -name $folderName `
                                                         -authLogin $authLogin `
                                                         -authPassword $authPassword `
                                                         -authToken $authToken | Out-Null
    $rebuildedPermissions = @()
    # Build query body with the current permissions
    # Not very sexy but most readable
    foreach ($permission in $currentPermissions) {
        $tmpAcl = @{}
        # Don't add sys role in the rebuilded ACL if role parameter is alone
        if ( ( $permission.userId -eq 0 ) -and ( $permission.teamId -eq 0 ) ){
            if ( $permission.role -imatch "^$role$" ){
                continue
            }else{
                $tmpAcl.add('role', $permission.role)
            }
        # Don't add user in the rebuilded ACL if current ID match parameter and ACE is for user
        # Presence of userLogin indicate that the entry is for a user
        }elseif( ($permission.userId -eq $userId ) -and ( $permission.userLogin -ne "" ) ){
            continue
        # Don't add team in the rebuilded ACL if current ID match parameter and ACE is not for user
        }elseif( ( $permission.teamId -eq $teamId ) -and ( $permission.userLogin -eq "" ) ) {
            continue
        }
        else{
            $tmpAcl.add('userId',$permission.userId)
            $tmpAcl.add('teamId',$permission.teamId)
        }
        $tmpAcl.add('permission',$permission.permission)
        $rebuildedPermissions += $tmpAcl
    }

    $body = @{items = $rebuildedPermissions}
    
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/folders/$folderUid/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
            Invoke-RestMethod -Uri $url -Headers $headers -Method POST `
                              -ContentType 'application/json;charset=utf-8' -Body $jsonBody
                        
    }catch{
        Write-Error "Unable to modify folder permissions : $_"
    }
}

function Get-GrafanaDashboardPermissions{
    <#
    .SYNOPSIS
        Function to list all permissions of a dashboard
    .DESCRIPTION
        Return example :
            dashboardId    : 150
            created        : 2018-09-20T15:24:06+02:00
            updated        : 2018-09-20T15:24:06+02:00
            userId         : 75
            userLogin      : Foo Bar
            userEmail      : foobar@nomail.com
            userAvatarUrl  : /avatar/f1607519abb581cbc9029d02cfc0d0da
            teamId         : 0
            teamEmail      :
            teamAvatarUrl  :
            team           :
            permission     : 1
            permissionName : View
            uid            : aqzsdefr
            title          : dashboard_name
            slug           : dashboard_name
            isFolder       : False
            url            : /d/aqzsdefr/dashboard_name
            inherited      : True

            dashboardId    : 151
            created        : 2018-10-02T09:49:24+02:00
            updated        : 2018-10-02T09:49:24+02:00
            userId         : 77
            userLogin      : Matth Gyver
            userEmail      : matth.gyver@nomail.com
            userAvatarUrl  : /avatar/362f7c0b744a025513a3c4ae5b6cf8a3
            teamId         : 0
            teamEmail      :
            teamAvatarUrl  :
            team           :
            permission     : 1
            permissionName : View
            uid            : aqzsdefr
            title          : dashboard_name
            slug           : dashboard_name
            isFolder       : False
            url            : /d/aqzsdefr/dashboard_name
            inherited      : False
    .EXAMPLE
        Get dashboard permissions of "foobar" folder :
            Get-GrafanaDashboardPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                           -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER dashboardName
        Dashboard name
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$dashboardName
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $dashboardId = (Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $dashboardName).id 
    $resource = "/api/dashboards/id/$dashboardId/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $permissions = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ContentType 'application/json;charset=utf-8'

    return $permissions

}
#TODO:
function New-GrafanaDashboardPermissions{
    <#
    .SYNOPSIS
        Function to add a new permission to a dashboard.
        If userId and teamId parameter is missing the permission is
        allowed for all user with the role define in "role" parameter
    .DESCRIPTION
        Return example :          
            message
            -------
            Folder permissions updated
    .EXAMPLE
        Add viewer role to user with uid 11 :
            New-GrafanaDashboardPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                          -userId 11 -folderUid YCgsg8Mik -role Viewer
        
        Add editor role for user with editor role on the organisation :
            New-GrafanaDashboardPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                           -folderUid YCgsg8Mik -role Editor
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER userLogin
        Login of user to add in ACL        
    .PARAMETER dashboardName
        Name of the folder to modify    
    .PARAMETER userId
        User id (not uid !) from Grafana database
    .PARAMETER teamId
        Team id from Grafana database
    .PARAMETER role
        Role for the user into the organisation
            Viewer : read access            (id 1)
            Editor : Read / write access    (id 2)
            Admin : administrator access    (id 4)
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$userLogin,
        [Parameter(Mandatory=$false)]
        [string]$dashboardName,        
        [Parameter(Mandatory=$false)]
        [int]$userId,
        [Parameter(Mandatory=$false)]
        [int]$teamId,    
        [Parameter(Mandatory=$true)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$role      
    )

    $permissionMapping = @{
        Viewer = 1
        Editor = 2
        Admin  = 4
    }
    
    $dashboardId = (Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $dashboardName).id

    if ( $userId -eq 0 ){
        $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                    -url $url -login $userLogin).id
    }

    $url = Set-Grafana-Url -url $url
    # Collect current permissions to rebuilt it with the new entry
    $currentPermissions = Get-GrafanaDashboardPermissions -url $url -dashboardName $dashboardName `
                                    -authLogin $authLogin -authPassword $authPassword -authToken $authToken
    
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $rebuildedPermissions = @()
    # # Build query body with the current permissions
    foreach ($permission in $currentPermissions) {
        if ($permission.inherited -eq $true){ continue }
        $tmpAcl = @{}
        if ( ( $permission.userId -eq 0 ) -and ( $permission.teamId -eq 0 ) ){
            $tmpAcl.add('role', $permission.role)
        }else{
            $tmpAcl.add('userId',$permission.userId)
            $tmpAcl.add('teamId',$permission.teamId)
        }
        $tmpAcl.add('permission',$permission.permission)
        $rebuildedPermissions += $tmpAcl
    }

    # Add new permissions to the body
    $newPermission = @{}
    if ( ( $userId -eq 0 ) -and ( $teamId -eq 0 ) ){    # If addition is for 'system' group
        $newPermission.add('role',$role)
    }elseif ( $teamId -ne 0 ) {                         # If addition is for a team
        $newPermission.add('teamId',$teamId)
    }else{                                              # If addition is for user
        $newPermission.add('userId',$userId)
        $newPermission.add('teamId',0)
    }
    $newPermission.add('permission',$permissionMapping["$role"])

    $rebuildedPermissions += $newPermission
    $body = @{items = $rebuildedPermissions}
    
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/dashboards/id/$dashboardId/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
        Invoke-RestMethod -Uri $url -Headers $headers -Method POST -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody
    }catch{
        Write-Error "Unable to modify dashboard permissions : $_"
    }
}

function Remove-GrafanaDashboardPermissions{
    <#
    .SYNOPSIS
        Function to remove a dashboard permission.
        If userId and teamId parameter is missing the permission is
        removed for all user with the role define in "role" parameter
    .DESCRIPTION
        Return example :          
            message
            -------
            Folder permissions updated
    .EXAMPLE
        Remove-GrafanaFolderPermissions -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" `
                                          -userId 11 -folderUid YCgsg8Mik
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER userLogin
        Login of user to remove from ACL
    .PARAMETER userId
        User id (not uid !) from Grafana database
    .PARAMETER teamId
        Team id from Grafana database
    .PARAMETER dashboardName
        Name of the dashboard to modify
    .PARAMETER role
        Role for the user into the organisation
            Viewer : read access            (id 1)
            Editor : Read / write access    (id 2)
            Admin : administrator access    (id 4)
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$userLogin,
        [Parameter(Mandatory=$false)]
        [string]$dashboardName,                
        [Parameter(Mandatory=$false)]
        [int]$userId,
        [Parameter(Mandatory=$false)]
        [int]$teamId,       
        [Parameter(Mandatory=$false)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$role      
    )

    $url = Set-Grafana-Url -url $url
    $dashboardId = (Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                     -authToken $authToken -url $url -name $dashboardName).id

    if ( $userId -eq 0 ){
        $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                    -url $url -login $userLogin).id
    }

    $url = Set-Grafana-Url -url $url
    # Collect current permissions to rebuilt it with the new entry
    $currentPermissions = Get-GrafanaDashboardPermissions -url $url -dashboardName $dashboardName `
                                    -authLogin $authLogin -authPassword $authPassword -authToken $authToken
    
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $rebuildedPermissions = @()
    # Build query body with the current permissions
    # Not very sexy but most readable
    foreach ($permission in $currentPermissions) {
        if ($permission.inherited -eq $true){ continue }
        $tmpAcl = @{}
        # Don't add sys role in the rebuilded ACL if role parameter is alone
        if ( ( $permission.userId -eq 0 ) -and ( $permission.teamId -eq 0 ) ){
            if ( $permission.role -imatch "^$role$" ){
                continue
            }else{
                $tmpAcl.add('role', $permission.role)
            }
        # Don't add user in the rebuilded ACL if current ID match parameter and ACE is for user
        # Presence of userLogin indicate that the entry is for a user
        }elseif( ($permission.userId -eq $userId ) -and ( $permission.userLogin -ne "" ) ){
            continue
        # Don't add team in the rebuilded ACL if current ID match parameter and ACE is not for user
        }elseif( ( $permission.teamId -eq $teamId ) -and ( $permission.userLogin -eq "" ) ) {
            continue
        }
        else{
            $tmpAcl.add('userId',$permission.userId)
            $tmpAcl.add('teamId',$permission.teamId)
        }
        $tmpAcl.add('permission',$permission.permission)
        $rebuildedPermissions += $tmpAcl
    }

    $body = @{items = $rebuildedPermissions}
    
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/dashboards/id/$dashboardId/permissions"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
            Invoke-RestMethod -Uri $url -Headers $headers -Method POST `
                              -ContentType 'application/json;charset=utf-8' -Body $jsonBody
                        
    }catch{
        Write-Error "Unable to modify folder permissions : $_"
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Teams functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function New-GrafanaTeam{
    <#
    .SYNOPSIS
        Function to create a new Grafana team
    .DESCRIPTION
        Return example :
            message      teamId
            -------      ------
            Team created      2
    .EXAMPLE
        New-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -teamName foobar `
                          -mail foo@bar.com
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the new team
    .PARAMETER email
        Mail address of the team
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$teamName,
        [Parameter(Mandatory=$false)]
        [string]$email
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $resource = "/api/teams"
    $url += "$resource"

    $body = @{
        name = $teamName
        email = $email
    }

    $jsonBody = $body | ConvertTo-Json -Compress

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType 'application/json;charset=utf-8' `
                        -Body $jsonBody

}

function Get-GrafanaTeam{
    <#
    .SYNOPSIS
        Function to search Grafana teams.
    .DESCRIPTION
        Return object collection : 
            id          : 1
            orgId       : 7
            name        : foo
            email       :
            avatarUrl   : /avatar/9e4207561a5e141f1338f39ef9484972
            memberCount : 1

            id          : 2
            orgId       : 7
            name        : bar
            email       : foo@bar.com
            avatarUrl   : /avatar/f3ada405ce890b6f8204094deb12d8a8
            memberCount : 0
    .EXAMPLE
        Search team named foobar :
            Get-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -teamName foobar
        
        List all teams
            Get-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication            
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the team to search
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$teamName
    )

    $teamName = $teamName -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $resource = "/api/teams/search"
    $url += $resource
    if ( $teamName -imatch ".*"){
        $param = "?name=$teamName"
    }
    $url += $param

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $teamResult = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ContentType 'application/json;charset=utf-8'
   
    return $teamResult.teams
}

function Remove-GrafanaTeam{
    <#
    .SYNOPSIS
        Function to remove grafana team
    .DESCRIPTION
        Return example :
            message
            -------
            Team deleted
    .EXAMPLE
        Remove team named "foobar":
            Remove-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -teamName foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the team to remove
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$teamName       
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $teamId = (Get-GrafanaTeam -authLogin $authLogin -authPassword $authPassword `
                                -authToken $authToken -url $url -teamName $teamName).id

    $resource = "/api/teams/$teamId"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Delete -ContentType 'application/json;charset=utf-8'
}

function Get-GrafanaTeamMembers{
    <#
    .SYNOPSIS
        Function to list all member of Grafana teams.
    .DESCRIPTION
        Return object collection : 
            orgId     : 1
            teamId    : 3
            userId    : 33
            email     : foo@noreply.com
            login     : foo
            avatarUrl : /avatar/2d7ce6802371724bcece7bc384e214c8

            orgId     : 1
            teamId    : 3
            userId    : 35
            email     : bar@noreply.com
            login     : bar
            avatarUrl : /avatar/d8c81a539617665ce32c643b9fa67fc7
    .EXAMPLE
        Search team named foobar :
            Get-GrafanaTeamMembers -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -teamName foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication            
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the team to get the members
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$teamName
    )

    $teamName = $teamName -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken
    
    $teamId = (Get-GrafanaTeam -authLogin $authLogin -authPassword $authPassword `
                                -url $url -teamName $teamName).id
    
    $resource = "/api/teams/$teamId/members"
    $url += $resource

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $teamMembers = Invoke-RestMethod -Uri $url -Headers $headers -Method Get -ContentType 'application/json;charset=utf-8'
   
    return $teamMembers
}

function Set-GrafanaTeam{
    <#
    .SYNOPSIS
        Function to modify some team propertys
    .DESCRIPTION
        Return example :
            message
            -------
            Team updated
    .EXAMPLE
        Rename "team1" to "foobar":
            Set-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" 
                                -teamName team1 -newTeamName foobar
        
        Modify team mail address:
            Set-GrafanaTeam -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" 
                                -teamName team1 -newMailAddr foobar@foo.com
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the team to modify
    .PARAMETER newTeamName
        New name of the team
    .PARAMETER newMailAddr
        New mail address assigned to the team
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$teamName,
        [Parameter(Mandatory=$false)]
        [string]$newTeamName,
        [Parameter(Mandatory=$false)]
        [string]$newMailAddr
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    $teamId = (Get-GrafanaTeam -authLogin $authLogin -authPassword $authPassword `
                                -authToken $authToken -url $url -teamName $teamName).id

    $resource = "/api/teams/$teamId"
    $url += "$resource"
    
    $body = @{}
    if ( $newTeamName -notmatch "^$" ){ $body.Add('name',$newTeamName) }
    if ( $newMailAddr -notmatch "^$" ){ $body.Add('email',$newMailAddr) }

    $jsonBody = $body | ConvertTo-Json -Compress
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Put -ContentType 'application/json;charset=utf-8' `
                      -Body $jsonBody
}
# ----------------------------------------------------------------------------------
#       Functions with plain text authentication only
# ----------------------------------------------------------------------------------
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Users functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Set-GrafanaContext{
    <#
    .SYNOPSIS
        Function to set current user context in organisation
    .DESCRIPTION
        To manage some organisation objects like folders, permissions ... you must
        move to a "context" with this commandlet.
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
        http://docs.grafana.org/http_api/user/
        
        Return example :
            Current user switched to 'foobar' organisation
    .EXAMPLE
        Set-GrafanaContext -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                            -orgName "foo bar org."
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER orgName
        Name of the Grafana organisation to switch
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName
    )

    $orgName = $orgName -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin authLogin -authPassword authPassword

    $orgId = (Get-GrafanaOrganisation -authLogin authLogin -authPassword authPassword `
                                        -orgName $orgName).id

    $resource = "/api/user/using/$orgId"
    $url += "$resource/$param"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
        Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json;charset=utf-8' -Headers $headers | Out-null
        Write-Host "Curent user switched to '$orgName' organisation"
    }catch{
        Write-Error "Unable to switch context : $_"
    }
}
function Get-GrafanaUser{
    <#
    .SYNOPSIS
        Function to get user informations from login
    .DESCRIPTION
        For user interactions, Grafana need user / password authentication (API token is'nt enough)
        http://docs.grafana.org/http_api/user/

        id             : 28
        email          : foo.bar@barfoo.com
        name           : Foo Bar
        login          : Foo Bar
        theme          :
        orgId          : 3
        isGrafanaAdmin : False
    .EXAMPLE
        Get-GrafanaUser -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -login foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER login
        Login to search
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$login
    )

    $login = $login -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $resource = "/api/users"
    $param = "lookup?loginOrEmail=$login"
    $url += "$resource/$param"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $userInfos = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json;charset=utf-8' -Headers $headers

    return $userInfos
}

function Get-GrafanaUserOrgs{
    <#
    .SYNOPSIS
    Function to get organisations of a user
    .DESCRIPTION
        For user interactions, Grafana need user / password authentication (API token is'nt enough)
         http://docs.grafana.org/http_api/user/
        Return example :
            orgId name                          role
            ----- ----                          ----
                1 Main Org.                     Admin
                2 Foo Org.                      Admin
                3 Bar Org.                      Admin
    .EXAMPLE
        Get-GrafanaUserOrgs -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -userID 35
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER userID
        # TODO: replace userId with login
        User ID from Grafana database
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,        
        [Parameter(Mandatory=$true)]
        [string]$userID
    )

    $login = $login -replace " ","%20"

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $resource = "/api/users/$userID/orgs"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $orgsOfUser = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json;charset=utf-8' -Headers $headers

    return $orgsOfUser
}

function New-GrafanaUser{
    <#
    .SYNOPSIS
    Function to create a new local user
    .DESCRIPTION
        For user interactions, Grafana need user / password authentication (API token is'nt enough)
         http://docs.grafana.org/http_api/user/
        Return example :
            id message
            -- -------
            31 User created
    .EXAMPLE
        New-GrafanaUser -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                        -name "Foo Bar" -email "foo@bar.com" -login "foobar" -password "********"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Common name of the new user
    .PARAMETER email
        Mail address of the new user
    .PARAMETER login
        Login of the new user
    .PARAMETER password
        Password of the new user
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$email,
        [Parameter(Mandatory=$true)]
        [string]$login,
        [Parameter(Mandatory=$true)]
        [string]$password
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $body = @{
        name = $name
        login = $login
        password = $password
    }

    if ( $email -notmatch "^$" ){
        $body.add("email",$email)
    }

    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/admin/users"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json;charset=utf-8' -Headers $headers `
                        -Body $jsonBody
}

function Remove-GrafanaUser{
    <#
    .SYNOPSIS
    Function to remove Grafana user
    .DESCRIPTION
        For user interactions, Grafana need user / password authentication (API token is'nt enough)
         http://docs.grafana.org/http_api/user/
        Return example :
            message
            -------
            User deleted
    .EXAMPLE
        Remove-GrafanaUser -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                            -login foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER login
        User login to remove
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$login
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $userID = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                -url $url -login $login).id
       
    $resource = "/api/admin/users/$userID"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Delete -ContentType 'application/json;charset=utf-8' -Headers $headers
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Organisations functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Get-GrafanaOrganisation{
    <#
    .SYNOPSIS
        Function to list all Grafana organisations or full details of one organisation.
    .DESCRIPTION
        By default, all organisation are returned.
        Specify name or uid to get all informations about a specific organisation.

        For this interactions, Grafana need user / password authentication (API token is'nt enough)
            http://docs.grafana.org/http_api/org/
        
        Return all organisation example :
            id name
            -- ----
            1  Main Org
            2  FooBar
        
        Return specific organisation example :
            id name                 address
            -- ----                 -------
            2 foobar @{address1=; address2=; city=; zipCode=; state=; country=}
        
    .EXAMPLE
        List all organisations
            Get-GrafanaOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd
        
        Get informations of organisation named "foobar"
            Get-GrafanaOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -name foobar
        
        Get informations of organisation with uid 11
            Get-GrafanaOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -id 11
    .PARAMETER url
        Grafana root URL
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER orgName
        Name of the Grafana organisation
    .PARAMETER id
        Id of the Grafana organisation
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$orgName,
        [Parameter(Mandatory=$false)]
        [int]$id
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $resource = "/api/orgs"

    if ( $orgName -notmatch "^$" ){
        $orgName = $orgName -replace " ", "%20"
        $resource += "/name/$orgName"
    }elseif( $id -ne 0 ){
        $resource += "/$id"
    }

    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $orgResult = Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json;charset=utf-8' -Headers $headers
    
    return $orgResult
}

function Add-GrafanaUserInOrganisation{
    <#
    .SYNOPSIS
    Function to add user inside an organisation
    .DESCRIPTION
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
            http://docs.grafana.org/http_api/org/
        Return example :
            message
            -------
            User added to organization
    .EXAMPLE
        Adding "foobar" user with "viewer" role to organisation named myCorp :
            Add-GrafanaUserInOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                                             -orgName myCorp -login "foobar" -role Viewer
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER orgName
        Name of the Grafana organisation
    .PARAMETER login
        Login of user to add into organisation
    .PARAMETER role
        Role for the user into the organisation
            Viewer : read access
            Editor : Read / write access
            Admin : administrator access
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName,
        [Parameter(Mandatory=$true)]
        [string]$login,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$role        
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $orgId = (Get-GrafanaOrganisation -authLogin $authLogin -authPassword $authPassword `
                                       -url $url -orgName $orgName).id

    $body = @{
        loginOrEmail = $login
        role = $role
    }

    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/orgs/$orgId/users"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json;charset=utf-8' -Headers $headers `
                        -Body $jsonBody
}

function Remove-GrafanaUserFromOrganisation{
    <#
    .SYNOPSIS
    Function to remove user from an organisation.
    .DESCRIPTION
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
            http://docs.grafana.org/http_api/org/
        Return example :
            message
            -------
            User removed from organization
    .EXAMPLE
        Remove user with login "foobar" from organisation named myCorp :
            Remove-GrafanaUserFromOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                                             -orgName myCorp -login "foobar"
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER orgName
        Name of the Grafana organisation
    .PARAMETER login
        Login of user to remove organisation
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName,
        [Parameter(Mandatory=$true)]
        [string]$login       
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $orgId = (Get-GrafanaOrganisation -authLogin $authLogin -authPassword $authPassword `
                                       -url $url -orgName $orgName).id

    $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                -url $url -login $login).id

    $resource = "/api/orgs/$orgId/users/$userId"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Delete -ContentType 'application/json;charset=utf-8' -Headers $headers
}

function Set-GrafanaUserRoleInOrganisation{
    <#
    .SYNOPSIS
        Function to modify user role on a Grafana organisation.
    .DESCRIPTION
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
            http://docs.grafana.org/http_api/org/
        Return example :
            message
            -------
            Organization user updated
    .EXAMPLE
        Adding "foobar" user with "viewer" role to organisation named myCorp :
            Set-GrafanaUserRoleInOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                                                  -orgName myCorp -login "foobar" -newRole Viewer
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER orgName
        Name of the Grafana organisation
    .PARAMETER login
        Login of user to edit
    .PARAMETER newRole
        Role for the user into the organisation
            Viewer : read access
            Editor : Read / write access
            Admin : administrator access
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName,
        [Parameter(Mandatory=$true)]
        [string]$login,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Viewer","Editor","Admin")]
        [string]$newRole        
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $orgId = (Get-GrafanaOrganisation -authLogin $authLogin -authPassword $authPassword `
                                       -url $url -orgName $orgName).id

    $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                       -url $url -login $login).id
                                       
    $body = @{ role = $newRole }

    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/orgs/$orgId/users/$userId"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Patch -ContentType 'application/json;charset=utf-8' -Headers $headers `
                        -Body $jsonBody
}
function Get-GrafanaOrganisationUsers{
    <#
    .SYNOPSIS
    Function to get all users of an organisation
    .DESCRIPTION
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
            http://docs.grafana.org/http_api/org/#get-users-in-organisation
        Return example :
            orgId         : 7
            userId        : 10
            email         : foo@bar.com
            avatarUrl     : /avatar/94f38d9b3027c1edbdb802a9eac3bdf7
            login         : foo
            role          : Viewer
            lastSeenAt    : 2018-05-18T14:31:28+02:00
            lastSeenAtAge : 6d

            orgId         : 7
            userId        : 1
            email         : admin@localhost
            avatarUrl     : /avatar/46d229b033af06a191ff2267bca9ae56
            login         : admin
            role          : Admin
            lastSeenAt    : 2018-05-24T18:45:45+02:00
            lastSeenAtAge : 1m
    .EXAMPLE
        Get-GrafanaOrganisationUsers -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                                       -name foobar
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER orgName
        Organisation name
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName       
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword
    
    $orgId = (Get-GrafanaOrganisation -authLogin $authLogin -authPassword $authPassword `
                                        -url $url -orgName $orgName).id

    $resource = "/api/orgs/$orgId/users"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json;charset=utf-8' -Headers $headers 
}

function New-GrafanaOrganisation{
    <#
    .SYNOPSIS
        Function to create a new Grafana organisation.
    .DESCRIPTION
        For this interactions, Grafana need user / password authentication (API token is'nt enough)
        http://docs.grafana.org/http_api/org/#create-organisation

        Return example :
            message              orgId
            -------              -----
            Organization created     8
        
    .EXAMPLE
        Create organisation named foobar
            New-GrafanaOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd -orgName foobar
    .PARAMETER url
        Grafana root URL
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER orgName
        Name of the Grafana organisation
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $body = @{ name = $orgName }
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/orgs"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Post -ContentType 'application/json;charset=utf-8' -Headers $headers `
                        -Body $jsonBody
    
}

function Set-GrafanaOrganisation{
    <#
    .SYNOPSIS
        Function to modify propertys of a Grafana organisation.
    .DESCRIPTION
        Actually, only name field could be modified by the API     
        (Address 1, Address 2, City are not implemented yet)

        For this interactions, Grafana need user / password authentication (API token is'nt enough)
        http://docs.grafana.org/http_api/org
        Return example :
            message              orgId
            -------              -----
            Organization created     8
        
    .EXAMPLE
        Rename organisation named foobar to barfoo
            Set-GrafanaOrganisation -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd ` 
                                     -orgName foobar -newOrgName barfoo
    .PARAMETER url
        Grafana root URL
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER orgName
        Name of the Grafana organisation
    .PARAMETER newOrgName
        New name of the organisation
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$orgName,
        [Parameter(Mandatory=$false)]
        [string]$newOrgName        
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $orgId = ( Get-GrafanaOrganisation -authLogin $authLogin -authPassword $authPassword `
                                        -url $url -orgName $orgName ).id

    $body = @{}
    if ( $orgName -notmatch "^$" ){ $body.Add('name',$newOrgName) }
    $jsonBody = $body | ConvertTo-Json -Compress

    $resource = "/api/orgs/$orgId"
    $url += "$resource"

    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Method Put -ContentType 'application/json;charset=utf-8' -Headers $headers `
                        -Body $jsonBody
    
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   Teams functions
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function Add-GrafanaTeamMember{
    <#
    .SYNOPSIS
        Function to add user to a Grafana team
    .DESCRIPTION
        Return example :
            message
            -------
            Member added to Team
    .EXAMPLE
        Add johndoe to foobar team :
            Add-GrafanaTeamMember -url "https://foobar.fr" -authLogin admin -authPassword Passw0rd `
                                    -teamName foobar -memberLogin johndoe
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER url
        Grafana root URL
    .PARAMETER teamName
        Name of the Grafana team to populate
    .PARAMETER memberLogin
        User login to add in the group
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$true)]
        [string]$teamName,
        [Parameter(Mandatory=$true)]
        [string]$memberLogin
    )
 
    $url = Set-Grafana-Url -url $url

    $teamId = (Get-GrafanaTeam -authLogin $authLogin -authPassword $authPassword `
                                -url $url -teamName $teamName).id

    $userId = (Get-GrafanaUser -authLogin $authLogin -authPassword $authPassword `
                                -url $url -login $memberLogin).id

    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword

    $resource = "/api/teams/$teamId/members"
    $url += "$resource"
    
    $body = @{
        userId = $userId
    }

    $jsonBody = $body | ConvertTo-Json -Compress
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Invoke-RestMethod -Uri $url -Headers $headers -Method Post -ContentType 'application/json;charset=utf-8' `
                      -Body $jsonBody

}

# ----------------------------------------------------------------------------------
#       Private functions
# ----------------------------------------------------------------------------------

function Convert-PScred-To-Base64{
    <#
    .SYNOPSIS
        Function to decode PS credential and format to
         base 64
    .EXAMPLE
        Convert-PScred-To-Base64 -credentialObject myObj
    .PARAMETER credentialObject
        Credential object to convert
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object]$credentialObject
    )
    
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($credentialObject.Password);
    $password = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);        
    $key = [string]::Format("{0}:{1}", $credentialObject.UserName, $password)
    $base64AuthInfo = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($key))

    return $base64AuthInfo
}

function Convert-PlainTextCred-To-Base64{
    <#
    .SYNOPSIS
        Function for converting plain text authentication
         informations to base 64
    .EXAMPLE
        Convert-PlainTextCred-To-Base64 -login foo -password bar
    .PARAMETER login
        Login of plain text authentication string
    .PARAMETER password
        Password of plain text authentication string
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string]$login,
        [Parameter(Mandatory=$true)]
        [string]$password
    )
    
    return [Convert]::ToBase64String( [Text.Encoding]::ASCII.GetBytes(`
                            ( "{0}:{1}" -f $login,$password) ) )
}

function Set-Grafana-Credentials{
    <#
    .SYNOPSIS
        Simple function to ask user credential or/and convert
         existing credential to base64
    .EXAMPLE
        Set-Grafana-Credentials -login foo -password bar
    .PARAMETER login
        Login used for Grafana authentication
    .PARAMETER password
        Password used for Grafana authentication
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$login,
        [Parameter(Mandatory=$false)]
        [string]$password
    )

    if ( $Global:grafanaCredentials -eq $null ){
        if ( $login -imatch "^$" -and $password -imatch "^$" ){
            $credentials = Get-Credential
            $base64AuthInfo = Convert-PScred-To-Base64 -credentialObject $credentials
        }else{
            $base64AuthInfo = Convert-PlainTextCred-To-Base64 -login $login -password $password
        }
    }else{
        $base64AuthInfo = $Global:grafanaCredentials
    }

    return $base64AuthInfo
}

function Set-Grafana-Token{
    <#
    .SYNOPSIS
        Simple function to ask user token if needed
    .EXAMPLE
        Set-Grafana-Token -token 
    .PARAMETER authToken
        Token of Grafana organisation
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authToken
    )

    if ( ( $authToken -eq $null ) -or ( $authToken -imatch "^$" ) ){
        if ( $Global:grafanaToken -eq $null ){
            $authToken = Read-Host -Prompt 'Token '
        }else{
            $authToken = $Global:grafanaToken
        }
    }

    return $authToken
}

function Set-Grafana-Url{
    <#
    .SYNOPSIS
        Simple function to ask Grafana URL if needed
    .EXAMPLE
        Set-Grafana-Url -url 
    .PARAMETER url
        Root URL of Grafana
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$url
    )

    if ( ( $url -eq $null ) -or ( $url -imatch "^$" ) ){
        if ( $Global:grafanaURL -eq $null ){
            $url = Read-Host -Prompt 'Grafana URL '
        }else{
            $url = $Global:grafanaURL
        }
    }

    return $url
}

function Ask-Grafana-Auth-Methode{
    <#
    .SYNOPSIS
        Simple function to ask authentication method to the user
    #>
    Write-Host "Choose authentication :"
    Write-Host "  1 - Login / Password"
    Write-Host "  2 - API Token"
    $authUserChoice = Read-Host -Prompt 'Your choice [1/2] '

    if ( ( $authUserChoice -ne "1" ) -and ( $authUserChoice -ne "2" ) ){
        $authUserChoice = Ask-Grafana-Auth-Methode
    }

    return $authUserChoice
}

function Set-Grafana-Auth-Header{
    <#
    .SYNOPSIS
        Function to build http headers in function of authentication type.
    .DESCRIPTION
        Commandlet will ask you token or credential if it not passed in parameter
    .EXAMPLE
        Login / password authentication :
            Set-Grafana-Auth-Header -authLogin foobar -authPassword myPassword
        Token :
            Set-Grafana-Auth-Header -authToken a1z2e3r4t5y6u7i8o9
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER authToken
        API token of Grafana organisation
    #>

    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$authToken
    )

    if ( ( $Global:headers -eq $null ) -or ( $Global:headers -imatch "^$") ){
        if ( ( $authPassword -imatch "^$" ) -and ( $authToken -imatch "^$" ) ){
            $authUserChoice = Ask-Grafana-Auth-Methode
        }

        if ( ( $authUserChoice -eq 1 ) -or ( $authPassword -imatch ".+" ) ){
            $base64AuthInfo = Set-Grafana-Credentials -login $authLogin -password $authPassword
            $headers=@{ 
                Accept = 'application/json'
                Authorization = ("Basic {0}" -f $base64AuthInfo)
            }
        }else{
            $token = Set-Grafana-Token -authToken $authToken
            $headers=@{
                Accept = 'application/json'
                Authorization = "Bearer $token"
            }
        }
    }

    return $headers
}

# Thank's to Adam Bertram for this function
#  https://4sysops.com/archives/convert-json-to-a-powershell-hash-table/
function ConvertTo-Hashtable {
    [CmdletBinding()]
    [OutputType('hashtable')]
    param (
        [Parameter(ValueFromPipeline)]
        $InputObject
    )
 
    process {
        ## Return null if the input is null. This can happen when calling the function
        ## recursively and a property is null
        if ($null -eq $InputObject) {
            return $null
        }
 
        ## Check if the input is an array or collection. If so, we also need to convert
        ## those types into hash tables as well. This function will convert all child
        ## objects into hash tables (if applicable)
        if ($InputObject -is [System.Collections.IEnumerable] -and $InputObject -isnot [string]) {
            $collection = @(
                foreach ($object in $InputObject) {
                    ConvertTo-Hashtable -InputObject $object
                }
            )
 
            ## Return the array but don't enumerate it because the object may be pretty complex
            Write-Output -NoEnumerate $collection
        } elseif ($InputObject -is [psobject]) { ## If the object has properties that need enumeration
            ## Convert it to its own hash table and return it
            $hash = @{}
            foreach ($property in $InputObject.PSObject.Properties) {
                $hash[$property.Name] = ConvertTo-Hashtable -InputObject $property.Value
            }
            $hash
        } else {
            ## If the object isn't an array, collection, or other object, it's already a hash table
            ## So just return it.
            $InputObject
        }
    }
}

function Get-GrafanaDashboard-Obj{
    <#
    .SYNOPSIS
        Function to get dashboard informations from name,uid or id
    .DESCRIPTION

    .EXAMPLE
        Get dashboard named "foobar" :
            Get-GrafanaDashboard-Obj -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -name foobar -version 3
        
        Get dashboard with uid "whxgUL4iz" :
            Get-GrafanaDashboard-Obj -token th1sIsTh3mag1calT0k3n0fTheDeaTh -url "https://foobar.fr" -uid whxgUL4iz
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER token
        API key of Grafana Organization
    .PARAMETER url
        Grafana root URL
    .PARAMETER name
        Dashboard name
    .PARAMETER uid
        Dashboard uid
    .PARAMETER id
        Dashboard id
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,        
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$false)]
        [string]$url,
        [Parameter(Mandatory=$false)]
        [string]$name,
        [Parameter(Mandatory=$false)]
        [string]$uid,
        [Parameter(Mandatory=$false)]
        [int]$id
    )

    $url = Set-Grafana-Url -url $url
    $headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                       -authToken $authToken

    if ( $name -notmatch "^$" ){
        $dashboard = Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                           -url $url -authToken $authToken -name $name
        if ( $dashboard.Count -gt 1 ){
            Write-Error "More of one dashboard named '$name' !"
            Write-Error "Please use uid to get content"
            exit 5
        }
    }elseif ( $uid -notmatch "^$"){
        $dashboard = Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                           -url $url -authToken $authToken -uid $uid
    }elseif ( $id -notmatch "^$"){
        $dashboard = Get-GrafanaDashboard -authLogin $authLogin -authPassword $authPassword `
                                             -url $url -authToken $authToken -id $id
    }else{
        Write-Error "You must specify a name or an uid !"
        exit 6
    }

    return $dashboard
}

function Replace-Grafana-Var-In-Tpl{
    <#
    .SYNOPSIS
        Function to replace from a file, all string between $$ (ex $$foobar$$)
         defined as hashtable key by the value
    .DESCRIPTION
        This function take 2 parameter : a file and a hastable.
        Exemple of hastable :
        $myVars = @{
                    "userFirstName" : "foo",
                    "userLastName" : bar
                }
        Into the file, $$userFirstName$$ will be replaced by "foo" and
         $$ userLastName by "bar"

    .PARAMETER fileContent
        Variable containing the content of the template
    
    .PARAMETER hashVars
        Hashtable containing variable name to replace as key and string
        to use as replacement
    #>
    param(
        [Parameter(Mandatory=$true)]
        $fileContent,
        [Parameter(Mandatory=$true)]
        $hashVars
    )
    
    $newFileContent = @()

    foreach ( $line in $fileContent ){
        # If the current line contain a custom variable
        if ( $line -imatch '.*\$\$.*\$\$.*' ){
            Foreach ( $key in $hashVars.keys ){
                $pattern = "\$\$" + $key + "\$\$"
                if ( $line -imatch $pattern ){
                    $newLine = $line -replace $pattern, $hashVars[$key]
                    $newFileContent += $newLine
                }
            }
        }else{
            $newFileContent += $line
        }
    }

    return $newFileContent
}
# ----------------------------------------------------------------------------------
#       Common functions
# ----------------------------------------------------------------------------------

function Connect-Grafana{
    <#
    .SYNOPSIS
        Function to store Grafana credentials to simplify
        multiples actions
    .DESCRIPTION
        Not realy a connection, just a HTTP header constructor from credential
         or API token
    .EXAMPLE
        Connexion with login / password :       
            Connect-Grafana -authLogin admin -authPassword Passw0rd
        Connexion with Grafana organisation API token
            Connect-Grafana -authToken a1z2e3r4t5y6u7i8o9
    .PARAMETER authLogin
        Login for Grafana authentication
    .PARAMETER authPassword
        Password for Grafana authentication
    .PARAMETER authToken
        API token of Grafana organisation        
    .PARAMETER url
        Grafana root URL
    #>
    param(
        [Parameter(Mandatory=$false)]
        [string]$authLogin,
        [Parameter(Mandatory=$false)]
        [string]$authPassword,
        [Parameter(Mandatory=$false)]
        [string]$authToken,
        [Parameter(Mandatory=$true)]
        [string]$url
    )

    if ( ( $authPassword -imatch ".+" ) -and ( $authToken -imatch ".+" ) ){
        Write-Error "You must choose between credentials and API token authentication !"
        exit 3
    }

    $Global:grafanaURL = Set-Grafana-Url -url $url
    $Global:headers = Set-Grafana-Auth-Header -authLogin $authLogin -authPassword $authPassword `
                                                -authToken $authToken   

    $resource = "/api/search"
    $param = "?type=dash-db&query="
    $url += "$resource/$param"

    # Test connection to validate credential
    # Force using TLS v1.2
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    try{
        Invoke-RestMethod -Uri $url -Method Get -ContentType 'application/json;charset=utf-8' -Headers $Global:headers | Out-null
        Write-Host "Connexion succesfull"
    }catch{
        Write-Error "Unable to connect : $_"
        Disconnect-Grafana
    }

}

function Disconnect-Grafana{
    <#
    .SYNOPSIS
        Function to clear Grafana credentials stored
    .DESCRIPTION

    .EXAMPLE
        Disconnect-Grafana
    #>
    param()

    $Global:headers = $null
    $Global:grafanaURL = $null

    Write-Host "Disconnexion successul"

}

Export-ModuleMember -Function Get-GrafanaDatasource, `
                              Get-GrafanaDashboard, `
                              Get-GrafanaDashboardVersion, `
                              Get-GrafanaDashboardContent, `
                              Move-GrafanaDashboard, `
                              New-GrafanaDashboard, `
                              Remove-GrafanaDashboard, `
                              Get-GrafanaFolderList, `
                              Get-GrafanaFolder, `
                              New-GrafanaFolder, `
                              Remove-GrafanaFolder, `
                              Set-GrafanaFolder, `
                              Get-GrafanaFolderPermissions, `
                              New-GrafanaFolderPermissions, `
                              Remove-GrafanaFolderPermissions, `
                              Get-GrafanaDashboardPermissions, `
                              New-GrafanaDashboardPermissions, `
                              Remove-GrafanaDashboardPermissions, `
                              New-GrafanaTeam, `
                              Get-GrafanaTeam, `
                              Remove-GrafanaTeam, `
                              Get-GrafanaTeamMembers, `
                              Set-GrafanaTeam, `
                              Set-GrafanaContext, `
                              Get-GrafanaUser, `
                              Get-GrafanaUserOrgs, `
                              New-GrafanaUser, `
                              Remove-GrafanaUser, `
                              Get-GrafanaOrganisation, `
                              Add-GrafanaUserInOrganisation, `
                              Remove-GrafanaUserFromOrganisation, `
                              Set-GrafanaUserRoleInOrganisation, `
                              Get-GrafanaOrganisationUsers, `
                              New-GrafanaOrganisation, `
                              Set-GrafanaOrganisation, `
                              Add-GrafanaTeamMember, `
                              Connect-Grafana, `
                              Disconnect-Grafana
