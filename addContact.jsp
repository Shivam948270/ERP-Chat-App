<%@page import="dao.ContactDAO"%>

<%
String user = (String)session.getAttribute("user");
String friend = request.getParameter("friend");

if(user != null && friend != null && !friend.trim().isEmpty()){
    ContactDAO.addContact(user, friend.trim());
}
%>
