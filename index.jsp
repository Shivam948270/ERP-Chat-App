<%
String user = (String) session.getAttribute("user");
if(user != null){
    response.sendRedirect("chat.jsp");
    return;
}
%>

<!DOCTYPE html>
<html>
<head>
<title>Login</title>

<style>
body {
    margin:0;
    font-family: "Segoe UI";
    height:100vh;
    display:flex;
    justify-content:center;
    align-items:center;
    background: linear-gradient(135deg, #0f172a, #020617);
}

/* CARD */
.card {
    background:#1e293b;
    padding:30px;
    border-radius:10px;
    width:320px;
    color:white;
    box-shadow:0 10px 30px rgba(0,0,0,0.5);
}

/* TITLE */
.card h2 {
    text-align:center;
    margin-bottom:10px;
}

.sub {
    text-align:center;
    font-size:13px;
    color:#94a3b8;
    margin-bottom:20px;
}

/* INPUT */
.inputBox {
    margin:10px 0;
}

.inputBox input {
    width:100%;
    padding:10px;
    border:none;
    border-radius:6px;
    background:#020617;
    color:white;
}

/* BUTTON */
button {
    width:100%;
    padding:10px;
    margin-top:10px;
    border:none;
    border-radius:6px;
    background:#3b82f6;
    color:white;
    cursor:pointer;
}

button:hover {
    background:#2563eb;
}

/* ERROR */
.error {
    color:#ef4444;
    text-align:center;
    margin-bottom:10px;
}

.success {
    color:#22c55e;
    text-align:center;
    margin-bottom:10px;
}

/* LINK */
.link {
    text-align:center;
    margin-top:15px;
    font-size:14px;
}

.link a {
    color:#22c55e;
    text-decoration:none;
}
</style>

</head>

<body>

<div class="card">

    <h2>Welcome Back</h2>
    <div class="sub">Login to continue chatting</div>

    <%
    String error = request.getParameter("error");
    String success = request.getParameter("success");

    if(error != null){
    %>
        <div class="error">Invalid Username or Password</div>
    <%
    }

    if(success != null){
    %>
        <div class="success">Account created successfully</div>
    <%
    }
    %>

    <form action="login.jsp" method="post">

        <div class="inputBox">
            <input name="username" placeholder="Username" required autocomplete="off">
        </div>

        <div class="inputBox">
            <input type="password" name="password" placeholder="Password" required>
        </div>

        <button type="submit">Login</button>
    </form>

    <div class="link">
        New user? <a href="register.jsp">Create Account</a>
    </div>

</div>

</body>
</html>
