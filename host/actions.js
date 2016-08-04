import { createAction } from 'redux-actions'

export const MATCH = 'DO_MATCH'
export const ROLE  = 'SET_ROLE'

export const doMatching = createAction(MATCH)
export const setRole    = createAction(ROLE)
