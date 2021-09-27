// main index.js

import { NativeModules, NativeEventEmitter, Platform } from "react-native";

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
  RNDLNA.stopDLNAService();
}

export function getAllApps(config) {
  if (Platform.OS === "ios") {
    return RNDLNA.getAllApps(config);
  } else {
    return RNDLNA.getAllApps();
  }
}

export function startApp(packageName) {
  RNDLNA.startApp(packageName);
}

export function onDlnaStateChange(callback) {
  if (!RNDLNAEmitter || !RNDLNAEmitter.addListener) {
    return;
  }
  EmitterMap["DlnaStateChange"] = RNDLNAEmitter.addListener(
    "DlnaStateChange",
    callback
  );
  return EmitterMap["DlnaStateChange"];
}

export function onDlnaMediaInfo(callback) {
  if (!RNDLNAEmitter || !RNDLNAEmitter.addListener) {
    return;
  }
  EmitterMap["DlnaMediaInfo"] = RNDLNAEmitter.addListener(
    "DlnaMediaInfo",
    callback
  );
  return EmitterMap["DlnaMediaInfo"];
}

export function getDLNAState() {
  if (!RNDLNA.getDLNAState) {
    return;
  }
  return RNDLNA.getDLNAState();
}