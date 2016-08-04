import { createAction } from 'redux-actions'

export const NAME = 'UPDATE_NAME'
export const WAIT = 'SET_WAIT'

export const setName = createAction(NAME, name => name)
export const setWait = createAction(WAIT)
