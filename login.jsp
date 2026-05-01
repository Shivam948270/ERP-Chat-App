<%@page import="dao.LoginDAO"%>

<%
String u = request.getParameter("username");
String p = request.getParameter("password");

// VALIDATION
if(u == null || p == null || u.trim().isEmpty() || p.trim().isEmpty()){
    response.sendRedirect("index.jsp?error=1");
    return;
}

u = u.trim().toLowerCase();
p = p.trim();

// CHECK USER
String role = LoginDAO.validateUser(u, p);

if(role != null){

    session.setAttribute("user", u);
    session.setAttribute("role", role);

    session.setMaxInactiveInterval(60 * 30); // 30 min

    response.sendRedirect("chat.jsp");

} else {
    response.sendRedirect("index.jsp?error=1");
}
%>
