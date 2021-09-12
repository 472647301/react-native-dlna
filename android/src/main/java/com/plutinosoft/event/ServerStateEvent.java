package com.plutinosoft.event;

import com.plutinosoft.instance.ServerInstance;

/**
 * Created by huzongyao on 2018/6/11.
 * to send the server status from work thread
 */

public class ServerStateEvent {

    private ServerInstance.State state;

    public ServerStateEvent(ServerInstance.State mState) {
        this.state = mState;
    }

    public ServerInstance.State getState() {
        return state;
    }

    public void setState(ServerInstance.State state) {
        this.state = state;
    }
}
