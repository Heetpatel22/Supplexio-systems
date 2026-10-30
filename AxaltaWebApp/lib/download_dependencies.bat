@echo off
echo Downloading required dependencies...

REM Create lib directory if it doesn't exist
if not exist "lib" mkdir lib

REM Download JUnit and Hamcrest for testing
curl -L -o lib/junit-4.13.2.jar https://repo1.maven.org/maven2/junit/junit/4.13.2/junit-4.13.2.jar
curl -L -o lib/hamcrest-core-1.3.jar https://repo1.maven.org/maven2/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar

echo Dependencies downloaded successfully!
