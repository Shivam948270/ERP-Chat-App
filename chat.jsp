<%
String u=request.getParameter("username");
%>
<h3><%=u%></h3>
<input id="r" placeholder="receiver">
<div id="box"></div>
<input id="m">
<button onclick="s()">Send</button>

<script>
let ws=new WebSocket("ws://localhost:8080/ERP-Chat-App/chat?username=<%=u%>");
ws.onmessage=e=>box.innerHTML+= "<div>"+e.data+"</div>";
function s(){
ws.send("<%=u%>|"+r.value+"|"+m.value);
}
</script>
