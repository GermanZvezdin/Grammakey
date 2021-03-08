new Vue({
    el: '#app',

    data: {
        ws: null, // Our websocket
        newMsg: '', // Holds new messages to be sent to the server
        chatContent: '', // A running list of chat messages displayed on the screen
        newS: 'user', // Who sent the message to the ws
    },

    created: function() {
        var self = this;
        this.ws = new WebSocket('ws://' + window.location.host + '/ws');
        this.ws.addEventListener('message', function(e) {
            var msg = JSON.parse(e.data);
            if (msg.sender == 'user') {
                self.chatContent += '<div class="chip">'
                        + msg.message
                    + '</div>' + '<br/>'; // Parse emojis

                var element = document.getElementById('chat-messages');
            }
            if (msg.sender == 'server') {
                self.chatContent += '<div class="chip" style="background-color: #f19e9e;">'
                        + msg.message
                    + '</div>' + '<br/>'; // Parse emojis

                var element = document.getElementById('chat-messages');
            }
            element.scrollTop = element.scrollHeight; // Auto scroll to the bottom
        });
    },

    methods: {
        send: function () {
            if (this.newMsg != '') {
                this.ws.send(
                    JSON.stringify({
                        sender: 'user'
                        message: $('<p>').html(this.newMsg).text() // Strip out html
                    }
                ));
                this.newMsg = ''; // Reset newMsg
            }
        },
    }
});