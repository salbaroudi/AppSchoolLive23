::Import tests
/+  *test
:: We import and agent and run a new instance of it. We don't worry about past state or mutation effects.
:: So our tests will not sporadically fail.  Also note: for each arm run, we recompile the bowl and agent. 
:: So an earlier test setup does not affect later tests.
/=  agent  /app/delta  
|%
::without this, our core has no idea what "state" is. We need to define a structure.
+$  state   
    $:  [%0 values=(list @)]
    ==
++  bowl  ::artificial bowl to be fed into our tests.
  |=  run=@ud
  ^-  bowl:gall
  :*  [~zod ~zod %delta ~]  ::note this needed to be modified (extra sig here)
    [~ ~ ~] ::and here for this to work. the HW notes are not correct.
    [run `@uvJ`(shax run) (add (mul run ~s1) *time) [~zod %delta ud+run]]
  ==
++  test-delta-one  
  =|  run=@ud
  =^  move  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 10.000]))
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  `(list @)`~[10.000]
    !>  values.state
++  test-delta-two
  =|  run=@ud
  =^  move  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 10.000]))
  =^  move2  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 20.000]))
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  `(list @)`~[20.000 10.000]
    !>  values.state
++  test-delta-sig  ::empty case
  =|  run=@ud
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  `(list @)`~
    !>  values.state
++  test-delta-push-pop-a-lot ::do many operations, see what happens.
  =|  run=@ud
  =^  push1  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 10.000]))
  =^  push2  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 20.000]))
  =^  pop  agent  (~(on-poke agent (bowl run)) %delta-action !>([%pop ~zod]))
  =^  push3  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 30.000]))
  =^  push4  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 40.000]))
  =^  pop  agent  (~(on-poke agent (bowl run)) %delta-action !>([%pop ~zod]))
  =^  push5  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 50.000]))
  =^  push6  agent  (~(on-poke agent (bowl run)) %delta-action !>([%push ~zod 60.000]))
  =^  pop  agent  (~(on-poke agent (bowl run)) %delta-action !>([%pop ~zod]))
  =+  !<(=state on-save:agent)
  %+  expect-eq
    !>  `(list @)`~[50.000 30.000 10.000]
    !>  values.state
--