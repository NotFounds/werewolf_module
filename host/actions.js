import { createAction } from 'redux-actions'

export const START   = 'START'
export const DESTROY = 'DESTROY'
export const MATCH   = 'DO_MATCH'
export const ROLE    = 'SET_ROLE'

export const start      = createAction(START)
export const destroy    = createAction(DESTROY)
export const doMatching = createAction(MATCH)
export const setRole    = createAction(ROLE)
