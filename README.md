# Drone Proto Zero

iPad app prototype version 0 for programming drones  with cards.  

This project runs in Swift 3 and requires Xcode 8.  Like most projects this one has dependencies.  We utilize Carthage to minimize some of the work to get the dependencies up and working, although that is up for debate.

##Install

1. Clone the project `git@github.ibm.com:ETX-CardKit/drone-proto-zero.git`

2. In the directory where the `Cartfile` exists run... 

 `carthage update --platform iOS --configuration Debug`  
 
 This will update the dependency libraries associated with the ptoject but only build them for the iOS platform and the Debug configuration.  If you are trying to archive for Release then you will need to change the configuration to `Release`.  If you don't have Carthage installed on your machine, you will need to do that first. [Go Here](https://github.com/Carthage/Carthage) 

3. open the `DroneProtoZero.xcodeproj` and build.  You should have a working version of the app.

Note that we're using the traditional master/develop branching system.  Master branch will always have a stable working version of the app.  Develop will most likely be stable but will be further ahead as far as features.

##Contributions

If you are contributing to the repo, you should create a branch from develop add your feature/changes/fixes, then check that branch in.  Submit a Pull Request to develop and include other contributors in the PR by adding their names (like this @boland).

Also, in your pull request submit a brief explanation about what you did, and any other info that might be important.

Make sure to include at least 2 reviewers in your PR otherwise it might get lost or forgotten and no one likes an unreviewed PR.

![zoidberg PR](https://cdn.meme.am/cache/instances/folder483/54180483.jpg)

