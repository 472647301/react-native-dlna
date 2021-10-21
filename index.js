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
  RNDLNA.stopDLNAService();
}

export function getAllApps(config) {
  return RNDLNA.getAllApps(config);
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

export const DLNAServiceState = {
  IDLE: "IDLE",
  STARTING: "STARTING",
  RUNNING: "RUNNING",
  STOPPING: "STOPPING",
};

export const DLNAMediaType = {
  TYPE_UNKNOWN: "TYPE_UNKNOWN",
  TYPE_VIDEO: "TYPE_VIDEO",
  TYPE_AUDIO: "TYPE_AUDIO",
  TYPE_IMAGE: "TYPE_IMAGE",
};
