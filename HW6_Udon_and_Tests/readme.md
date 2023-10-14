### HW6 Question 1:

This github folder serves as my answer to HW6 Q1.  We are asked to produce documentation and tests for the %delta app that was demonstrated for ASL. In this folder, I include only the delta app files, and my additional /doc and /tests folders for the app (for brevity).  

The structure of our desk (minus all %base files), is below:

```
%delta
├── app
│   ├── delta.hoon
│   └── delta-follower.hoon
│       
├── sur 
│   └── delta.hoon
├── mar
│    └── delta
│       ├── action.hoon
│       └── update.hoon
│       
├── docs 
│   ├── dev
│   │    └── overview.hoon
│   └── usr
│        └── overview.hoon
│   
│
└── tests 
      └──app
         └── delta.hoon
``` 

Of note, I simulate a /doc folder according to %docs-app specifications. Specifically, documentation for users and developers is included. THe required 'doc.toc' folder file is excluded, as this causes compile errors (you need a mark file for this) - which is beyond the scope of what was asked.

#### Setup of Desk, and running the Tests.

To build this modified delta desk, simply merge the %base desk, and copy the files and sub-folders over. 

In dojo, run:

```
|merge %delta our %base
|mount %delta
|commit %delta

::And run...
-test /=delta=/tests/app/delta/hoon

```

To try out the tests.  Remember to set %delta and %delta-follower in desk.bill (!), before you install the app.

### Question 2:

#### General Notes:

- list with ~. is the "ALL" list
- appears to have its own custom scries library, that allow a user to do the following:
    - developer encourages people not to scry directly, and to use his interface. 

####  What libraries does the code use?

- rudder (which acts as a mini http server). This allows ~paldev to completely avoid using React - he just runs his own http server.
- and verb, which prints what our gall agent does for every interaction.
- usual dbug and default-agent inclusions

- rudder does not run as a thread on its own (like a normal http server (say apache, or some node package)), it is actually run by the backend, in the ++on-poke arm.  
    => In your app, call steer rudder with a configuration. We use poke requests to server pages, as these are done over HTTP


#### Summary of the Files:

- /mar files:
    - effect: involves changes to our pals. Grow arm is used with json, so sending to FE. We send effects to the FE.
    - command involves Grab, so this is from FE to BE. WE send commands from the FE

- /sur files:
    - only one structure file for the app.
    - main strucutre is the **record**. This is reduced to outgoing and incoming connections.
        - if a ship is present in both, we have a match.
    - effects and commands.
        - for some reason, requests/cancellations for leeches and targets have different names for the actions .

- /webui files:
    - index.hoon and sigil.hoon
        - these are compiled files that display for the front end.
        - sigil.hoon displays custom (simiplified) sigils, and feeds into index.hoon.
        - our rudder is "steered" by the BE to display these files and serve them to the Landscape.

- /lib/verb.hoon
    - this prints out every interaction that occurs with standard Gall Arms. This basically helps us avoid covering our app in sigpams.

- /lib/rudder.hoon
    - this library implements a basic HTTP server, and serves up our index.hoon file. Note that Eyre is still running in the background.

- /lib/pals.hoon
    - the developer has actually made his own custom scry library (we should not do direct scries, use his interface).
        - check if a user is a leech/match/target
        - get a requesting users leech/match/target set.

- /app/pals.hoon:
    - Main app that handles all of the scry, poke, subscribe and state processing.
    - Also imports rudder, and handles HTTP-Requests (a kind of Poke) from Eyre.

#### Outstanding Questions:

- Q:  How do we initialize the webpage? Walking through it...
    -  We click on the pals app in Landscape grid, and it is loaded.
    -  Docket makes a request to our backend gall app, which has just been setup to run.
    - This is a poke request to initialize, sent through Eyre. 
    - In the ++-on-poke arm, the http-request is hit. We activate the rudder library, compile the index.hoon page, and then send it to Docket.
        - Likely by a subscribe wire...
    - The page (with its javascript) is loaded in the browser.
    - User interacts with page (This is a command). Send to eyre -> through command mar file -> processed by Gall App.
    - Gall updates state, and sends an effect through mar effect -> eyre -> Back to FE interface. Interface updates accordingly.


#### Text Used for Diagram (Q2):


Initialization:
[1] User clicks on "Pals" app in Landscape Grid. Docket loads pals.hoon (backend), and sends a request for the front end.  An initial subscriber wire is also sent
[2] Pals.hoon has loaded (with all libraries), including Rudder which acts as an HTTP Server.  Gall app gets a poke for [%http-request].
[3] Rudder gates are called (steer), and the webui pages are rendered.
[4] Gall App sends pages back to Landscape Docket.
[5] Which loads the Front-End display in the browser.

User Interactions/Run-Time:
[a] User interacts with UI (such as adding a pal, adding a tag...). Front End UI sends a poke (of type command) back to Gall. 
[b] This HTTP request is intercepted by Eyre, which uses the [command] mark file to process the request.
[c] Gall App recieves the request, processes it, and optionally sends a %give/%pass card (Depending on the state changes, and requst type).
[d] Updated state results in information being sent back via a subscription wire. This response data is formatted through the [effect] mark (via Eyre), and send on to the UI.
[e] The UI recieves the update, and changes/informs the user accordingly.
