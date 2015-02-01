How to authorize cURL with Facebook?
---

1. Start local instance of PHP server for recieving Facebook redirects:
    
        Double click on '01. Start Local PHP Server.command' file

2. Get access token:

        Double click on '02. Open Facebook Login Dialog.webloc' file
    
3. Copy access token from browser page and paste into `Scripts/Curls/access_token.txt` file.
4. Open Terminal.app and change directory to `Scripts/Curls` folder.

Now you are ready to execute requests from curls.txt file.