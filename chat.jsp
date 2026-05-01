<%
    String u = (String) session.getAttribute("user");
    if (u == null) {
        response.sendRedirect("index.jsp");
        return;
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Chat</title>

        <style>
            body {
                margin:0;
                font-family: Arial;
                display:flex;
                height:100vh;
            }

            /* LEFT SIDEBAR */
            #users {
                width:300px;
                background:#111;
                color:white;
                overflow-y:auto;
            }

            .user {
                padding:12px;
                border-bottom:1px solid #222;
                cursor:pointer;
            }

            .user:hover {
                background:#222;
            }

            .active {
                background:#333 !important;
            }

            .name {
                font-weight:bold;
            }

            .last {
                font-size:12px;
                color:#aaa;
            }

            .unread {
                float:right;
                background:red;
                border-radius:50%;
                padding:3px 7px;
                font-size:12px;
            }

            /* RIGHT CHAT */
            #chat {
                flex:1;
                display:flex;
                flex-direction:column;
            }

            #header {
                background:#3b82f6;
                color:white;
                padding:12px;
            }

            #box {
                flex:1;
                padding:10px;
                overflow:auto;
                background:#ece5dd;
            }

            /* MESSAGE */
            .msg {
                padding:8px 12px;
                margin:6px;
                border-radius:10px;
                max-width:60%;
            }

            .me {
                background:#3b82f6;
                color:white;
                margin-left:auto;
            }

            .other {
                background:white;
            }

            /* BOTTOM */
            #bottom {
                display:flex;
                padding:10px;
                background:#ddd;
            }

            #bottom input {
                padding:8px;
                margin-right:5px;
            }

            #m {
                flex:1;
            }

            button {
                padding:8px 12px;
            }
        </style>

    </head>

    <body>

        <!-- CONTACT LIST -->
        <div id="users"></div>
        <input id="addUser" placeholder="Add user">
<button onclick="addContact()">Add</button>

        <!-- CHAT AREA -->
        <div id="chat">

            <div id="header">
                <span id="chatUser">Select user</span>
                | <%=u%> 
                | <a href="logout.jsp" style="color:white;">Logout</a>
            </div>

            <div id="box"></div>

            <div id="bottom">
                <input id="r" readonly placeholder="receiver">
                <input id="m" placeholder="message">
                <button onclick="sendMsg()">Send</button>
            </div>

        </div>
        <script>
