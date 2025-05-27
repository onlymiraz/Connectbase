# Define the content for web.config
$webConfigContent = @'
<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <system.webServer>
    <handlers>
      <add name="PythonHandler" path="*" verb="*" modules="FastCgiModule" scriptProcessor="D:\Program Files\Python\python.exe|D:\Program Files\Python\Lib\site-packages\wfastcgi.py" resourceType="Unspecified" requireAccess="Script" />
    </handlers>
  </system.webServer>
  <appSettings>
    <add key="WSGI_HANDLER" value="app.app" />
    <add key="PYTHONPATH" value="D:\Scripts\WebApp" />
  </appSettings>
</configuration>
'@

# Write the content to web.config in the application directory
$webConfigPath = 'D:\Scripts\WebApp\web.config'
Set-Content -Path $webConfigPath -Value $webConfigContent
