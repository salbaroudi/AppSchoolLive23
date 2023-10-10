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
│   ├── delta.hoon
├── mar
│    └── delta
│       ├── action.hoon
│       └── update.hoon
│       
├── docs 
│   ├── dev
│   │    └── overview.hoon
│   ├── usr
│   │    └── overview.hoon
│   ├── doc.toc
│
├── tests 

``` 




Of note, I simulate a /doc folder according to %docs-app specifications. Specifically, documentation for users and developers is included, as well as a `doc.toc` file for the docs-app.


#### Setup of Desk:

To build this modified delta desk, simply merge the %base desk, and copy the files and sub-folders over. 



### Question 2:

####  What libraries does the code use?

- of note: 
    - rudder (which acts as a mini http server). This allows ~paldev to completely avoid using React - he just runs his own http server.
    - and verb, which prints what our gall agent does for every interaction.






Notes on %pals app:


- list with ~. is the "ALL" list
- primary integration usage: use the scry interface library

- mar:effect: involves changes to our pals. Grow arm is used with json, so sending to FE. mar:command involves Grab, so this is from FE. 


- Libraries Used:
    - dbug, default-agent (obvious)
    - rudder:  this actulaly serves our webui. Its a mini http server written by the pals dev.
    - verb: Prints what our agent is doing.
        => no more endless sigpams and syntax errors!


- Q: ::  Why are the heys and buys sub-typed based on target and leech?
    => Target and leech actions are either (meet) or cancel/break.