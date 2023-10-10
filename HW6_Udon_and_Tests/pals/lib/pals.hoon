::  pals: manual peer discovery
:: This library is mainly an external interface for scrying into pals.
/-  *pals
::
|_  bowl:gall
++  records                        (s ^records /)  ::get all the records
++  leeches                        (s (set ship) /leeches) :: get all the leeches
++  targets  |=  list=@ta          (s (set ship) %targets ?~(list / /[list])) 
++  mutuals  |=  list=@ta          (s (set ship) %mutuals ?~(list / /[list]))
++  leeche   |=  =ship             (s _| /leeches/(scot %p ship))  ::is a ship a leech
++  target   |=  [list=@ta =ship]  (s _| /mutuals/[list]/(scot %p ship))
++  mutual   |=  [list=@ta =ship]  (s _| /mutuals/[list]/(scot %p ship))
::
++  labels   ?.  running  `(set @ta)`~
             ~(key by dir:.^(arch %gy (snoc base %targets)))
::
++  base     ~+  `path`/(scot %p our)/pals/(scot %da now)
++  running  ~+  .^(? %gu (snoc base %$))
::This is a gate that performs scries for us. The
++  s  ::this is a wet gate...our argument is not of a strict type (!!)
  |*  [=mold =path]  ~+
  ?.  running  *mold
  .^(mold %gx (weld base (snoc `^path`path %noun)))
--