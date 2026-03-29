package com.chat;
import java.sql.*;
public class MessageDAO {
    public static void saveMessage(String s,String r,String m){
        try{
            Connection c=DBConnection.getConnection();
            PreparedStatement ps=c.prepareStatement("insert into messages(sender,receiver,message) values(?,?,?)");
            ps.setString(1,s); ps.setString(2,r); ps.setString(3,m);
            ps.executeUpdate();
        }catch(Exception e){e.printStackTrace();}
    }
}
