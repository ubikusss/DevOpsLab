Configuration InstallNETCoreAndRun
{
    Import-DscResource –ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost' 
    {
        
        # The first resource block ensures that the Web-Server (IIS) feature is enabled.
        #WindowsFeature WebServer {
        #    Ensure = "Present"
        #    Name   = "Web-Server"
        #}

        # The second resource block ensures that the website content copied to the website root folder.
        #File WebsiteContent {
        #    Ensure = 'Present'
        #    SourcePath = 'c:\inetpub\wwwroot\iisstart.htm'
        #    DestinationPath = 'c:\inetpub\wwwroot'
        #}


        Script InstallDotNetCore
        {
            #SetScript - This will be run when the node configuration needs to be updated
            SetScript = 
            { 
                C:\WebApp\dotnet-install-2.ps1 -Channel Current
            }
            #TestScript answers the question: Is the node up-to-date?
            TestScript = 
            { 
                #test if the command exists
                $cmd = get-command dotnet -ErrorVariable $err -ErrorAction SilentlyContinue
                
                    if(!($cmd))
                    {           
                        Write-Host "<dotnet> command does not exist - returining false to install"        
                        return $false
                    } 
                    else 
                    {   
                        $ver = dotnet --version     
                        Write-Host "The command <dotnet> does exist"
                        
                        if( $ver -like "2.1*" )
                            {
                                Write-Verbose -Message ('Already using version' -f $ver)
                                return $true
                            }
                        Write-Verbose -Message ('Version not up to date.')
                        return $false
                                        
                    }

                    # Alternatively check if the folder exists
                    # if (!(Test-Path "C:\Program Files\dotnet\")) 
                    #    {
                    #        return $true
                    #    }
            }

            #The status of the node
            GetScript = { @{ Result = (dotnet --version) } }          
        }
        Script RunApplication
        {
            SetScript = 
            { 
                C:\WebApp\runApp.ps1
            }
            TestScript = 
            { 

             $process = Get-Process "dotnet" -ErrorAction SilentlyContinue
             
             if( $process.Name -like "dotnet*" )
                {
                    Write-Verbose -Message ('App already running')
                    return $true
                }
                Write-Verbose -Message ('App is not running')
                return $false
            
            }
            GetScript = { @{ Result ="PID: " + (Get-Process "dotnet").Id } }
            DependsOn = '[Script]InstallDotNetCore'
                    
        }
    }
}


    # Compile the configuration file to a MOF format
    InstallNETCoreAndRun

    # Run the configuration on localhost
    Start-DscConfiguration .\InstallNETCoreAndRun -Wait -Force -Verbose
