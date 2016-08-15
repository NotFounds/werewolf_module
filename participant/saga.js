import { take, put, fork, select, call } from 'redux-saga/effects'
import { NAME, WAIT, VOTE, OPTION, ABILITY, CHECKED, RESULT } from './actions'

function* setNameSaga() {
  while (true) {
    const { payload } = yield take(NAME)
    yield call(sendData, 'set_name', payload)
  }
}

function* setWaitSaga() {
  while (true) {
    const { payload } = yield take(WAIT)
    yield call(sendData, 'set_wait')
  }
}

function* voteSaga() {
  while (true) {
    const { payload } = yield take(VOTE)
    yield call(sendData, 'vote', payload)
  }
}

function* getOptionSaga() {
  while (true) {
    const { payload } = yield take(OPTION)
    yield call(sendData, 'fetch_option')
  }
}

function* abilitySaga() {
  while (true) {
    const { payload } = yield take(ABILITY)
    yield call(sendData, 'ability', payload)
  }
}

function* checkedSaga() {
  while (true) {
    const { payload } = yield take(CHECKED)
    yield call(sendData, 'checked')
  }
}

function* getResultSaga() {
  while (true) {
    const { payload } = yield take(RESULT)
    yield call(sendData, 'result')
  }
}

function* saga() {
  yield fork(setNameSaga)
  yield fork(setWaitSaga)
  yield fork(voteSaga)
  yield fork(getOptionSaga)
  yield fork(abilitySaga)
  yield fork(checkedSaga)
  yield fork(getResultSaga)
}

export default saga
