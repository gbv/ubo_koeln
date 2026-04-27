# Notices for Claude

## Jar Overlay for UBO Application
This project is a Jar Overlay which allows to overwrite files in the UBO application. It is a MyCoRe
Based Application bibliography application. To understand how to use this project, you should always
have a look at the ubo application. You can find it here: ../ubo

## Running the application
This Project is build with maven. The resulting Jar needs to be copied into the home/lib folder of the ubo application. 
The location depends on the installation of the ubo application. In a default installation it 
should be located at `~/.mycore/ubo/lib` in docker its probably located at `../ubo/docker/ubo-home/lib/`.
After copying the jar, you need to restart the ubo application. 
You can do this by ending the Tomcat process and run `mvn cargo:run -pl ubo-webapp -DskipTests` in the ubo folder.
Or if its is docker by running `docker-compose restart` in the ubo folder.

## Development
The files in this project were usually copied from the ubo application and then modified. 
If an update is required, syncing the files with the changes in ubo application is required. 
