package com.chat;
import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.util.*;

@ServerEndpoint("/chat")
public class ChatServer {
    static Map<String,Session> users=new HashMap<>();

    @OnOpen
    public void open(Session s){
        String u=s.getQueryString().split("=")[1];
        users.put(u,s);
    }

    @OnMessage
    public void msg(String m,Session s) throws Exception{
        String[] d=m.split("\\|");
        MessageDAO.saveMessage(d[0],d[1],d[2]);
        if(users.get(d[1])!=null)
            users.get(d[1]).getBasicRemote().sendText(d[0]+": "+d[2]);
    }

    @OnClose
    public void close(Session s){
        users.values().remove(s);
    }
}
