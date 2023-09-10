## App School Notes:

## Glossary:

- Arvo: Urbit's OS.
- Noun: A noun is an atom (a single value +ve integer), or a cell of two nouns.
- Core: A special cell that pares operations to data.
    - Arms: The comptation portion of a core.
    - Legs: THe data portion of a core.
- Door: A Core with a sample pinned to the head.
- Vanes: These are core Arvo (OS) modules that perform system level operations. Some important vanes:
    - Ames: P2P networking.
    - Behn: Timer Vane
    - Eyre: HTTP Vane
    - Gall: Application Vane
- Scry: Read only REQ to the namespace of a local vane or agent. 
- cage: a cell of [mark  vase]
    - mark: a @tas term used to mark data.
    - vase: data payload that is packaged in some way (?).

##  Lesson 0: Arvo and Creating Simple Agents:

- Def: App: the entire desk you are distributing.
- Def: Agent: A single process running on a particular Desk.
- The goal of any operating system is to define an expected way to load and execute programs.
- Urbit's OS is called **Arvo**, which is an event handler and dispatcher.  It provides a userspace app framework called Gall, which requires a standard application interface. It also gives you access to an environment, state management, and p2p software distribution.
- A Gall agent is both a noun and a core.
- Analogy of an Agent: It is a state-machine. It must respond to all possible outputs, and act accordingly to transition to another 
state.
    - It is a piece of software that maintains and distributes a stateful structure.
    - It has an interface that lets other entities interact with it.
    - It transitions based on a predefined function and input, and must guarentee that the next state is valid.

#### The Agent as a State Machine:

- An agent is a piece of software that is primarily focused on maintaining and distributing a piece of state with a defined structure. It exposes an interface that lets programs read, subscribe to, and manipulate the state. Every event happens in an atomic transaction, so the state is never inconsistent. 
- An agent is permanent and addressable -- a running program can talk to an agent just by naming it. An agent can perform IO, unlike most databases. This is a critical part of an agent: it performs IO along the same transaction boundaries as changes to its state, so if an effect happens, you know that the associated state change has happened
- Like a state machine, any input could happen at any time, and it must react coherently to that input


### The Agent Core:

- A Gall agent is a door with 10 arms. Each arm being responsible for handling specific events.
    - Analogy: A React/JS framework that handles user interaction events.

- The (most-basic) default agent is below:

