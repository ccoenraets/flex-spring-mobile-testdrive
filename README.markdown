Flex Spring Mobile Test Drive
=============================

1. Deploy flex-spring-mobile.war to your app server.
2. Import the projects into Flash Builder: (If you don't have Flash Builder, you can download it [here](http://www.adobe.com/cfusion/tdrc/index.cfm?product=flash_builder))

	* File > Import > General > Existing Projects into Workspace
	* Select ccoenraets-flex-spring-mobile-testdrive as the Root directory
	* Select all the projects (EmployeeDirectoryJ, flex-spring-mobile, and MobileTraderJ) 
	* Click Finish

3. Running the EmployeeDirectory

	* Open config.xml in the src folder and modify the endpoint to match the hostname and port number of your app server
	* Right-click EmployeeDirectoryJ and select Run As > Mobile Application
	* Select a target platform (iOS, Android, or BlackBerry Tablet OS), select On desktop as the launch method and select a device to simulate
	* Click Run

4. Running the MobileTrader Application

	* Right-click EmployeeDirectoryJ and select Run As > Mobile Application
	* Select a target platform (iOS, Android, or BlackBerry Tablet OS), select On desktop as the launch method and select a device to simulate
	* Click Run
	* The Settings view is automatically activated the first time you run the application. Enter the MessageBroker base URL, for example: http://localhost:8080/flex-spring-mobile/messagebroker (modify the endpoint to match the hostname and port number of your app server), select a Channel type, click Save Settings, and click Start Server Feed.
	* Access the Watch tab: The list should be automatically updated with the (simulated) real time updates pushed from the Spring web app.
