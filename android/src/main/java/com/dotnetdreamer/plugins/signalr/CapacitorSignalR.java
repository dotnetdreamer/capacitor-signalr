package com.dotnetdreamer.plugins.signalr;

import com.getcapacitor.Logger;

public class CapacitorSignalR {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
