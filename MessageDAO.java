package dao;

import java.sql.*;
import java.util.*;

public class MessageDAO {

    // 🔹 SAVE MESSAGE (WITH STATUS)
//    public static void saveMessage(String sender, String receiver, String message, String type) {
//
//        try (Connection con = DBConnection.getConnection()) {
//
//            String sql = "INSERT INTO messages(sender, receiver, message, type, status) VALUES (?, ?, ?, ?, 'SENT')";
//            PreparedStatement ps = con.prepareStatement(sql);
//
//            ps.setString(1, sender);
//            ps.setString(2, receiver);
//            ps.setString(3, message);
//            ps.setString(4, type);
//
//            ps.executeUpdate();
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    // 🔹 GET CHAT HISTORY (PRIVATE)
    public static List<String> getMessages(String u1, String u2) {

        List<String> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT sender, message FROM messages " +
                "WHERE type='PRIVATE' AND " +
                "((sender=? AND receiver=?) OR (sender=? AND receiver=?)) " +
                "ORDER BY timestamp";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, u1);
            ps.setString(2, u2);
            ps.setString(3, u2);
            ps.setString(4, u1);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(rs.getString("sender") + "|" + rs.getString("message"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 🔹 UPDATE STATUS BY ID (SAFE)
    public static void updateStatusById(int id, String status) {

        try (Connection con = DBConnection.getConnection()) {

            String sql = "UPDATE messages SET status=? WHERE id=?";
            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, status);
            ps.setInt(2, id);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 🔹 MARK MESSAGES AS SEEN
//    public static void markAsSeen(String user, String other) {
//
//        try (Connection con = DBConnection.getConnection()) {
//
//            String sql =
//                "UPDATE messages SET status='SEEN' " +
//                "WHERE sender=? AND receiver=? AND status!='SEEN'";
//
//            PreparedStatement ps = con.prepareStatement(sql);
//
//            ps.setString(1, other);
//            ps.setString(2, user);
//
//            ps.executeUpdate();
//
//        } catch (Exception e) {
//            e.printStackTrace();
//        }
//    }

    // 🔹 CONTACTS (SIMPLE)
    public static List<String> getContacts(String user) {

        List<String> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT DISTINCT " +
                "CASE WHEN sender=? THEN receiver ELSE sender END AS contact " +
                "FROM messages WHERE sender=? OR receiver=?";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user);
            ps.setString(2, user);
            ps.setString(3, user);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(rs.getString("contact"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 🔥 🔹 CONTACTS WITH LAST MESSAGE + UNREAD COUNT
    public static List<String> getContactsWithInfo(String user) {

        List<String> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT " +
                "CASE WHEN sender=? THEN receiver ELSE sender END AS contact, " +
                "MAX(timestamp) as last_time " +
                "FROM messages " +
                "WHERE sender=? OR receiver=? " +
                "GROUP BY contact " +
                "ORDER BY last_time DESC";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user);
            ps.setString(2, user);
            ps.setString(3, user);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {

                String contact = rs.getString("contact");

                // 🔹 LAST MESSAGE
                String lastMsg = "";
                PreparedStatement ps2 = con.prepareStatement(
                    "SELECT message FROM messages " +
                    "WHERE ((sender=? AND receiver=?) OR (sender=? AND receiver=?)) " +
                    "ORDER BY timestamp DESC LIMIT 1"
                );

                ps2.setString(1, user);
                ps2.setString(2, contact);
                ps2.setString(3, contact);
                ps2.setString(4, user);

                ResultSet rs2 = ps2.executeQuery();

                if (rs2.next()) {
                    lastMsg = rs2.getString("message");
                }

                // 🔹 UNREAD COUNT
                int unread = 0;
                PreparedStatement ps3 = con.prepareStatement(
                    "SELECT COUNT(*) FROM messages " +
                    "WHERE sender=? AND receiver=? AND status='SENT'"
                );

                ps3.setString(1, contact);
                ps3.setString(2, user);

                ResultSet rs3 = ps3.executeQuery();

                if (rs3.next()) {
                    unread = rs3.getInt(1);
                }

                list.add(contact + "|" + lastMsg + "|" + unread);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 🔹 GROUP CHAT HISTORY
    public static List<String> getGroupMessages() {

        List<String> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT sender, message FROM messages " +
                "WHERE type='GROUP' ORDER BY timestamp";

            PreparedStatement ps = con.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(rs.getString("sender") + "|" + rs.getString("message"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 🔹 SUPPORT CHAT
    public static List<String> getSupportMessages(String user) {

        List<String> list = new ArrayList<>();

        try (Connection con = DBConnection.getConnection()) {

            String sql =
                "SELECT sender, message FROM messages " +
                "WHERE type='SUPPORT' AND (sender=? OR receiver=?) " +
                "ORDER BY timestamp";

            PreparedStatement ps = con.prepareStatement(sql);

            ps.setString(1, user);
            ps.setString(2, user);

            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                list.add(rs.getString("sender") + "|" + rs.getString("message"));
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }
    public static List<String> getAllUsers(String currentUser){

    List<String> list = new ArrayList<>();

    try(Connection con = DBConnection.getConnection()){

        String sql = "SELECT username FROM users WHERE username != ?";

        PreparedStatement ps = con.prepareStatement(sql);
        ps.setString(1, currentUser);

        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            list.add(rs.getString("username") + "| |0"); 
            // empty lastMsg + unread
        }

    }catch(Exception e){
        e.printStackTrace();
    }

    return list;
}
    // SAVE MESSAGE
public static void saveMessage(String sender, String receiver, String message, String type) {

    try (Connection con = DBConnection.getConnection()) {

        String sql = "INSERT INTO messages(sender, receiver, message, type, status) VALUES (?, ?, ?, ?, 'SENT')";
        PreparedStatement ps = con.prepareStatement(sql);

        ps.setString(1, sender);
        ps.setString(2, receiver);
        ps.setString(3, message);
        ps.setString(4, type);

        ps.executeUpdate();

    } catch (Exception e) {
        e.printStackTrace();
    }
}
public static List<String> search(String user, String key){

    List<String> list = new ArrayList<>();

    try(Connection con = DBConnection.getConnection()){

        PreparedStatement ps = con.prepareStatement(
            "SELECT sender,message FROM messages WHERE message LIKE ? AND (sender=? OR receiver=?)"
        );

        ps.setString(1, "%" + key + "%");
        ps.setString(2, user);
        ps.setString(3, user);

        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            list.add(rs.getString(1) + "|" + rs.getString(2));
        }

    }catch(Exception e){}

    return list;
}
public static List<String> getMessagesPaginated(String u1, String u2, int offset){

    List<String> list = new ArrayList<>();

    try(Connection con = DBConnection.getConnection()){

        PreparedStatement ps = con.prepareStatement(
            "SELECT sender,message FROM messages " +
            "WHERE ((sender=? AND receiver=?) OR (sender=? AND receiver=?)) " +
            "ORDER BY created_at DESC LIMIT 20 OFFSET ?"
        );

        ps.setString(1, u1);
        ps.setString(2, u2);
        ps.setString(3, u2);
        ps.setString(4, u1);
        ps.setInt(5, offset);

        ResultSet rs = ps.executeQuery();

        while(rs.next()){
            list.add(rs.getString(1) + "|" + rs.getString(2));
        }

    }catch(Exception e){}

    return list;
}
// DELIVERED
public static void markDelivered(String sender, String receiver) {

    try (Connection con = DBConnection.getConnection()) {

        String sql = "UPDATE messages SET status='DELIVERED' WHERE sender=? AND receiver=? AND status='SENT'";
        PreparedStatement ps = con.prepareStatement(sql);

        ps.setString(1, sender);
        ps.setString(2, receiver);

        ps.executeUpdate();

    } catch (Exception e) {}
}

// SEEN
public static void markAsSeen(String user, String other) {

    try (Connection con = DBConnection.getConnection()) {

        String sql = "UPDATE messages SET status='SEEN' WHERE sender=? AND receiver=?";
        PreparedStatement ps = con.prepareStatement(sql);

        ps.setString(1, other);
        ps.setString(2, user);

        ps.executeUpdate();

    } catch (Exception e) {}
}
}
