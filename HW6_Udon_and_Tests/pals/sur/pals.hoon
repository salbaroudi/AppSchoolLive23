::  pals: manual neighboring
::
|%
+$  records  ::  local state
:: a ship is probably just an @p
  $:  outgoing=(jug ship @ta)  :: A jug is a map of sets, from key -> sets/
      incoming=(set ship)  :: a set of ships
    ::
      ::  receipts: for all outgoing, status
      ::
      ::    if ship not in receipts,  poke awaiting ack
      ::    if ship present as true,  poke acked positively
      ::    if ship present as false, poke acked negatively  
      ::
      receipts=(map ship ?)
  ==
::
+$  gesture  ::  to/from others
  $%  [%hey ~]
      [%bye ~]
  ==
:: Meet is an outgoing request for a target. Part is to cancel it.
+$  command  ::  from ourselves
  $%  [%meet =ship in=(set @ta)]  ::  empty set allowed
      [%part =ship in=(set @ta)]  ::  empty set implies un-targeting
  ==
::
+$  effect  ::  to ourselves
  $%  target-effect
      leeche-effect
  ==
::  Why are the heys and buys sub-typed based on target and leech?
+$  target-effect 
  $%  [%meet =ship]  ::  hey to target
      [%part =ship]  ::  bye to target
  ==
::
+$  leeche-effect
  $%  [%near =ship]  ::  hey from leeche
      [%away =ship]  ::  bye from leeche
  ==
--
