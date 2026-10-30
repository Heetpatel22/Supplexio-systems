@echo off
echo Setting up GlassFish Server for Supplexio Web Application

REM Set environment variables
set GLASSFISH_HOME=%USERPROFILE%\GlassFish_Server
set DOMAIN_HOME=%GLASSFISH_HOME%\glassfish\domains\domain1
set MYSQL_CONNECTOR=lib\mysql-connector-j-9.2.0.jar

REM Check if GlassFish is installed
if not exist "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" (
    echo Error: GlassFish Server not found at %GLASSFISH_HOME%
    echo Please install GlassFish Server 4.1 or later
    exit /b 1
)

REM Check if MySQL connector exists
if not exist "%MYSQL_CONNECTOR%" (
    echo Error: MySQL connector not found at %MYSQL_CONNECTOR%
    exit /b 1
)

echo Using MySQL connector: %MYSQL_CONNECTOR%

REM Stop domain if it's running
echo Stopping GlassFish domain if running...
call "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" stop-domain domain1

REM Start domain
echo Starting GlassFish domain...
call "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" start-domain domain1

REM Copy MySQL connector to GlassFish lib directory if not already there
if not exist "%DOMAIN_HOME%\lib\mysql-connector-j-9.2.0.jar" (
    echo Copying MySQL connector to GlassFish lib directory...
    copy "%MYSQL_CONNECTOR%" "%DOMAIN_HOME%\lib\"
)

REM Create JDBC connection pool
echo Creating JDBC connection pool...
call "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" create-jdbc-connection-pool --restype javax.sql.DataSource --datasourceclassname com.mysql.cj.jdbc.MysqlDataSource --property "user=root:password=root:url=jdbc\:mysql\://localhost\:3306/supplexio?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" SupplexioDBPool

REM Create JDBC resource
echo Creating JDBC resource...
call "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" create-jdbc-resource --connectionpoolid SupplexioDBPool jdbc/supplexioDB

REM Build and deploy the application
echo Building and deploying the application...

REM Create target directory if it doesn't exist
if not exist "target" mkdir target

REM Compile Java classes
javac -cp "%MYSQL_CONNECTOR%;web\WEB-INF\lib\*" -d target\classes src\java\com\supplexio\util\*.java src\java\com\supplexio\servlet\*.java

REM Create WAR file structure
if not exist "target\SupplexioWebApp\WEB-INF\classes\com\supplexio\util" mkdir target\SupplexioWebApp\WEB-INF\classes\com\supplexio\util
if not exist "target\SupplexioWebApp\WEB-INF\classes\com\supplexio\servlet" mkdir target\SupplexioWebApp\WEB-INF\classes\com\supplexio\servlet

REM Copy compiled classes
xcopy /Y target\classes\* target\SupplexioWebApp\WEB-INF\classes\

REM Copy web files
xcopy /E /Y web\* target\SupplexioWebApp\

REM Copy libraries
xcopy /Y lib\*.jar target\SupplexioWebApp\WEB-INF\lib\

REM Create WAR file
cd target
jar -cf SupplexioWebApp.war -C SupplexioWebApp .
cd ..

REM Deploy the application
echo Deploying the application...
call "%GLASSFISH_HOME%\glassfish\bin\asadmin.bat" deploy --contextroot supplexio --force=true target\SupplexioWebApp.war

echo.
echo Deployment complete!
echo Access the application at http://localhost:8080/supplexio
