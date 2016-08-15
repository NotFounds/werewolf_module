import { createAction } from 'redux-actions'

export const START   = 'START'
export const DESTROY = 'DESTROY'
export const MATCH   = 'DO_MATCH'
export const ROLE    = 'SET_ROLE'
export const NAME    = 'SET_VILLAGE_NAME'
export const SKIP    = 'SKIP_MEETING'

export const start      = createAction(START)
export const destroy    = createAction(DESTROY)
export const doMatching = createAction(MATCH)
export const setRole    = createAction(ROLE)
export const setName    = createAction(NAME)
export const skip       = createAction(SKIP)
