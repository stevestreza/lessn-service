This is a text service for Mac OS X 10.6+ which compresses URLs with Lessn 
(http://shauninman.com/archive/2009/08/17/less_n) or ButteredURLs 
(http://github.com/jfro/butteredurls). You'll need to have one of those running
on your own server. 

Installation
============

1. Clone the project
2. Open the xcodeproj inside
3. Build (this will copy the service into your ~/Library/Services/ folder)
4. Activate the service in System Preferences > Keyboard > Keyboard Shortcuts
5. In your terminal, type and replace <<LessnDomain>> with your domain:
      defaults write com.stevestreza.lessnshorten baseURL <<LessnDomain>>

License
=======

All code in this project is licensed under the MIT license.