function addContact(){

    let friend = document.getElementById("addUser").value;

    fetch("addContact.jsp?friend=" + friend)
        .then(() => {
            loadContacts();
            document.getElementById("addUser").value = "";
        });
}
            let currentUser = "<%=u%>";
            let selectedUser = null;
            let offset = 0;

            let ws = new WebSocket("ws://localhost:8080/ERP-Chat/chat?username=" + currentUser);
            let box = document.getElementById("box");

        // ? ADD MESSAGE
            function addMsg(sender, msg) {

                let d = document.createElement("div");
                d.className = "msg " + (sender === currentUser ? "me" : "other");

                d.innerText = sender + ": " + msg;

                box.appendChild(d);
                box.scrollTop = box.scrollHeight;
            }

        // ? LOAD CONTACTS
            function loadContacts() {

                fetch("contacts.jsp")
                        .then(r => r.text())
                        .then(data => {

                            let usersDiv = document.getElementById("users");
                            usersDiv.innerHTML = "";

                            data.split(",").forEach(item => {

                                if (!item.trim())
                                    return;

                                let parts = item.split("|");

                                let name = parts[0];
                                let last = parts[1] || "";
                                let unread = parts[2] || 0;

                                if (name === currentUser)
                                    return;

                                let div = document.createElement("div");
                                div.className = "user";

                                if (name === selectedUser) {
                                    div.classList.add("active");
                                }

                                let nameDiv = document.createElement("div");
                                nameDiv.className = "name";
                                nameDiv.textContent = name;

                                if (unread > 0) {
                                    let span = document.createElement("span");
                                    span.className = "unread";
                                    span.textContent = unread;
                                    nameDiv.appendChild(span);
                                }

                                div.onclick = () => selectUser(name);

                                usersDiv.appendChild(div);
                            });
                        });
            }

        // ? SELECT USER
            function selectUser(user) {

                selectedUser = user;
                offset = 0;

                document.getElementById("r").value = user;
                document.getElementById("chatUser").innerText = user;

                box.innerHTML = "";

                loadMessages();

                // mark seen
                fetch("markSeen.jsp?u1=" + currentUser + "&u2=" + user);

                loadContacts();
            }

        // ? LOAD MESSAGES (PAGINATION)
            function loadMessages() {

                fetch("history.jsp?u1=" + currentUser + "&u2=" + selectedUser + "&offset=" + offset)
                        .then(r => r.json())
                        .then(arr => {

                            arr.reverse().forEach(m => {
                                addMsg(m.sender, m.msg);
                            });

                        });
            }

        // ? SCROLL LOAD MORE
            box.addEventListener("scroll", () => {

                if (box.scrollTop === 0 && selectedUser) {

                    offset += 20;

                    fetch("history.jsp?u1=" + currentUser + "&u2=" + selectedUser + "&offset=" + offset)
                            .then(r => r.json())
                            .then(arr => {

                                arr.reverse().forEach(m => {

                                    let d = document.createElement("div");
                                    d.className = "msg " + (m.sender === currentUser ? "me" : "other");

                                    d.innerText = m.sender + ": " + m.msg;

                                    box.prepend(d);
                                });

                            });
                }
            });

        // ? RECEIVE MESSAGE
            ws.onmessage = e => {

                let data = e.data;

                // STATUS (ignore or use later)
                if (data.startsWith("STATUS|")) {
                    return;
                }

                // TYPING
                if (data.startsWith("TYPING|")) {
                    let user = data.split("|")[1];

                    document.getElementById("typing").innerText = user + " typing...";

                    setTimeout(() => {
                        document.getElementById("typing").innerText = "";
                    }, 1500);

                    return;
                }

                let parts = data.split("|");

                if (parts.length === 2) {

                    let sender = parts[0];
                    let msg = parts[1];

                    // show only if active chat
                    if (sender === selectedUser || sender === currentUser) {
                        addMsg(sender, msg);
                    }

                    loadContacts();
                }
            };

        // ? SEND MESSAGE
            function sendMsg() {

                let r = document.getElementById("r").value.trim();
                let m = document.getElementById("m").value.trim();

                if (!r) {
                    alert("Select user");
                    return;
                }

                if (!m) {
                    alert("Enter message");
                    return;
                }

                ws.send("PRIVATE|" + currentUser + "|" + r + "|" + m);

                addMsg(currentUser, m);

                document.getElementById("m").value = "";
            }

        // ? TYPING EVENT
            document.getElementById("m").addEventListener("input", () => {

                let r = document.getElementById("r").value;

                if (r) {
                    ws.send("TYPING|" + currentUser + "|" + r + "|x");
                }
            });

        // ? AUTO LOAD CONTACTS
            setInterval(loadContacts, 3000);
            window.onload = loadContacts;

        </script>

        <div id="typing" style="padding:5px;color:gray;"></div>
        <!--        <script>
        
                    let currentUser = "<%=u%>";
                    let selectedUser = null;
        
                    let ws = new WebSocket("ws://localhost:8080/ERP-Chat/chat?username=" + currentUser);
                    let box = document.getElementById("box");
        
                // ? ADD MESSAGE
                    function addMsg(sender, msg) {
        
                        let d = document.createElement("div");
                        d.className = "msg " + (sender === currentUser ? "me" : "other");
        
                        d.innerText = (sender === currentUser ? "Me: " : sender + ": ") + msg;
        
                        box.appendChild(d);
                        box.scrollTop = box.scrollHeight;
                    }
        
                // ? LOAD CONTACTS
                    function loadContacts() {
        
                        fetch("contacts.jsp")
                                .then(r => r.text())
                                .then(data => {
        
                                    let usersDiv = document.getElementById("users");
                                    usersDiv.innerHTML = "";
        
                                    data.split(",").forEach(item => {
        
                                        if (!item || item.trim() === "")
                                            return;
        
                                        let parts = item.split("|");
        
                                        let name = parts[0];
                                        let last = parts[1] || "";
                                        let unread = parts[2] || 0;
        
                                        if (name === currentUser)
                                            return;
        
                                        let div = document.createElement("div");
                                        div.className = "user";
        
                                        if (name === selectedUser) {
                                            div.classList.add("active");
                                        }
                                        let nameDiv = document.createElement("div");
                                        nameDiv.className = "name";
                                        nameDiv.textContent = "? " + name;
        
                                        if (unread > 0) {
                                            let span = document.createElement("span");
                                            span.className = "unread";
                                            span.textContent = unread;
                                            nameDiv.appendChild(span);
                                        }
        
                                        let lastDiv = document.createElement("div");
                                        lastDiv.className = "last";
                                        lastDiv.textContent = last;
        
                                        div.appendChild(nameDiv);
                                        div.appendChild(lastDiv);
        
                                        div.onclick = () => selectUser(name);
        
                                        usersDiv.appendChild(div);
                                    });
                                });
                    }
        
                // ? SELECT USER
                    function selectUser(user) {
        
                        selectedUser = user;
                        document.getElementById("r").value = user;
                        document.getElementById("chatUser").innerText = user;
        
                        box.innerHTML = "";
        
                        fetch("history.jsp?u1=" + currentUser + "&u2=" + user)
                                .then(r => r.json())
                                .then(arr => {
        
                                    arr.forEach(m => {
                                        addMsg(m.sender, m.msg);
                                    });
        
                                });
        
                        fetch("markSeen.jsp?u1=" + currentUser + "&u2=" + user);
        
                        loadContacts();
                    }
        
                // ? RECEIVE MESSAGE
                    ws.onmessage = e => {
        
                        let parts = e.data.split("|");
        
                        if (parts.length === 2) {
        
                            let sender = parts[0];
                            let msg = parts[1];
        
                            // only show if chat open
                            if (sender === selectedUser || sender === currentUser) {
                                addMsg(sender, msg);
                            }
                        }
        
                        loadContacts();
                    };
        
                // ? SEND
                    function sendMsg() {
        
                        let r = document.getElementById("r").value.trim();
                        let m = document.getElementById("m").value.trim();
        
                        if (!r) {
                            alert("Select user");
                            return;
                        }
        
                        if (!m) {
                            alert("Enter message");
                            return;
                        }
        
                        ws.send("PRIVATE|" + currentUser + "|" + r + "|" + m);
        
                        addMsg(currentUser, m);
        
                        document.getElementById("m").value = "";
                    }
        
                // ? AUTO REFRESH CONTACTS
                    setInterval(loadContacts, 3000);
        
                // INIT
                    window.onload = loadContacts;
        
                </script>-->

    </body>
</html>
