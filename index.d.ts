import { EmitterSubscription } from "react-native";

export declare enum DLNAServiceState {
  IDLE = "IDLE",
  STARTING = "STARTING",
  RUNNING = "RUNNING",
  STOPPING = "STOPPING",
}

export declare enum DLNAMediaType {
  TYPE_UNKNOWN = "TYPE_UNKNOWN",
  TYPE_VIDEO = "TYPE_VIDEO",
  TYPE_AUDIO = "TYPE_AUDIO",
  TYPE_IMAGE = "TYPE_IMAGE",
}

type StateChangeCallback = (data: { state: DLNAServiceState }) => void;
type MediaInfoCallback = (data: {
  url: string;
  title: string;
  mediaType: DLNAMediaType;
  albumArtURI: string;
}) => void;

/**
 * 启动服务
 */
export declare function startDLNAService(serverName: string): void;
/**
 * 停止服务
 */
export declare function stopDLNAService(): void;
export declare function onDlnaStateChange(
  callback: StateChangeCallback
): EmitterSubscription;
export declare function onDlnaMediaInfo(
  callback: MediaInfoCallback
): EmitterSubscription;
export declare function getAllApps(params?: {
  [key: string]: string;
}): Promise<{
  [key: string]: string;
}>;
export declare function startApp(packageName: string): void;
export declare function getDLNAState(): Promise<DLNAServiceState>;