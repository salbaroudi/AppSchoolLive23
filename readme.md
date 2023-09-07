 ## App School Live 23':

 This repo stores my ASL 23' coursework and notes.  For Dev Ops setup stuff, this will be stored in this readme file to get examples working. Notes are stored in a separate file.  

 ### Getting Agents to Run:

-Note: lines with $ signify bash, lines with > signifiy the Dojo.
-First get the latest [urbit developer pill](https://developers.urbit.org/blog/dev-pill)
-Install it with the urbit binary (this might take a few minutes):

```
$ urbit -B dev-latest.pill -F zod
$ urbit dock zod$ ./zod/.run

```

-Create a new desk, and mount it:

```
> |merge %alfa our %base
> |mount %alfa
```

- Modify your desk.bill to add the mounted alfa desk:

```
$ cd zod/alfa$ echo "~[%alfa]" > desk.bill
```

- Add your app to /app, commit it and install it:

```
> |commit %alfa
> |install our %alfa
```

