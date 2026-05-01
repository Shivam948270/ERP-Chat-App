<%@page import="java.util.*"%>
<%@page import="dao.MessageDAO"%>

<%
String u1 = request.getParameter("u1");
String u2 = request.getParameter("u2");

int offset = 0;

try {
    offset = Integer.parseInt(request.getParameter("offset"));
} catch(Exception e){}

response.setContentType("application/json");

List<String> msgs = MessageDAO.getMessagesPaginated(u1, u2, offset);

StringBuilder json = new StringBuilder("[");

for(int i=0;i<msgs.size();i++){

    String[] p = msgs.get(i).split("\\|");

    json.append("{\"sender\":\"")
        .append(p[0])
        .append("\",\"msg\":\"")
        .append(p[1])
        .append("\"}");

    if(i < msgs.size()-1) json.append(",");
}

json.append("]");

out.print(json.toString());
%>
