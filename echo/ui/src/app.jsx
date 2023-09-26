import React, { useEffect, useState, useReducer } from 'react'
import Urbit from '@urbit/http-api'
import { AppTile } from './components/AppTile'

const api = new Urbit( '', '', window.desk )
api.ship = window.ship


//This is used to update our global store stack. Its just an array of values in the end.
//
function reducer( state, action ) {
  let newState = [ ...state ]
  switch ( action.type ) {
    case 'init':  //initialize
      return action.init
    case 'push':
      newState.unshift(action.val)
      return newState
    case 'pop':
      newState.shift()
      return newState
    default:
      return state
  }
}

export function App() {
  const [ state, dispatch ] = useReducer( reducer, [] )
  const [ inputValue, setInputValue ] = useState( "" ) 
  const [ inputShip, setInputShip ] = useState( "zod" )


  useEffect(() => {
    async function init() {  //we send an subscription request to api. handleUpdate is our event handler.
      api.subscribe( { app:"echo", path: '/values', event: handleUpdate } )
    }
    init()
  }, [] ) //notice that we are using an IIFE, and our stack is initially empty.


  const handleUpdate = ( upd ) => {
    if ( 'init' in upd ) {
      dispatch({type:'init', init:upd.init})
    }
    else if ( 'push' in upd ) {
      dispatch({type:'push', val:upd.push.value})
    }
    else if ( 'pop' in upd ) {
      dispatch( { type:'pop' } )
    }
  }

  const push = () => {
    const val = parseInt( inputValue )
    if ( isNaN( val ) ) return
    api.poke( {
      app: 'echo',
      mark: 'echo-action',
      json: { push: { target:`~${window.ship}`, value:val } }
    } )
    setInputValue( "" )
  }

  const pop = () => {
    api.poke( {
      app: 'echo',
      mark: 'echo-action',
      json: { pop: `~${window.ship}` }
    } )
  }

  const poke = () => {
    const shipname = inputShip
    if (shipname == "") return
    console.log("Shipname = " + shipname + "and window.ship =" + window.ship)
    api.poke( {
      app: 'echo',
      mark: 'echo-action',
      json: { pop: `~${shipname}` }
    } )
    setInputShip( "" )
  }

  return (
    <main className="flex flex-col items-center justify-center min-h-screen">
      <input style={{width:200}} className='border' type='text' value={inputValue} onChange={(e) => setInputValue(e.target.value)}/>
      <div>
        <button onClick={() => push()} style={{width:100}} className='border p-2 text-black-400'>Push</button>
        <button onClick={() => pop()} style={{width:100}} className='border p-2 text-black-400'>Pop</button>
        <p>Our stack</p>
        {state.map((eachValue, index) => {
          return (<li key={index}>{eachValue}</li>)
        })}
      </div>
      <br />
      <h3> Poke Request:</h3>
      <input style={{width:200}}  className='border' type='text' value={inputShip} onChange={(e) => setInputShip(e.target.value)}/>
      <button onClick={() => poke()} style={{width:100}} className='border p-2 text-black-400'>Poke Ship!</button>


    </main>
  )
}

export default App;