```
|_  =bowl:gall
++  on-init   `..on-init
++  on-save   !>(~)
++  on-load   |=(vase `..on-init)
++  on-poke   |=(cage !!)
++  on-watch  |=(path !!)
++  on-leave  |=(path `..on-init)
++  on-peek   |=(path ~)
++  on-agent  |=([wire sign:agent:gall] !!)
++  on-arvo   |=([wire sign-arvo] !!)
++  on-fail   |=([term tang] `..on-init)
--
```

#### Some Important Terms:

- Vase:  is a data container tha tholds a pair of type and value.  This is used to send/recieve data, and interpret the data that has been sent.  The type is applied to the value, to interpret it.
- Cage:  A pair of mark and a vase. A mark bein a text tag that corresponds to a dynamic type in a vase. Marks are akin to filetypes, and are stored in the /mar folder of your desk.
- Path:  a list of knots. Exactly what you would expect.
- Wire: An alias of a path. Acts as a unique identifier for a request.
-  \``..on init`: Recall back-tic notation denotes a **unit**.  When  ++on-init is run, the core is built, and a unit with the core itself is passed back.
- sign/sign-arvo:  these are incoming events (in response to a standing request for data (?)).
- tang:  a formatted print structure.


#### Basic Summaries of Arms:

0) The Bowl: This is our main sample pinned to our gall core.  It contains a number of fields:
    - Basic Agent Info:
        - our:  host ship
        - src:  guest ship
        - dap:  agent name
    - Resource Payload:
        - act:  change number for agent.
        - eny:  entropy bits
        - now:  the current time
        - byk:  load source (?)
    - Subscription Payload:
        - wex:  outgoing subscriptions
        - sup:  incoming subscriptions.
        - sky: bindings:

1) State Management: For initing and upgrading an agent.
    - on-init:  first-time startup arm. Returns the whole arm in a unit.
    - on-save: envases, produces a vase of the current state (before an upgrade).
    - on-load: unwraps the old vase, makes state changes (after an upgrade).

2) Request Handlers:  These handle internet requests.
    - Note: Gall agents implement a dataflow computing model (push data downstream to subscribers).
    - on-poke:  single-instance interaction - like a data status request.
    - on-watch: registers a new subscription.
    - on-leave: quit a subscription / registers a dropped subscriber.

3) Response Handlers: These handle agent responses (info sent back), that our agent receives from making its own requests.
    - on-agent: Req agknow. and subscription updates from other agents. Recieve data from another agent.
    - on-arvo: Handles vane responses, Recieve data from Arvo OS. An arm that basically makes system calls.

4) Scry Handler:
    - on-peek: local read-only requests. Single time data request. Can only read data - never modify.

5) Failure Handler: 
    - on-fail: RT error crashing, handles crash reports from Gall.

- Most of the Gall arms produce a cell that contains two types of data:
    - Cards: A list of effects.
    - Modified Core, usually with the same battery but a modified payload (read: subject for the battery).

#### Understanding Key Agent Data Types [1]:

- Our different components communicate to one another - this can be on the same machine, or a remote machine.
- Just like a data stream with a MIME-Type, we need to encode bits and send them in packets to other agents. 

##### Vase:

- A Vase: A cell of <type> and noun.
    - They encapsulate dynamically typed data (they allow you to move around where the type isn't known beforehand).
        - Practically, almost all data sent to/from agents will involve vases, or be wrapped in them.
        - **Arm Def:**  `+$  vase  [p=type q=*]`
    - Make a Vase with Zapgar (!>)
        - Usage:  `!>(  <noun>  )`.
        - When you make a vase, it creates a cell with inferred datatype as the first slot, and data as second slot (pinned to face q)
    - Unpack a Vase with Zapgal (!<):  The rune uses the type as a mold, and tries to cast the data inside the vase as that type.
        - Usage: !<  <type>  <vase>
        - **When used:**  on data in a `card` that comes from other ships and agents...
    - You can make any noun a vase, even complex cells(!)
```
!>([foo="bar" 55 (limo ~[1 2 3]) [%myterm  "Hello!!"] ])

[ #t/[foo="" @ud ^#4.?([i=@ud t=#4] ^#3.?([i=@ud t=#3] it(@ud))) %myterm ""]
  q=[[98 97 114 0] 55 [1 2 3 0] 120.338.095.831.405 72 101 108 108 111 33 33 0]
]

```

##### Mark:

- is just a kind of term (@tas), that specifies a clay filetype. All marks have a mark file in /mar of your fake zod.
- A mark of type %foo corresponds to `/mar/foo/hoon`


##### Cage:

- A cage is a cell of a mark and a vase. 
- Cages typically hold vases. 
- Structure:  `[%mark [<vase...>]]`
    - To examine the vase, you can walk the binary tree to address +3.cage...


### Examining the Bravo Core (Extended):

```
/+  default-agent, dbug
|%
+$  versioned-state
  $%  state-0
  ==
+$  state-0
  $:  [%0 values=(list @)]
  ==
+$  card  card:agent:gall
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this  .
    default  ~(. (default-agent this %|) bowl)
++  on-init
  ^-  (quip card _this)
  ~&  >  '%bravo initialized successfully'
  =.  state  [%0 *(list @)]  [~ this]
++  on-save   on-save:default
++  on-load   on-load:default
++  on-poke   on-poke:default
++  on-arvo   on-arvo:default
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-fail   on-fail:default
--
```

#### Note the following:

- In this core, we have imported a default library which just uses standard arms (instead of us having to write it out). What is significant is the stuff on the top. Some observations:

- `/+  default-agent, dbug`: We import two libraries.
-  Core (|%):  
    - The +$ arms define types and structures we will use later.
- `%-  agent:dbug=|  state-0=*  state  -^-  agent:gall`: We wrap our gall core in a debug agent - starting with a gate/function call.
- Whats inside /lib/default-agent/hoon?
    - Our 10 default arms are stored as gates in default-agent's arms...They are fleshed out, and have good pretty-printing to help
    us understand things in Dojo console.
- Aliasing/Pinning:
    - `this` keyword: is pinned to the subject (.) with +*.
    - `default  ~(. (default-agent this %|) bowl)` we pin default to a %~ call, with subject compiled core, and bowl attached.

## Lesson 1: Arvo Services:

- "Arvo is the Urbit OS and kernel which is written in Hoon, compiled to Nock, and executed by the runtime environment and virtual machine Vere. Arvo has currently nine kernel modules called vanes."
- Arvo is the OS and Kernel of Hoon, which compiles to the Turing Complete Nock low-level language.

### State Machine:

- The core operation of Arvo (for any system like call), is to execute the Transition Function:

$$TF(oldState,Events) \rightarrow  (effects, newState) $$

- Each Vane has its own state - and all the vane states are nested in Arvo's state object.
- Arvo also handles the scry system, inter-vane messaging. Arvo just deals with state management, and routing cards to different vanes.

### Events and Event Log:

- Arvo's current state is the end result of the events which have operated on it. 
- Formal State: A log of events, in a linked list of nouns. It can be recomputed from the beginning at any time.
- Events have two key properties that give us guarentees for state transitions:

1) **Atomicity:** The event is written to the event log, and only then the effects of the event are applied.

2) **Consistency:**  The database is in a consistent state before an effect, and after an effect. All transitions of state are result in a valid database.

- Because we write to log before performing the side-effect, even if we crash, we can be sure the side-effect will occur.
- "It behooves one to think of Arvo as being a stateful packet transceiver rather than an ordinary computer—events are never guaranteed to complete, even if one can prove that the computation would eventually terminate"
- Arvo's causal stack is called a `duct`.
    - this is a list of paths, which represents a step in the cause chain.
    - think of an event as a tree - where the internal nodes are different vanes/arvo performing work, and leafs are Unix events (for the end side-effects on our system).
- This causal stack is to avoid **event spaghetti**.
    - Keeping track of every event's cause creates a clear chain of computation.
    - To route the results of our event computation, we can unwind our causal stack.


### Other Arvo Notes[2]:

- Arvo is considered to be a "solid-state interpreter":  Because we can reliably reconstruct our state from the event log.
    - Like an SSD: If the power resets, the data is still the same. We can pick up where we left off.

- Arvo is an ACID Database:
    1) Atomicity: Events are atomic (succeed or fail only).

    2) Consistency: Updates always leave DB in valid state.

    3) Isolation: No concurrent transactions / race conditions. Things happen sequentially.

    4) Durability: Complete transactions are permanant, and commited to log.

- Arvo is a Single Level Store: All data is stored in one permanent location.

- Arvo is an event loop.
    - reciveds a `move`, and processes it into an event, and transitions system state.
    - we do an event log replay to rebuild our state.
    - arvo can bootstrap itself to upgrade (complex)
    - An event is the result of one of our moves.
    - events only have meaning insofar as they are parts that constitute a state, when arranged in a particular sequence.
    - urbit is a functional operating system.
        - functions are referentially transparent. => determinsitic 
    - whenever you make a request for deterministic data, you are making a Scry
    - every operation (network call, file change), is scryed. it is bound at a unique path in time. (Temporal-Spatial addressing.)
    - every door agent takes your state as as sample...
    - Skry reference: there is a ++skry arm for every vane...https://developers.urbit.org/reference/arvo/overview

- Arvo routes events to different vanes, and coordinates things.
- Arvos current state is the end result of a set of events that have operated on it, via the transition function and agent interactions.
- In general, you will design apps taht mainlu use Gall, and also use Eyre, Behn and sometimes Clay. Other vanes are not often used (at least, at the beginner level).

### Introducing Vanes: 

- Vanes are different sub-components of Arvo that handle different tasks.
- We interact with them with one of two methods:

    1) Scries (Peeks): Using .^ rune, which allows for a one-time read-only request.

    2) Note passing:  Using |pass and a structured note.


- Scries are highly structured and varied requests. See the chart below:
- Most vanes are the indented endpoints of scry requests.
    - Exception: Gall: which passes scries to its running agents.

![scry image](./img/scries_diagaram.png)

Some Scry Terms:
- First Term: The return type (will be cast to this)
- Cases: This allows you to target a specific file revision. We typically use (scot @da now) for **the latest version of the file**.
- Cares are particular modes of operation (read, write, directory, etc.)

#### App Usage:

- Most of our simple apps will involve Gall, Eyre Behn and some Clay.
- A desk is a collection of files on Clay. It is like a git branch for your app agent.
- An agent is a particular /app entry which can be run.
- Structurally: An "App" is a distributed desk with end-user agents included.

### Ames:

- Ames receives packets as Arvo *events*, and emits packets as arvo *effects*.
- this vane uses UDP to transmit messages between ships.
    - unlike TCP, urbit nodes don't care if some packets are lost. We don't need a handshake, or agknowlegement for every package.
- Urbit has acks (+ve) and nacks (-ve) responses. If a packet gets to its destination, we don't do anything.
- If the packet is recieved, but in error or not recognized, the ship may send a nack with an error payload (optionally).
- messages may be of arbitrary length, and are broken into Maximum Transmissible Units.
- Ames doesn't report packets that fail to authenticate / unencrypt. This is an attack surface.
- Postel's Law:  "Be conservative in what you send, and liberal in what you accept".
- Ames Arms:
    - call:  handle request stack
    - take: handle response sign
    - stay extract state before reload
    - load  load in old state after reload
    - scry: deref namespace.

- Structurallly, Ames maintains a duct of ordered messages, which represent arvo events.
- Scrying with Ames is not often done. It is for direct network negotiation only, or done through Gall.

### Behn:
- timer/wakeup call system.
- Note: Desk/tag portion of scry is empty for Behn (//).
- *Q: How would you scry (seen in /gen/timers/hoon) Behn at the Dojo Prompt?*

```
.^(noun %bx /(scot %p our)//(scot %da now)/gen/timers/hoon)

> 
```

### Clay:
- our vane that manages a globally-addressable file system. 
- attaches ID tags to data, these are called "marks". They act like MIME types.
- Practically, a desk is a discrete collection of files on Clay. 
- Analogy: A desk is just a git branch.
- referentially transparent: a request must yield the same result for all time.
    - how do we delete files? We leave a "Tombstone", with empty content.
- A Mark is best defined as a synbolic mapping for a filesystem to a schema engine.

- Top level determiner for Clay is a **Beak**: which is a triplet of ship, desk and case.
- Case is a type union of the following: `?([%da @da] [%tas @tas] [%ud @ud])`
    - note that each aura is tagged here, we don't place them raw.
- There are default values, to make Beak entry faster. For Example:

```
> /===  [~.~zod ~.base ~.~2022.7.17..23.50.01..3305 ~]  
> /~nec==  [~.~nec ~.base ~.~2022.7.17..23.50.13..dd5d ~]

```

- So for certain scries, you can use "===" notation to shorten the call.
- Clay has a metric ST of cares, more than any other vane. Consult the documentation often.

- our Mark files can be used as gates to convert data...


- A Static Mark Gate: Converts from just one type to another (fixed):
```
> =txt-to-mime .^($-(wain mime) %cf /===/txt/mime)
> (txt-to-mime ~['foo'])


[p=/text/plain q=[p=3 q=7.303.014]]
```

- A Dynamic Mark Gate (a Tube): proceses vases instead:

```
> =txt-mime-tube .^(tube:clay %cc /===/txt/mime)
> !<  mime  (txt-mime-tube !>(~['foo']))

[p=/text/plain q=[p=3 q=7.303.014]]
```

- Q: Examine the scry call in /gen/cat/hoon. Call it!

```
code here
```

- Q: Examine the scry call in /gen/ls/hoon. Call it!

```
code here
```

##### Marks:

-  "A mark is a validated data structure, including rules for transformation between representations."
- "We frequently use marks in Gall agents to verify classes of operations (such as actions or updates) or to convert incoming data (such as via the JSON mark)." 

- Marks files define various arms, for converting between value reprsentations:

- `++grab`: Converts to our mark from other marks.
- `++grow`: Converts from our mark to another mark.
- `++grad`: specify functions for revision control like creating diffs.

**Q: Examine /mar/tape/hoon:**
**Q: Examine /mar/xml/hoon:**

- In both files, we see that for grab and grow, we actually define a core-in-arm with sub-types that can be called. This gives us options for converting to/from.


### Dill:

- simply drives our dojo terminal.
- You can write to Dill Console, using a simple |pass:

```
|pass [%d %text "hello world"]
```



### Eyre:

- our HTTP server. Mainly uses PUT, GET and POST requests.
- recieves HTTP messages from Unix, and produces HTTP messages as replies.
- your agent can register endpoints that can be interacted with (by browser, or curl).
- Mainly processes POST, PUT and GET requests.

### Gall:

- Manages users space apps, including subscriber lists.

### Iris:

- is an HTTP Client. By this, we mean it fetches resources via http.
    - Example: Think if it like the curl command.

### Jael:

- Stores our Azimuth Information.
- Primarily deals with ship networking management, and cryptography. Also implements promises (?)
- State segregation: Absolute and Relative.
    - Absolute: What is known about the Azimuth PKI, ship ownership, private keys of other ships. 
    - Relative: What is know about the state of the current ship (for fakezods, for example).
- the state of Jael in code is referred to as `lex`
- Jael is a low level vane - you will only use it (with Gall to do Azimuth Operations).

##### Exceptions on Scries:
- Jael takes no cares.
- Jael has "operation type" in place of desk name.

- Some Examples of Jael Scries are below. Note the unusual notation:

```
::Reveal Web Login Code:
.^(@p %j /=code=/(scot %p our))

::Query Sponsorship chain:
.^((list @p) %j /=saxo=/~sampel-palnet)

```
### Khan:
- Triggers threads. Threads are lightweight agents (**not** Linux OS threads)

### Lick:
- deals with Inter Process Communicaiton (IPC). 
- this is not between urbit agents or vanes, but for other processes on your host OS
    - So for linux processes or hardware peripherals...

#### Q3 and the Writing Marks Tutorial:

- The Simplest Mark Implementation is below:

```
|_  csv=(list (list @t))
++  grab
  |%
  ++  noun  (list (list @t))
  --
++  grow
  |%
  ++  noun  csv
  --
++  grad  %noun
--
```

- Note the Following:
    - We have a door, with a face csv pinned to a type (list list @t)
    - Our Grab Arm is for converting TO our mark, FROM another type (pull towards you).
        - noun is a type that matches anything, and we just cram the thing into a (list list @t) type.
    - The +noun arm in +grab is *mandatory*. Clay cannot build a mark core without it.
    - Grow is for converting FROM our mark, TO another type (push up).
        - we have noun again...we just return csv's with no manipulations.
    - Grad is for revision control (?) and other operations.
        - we just specified a %noun mark for grad...this is because we make to/from noun conversions in **++grab and ++grow**


##### Mime Conversions:

- $mime is a type that represents raw Unix Data 
    - Everything, from HTTP requests, to pipes...
- Likewise, the %mime mark is used by Clay to store and convert $mime data. It is always used, when we move data from Unix to Urbit (Earth -> Mars)
- Example: |commit
    - The file is recieved by Clay as a %mime mark. The %mime mark files will have an arm that convert the file to whatever file exension is detected (.hoon, .txt...).


- We take the csv-utils file from [here](https://developers.urbit.org/reference/arvo/clay/marks/examples#libcsv-utilshoon), and commit it.
    - This is just a core with 4 sophisticated core-in-arms to encode/decode CSV files.

- To test the csv-utils core, we try the following:

```
::decode
> (de-csv:csv-utils 'foo,bar,baz\0ablah,blah,blah\0a1,2,3')
> [i=<|foo bar baz|> t=[i=<|blah blah blah|> t=~[<|1 2 3|>]]]

::encode
> (en-csv:csv-utils [['foo' 'bar' 'baz' ~] ['blah' 'blah' 'blah' ~] ['1' '2' '3' ~] ~])
>'foo,bar,baz\0ablah,blah,blah\0a1,2,3\0a'

```

- csv-utils is now used as a library for or primitive csv.hoon file.  We add a foo.csv test file to the root of the base desk, and read in our data. The mark is converted automatically!

```
> -read [%x our %base da+now /foo/csv]
~[<|foo bar baz|> <|blah blah blah|> <|1 2 3|>]
```

- But how?  We read in some data from the file, which is of type .csv. Hoon looks in the mark folder for csv.hoon, and runs the grab arm.
- We can also go the other direction. Lets convert a list and make a csv file (bar.csv)

```
*/bar/csv ~[['sol' 'zod' ~] ['nod' 'tod' ~] ['dac' 'dyl' ~] ['mil' 'lex' ~]]
+ /~zod/base/5/bar/csv
```

- Here we specified a new file, of type csv, and gave a list list of cords. Hoon looked up the csv.hoon mark, and used the grow arm accordingly...


### App School Lesson 2:  Agents:

- Note: when you write a small/medium-sized agent, expect 3-5 arms to be default.
- most agent arms produce the same two things:
    - `[(list card) _this]`: which is a list of cards, and a reference to a modified agent after state change.
- Urbit has a semi-reactive data model - in which dependent values are updated as upstream values change.
    - Practical Example: Think of MS Spreadsheets with cell variables.
    - Via ship subscriptions kept by the agent, data changes are pushed upstream to each subscriber.
        - Think of an RSS feed that auto-pushes.

- **Goal of Lesson:** *Understand how agents communicate, and then examine how pokes and peeks work. Finally, we start working with subscriptions.*


### Understanding Cards Better:

- To perform actions, we produce lists of cards, to interact with other agents on the internet, or other agents on your ship.
- `_this`  is syntactic sugar for for $_(this) which means :give us the type!
    - this is boiler plate so you can refer to the "kind of thing" quickly, when given an arg. 

- Vanes communicate using `moves`, whilst Gall Agents communicate using `cards`.
    - Cards can be converted into moves by Gall (in some circumstances).
    - info|move| > info|card|, in general.

- cards are a typed structure that store information. This is known as `card:agent:gall`. The data inside the three subtypes listed are known as *(wind  note  gift)*.  
- cards come in two formats:
    - `[%pass wire note]`: Which is sent forward to an agent.
    - `[%give gift]`: Which is sent back to an agent.
- the type wire is just a path of type cord (@ta). This is where the response will come back, for your agent to check.
- Notes have more complicated structures. They are tuples of the form:
    - `[%agent [=ship name=term] =task]`: For other agents.
    -  `[%arvo note-arvo]`: Speficially for other vanes on your system!
- Example: An ARVO Card:
```
::Example: An ARVO CARD
:: outbound value or task
:*  %pass       :: head tag
    /some/ wire     :: wire = unique ID
    %arvo        ::choose to give somethign to ARVO, or agent
    %b          :: target vane
    %wait       ::Behn Specific task.
    (add ~m1  now.bowl)    ::@da
==
```

- Example: An AGENT Card:
```
:: returned value
:*  %pass
    /some/other/wire/(scot %da now.bowl)
    %agent
    [~sampel-palnet  %target-agent]
    %poke
    mark
    !>(value)
```

- ARVO outbound cards return through `++on-arvo`.
- AGENT outbound Cards return through `++on-agent`.

#### More on Pokes and Scries:

- A poke is a simple message to an agent.
- A scry is a request for data from an agent.
    - See the scry diagram (above, Lesson 1) for more details.


##### Charlie.hoon: A Poke and Scry Example Agent:

- in this example, we have a app named %charlie which runs on two fake zods (~zod and ~nec) on our local machine. Each app has the %charlie desk installed, and sends messages to one another, to demonstrate our example.

- The charlie desk consists of three files:
    - `/app/charlie.hoon:`  Where are Gall app actually lives. With some default and modified arms.
    - `/mar/charlie/action.hoon`: Our marks file, which will allow us to convert our poke data to a noun type..
    - `/sur/charlie.hoon`: This is like a header file (??).

- Recall our poke notation. Note that each agent can poke itself, and the other one as well:

```
agent:  %mark  [%action data...]

::add to value stack of zod and nec
charlie:  &charlie-action [%push ~zod 100]
charlie:  &charlie-action [%push ~nec 55]

::remove from value stack
:charlie &charlie-action [%pop ~zod]
```

- Pokes, although simple, pass through our action.hoon mark, before hitting our ++on-poke arm.
- You don't need to import marks into a agent. They are automatically chekced by Clay when it needs to use a mark.

- **A Complication:**  Uribt is functional, so we can't mutate our state. So when we have a state change, the entire agent state must be replaced. This is what the modified `this` statement is for. It can be challenging to get the state back and out, due to the systems type expectaions (!!).


#### Subscriptions:
- Basic unit of a subscription is a path.
- These paths, which are dynamic or static, are usually defined in the `++on-watch` arm.
- The agent will send out updates called `%facts` on one or more path, and all subscribers of the paths will recieve them.
- Agents talk to each other via cards, and cards are run in the order they are recieved.

##### Delta Subscriber and Delta-Follower Example:

- We do not program our agents for pokes or peeks, we only

#### Winds and Pass Cards:

- Gall will only accept %pass and %give types of winds.
- %pass:
    - **passes are unsolicited!**
    - this type of card is used to send a one off request to another agent or vane.
    - your agent initiates the %pass request.
    - Structure:  [%pass  wire  note]
    - **wire:** This is a path, which the agent being queried will send a response back to. Your agent will check what is written at this wire, to see the response (if applicable).
    - **note:** Contains information for the request.
        - Structure  [%agent  %arvo  %pyre]
            - %agent: holds the ship and agent name.
            - %arvo: information request for a particular vane at site.
            - %pyre: used for error info - not needed atm.

#### Tasks:

- There are two catagories of tasks:

1) Subscriptions:

- Both types below are kinds of %pass-es...
- %watch: a type of subscription request. You specify a path, and the distant agent will send updates to this path (much like a wire). 
- %leave: allows you to unsubscribe.

Example: A %pass subscription, is structured as follows:

```
[%pass  /some/wire/...  %agent  [~aship  %some-agent]  %watch  /another/path/...]
```

- card portion: `%pass  /some/wire/...`
- note portion: `%agent  [~aship  %some-agent]`
- task portion: `%watch  /another/path/...`

2) Pokes:

- just a one off message with no expected response from the target.
- the data portion contains a cage which is just a [%mark and vase].
- Example card structure:

```
[%pass  /some/wire/...  %agent  [~aship  %some-agent]  %poke %mark !>(vase data)]

```

### Give Cards:

- gives are solicited. They respond to a request made by another agent or vane. 
- Structure:  [%give  %gift-term  tang]

- There are two main types of give cards:

1) Acknowledgements:

- %watch-ack: a response to a %watch or %watch-as pass request.
- %poke-ack: a response to a %poke or %poke-as request.
- if tang (error packet is null), its a +ve ack. If populated, its a nack.
- Caveat: Gall sends an ack if your agent does not crash when processing a request. So you don't need to send a %watch-ack or %poke-ack.
- Example Request:

```
[%give  %watch-ack  [leaf+"foo"  leaf+"bar"]]
```

2) Subscriptions:

- %fact and %kick must be sent out to existing subscribers - those have have placed a %watch in the past.
- There are also %facts, which are updates sent to subscribers.
- Example Response:

```
[%give  %kick  ~[/some/path  /another] ~some-ship]
```

- Summary Image of Card Types (see below):

![cardtypes](./img/card-diagram.png)


## Lesson 2: More on Agents:

- upper-level (vane) components communicate with moves, while Gall agents communciate with **cards**.
- Recall from last time, two of our unsolicited cards are [%pass wire note] and [%give gift] types. 
    - *notes* are either of type %agent or %arvo. The former is for Gall agents to talk to other gall agents.
    - if we give a gift, this is to poke, ack or kick other agents...


### Pokes and Peeks:

- Pokes are messages to agents (not vanes).
- A peak is a kind of skry: it queries other name spaces for pieces of state data.
-


#### Agent and Arvo Commands in Dojo:

- |pass [%d  %text  "hi world"]: send a note to a vane (here, the Dojo).
- |suspend %gallname - stops an agent, keeps state.
- |nuke - stops an agent, deletes state.
- |rein  - fine grained control?? 
    - |rein  %desk [%.y %agent]  - |revive
    - |rein  %desk [%.n %agent]  - |suspend
- |new-desk  - create a minimalist desk.
    - need to copy a lot of mark and library files to make it to work.
- |merge  %charlie our %base.
    - has all stuff, but larger.
    - can override system (edit desk.bill immedately!). This will superscede your base desk.
    - get agents list:  >+agents  %base)


## Lesson 2: 



==
- how do we get agents to talk to each other? How do we formalize pokes and messages?  Thats what we learned this lesson.
- /sur analogy: They are like structured header files.
- note: if you launch two fake planets on the same machine, they still network through there external star/galaxy! Easiest with galaxies to test agents.
- when adding a new agent + desk to install, remember to change desk.bill first!!
- if we have three ways to fail, we return a unit unit unit cage (!!)

### References:

[1] Agent Types:  https://developers.urbit.org/guides/core/app-school/types
[2] Arvo Overview: https://developers.urbit.org/reference/arvo/overview