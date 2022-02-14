# selenium-assesment

## Local Setup -
 
Initiate - Chromedriver <br />
`./chromdriver`

Run selenium standalone jan - setup host at 4444 (default) <br />
`java -jar selenium.jar standalone`

---
## Flags and Options

### --browserstack 
flag with count of parallel threads. <br />
Default thread count = 1 <br />
E.g. `./script2.sh --browserstack`

### --ip-check 
Flag to print the IP address of running device. <br />
E.g. `./script2.sh --browserstack --ip-check`

### -c 
option with count of parallel threads. <br />
E.g. `./script2.sh --browserstack -c 4`

---
Commits <br />

Phase - 1 (Solution TAG: v1.0)<br />
Write a shell script to launch a selenium session locally (i.e. on your system) on Chrome. Download and run the latest selenium JAR and interact with it by using `curl` commands. The script should go to google and search for your name and then fetch and print the page title on the console.

Phase - 2 (Solution TAG: v2.0)<br />
Now do minimal modifications in the previous script to take a command line flag --browserstack. If this flag is provided then the session should run on BrowserStack. For now, run it on the Chrome 65 on OS X Sierra; also pass appropriate build name, so that all your sessions are inside one build.

Phase - 3 (Solution TAG: v3.0)<br />
Add a flag --ip-check, which figures out the IP Address of the machine where your Selenium session runs on BrowserStack and then prints the RTT to that IP. You can either modify the previous phase's test steps to support this functionality or write a different test for fetching the IP.

Phase - 4 (Solution TAG: v4.0)<br />
 After that, add a command line argument -c X. Where X is the number of parallel sessions to run. The default value is 1. The different sessions should have the same build name but different session names. So, -c 2 --ip-check will print the RTT times to two different BrowserStack machines(terminals).
