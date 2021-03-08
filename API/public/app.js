new Vue({
    el: '#app',

    data: {
        ws: null, // Our websocket
        newMsg: '', // Holds new messages to be sent to the server
        chatContent: '', // A running list of chat messages displayed on the screen
        sender: 'asd', // Email address used for grabbing an avatar
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
            else {
                self.chatContent += '<div class="chip" style="background-color: #F1F3FF; float: left;">'
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
                        sender: this.sender,
                        message: $('<p>').html(this.newMsg).text() // Strip out html
                    }
                ));
                this.newMsg = ''; // Reset newMsg
            }
        },
    }
});