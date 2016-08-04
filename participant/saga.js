import { take, put, fork, select, call } from 'redux-saga/effects'
import { NAME, WAIT } from './actions'

function* setNameSaga() {
  const { payload } = yield take(NAME)
  yield call(sendData, 'set_name', payload)
}

function* setWaitSaga() {
  const { payload } = yield take(WAIT)
  yield call(sendData, 'set_wait')
}

function* saga() {
  yield fork(setNameSaga)
  yield fork(setWaitSaga)
}

export default saga
