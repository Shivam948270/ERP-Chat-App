package dao;

import javax.websocket.*;
import javax.websocket.server.ServerEndpoint;
import java.util.concurrent.ConcurrentHashMap;
import java.util.Map;

@ServerEndpoint("/chat")
public class ChatServer {

    private static Map<String, Session> users = new ConcurrentHashMap<>();

    @OnOpen
    public void open(Session session) {
        String query = session.getQueryString();

        if (query == null || !query.contains("=")) return;

        String username = query.split("=")[1].trim();

        users.put(username, session);

        System.out.println(username + " connected");

        broadcast("STATUS|" + username + "|ONLINE");
    }

    @OnClose
    public void onClose(Session session) {

        String removeUser = null;

        for (Map.Entry<String, Session> e : users.entrySet()) {
            if (e.getValue().equals(session)) {
                removeUser = e.getKey();
                break;
            }
        }

        if (removeUser != null) {
            users.remove(removeUser);
            broadcast("STATUS|" + removeUser + "|OFFLINE");
        }
    }

    @OnMessage
    public void onMessage(String message, Session session) {

        try {
            String[] data = message.split("\\|");

            if (data.length < 4) return;

            String type = data[0];
            String sender = data[1];
            String receiver = data[2];
            String msg = data[3];

            MessageDAO.saveMessage(sender, receiver, msg, type);

            // PRIVATE
            if ("PRIVATE".equals(type)) {

                Session r = users.get(receiver);

                if (r != null && r.isOpen()) {

                    r.getBasicRemote().sendText(sender + "|" + msg);

                    MessageDAO.markDelivered(sender, receiver);
                }
            }

            // TYPING
            else if ("TYPING".equals(type)) {

                Session r = users.get(receiver);

                if (r != null && r.isOpen()) {
                    r.getBasicRemote().sendText("TYPING|" + sender);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void broadcast(String msg) {
        for (Session s : users.values()) {
            try {
                if (s.isOpen()) s.getBasicRemote().sendText(msg);
            } catch (Exception e) {}
        }
    }
}
