# Supplexio Web Application

A web-based auction system for Supplexio.

## Prerequisites

1. NetBeans IDE 8.0.2
2. JDK 8 (1.8.0)
3. MySQL Server 8.0 or later
4. GlassFish Server 4.1

## Quick Setup

1. Install Prerequisites:
   - NetBeans IDE 8.0.2
   - MySQL Server 8.0 or later
   - GlassFish Server 4.1

2. Configure Tomcat Database Resource:
   - Copy `web/META-INF/supplexio_global_resource.xml` content to your Tomcat's `conf/server.xml` inside the `<GlobalNamingResources>` section
   - Restart Tomcat server

3. Open in NetBeans:
   The database will be automatically created when you first run the application.

3. Open in NetBeans:
   - Open NetBeans IDE 8.0.2
   - File -> Open Project
   - Select the project directory
   - Right-click project -> Clean and Build
   - Right-click project -> Run

## Manual Setup (if automatic setup fails)

1. **Database Setup**
   - Install MySQL Server
   - Default credentials: username=root, password=root
   - The database will be automatically created on first run
   - If you need to manually set up the database, run `setup_database.bat`

2. **GlassFish Setup**
   - Install GlassFish Server 4.1
   - Run `setup_glassfish.bat`
   - Run `setup_glassfish_resource.bat`
   - Restart GlassFish

3. **Project Setup**
   - Open in NetBeans 8.0.2
   - Verify JARs in lib/:
     - mysql-connector-j-9.2.0.jar
     - junit-4.13.2.jar
     - hamcrest-core-1.3.jar

3. **Build and Deploy**
   - Right-click on the project and select "Clean and Build"
   - Right-click on the project and select "Deploy"
   - The application will be deployed to http://localhost:8080/SupplexioWebApp
   - GlassFish Admin Console will be available at http://localhost:4848

## Default Admin Account
- Email: admin@example.com
- Password: admin123

## Recent Improvements

1. **Enhanced Database Initialization**
   - Improved startup process with robust database initialization
   - Added timeout mechanism to prevent indefinite waiting
   - Implemented better error handling and logging during initialization

2. **New DatabaseStatusServlet**
   - Added a new servlet at `/dbstatus` to check database status
   - Useful for diagnostics and monitoring

3. **Improved Error Handling**
   - Enhanced error.jsp to provide more detailed and user-friendly error information
   - Added specific error handling for database-related issues

4. **Dynamic Startup Feedback**
   - Updated please-wait.jsp to provide real-time feedback during application startup
   - Automatically redirects to home page when initialization is complete

## Troubleshooting

1. **Database Connection Issues**
   - Verify MySQL is running
   - Check database credentials in DatabaseConnection.java
   - Run setup_database.bat again if tables are missing
   - If you see 'No suitable driver found' or 'No registered driver' error:
     1. Run `setup_glassfish.bat` to install MySQL driver
     2. Restart GlassFish server
     3. Clean and Build the project
     4. Deploy the application again
     5. If error persists, verify mysql-connector-j-9.2.0.jar exists in:
        - Project's lib/ directory
        - GlassFish domain lib directory (usually in %USERPROFILE%/GlassFish_Server/glassfish/domains/domain1/lib)
   - Check application logs for detailed error messages during startup

2. **Build Errors**
   - Clean and build the project
   - Verify all required JARs are in lib/ directory
   - Right-click project -> Clean and Build
   - If needed, right-click project -> Resolve Reference Problems

3. **Deployment Issues**
   - Verify GlassFish server is running (Services -> Servers -> GlassFish Server)
   - Check server logs in NetBeans (Window -> Output -> GlassFish Server)
   - Access Admin Console at http://localhost:4848 for detailed monitoring
   - If you encounter a "web container has not yet been started" error, check the following:
     - Ensure the database is properly initialized (check logs for any initialization errors)
     - Verify that the DatabaseReadinessFilter is properly configured in web.xml
     - Check the please-wait.jsp page for any error messages

4. **Startup Process**
   - The application now has an improved startup process with better error handling
   - If the application seems stuck on the please-wait.jsp page:
     - Check the server logs for any error messages
     - Verify database connectivity
     - Access the `/dbstatus` endpoint for current database status

## Support
For any issues, please contact the development team. Include any relevant error messages or logs when reporting problems.
