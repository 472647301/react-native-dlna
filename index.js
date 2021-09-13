// main index.js

import { NativeModules, NativeEventEmitter } from "react-native";

const { RNDLNA } = NativeModules;

const RNDLNAEmitter = new NativeEventEmitter(RNDLNA);

const EmitterMap = {};

/**
 * 启动服务
 * @param {*} serverName
 */
export function startDLNAService(serverName) {
  if (!RNDLNA.startDLNAService) {
    return;
  }
  RNDLNA.startDLNAService(serverName);
}

/**
 * 停止服务
 */
export function stopDLNAService() {
  if (!RNDLNA.stopDLNAService) {
    return;
  }
  for (let key in EmitterMap) {
    if (EmitterMap[key].remove) {
      EmitterMap[key].remove();
    }
  }
  RNDLNA.stopDLNAService();
}

export function onDlnaStateChange(callback) {
  EmitterMap["DlnaStateChange"] = RNDLNAEmitter.addListener(
    "DlnaStateChange",
    callback
  );
  return EmitterMap["DlnaStateChange"];
}

export function onDlnaMediaInfo(callback) {
  EmitterMap["DlnaMediaInfo"] = RNDLNAEmitter.addListener(
    "DlnaMediaInfo",
    callback
  );
  return EmitterMap["DlnaMediaInfo"];
}
