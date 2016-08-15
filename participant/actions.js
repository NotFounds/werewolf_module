import { createAction } from 'redux-actions'

export const NAME    = 'UPDATE_NAME'
export const WAIT    = 'SET_WAIT'
export const VOTE    = 'VOTE'
export const OPTION  = 'GET_OPTIONAL_DATA'
export const ABILITY = 'ABILITY'
export const CHECKED = 'CHECKED'
export const RESULT  = 'GET_RESULT'

export const setWait         = createAction(WAIT)
export const setName         = createAction(NAME, name => name)
export const vote            = createAction(VOTE, vote => vote)
export const ability         = createAction(ABILITY, ability => ability)
export const getOptionalData = createAction(OPTION)
export const check           = createAction(CHECKED)
export const getResult       = createAction(RESULT)
